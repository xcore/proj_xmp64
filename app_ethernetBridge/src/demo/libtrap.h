// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * Ethernet MAC Layer Implementation
 * XMOS Trap Handling Library
 *
 *   File        : libtrap.h
 *
 *************************************************************************
 *
 * Allows registering a generic function as a trap handler.
 * This function will get trap and context information passed in.
 *
 * Also allows triggering exceptions in the form of user traps.
 *
 *************************************************************************/

#ifndef _libtrap_h_
#define _libtrap_h_

/* Note: trap information is shared between trap handlers to keep foot print low
 * therefore multiple traps happenning at the same time will corrupt each other's
 * trap information */

#ifndef __asm__
struct trapinfo_t
{
  int id;
  unsigned et;
  unsigned ed;
  unsigned spc;
  unsigned ssr;
  unsigned r[12];
	unsigned sp;
  unsigned dp;
};
#endif

/* Trap handler function may use up to 62 words of stack space
 * Total reserved stack space is (62 + 2) * 4 * 8 = 2 KB
 * Can be overriden from makefile if necessary */
#ifndef TRAPHANDLER_STACK_NUM_WORDS
#define TRAPHANDLER_STACK_NUM_WORDS 62
#endif

#ifndef __asm__
#ifdef __STDC__
void register_traphandler(void (*traphandler)(const struct trapinfo_t *info));
#else
// No XC version
#endif
#endif

#ifndef __asm__
void unregister_traphandler();
#endif

#ifndef __asm__
void user_trap();
#endif

#endif /* _libtrap_h_ */
