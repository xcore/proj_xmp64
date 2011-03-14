// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>
#include <xs1.h>

on stdcore[60]: out port led_60 = XS1_PORT_1E;

void lightUp(out port led) {
    led <: 0x1;
    while (1) { }
}

int main() {
  par {
    on stdcore[60] : lightUp(led_60);
  }
  return 0;
}
