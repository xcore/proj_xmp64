// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * XMOS Trap Handling Library
 *
 *   Header File : libtrap.S
 *   Author      : Ladislav Snizek
 *   Description : Functions for registering a trap handler and triggering
 *                 an exception
 *
 *************************************************************************/

#include <xs1_user.h>
#include <xs1_kernel.h>
#include <xs1_registers.h>
#ifdef SIMULATION
#define OSCALL_EXIT 0
#define IEEBLE_BIT 3
#endif
#define __asm__
#include "libtrap.h"

.globl   register_traphandler.nstackwords
.globl   register_traphandler.maxthreads
.linkset register_traphandler.nstackwords,0
.linkset register_traphandler.maxthreads,1
.globl   register_traphandler
.text
.align 4
register_traphandler:
  get      r11, id
  mov      r3, r11
	ldap     r11, __traphandler_secondary
  stw      r0, r11[r3]
	ldap     r11, __traphandler_primary
  mov      r1, r11
  get      r11, kep
  mov      r0, r11
  eq       r11, r0, r1
  bt       r11, register_traphandler_function
  ldap     r11, __traphandler_primary_saved
  stw      r0, r11[r3]
register_traphandler_function:
  mov      r11, r1
  set      kep, r11
register_traphandler_stack:
	ldc      r2, TRAPHANDLER_STACK_NUM_WORDS
	add      r2, r2, 2
	mul      r1, r2, r3
  ldap     r11, __traphandler_stack
	ldaw     r11, r11[r1]
	ldaw     r11, r11[r2]
	ldaw     r11, r11[-2]
  ldaw     r0, sp[0]
  stw      r0, r11[0]
  set      sp, r11
  krestsp  0
register_traphandler_done:
  retsp    0

.globl   unregister_traphandler.nstackwords
.globl   unregister_traphandler.maxthreads
.linkset unregister_traphandler.nstackwords,0
.linkset unregister_traphandler.maxthreads,1
.globl   unregister_traphandler
.text
.align 4
unregister_traphandler:
  get      r11, id
  mov      r3, r11
	ldap     r11, __traphandler_primary_saved
  mov      r1, r11
  ldw      r11, r1[r3]
  set      kep, r11
  ldc      r11, 0
  stw      r11, r1[r3]
  // TODO Restore kernel stack too
  retsp    0

.globl   user_trap
.globl   user_trap.maxthreads
.linkset user_trap.nstackwords,0
.linkset user_trap.maxthreads,1
.globl   user_trap.nstackwords
user_trap:
.text
.align 4
  ldc      r11, 0
  ecallf   r11
  retsp    0

.align 4
__traphandler_primary_saved:
.skip (4 * 8)
__traphandler_secondary:
.skip (4 * 8)
__traphandler_trapinfo:
.skip 80
__traphandler_stack:
.skip (4 * (TRAPHANDLER_STACK_NUM_WORDS + 2) * 8)

.align XS1_KEP_ALIGNMENT
__traphandler_primary:
#ifdef SIMULATION
  mov      r1, r0
  ldc      r0, OSCALL_EXIT
  bl       _DoSyscall
  clrsr    IEEBLE_BIT
  waiteu
#endif
  kentsp   0
  stw      r11, sp[1]
	ldap     r11, __traphandler_trapinfo
  ldaw     r11, r11[5]
  stw      r0, r11[0]
  stw      r1, r11[1]
  stw      r2, r11[2]
  stw      r3, r11[3]
  stw      r4, r11[4]
  stw      r5, r11[5]
  stw      r6, r11[6]
  stw      r7, r11[7]
  stw      r8, r11[8]
  stw      r9, r11[9]
  stw      r10, r11[10]
	ldap     r11, __traphandler_trapinfo
  ldaw     r11, r11[10]
	ldaw     r11, r11[6]
  ldw      r0, sp[1]
  stw      r0, r11[0]
  get      r11, et
  mov      r0, r11
  get      r11, ed
  mov      r1, r11
  stw      spc, sp[1]
  ldw      r2, sp[1]
  stw      ssr, sp[2]
  ldw      r3, sp[2]
	ldap     r11, __traphandler_trapinfo
  stw      r0, r11[1]
  stw      r1, r11[2]
  stw      r2, r11[3]
  stw      r3, r11[4]
  mov      r0, r11
  get      r11, id
  stw      r11, r0[0]
	ldw      r1, sp[0]
  ldaw     r2, dp[0]
	ldap     r11, __traphandler_trapinfo
  ldaw     r11, r11[10]
  ldaw     r11, r11[7]
  stw      r1, r11[0]
  stw      r2, r11[1]
  get      r11, id
  mov      r3, r11
  ldap     r11, __traphandler_trapinfo
  mov      r0, r11
  ldap     r11, __traphandler_secondary
  ldw      r11, r11[r3]
  bla      r11
  krestsp  0
  kret
