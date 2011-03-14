// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <swlock.h>
#include <mii_queue.h>
#include <mii.h>

swlock_t queue_locks[MAX_NUM_QUEUES];

swlock_t tc_lock;

static int tcounts[NUM_MII_BUF] = {0};

int get_and_dec_transmit_count(int buf_num) 
{
  hwlock_t hwlock = global_hwlock;  
  int count;
  spin_lock_acquire(&tc_lock, hwlock);
  count = tcounts[buf_num];
  if (count) 
    tcounts[buf_num] = count - 1;
  spin_lock_release(&tc_lock, hwlock);
  return count;
}

void set_transmit_count(int buf_num, int count) 
{
  hwlock_t hwlock = global_hwlock;  
  spin_lock_acquire(&tc_lock, hwlock);
  tcounts[buf_num] = count;
  spin_lock_release(&tc_lock, hwlock);
}


void init_queues()
{
  init_swlocks();
  spin_lock_init(&tc_lock);
}

void init_queue(mii_queue_t *q, int n)
{
  int i;
  static int next_qlock = 1;
  q->lock = (int) &queue_locks[next_qlock];
  next_qlock++;

  for (i=0;i<n;i++)
    q->fifo[i] = i+1;

  q->rdIndex = 0;
  q->wrIndex = n;

  spin_lock_init((swlock_t *) q->lock);
  return;
}

int get_queue_entry(mii_queue_t *q) 
{
  int i=0,next;
  hwlock_t hwlock = global_hwlock;
  int rdIndex, wrIndex;
  spin_lock_acquire((swlock_t *) q->lock, hwlock);
  
  rdIndex = q->rdIndex;
  wrIndex = q->wrIndex;

  if (rdIndex == wrIndex)
    i = 0;
  else {
    i = q->fifo[rdIndex];
    rdIndex++;
    rdIndex &= (MAX_ENTRIES-1);
    q->rdIndex = rdIndex;
  }
  spin_lock_release((swlock_t *) q->lock, hwlock);
  return i;
}

int get_queue_entry_no_lock(mii_queue_t *q) 
{
  int i=0,next;
  int rdIndex, wrIndex;
  
  rdIndex = q->rdIndex;
  wrIndex = q->wrIndex;

  if (rdIndex == wrIndex)
    i = 0;
  else {
    i = q->fifo[rdIndex];
    rdIndex++;
    rdIndex &= (MAX_ENTRIES-1);
    q->rdIndex = rdIndex;
  }
  return i;
}

void add_queue_entry(mii_queue_t *q, int i) 
{
  hwlock_t hwlock = global_hwlock;
  int wrIndex;
  spin_lock_acquire((swlock_t *) q->lock, hwlock); 
  wrIndex = q->wrIndex;
  q->fifo[wrIndex] = i;
  wrIndex++;
  wrIndex &= (MAX_ENTRIES-1);
  q->wrIndex = wrIndex;
  spin_lock_release((swlock_t *) q->lock, hwlock);
  return;
}

void add_queue_entry_no_lock(mii_queue_t *q, int i) 
{
  int wrIndex;
  wrIndex = q->wrIndex;
  q->fifo[wrIndex] = i;
  wrIndex++;
  wrIndex &= (MAX_ENTRIES-1);
  q->wrIndex = wrIndex;
  return;
}


