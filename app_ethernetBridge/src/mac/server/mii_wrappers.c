// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xccompat.h>
#define streaming 
#include "mii.h"
#include "mii_queue.h"
#include "mii_filter.h"
#include <print.h>


mii_queue_t free_queue, filter_queue, internal_queue, ts_queue;
mii_queue_t tx_queue[2];

mii_packet_t mii_packet_buf[NUM_MII_BUF+1]={1};

void init_mii_mem() {
  int i;  
  init_queues();
  init_queue(&free_queue, NUM_MII_BUF);
  init_queue(&filter_queue, 0);
  init_queue(&internal_queue, 0);
  init_queue(&ts_queue, 0);
  for(i=0;i<2;i++)
    init_queue(&tx_queue[i], 0);
  return;
}

void mii_rx_pins_wr(port p1,
                    port p2,
                    int i,
                    streaming chanend c)
{
  mii_rx_pins(&free_queue, mii_packet_buf, p1, p2, i, c);
}


void mii_tx_pins_wr(port p,
                    int i)
{
  mii_tx_pins(mii_packet_buf, &tx_queue[i], &free_queue, &ts_queue, p, i);
}


void two_port_filter_wr(const int mac[2], streaming chanend c, streaming chanend d)
{
  two_port_filter(mii_packet_buf,
                  mac, 
                  &free_queue, 
                  &internal_queue,
                  &tx_queue[0], 
                  &tx_queue[1],
                  c,
                  d);
}


void one_port_filter_wr(const int mac[2], streaming chanend c)
{
  one_port_filter(mii_packet_buf,
                  mac, 
                  &free_queue, 
                  &internal_queue,
                  c);
}

