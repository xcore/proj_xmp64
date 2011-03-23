// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <print.h>
#include <platform.h>
#include "ethernet_server.h"
#include "ethernet_rx_client.h"
#include "ethernet_tx_client.h"

on stdcore[4]: mii_interface_t mii = {
    XS1_CLKBLK_1, XS1_CLKBLK_2,
    PORT_ETH_RXCLK_1, PORT_ETH_RXER_1, PORT_ETH_RXD_1, PORT_ETH_RXDV_1,
    PORT_ETH_TXCLK_1, PORT_ETH_TXEN_1, PORT_ETH_TXD_1,
};
on stdcore[4]: smi_interface_t smi = { PORT_ETH_RST_N_MDIO_1, PORT_ETH_MDC_1, 1 };
on stdcore[4]: clock clk_smi = XS1_CLKBLK_5;

on stdcore[12]: mii_interface_t mii_12 = {
    XS1_CLKBLK_1, XS1_CLKBLK_2,
    PORT_ETH_RXCLK_3, PORT_ETH_RXER_3, PORT_ETH_RXD_3, PORT_ETH_RXDV_3,
    PORT_ETH_TXCLK_3, PORT_ETH_TXEN_3, PORT_ETH_TXD_3,
};
on stdcore[12]: smi_interface_t smi_12 = { PORT_ETH_RST_N_MDIO_3, PORT_ETH_MDC_3, 1 };
on stdcore[12]: clock clk_smi_12 = XS1_CLKBLK_5;

extern void ethernet_register_traphandler();

int mac_custom_filter(unsigned int data[]){
    return 1;
}

void demo(chanend tx, chanend rx) {
    unsigned int xbuf[400];
  
    mac_set_custom_filter(rx, 0x1);
    printstr("Test started\n");

    while (1) {
        unsigned int src_port;
        unsigned int nbytes;
        mac_rx(rx, (xbuf, unsigned char[]), nbytes, src_port);
        mac_tx(tx, xbuf, nbytes, ETH_BROADCAST);
    }
}

int main() {
    chan rx[1], tx[1];
    chan rx2[1], tx2[1];

#error "Make sure you have patched sc_ethernet as per issue 3"

    par {
        on stdcore[4]: {
            int dummy[2];
            phy_init(clk_smi, null, smi, mii);
            ethernet_server(mii, dummy,  rx, 1,  tx, 1, null, null);
        }
        on stdcore[12]: {
            int dummy[2];
            phy_init(clk_smi_12, null, smi_12, mii_12);
            ethernet_server(mii_12, dummy,  rx2, 1,  tx2, 1, null, null);
        }
        on stdcore[0]: demo(tx2[0], rx[0]);
        on stdcore[0]: demo(tx[0], rx2[0]);
    }
	return 0;
}
