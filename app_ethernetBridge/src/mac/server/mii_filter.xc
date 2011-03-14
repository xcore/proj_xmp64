// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "mii.h"
#include "mii_queue.h"
#include "ethernet_server_def.h"
#include <xccompat.h>
#include <print.h>

typedef enum 
{
  OPCODE_NULL,
  OPCODE_AND,
  OPCODE_OR 
}
  filter_opcode_t;

// Frame filter
typedef struct mac_filter_t {
   unsigned int  opcode;
   // Destination MAC address filter.
   unsigned int dmac_msk[2];
   unsigned int dmac_val[2];   
   // VLAN and EType filter.
   unsigned int vlan_msk[6];
   unsigned int vlan_val[6];   
  int val;
} mac_filter_t;

#define NUM_FILTERS 4





#define is_broadcast(x) (x & 0x1)
#define compare_mac(x,y) (x[0] == y[0] && ((short) x[1]) == ((short) y[1]))



#pragma unsafe arrays
void two_port_filter(mii_packet_t buf[],
                     const int mac[2],
                     mii_queue_t &free_queue,
                     mii_queue_t &internal_q,
                     mii_queue_t &q1,
                     mii_queue_t &q2,
                     streaming chanend c0,
                     streaming chanend c1)
{
  int result;
  int enable0=1, enable1=1;
  int j;
  j = get_queue_entry(free_queue);
  c0 <: j;
  j = get_queue_entry(free_queue);
  c1 <: j;
  while (1) 
    {
      int i=0;

      select 
        {
        case enable0 => c0 :> i:
          enable0 = 0;
          j = get_queue_entry(free_queue);
          c0 <: j;
          break;
        case enable1 => c1 :> i:
          enable1 = 0;
          j = get_queue_entry(free_queue);
          c1 <: j;
          break;
        (!enable0 || !enable1) => default:
          enable0 = 1;
          enable1 = 1;
          break;
      }     
      
      if (i) {
        if (is_broadcast(buf[i].data[0])) {
          set_transmit_count(i, 1);       
          add_queue_entry(internal_q,i);
          if (buf[i].src_port == 0)
            add_queue_entry(q2, i);
          else
            add_queue_entry(q1, i);        
        }
        else if (compare_mac(buf[i].data,mac)) {
          add_queue_entry(internal_q,i);       
        }
        else {
#ifdef PROMISCUOUS
          set_transmit_count(i, 1);       
          add_queue_entry(internal_q,i);          
#endif
          if (buf[i].src_port == 0)
            add_queue_entry(q2, i);
          else
            add_queue_entry(q1, i);
        }      
      }

    }
}



#pragma unsafe arrays
void one_port_filter(mii_packet_t buf[],
                     const int mac[2],
                     mii_queue_t &free_queue,
                     mii_queue_t &internal_q,
                     streaming chanend c)
{
  int result;
  int enable0=1, enable1=1;
  int j;
  j = get_queue_entry(free_queue);
  c <: j;

  while (1) 
    {
      int i=0;

      c :> i;
      j = get_queue_entry(free_queue);
      c <: j;
      
      if (i) {
#ifdef PROMISCUOUS
          add_queue_entry(internal_q,i);          
#else
        if (is_broadcast(buf[i].data[0])          
            ||
            compare_mac(buf[i].data,mac)) 
          {          
            add_queue_entry(internal_q,i);                               
          }
        else
          add_queue_entry(free_queue,i);
#endif
      }     
    }
}



