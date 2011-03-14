// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
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

#ifndef _ETHERNET_RX_FILTER_H_
#define _ETHERNET_RX_FILTER_H_ 1

// generic definations.
#include "ethernet_server_def.h"

// include FrameFilterFormat_t definition
#include "ethernet_rx_client.h"


#define NUM_BYTES_IN_FRAME_FILTER 6

typedef struct mac_filter_t FrameFilterFormat_t;

// Combine frame filters.
typedef struct clientFilter {
   FrameFilterFormat_t  filters[MAX_MAC_FILTERS];
} ClientFrameFilter_t;


/** This clear all entries inside ethernet frame filter (i.e. filter is NOT active).
 *
 *  \para   pFilter pointer to ethernet frame filter data structure.
 *  \return none.
 */

#ifdef __XC__
void ethernet_frame_filter_clear(FrameFilterFormat_t &pFilter);
#else
void ethernet_frame_filter_clear(FrameFilterFormat_t *pFilter);
#endif


/** Initialise array of client frame filters.
 */
#ifdef __XC__
void ethernet_frame_filter_init(ClientFrameFilter_t &Filter);
#else
void ethernet_frame_filter_init(ClientFrameFilter_t *Filter);
#endif


/** This performs a per client filtering on a given packet with given filter set (*pFilter).
 * 
 *  \para    *pFilter pointer to client filter to use.
 *  \para    baseAdrs Absolute base address of packet buffer area.
 *  \para    startByteOffset byte offset from buffer for start of packet.
 *  \return  -1 on NO match and others for match.
 */
#ifdef __XC__
int ethernet_frame_filter(ClientFrameFilter_t pFilter, unsigned int mii_rx_buf[]);
#else 
int ethernet_frame_filter(ClientFrameFilter_t pFilter, unsigned int mii_rx_buf[]);
#endif


#endif

