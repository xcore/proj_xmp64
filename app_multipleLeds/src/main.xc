// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>
#include <xs1.h>

on stdcore[0]: out port led_0 = XS1_PORT_1E;
on stdcore[4]: out port led_4 = XS1_PORT_1E;
on stdcore[8]: out port led_8 = XS1_PORT_1E;
on stdcore[12]: out port led_12 = XS1_PORT_1E;
on stdcore[16]: out port led_16 = XS1_PORT_1E;
on stdcore[20]: out port led_20 = XS1_PORT_1E;
on stdcore[24]: out port led_24 = XS1_PORT_1E;
on stdcore[28]: out port led_28 = XS1_PORT_1E;
on stdcore[32]: out port led_32 = XS1_PORT_1E;
on stdcore[36]: out port led_36 = XS1_PORT_1E;
on stdcore[40]: out port led_40 = XS1_PORT_1E;
on stdcore[44]: out port led_44 = XS1_PORT_1E;
on stdcore[48]: out port led_48 = XS1_PORT_1E;
on stdcore[52]: out port led_52 = XS1_PORT_1E;
on stdcore[56]: out port led_56 = XS1_PORT_1E;
on stdcore[60]: out port led_60 = XS1_PORT_1E;

void lightUp(out port led, int number, chanend inC, chanend outC) {
  timer tmr;
  int t, ledStatus = 1;

  if (number == 0) {
    inC :> number;
  }
  while (1) {
    led <: ledStatus;
    tmr :> t;
    t += number;
    tmr when timerafter(t) :> void;
    outC <: number;
    inC :> number;
    ledStatus = !ledStatus;
  }
}

int main() {
  chan c[16];
  par {
    on stdcore[0] : lightUp(led_0, 50000000, c[0], c[1]);
    on stdcore[4] : lightUp(led_4, 0, c[1], c[2]);
    on stdcore[8] : lightUp(led_8, 0, c[2], c[3]);
    on stdcore[12] : lightUp(led_12, 0, c[3], c[4]);
    on stdcore[16] : lightUp(led_16, 0, c[4], c[5]);
    on stdcore[20] : lightUp(led_20, 0, c[5], c[6]);
    on stdcore[24] : lightUp(led_24, 0, c[6], c[7]);
    on stdcore[28] : lightUp(led_28, 0, c[7], c[8]);
    on stdcore[32] : lightUp(led_32, 0, c[8], c[9]);
    on stdcore[36] : lightUp(led_36, 0, c[9], c[10]);
    on stdcore[40] : lightUp(led_40, 0, c[10], c[11]);
    on stdcore[44] : lightUp(led_44, 0, c[11], c[12]);
    on stdcore[48] : lightUp(led_48, 0, c[12], c[13]);
    on stdcore[52] : lightUp(led_52, 0, c[13], c[14]);
    on stdcore[56] : lightUp(led_56, 0, c[14], c[15]);
    on stdcore[60] : lightUp(led_60, 0, c[15], c[0]);
  }
  return 0;
}

