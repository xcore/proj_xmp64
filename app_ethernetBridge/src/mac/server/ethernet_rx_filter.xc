// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**************************************************************************
 *
 * Ethernet MAC Layer Implementation
 * IEEE 802.3 LLC Frame Filter
 *
 *
 *
 * Implements Ethernet frame filtering.
 *
 * An Ethernet frame can be filtered either base on *destination* MAC
 * address (6 bytes) or/and VLAN tag and EType field (6 bytes) in the
 * frame. Each filter in turn has individual bit mask and compare, to
 * allow only interested portion of each filter is compared. It is also
 * useful to filter on a range of MAC address.
 *
 * Each *interface* in turn has up to NUM_FRAM_FILTERS_PER_CLIENT
 * filters, ethernet frames which matches any of the filter will be
 * passed on the specified client/interface.
 *
 * A frame may be routed to more than one client/interface base on
 * individual filters.
 *
 *************************************************************************/

#include "ethernet_rx_filter.h" 
#ifdef XLOG
#include "sprintf.h"
#endif
#include <string.h>


static  int ether_filter(FrameFilterFormat_t pFilter,  unsigned char pBuf[]);


/** This clear all entries inside ethernet frame filter (i.e. filter is NOT active).
 *
 *  \para   pFilter pointer to ethernet frame filter data structure.
 *  \return none.
 */
void ethernet_frame_filter_clear(FrameFilterFormat_t &pFilter)
{  
   pFilter.filterOpcode = FILTER_OPCODE_NULL;
   for (int i=0;i<6;i++) {
     pFilter.dmac_msk[i] = 0;
     pFilter.vlan_msk[i] = 0;
     pFilter.dmac_val[i] = 0;
     pFilter.vlan_val[i] = 0;
   }
}


/** Initialise array of client frame filters.
 */
void ethernet_frame_filter_init(ClientFrameFilter_t &Filter)
{
  for (int i=0;i < MAX_MAC_FILTERS;i++) {
    ethernet_frame_filter_clear(Filter.filters[i]);
  }  
}

/** This perform filtering on a given packet  with given filter set (*pFilter).
 * 
 *  \para    *pFilter pointer to filter to use.
 *  \para    baseAdrs Absolute base address of packet buffer area.
 *  \para    startByteOffset byte offset from buffer for start of packet.
 *  \return  -1 on NO match and 0..n for match.
 */
int  ethernet_frame_filter(ClientFrameFilter_t pFilter, unsigned int mii_rx_buf[])
{
   int i;
   int result = -1;
   // for every filter bank
   for (i = 0; i < MAX_MAC_FILTERS; i++)
   {
      // only filter on the enabled filter.
      if (pFilter.filters[i].opcode != OPCODE_NULL)
      {
         // do filter on each mask/compare
        result = ether_filter( pFilter.filters[i], (mii_rx_buf,char[]));
         // check if we foud a match.
         if (result != -1)
         {
            break;
         }
      }
   }
   
   return (result);
}

/** This perform mask/compare filter on Destination MAC address field and VLAN Tag & EtherType field.
 *
 *  \para   *pFilter filter to use.
 *  \para   *pBuf    start of buffer.
 */
