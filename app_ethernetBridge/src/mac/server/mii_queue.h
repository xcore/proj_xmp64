// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef __mii_queue_h__
#define __mii_queue_h__

#include <xccompat.h>

#define MAX_NUM_QUEUES 10
#define MAX_ENTRIES 64

typedef struct mii_queue_t {
  int lock;
  int rdIndex;
  int wrIndex;
  int fifo[MAX_ENTRIES];
} mii_queue_t;


void init_queue(REFERENCE_PARAM(mii_queue_t, q), int n);
int get_queue_entry(REFERENCE_PARAM(mii_queue_t, q));
void add_queue_entry(REFERENCE_PARAM(mii_queue_t, q), int i);
void init_queues();
void set_transmit_count(int buf_num, int count);
int get_and_dec_transmit_count(int buf_num);
int get_queue_entry_no_lock(REFERENCE_PARAM(mii_queue_t,q));
#endif //__mii_queue_h__
