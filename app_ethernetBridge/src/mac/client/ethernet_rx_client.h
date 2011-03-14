// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * Ethernet MAC Layer Implementation
 * IEEE 802.3 MAC Client Interface (Receive)
 *
 *
 *************************************************************************
 *
 * This implement Ethernet frame receiving client interface.
 *
 *************************************************************************/
 
#ifndef _ETHERNET_RX_CLIENT_H_
#define _ETHERNET_RX_CLIENT_H_ 1
#include <xccompat.h>
#include "sw_comps_common.h"

/** This get a *complete* ethernet frame from PHY (i.e. src/dest MAC address,
 *  type & payload),
 *  excluding Pre-amble, SoF & CRC32.
 *
 *  NOTE:
 *  1. It is blocking call, (i.e. it will wait until a complete packet is 
 *     received).
 *  2. Time is populated with 32bis internal timestamp @ received.
 *  3. Only the packets whih pass CRC32 are processed.
 *  4. Returns the number of bytes in the frame.
 *  5. The src_port return parameter returns the number of the port 
 *     the packet arrived on (if using multiple ports)
 */
int mac_rx(chanend c_mac, 
           unsigned char buffer[], 
           REFERENCE_PARAM(unsigned int, src_port));
int mac_rx_timed(chanend c_mac, 
                 unsigned char buffer[], 
                 REFERENCE_PARAM(unsigned int, time),
                 REFERENCE_PARAM(unsigned int, src_port));



/*****************************************************************************
 *
 * MAC address filtering.
 *
 *****************************************************************************/

// Filter operation identifier.
#define OPCODE_NULL 0x0          // disabled.
#define OPCODE_AND  0x80000080   // Logical AND between DMAC & VLANET filter
#define OPCODE_OR   0x80000081   // Logical OR between DMAC & VLANET filter

#define FILTER_OPCODE_NULL OPCODE_NULL
#define FILTER_OPCODE_AND  OPCODE_AND
#define FILTER_OPCODE_OR   OPCODE_OR

// specify number of frame filters per interface.
#define MAX_MAC_FILTERS   4

// Frame filter
struct mac_filter_t {
   unsigned int  opcode;
   // Destination MAC address filter.
   unsigned char dmac_msk[6];
   unsigned char dmac_val[6];   
   // VLAN and EType filter.
   unsigned char vlan_msk[6];
   unsigned char vlan_val[6];   
};

#define filterOpcode opcode
#define DMAC_filterMask dmac_msk
#define DMAC_filterCompare dmac_val
#define VLANET_filterMask vlan_msk
#define VLANET_filterCompare vlan_val

/** Setup a given filter index for *this* interface. There are
 *  MAX_MAC_FILTERS per client.
 *
 *  \para  c_mac           : channelEnd to ethernet server.
 *  \para  index           : Must be between 0..MAX_MAC_FILTERS-1,
 *                           select which filter.
 *  \para  filter          : reference to filter data structre.
 *  \return -1 on failure and filterIndex on success.
 */
#ifdef __XC__
int mac_set_filter(chanend c_mac, int index, struct mac_filter_t &filter);
#else
int mac_set_filter(chanend c_mac, int index, struct mac_filter_t *filter);
#endif


#define ethernet_rx_frame_filter_set mac_set_filter
/** Setup whether a link should drop packets or block if the link is not ready
 *
 *  \para max_srv          : chanend of receive server.
 *  \para x                : boolean value as to whether packets should 
 *                           be dropped at mac layer.
 * 
 *  NOTE: setting no dropped packets does not mean no packets will be 
 *  dropped. If packets are not dropped at the mac layer, it will block the
 *  mii fifo. The Mii fifo could possibly overflow and frames for other 
 *  links could be dropped.
 */
void mac_set_drop_packets(chanend mac_svr, int x);

#define ethernet_rx_set_drop_packets mac_set_drop_packets

#endif
