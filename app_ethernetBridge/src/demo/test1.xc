// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <print.h>
#include <platform.h>
#include "libtrap.h"
#include "ethernet_server.h"
#include "ethernet_tx_client.h"
#include "ethernet_rx_client.h"
#include "frame_channel.h"
#include "getmac.h"



//***** Ethernet Configuration ****

on stdcore[4]: clock clk_mii_ref = XS1_CLKBLK_REF;

on stdcore[4]: mii_interface_t mii =
  {
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,

    PORT_ETH_RXCLK_1,
    PORT_ETH_RXER_1,
    PORT_ETH_RXD_1,
    PORT_ETH_RXDV_1,

    PORT_ETH_TXCLK_1,
    PORT_ETH_TXEN_1,
    PORT_ETH_TXD_1,
  };


#ifdef PORT_ETH_RST_N
on stdcore[4]: out port p_mii_resetn = PORT_ETH_RST_N_1;
on stdcore[4]: smi_interface_t smi = { PORT_ETH_MDIO_1, PORT_ETH_MDC_1, 0 };
#else
on stdcore[4]: smi_interface_t smi = { PORT_ETH_RST_N_MDIO_1, PORT_ETH_MDC_1, 1 };
#endif

on stdcore[4]: clock clk_smi = XS1_CLKBLK_5;



//***** Ethernet Configuration ****

on stdcore[12]: clock clk_mii_ref2 = XS1_CLKBLK_REF;

on stdcore[12]: mii_interface_t mii2 =
  {
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,

    PORT_ETH_RXCLK_3,
    PORT_ETH_RXER_3,
    PORT_ETH_RXD_3,
    PORT_ETH_RXDV_3,

    PORT_ETH_TXCLK_3,
    PORT_ETH_TXEN_3,
    PORT_ETH_TXD_3,
  };


#ifdef PORT_ETH_RST_N_2
on stdcore[12]: out port p_mii_resetn = PORT_ETH_RST_N_3;
on stdcore[12]: smi_interface_t smi2 = { PORT_ETH_MDIO_3, PORT_ETH_MDC_3, 0 };
#else
on stdcore[12]: smi_interface_t smi2 = { PORT_ETH_RST_N_MDIO_3, PORT_ETH_MDC_3, 1 };
#endif

on stdcore[12]: clock clk_smi2 = XS1_CLKBLK_5;



void set_filter_broadcast(chanend rx);

void receiver(chanend rx, chanend loopback);
void transmitter(chanend tx, chanend loopback);

void test(chanend tx, chanend rx, chanend loopin, chanend loopout)
{
  unsigned time;

  printstr("Connecting...\n");
  { timer tmr; tmr :> time; tmr when timerafter(time + 600000000) :> time; }
  printstr("Ethernet initialised\n");
  
//  set_filter_broadcast(rx);
//  printstr("Filter configured\n");
  
  printstr("Test started\n");
  
  par
    {
      transmitter(tx, loopin);
      receiver(rx, loopout);
    }
}

void receiver(chanend rx, chanend loopback)
{
  int counter = 0;
  unsigned char rxbuffer[1600];
    
  while (1)
    {
      unsigned int src_port;
      int nbytes = mac_rx(rx, rxbuffer, src_port);
//      printstr("\nR ");
//      printhex(rxbuffer[3] | rxbuffer[2]<<8 | rxbuffer[1]<<16 | rxbuffer[0]<<24);
      pass_frame(loopback, rxbuffer, nbytes);
    }  
  set_thread_fast_mode_off();
}

void transmitter(chanend tx, chanend loopback)
{
  unsigned  int txbuffer[1600/4];
  int counter = 0;
 
 
  while (1)
    {
      int nbytes;
      fetch_frame((txbuffer, unsigned char[]), loopback, nbytes);
//      printstr("\nT ");
//      printhex(txbuffer[0]);
//      (txbuffer, unsigned char[])[12] = 0xF0;
//      (txbuffer, unsigned char[])[13] = 0xF0;
      mac_tx(tx, txbuffer, nbytes, 0);
    }
}

void set_filter_broadcast(chanend rx)
{
  struct mac_filter_t f;
  f.opcode = OPCODE_OR;
  for (int i = 0; i < 6; i++)
  {
    f.dmac_msk[i] = 0x00;
    f.vlan_msk[i] = 0;
  }
  f.dmac_msk[0] = 0x80;
  for (int i = 0; i < 6; i++)
  {
    f.dmac_val[i] = 0x00;
  }
  if (mac_set_filter(rx, 1, f) == -1)
  {
    printstr("Filter configuration failed\n");
    user_trap();
  }
}



int main() 
{
  chan rx[1], tx[1];
  chan rx2[1], tx2[1];
  chan maccie;
  chan loop, loop2;

  par
    {
      on stdcore[4]:
      {
        int mac_address[2];
        ethernet_getmac_otp((mac_address, char[]));
        maccie <: mac_address[0];
        maccie <: mac_address[1];
        phy_init(clk_smi, clk_mii_ref, 
#ifdef PORT_ETH_RST_N               
               p_mii_resetn,
#else
               null,
#endif
                 smi,
                 mii);
        ethernet_server(mii, clk_mii_ref, mac_address, 
                        rx, 1,
                        tx, 1,
                        null,
                        null);
      }
      on stdcore[12]:
      {
        int mac_address[2];
        maccie :> mac_address[0];
        maccie :> mac_address[1];
        mac_address[1]++;
        printhexln(mac_address[0]);
        printhexln(mac_address[1]);
        phy_init(clk_smi2, clk_mii_ref2, 
#ifdef PORT_ETH_RST_N               
               p_mii_resetn,
#else
               null,
#endif
                 smi2,
                 mii2);
        ethernet_server(mii2, clk_mii_ref2, mac_address, 
                        rx2, 1,
                        tx2, 1,
                        null,
                        null);
      }
      on stdcore[29] : test(tx[0],  rx[0],  loop, loop2);
      on stdcore[33] : test(tx2[0], rx2[0], loop2, loop);
    }
  
  return 0;
}
