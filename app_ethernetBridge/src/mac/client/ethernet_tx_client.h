// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * Ethernet MAC Layer Implementation
 * IEEE 802.3 MAC Client Interface (Send)
 *
 *
 *
 * This implement Ethernet frame sending client interface.
 *
 *************************************************************************/

#ifndef _ETHERNET_TX_CLIENT_H_
#define _ETHERNET_TX_CLIENT_H_ 1
#include <xccompat.h>
#include "sw_comps_common.h"
#define ETH_BROADCAST (-1)

/** This send a ethernet frame, frame includes Dest/Src MAC address(s), 
 *  type and payload.
 *  c_mac       : channelEnd to tx server.
 *  buffer[]    : Byte buffer of ethernet frame. MUST BE WORD ALIGNED.
 *  nbytes      : number of bytes in buffer.
 * 
 *  NOTE: This function will be blocked until the packet is sent to PHY.
 *
 */
int mac_tx(chanend c_mac, unsigned int buffer[], int nbytes, int ifnum);

#define ethernet_send_frame mac_tx
#define ethernet_send_frame_getTime mac_tx_timed

/** This send a ethernet frame, frame includes Dest/Src MAC address(s), type
 *  and payload.
 *  It's blocking call and return the *actual time* the frame is sent to PHY.
 *  *actual time* : 32bits XCore internal timer.
 *  c_mac         : channelEnd to tx server.
 *  buffer[]      : Byte buffer of ethernet frame. MUST BE WORD ALIGNED.
 *  nbytes	  : number of bytes in buffer.
 *  ifnum         : The number of the eth interface to transmit to 
 *                   (using ETH_BROADCAST transmits to all ports)
 *
 *  NOTE: This function will be blocked until the packet is sent to PHY.
 */
#ifdef __XC__ 
int mac_tx_timed(chanend c_mac, unsigned int buffer[], int nbytes, unsigned int &time, int ifnum);
#else
int mac_tx_timed(chanend c_mac, unsigned int buffer[], int nbytes, unsigned int *time, int ifnum);
#endif

/** This get MAC address of *this*, normally its XMOS assigned id, appended with
 *  24bits per chip, id stores in OTP.
 *
 *  \para   macaddr[] array of char, where MAC address is placed, network order.
 *  \return zero on success and non-zero on failure.
 */

int mac_get_macaddr(chanend c_mac, unsigned char macaddr[]);

#define ethernet_get_my_mac_adrs mac_get_macaddr


/** This function sets the transmit 
 *  bandwidth restriction on a link to the mac server.
 *
 *  \para   bandwitdth - The allowed bandwidth of the link in Mbps
 *
 */
int mac_set_bandwidth(chanend ethernet_tx_svr, unsigned int bandwidth);

#define ethernet_set_bandwidth mac_set_bandwidth

#endif