static  int ether_filter(FrameFilterFormat_t pFilter, unsigned char pBuf[])
{
   int i;
   unsigned char FilterEnable, DMACResult, VLANETResult, FinalResult;
   //char Message[500];
   
#if 0
   xlog_debug("\n");
   xlog_debug("Filter Details: \n");
   sprintf(Message, "  DMAC Filter Mask    : 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n", 
               pFilter.dmac_msk[0],
               pFilter.dmac_msk[1],
               pFilter.dmac_msk[2],
               pFilter.dmac_msk[3],
               pFilter.dmac_msk[4],
               pFilter.dmac_msk[5] );               
   xlog_debug(Message);
   sprintf(Message, "  DMAC Filter Compare : 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n", 
               pFilter.dmac_val[0],
               pFilter.dmac_val[1],
               pFilter.dmac_val[2],
               pFilter.dmac_val[3],
               pFilter.dmac_val[4],
               pFilter.dmac_val[5] );               
   xlog_debug(Message);
   sprintf(Message, "  DMAC Data value     : 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n", 
               pBuf[0],
               pBuf[1],
               pBuf[2],
               pBuf[3],
               pBuf[4],
               pBuf[5] );               
   xlog_debug(Message);
   xlog_debug("\n");
   sprintf(Message, "  VLANT Fitler Mask   : 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n", 
               pFilter.vlan_msk[0],
               pFilter.vlan_msk[1],
               pFilter.vlan_msk[2],
               pFilter.vlan_msk[3],
               pFilter.vlan_msk[4],
               pFilter.vlan_msk[5] );               
   xlog_debug(Message);
   sprintf(Message, "  VLANT Fitler Compare: 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n", 
               pFilter.vlan_val[0],
               pFilter.vlan_val[1],
               pFilter.vlan_val[2],
               pFilter.vlan_val[3],
               pFilter.vlan_val[4],
               pFilter.vlan_val[5] );               
   xlog_debug(Message);
   sprintf(Message, "  VLANT Data value    : 0x%x 0x%x 0x%x 0x%x 0x%x 0x%x\n", 
               pBuf[12],
               pBuf[13],
               pBuf[14],
               pBuf[15],
               pBuf[16],
               pBuf[17] );                              
   xlog_debug(Message);
   xlog_debug("\n");   
#endif
   
   // Destination MAC address filter.
   DMACResult = 0;
   FilterEnable = 0;
   for (i = 0; i < NUM_BYTES_IN_FRAME_FILTER; i++)
   {
      // if the result is ZERO its a match, otherwise its NOT
      FilterEnable |= pFilter.dmac_msk[i];
      DMACResult |= (pFilter.dmac_msk[i] & (unsigned char) pBuf[i]) ^ (pFilter.dmac_msk[i] & pFilter.dmac_val[i]);      
      
      /*
      sprintf(Message, "DMACResult %d : Mask 0x%x Comp 0x%x Data 0x%x Result 0x%x\n", i,
                         pFilter.dmac_msk[i], pFilter.dmac_val[i], (unsigned char) pBuf[i], DMACResult);
      xlog_debug(Message);
      */
   }
   // if fitler is NOT enabled mark as no match.
   if (FilterEnable == 0)
   {
      DMACResult = 1;
   }
   
   //  VLAN Tag and EtherType filter
   VLANETResult = 0;
   FilterEnable = 0;
   for (i = 0; i < NUM_BYTES_IN_FRAME_FILTER; i++)
   {
      FilterEnable |= pFilter.vlan_msk[i];
      // if the result is ZERO its a match, otherwise its NOT      
      VLANETResult |= (pFilter.vlan_msk[i] & pBuf[i + 12]) ^ (pFilter.vlan_msk[i] & pFilter.vlan_val[i]); 
      
      /*
      sprintf(Message, "VLANETResult %d : Mask 0x%x Comp 0x%x Data 0x%x Result 0x%x\n", i,
                         pFilter.vlan_msk[i], pFilter.vlan_val[i], pBuf[i+12], VLANETResult);
      xlog_debug(Message);            
      */      
   }
   // if fitler is NOT enabled mark as no match.
   if (FilterEnable == 0)
   {
      VLANETResult = 1;
   }
   
   /*
   sprintf(Message,"  DMAC fitler result %d VLAN Tag filter result %d\n", DMACResult, VLANETResult);
   xlog_debug(Message);
   */
   FinalResult = 1;
   // perform next level opcode.
   switch (pFilter.opcode)
   {
      case OPCODE_AND:
         //xlog_debug("  Filter OPCODE AND\n");
         if ((DMACResult == 0) && (VLANETResult == 0))
         {
            FinalResult = 0;
         }
         break;
      case OPCODE_OR:
         //xlog_debug("  Filter OPCODE OR\n");               
         if ((DMACResult == 0) || (VLANETResult == 0))
         {
            FinalResult = 0;
         }
         break;
      default:
         xlog_debug("  Filter OPCODE UNKNOWN\n");      
         break;
   }
  
   /*
   if (FinalResult == 0) {
      xlog_debug("  Filter PASS.\n");
   } else {
      xlog_debug("  Filter FAIL.\n");
   }
   */
   
   return 1;

   if (FinalResult == 0) 
     return 1;
   else
     return -1;
}
