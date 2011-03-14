// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>
#include <xs1.h>
#include <print.h>

#if 0

void pipelineStep(chanend inC, chanend outC, int number) {
  if (number == 0) {
    inC :> number;
  }
  while (1) {
    number = number + 1;
    outC <: number;
    inC :> number;
  }
}

int main() {
  chan c[512];
  par (int i = 0; i < 512; i++) {
    on stdcore[i/8] : pipelineStep(c[i], c[(i+1)&511], i);
  }
  return 0;
}

#endif

void mmaster(chanend c0, chanend c1, chanend c2, chanend c3) {
    outuint(c0, 1);
    inuint(c0);
    outuint(c1, 1);
    inuint(c1);
    outuint(c2, 1);
    inuint(c2);
    outuint(c3, 1);
    inuint(c3);
    outct(c0, 1);
    chkct(c0, 1);
    outct(c1, 1);
    chkct(c1,1 );
    outct(c2, 1);
    chkct(c2, 1);
    outct(c3, 1);
    chkct(c3, 1);
}

void mslave(chanend c0, chanend c1, chanend c2, chanend c3) {
    inuint(c0);
    outuint(c0, 1);
    inuint(c1);
    outuint(c1, 1);
    inuint(c2);
    outuint(c2, 1);
    inuint(c3);
    outuint(c3, 1);
    chkct(c0, 1);
    outct(c0, 1);
    chkct(c1,1 );
    outct(c1, 1);
    chkct(c2, 1);
    outct(c2, 1);
    chkct(c3, 1);
    outct(c3, 1);
}

void light(int isOn, int time) {
    timer t;
    unsigned theTime;
    asm("ldc r11, 0x106");
    asm("shl r11, r11, 8");
    asm("setc res[r11], 8");
    asm("out res[r11], r0");
    t :> theTime;
    t when timerafter(theTime + time * 100000) :> void;
}

void check(int node, chanend c0, chanend c1, chanend c2, chanend c3, chanend c4, chanend c5, chanend c6, chanend c7, chanend c8, chanend c9, chanend c10, chanend c11, chanend c12, chanend c13, chanend c14, chanend c15) {
    light(1, 500);
    if (node & 1) {
        mmaster(c0, c1, c2, c3);
    } else {
        mslave(c0, c1, c2, c3);
    }
    light(0, 500);
    if (node & 2) {
        mmaster(c4, c5, c6, c7);
    } else {
        mslave(c4, c5, c6, c7);
    }
    light(1, 500);
    if (node & 4) {
        mmaster(c8, c9, c10, c11);
    } else {
        mslave(c8, c9, c10, c11);
    }
    light(0, 500);
    if (node & 8) {
        mmaster(c12, c13, c14, c15);
    } else {
        mslave(c12, c13, c14, c15);
    }
    while (1) {
        light(1, (node +  1) * 100);
        light(0, (16 - node) * 100);
    }
}

int main() {
    chan c[4 * 4 * 16];
    par (int i = 0; i < 16; i++) {
        on stdcore[i*4] : check(i, c[(i&14)*16], c[(i&14)*16+1], c[(i&14)*16+2], c[(i&14)*16+3],
                                 c[(i&13)*16+4], c[(i&13)*16+5], c[(i&13)*16+6], c[(i&13)*16+7],
                                 c[(i&11)*16+8], c[(i&11)*16+9], c[(i&11)*16+10], c[(i&11)*16+11],
                               c[(i&7)*16+12], c[(i&7)*16+13], c[(i&7)*16+14], c[(i&7)*16+15]);
    }
    return 0;
}
