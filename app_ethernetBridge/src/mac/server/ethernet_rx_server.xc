// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * Ethernet MAC Layer Implementation
 * IEEE 802.3 Link Layer (Receive)
 *
 *
 *
 * Implements the management server for Ethernet Rx Frames.
 * 
 * This manages the pointers to buffer and communication over channel(s)
 * to PHY & Link layers.
 *
 *************************************************************************/

#include <xs1.h>
#include "mii.h"
#include "mii_queue.h"
#include "ethernet_rx_server.h"
#include "ethernet_rx_filter.h"
#include <print.h>


// data structure to keep track of link layer status.
typedef struct
{
   unsigned pending_linkCmd;
   unsigned dropped_pkt_cnt;
   unsigned drop_packets;
} LinkLayerStatus_t;


/** This service incomming commands from link layer interfaces.
 */
transaction serviceLinkCmd(chanend link, int linkIndex, ClientFrameFilter_t link_filters[], LinkLayerStatus_t link_status[])
{
   int i, filterIndex, error;
   unsigned int cmd;

   link :> cmd;
   
   switch (cmd)
   {
      // request for data just mark it.x
      case ETHERNET_RX_FRAME_REQ:
      case ETHERNET_RX_TYPE_PAYLOAD_REQ:
         // Simply mark the request pending.
        link_status[linkIndex].pending_linkCmd = cmd;
         break;
      // filter set.
      case ETHERNET_RX_FILTER_SET:
         // get filter index.
         link :> filterIndex;
         // sanity checking.
         error = 0;
         if (filterIndex >= MAX_MAC_FILTERS)
         {
            filterIndex = 0;
            error = 1;
         }         
         // update filter parameter from client.
         for (i = 0; i < sizeof(struct mac_filter_t); i += 1)
         {
           char c;
           link :> c;
           (link_filters[linkIndex].filters[filterIndex],unsigned char[])[i] = c;
         }
         // response.
         if (error) {
           link <: ETHERNET_REQ_NACK;
         } else {
           link <: ETHERNET_REQ_ACK;            
         }
         break;
      // overflow count return
      case ETHERNET_RX_OVERFLOW_CNT_REQ:
         link <: ETHERNET_REQ_ACK;
         link <: link_status[linkIndex].dropped_pkt_cnt;     
         break;
      case ETHERNET_RX_OVERFLOW_CLEAR_REQ:
         link <: ETHERNET_REQ_ACK;
         link_status[linkIndex].dropped_pkt_cnt = 0;
         break;
      case ETHERNET_RX_DROP_PACKETS_SET:
         link :> link_status[linkIndex].drop_packets;
         link <: ETHERNET_REQ_ACK;
         break;
      default:    // unreconised command.
         link <: ETHERNET_REQ_NACK;
         break;
   }
   
}

/** This sent out recived frame to a given link layer, also track dropped packets.
 *
 */ 
static void sendReceivedFrame(mii_packet_t &p, 
                              chanend link, 
                              int linkIndex, ClientFrameFilter_t link_filters[], LinkLayerStatus_t link_status[])
{
  int i, length;

  if (!link_status[linkIndex].drop_packets) {
    while (link_status[linkIndex].pending_linkCmd == 0) {
        slave serviceLinkCmd(link, linkIndex, link_filters, link_status);
    }
  }

  while (!p.complete);

  // base on pending link command.
  switch (link_status[linkIndex].pending_linkCmd)
    {
    case ETHERNET_RX_FRAME_REQ:         // full frame request.
    case ETHERNET_RX_TYPE_PAYLOAD_REQ:  // payload only request.
      // base on payload request need to adjust bytes to sent.
      if (link_status[linkIndex].pending_linkCmd == ETHERNET_RX_FRAME_REQ) {
        i=0;
      } else {
        // strip source/dest MAC address, 6 bytes each.
        i=3;
      }



      length = p.length;

      master {
        link <: p.src_port;
        link <: length-(i<<2);
        for (;i < (length+3)>>2;i++) {
          link <: p.data[i];
        }
        link <: p.timestamp;

      }

      link_status[linkIndex].pending_linkCmd = 0;  
      break;
    default:    // link layer is falling behind, just drop it.
      link_status[linkIndex].dropped_pkt_cnt += 1;
      switch (linkIndex)
        {
        case 0:
          xlog_debug("ERROR: MAC pkt dropped, link 0.\n");
          break;
        case 1:
          xlog_debug("ERROR: MAC pkt dropped, link 1.\n");
          break;
        case 2:
          xlog_debug("ERROR: MAC pkt dropped, link 2.\n");
          break;
        case 3:
          xlog_debug("ERROR: MAC pkt dropped, link 3.\n");
          break;
        default:
          xlog_debug("ERROR: MAC pkt dropped, link UNKNOWN.\n");            
          break;               
        }         
      break;     
    }
}


/** This apply ethernet frame filters on the recieved frame for each link.
 *  A received frame may be required to sent to more than one link layer.
 */
static void processReceivedFrame(mii_packet_t &p, chanend link[], int n, ClientFrameFilter_t link_filters[], LinkLayerStatus_t link_status[])
{
   sendReceivedFrame(p, link[0], 0, link_filters, link_status);
}


/** This implement Ethernet Rx server, with packet filtering.
 *  Each interface need to enable *filter* to receive. Each link interface
 *  can accept ethernet frames based on destination MAC address (6bytes) and/or
 *  VLAN Tag & EType (6bytes). Each bit in the 12bytes filter in turn have mask
 *  and compare bit.
 *
 *  It interface with ethernet_rx_buf_ctl to handle frames 
 * 
 */
void ethernet_rx_server(mii_queue_t &in_q,
                        mii_queue_t &free_queue,
                        mii_packet_t buf[],
                        chanend link[],
                        int num_link)
{
   int i;
   unsigned int notification;

// Local data structures.
// Receive frame filter structures.
   ClientFrameFilter_t link_filters[NUM_LINK_LAYER_IF];
// Pending link commands
   LinkLayerStatus_t link_status[NUM_LINK_LAYER_IF];

   xlog_debug("INFO: Ethernet Rx Server init..\n");
   //   ethernet_register_traphandler();

   // Initialise the link filters & local data structures.
   for (i = 0; i < num_link; i += 1)
   {
      link_status[i].pending_linkCmd = 0;
      link_status[i].dropped_pkt_cnt = 0;      
      link_status[i].drop_packets = 1;      
      ethernet_frame_filter_init(link_filters[i]);      
   }

   xlog_debug("INFO: Ethernet Rx Server started..\n");



   // Main control loop.
   while (1)
   {
     // Make this select ordered so we deal with any commands from the client
     // before processing a packet
#pragma ordered
     select
       {
       case (int i=0;i<num_link;i++) serviceLinkCmd(link[i],i, link_filters, link_status):
         break;
       default:
         {
           int k;
           k=get_queue_entry(in_q);
           if (k != 0) {
             
             processReceivedFrame(buf[k], link, num_link, link_filters, link_status);

             if (get_and_dec_transmit_count(k) == 0) {
               add_queue_entry(free_queue, k);
             }
           }   
           break;
         }
       }       
   }
   
}

