// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*************************************************************************
 *
 * Ethernet MAC Layer Implementation
 * IEEE 802.3 Device MAC Address
 *
 *
 *
 * Retreives three bytes of MAC address from OTP.
 *
 *************************************************************************/

#include <xs1.h>
#include <platform.h>
#include <print.h>
#define OTP_DATA_PORT XS1_PORT_32B
#define OTP_ADDR_PORT XS1_PORT_16C
#define OTP_CTRL_PORT XS1_PORT_16D

#define OTPADDRESS 0x7FF
#define OTPMASK    0xFFFFFF
#define OTPREAD 1

/* READ access time */
#define OTP_tACC_TICKS 4 // 40nS

// -------------------------------------------------------------------

on stdcore[4]: port otp_data = OTP_DATA_PORT;
on stdcore[4]: out port otp_addr = OTP_ADDR_PORT;
on stdcore[4]: port otp_ctrl = OTP_CTRL_PORT;

static int otpRead(unsigned address)
{
  unsigned value;
  timer t;
  int now;
  
  otp_ctrl <: 0;
  otp_addr <: 0;
  otp_addr <: address;
  sync(otp_addr);
  otp_ctrl <: OTPREAD;
  sync(otp_addr);
   t :> now;
   t when timerafter(now + OTP_tACC_TICKS) :> now;
  otp_data :> value;
  otp_ctrl <: 0;

  return value;
}

static int getMacAddrAux(unsigned MACAddrNum, unsigned macAddr[2])
{
  int address = OTPADDRESS;
  unsigned bitmap;
  if (MACAddrNum < 7)
  {
    int validbitmapfound = 0;
    while (!validbitmapfound && address >= 0)
    {      
      bitmap = otpRead(address);
      if (bitmap >> 31)
      {
        // Bitmap has not been written
        return 1;
      }
      else if (bitmap >> 30)
      {
        validbitmapfound = 1;
      }
      else
      {
        int length = (bitmap >> 25) & 0x1F;
        if (length==0)
          length=8;
        // Invalid bitmap
        address -= length;
      }
    }

    if (address < 0) {
      return 1;
    }
    else if (((bitmap >> 22) & 0x7) > MACAddrNum)
    {
      address -= ((MACAddrNum << 1) + 1);
      macAddr[0] = otpRead(address);
      address--;
      macAddr[1] = otpRead(address);
      return 0;
    }
    else
    {
      // MAC Address cannot be found
      return 1;
    }
  }
  else
  {
    // Incorrect number of MAC addresses given
    return 1;
  }
}


static int ethernet_gethalfmac()
{
  unsigned value;
  timer t;
   
  otp_ctrl <: 0;
  otp_addr <: 0;
  otp_addr <: OTPADDRESS;
  sync(otp_addr); 
  otp_ctrl <: OTPREAD;
  sync(otp_addr);
  {
   int now;
   t :> now;
   t when timerafter(now + OTP_tACC_TICKS) :> now;
  }
  otp_data :> value;
  otp_ctrl <: 0;
  
  return (int)(value & OTPMASK);
}


void ethernet_getmac_otp(char macaddr[]) 
{
  unsigned int OTPId;
  unsigned int wrd_macaddr[2];
  int value;
  timer tmr;

  value = getMacAddrAux(0, wrd_macaddr);
  if (value == 0) {
    macaddr[0] = (wrd_macaddr[0] >> 8) & 0xFF;
    macaddr[1] = (wrd_macaddr[0]) & 0xFF;
    macaddr[2] = (wrd_macaddr[1] >> 24) & 0xFF;
    macaddr[3] = (wrd_macaddr[1] >> 16) & 0xFF;
    macaddr[4] = (wrd_macaddr[1] >> 8) & 0xFF;
    macaddr[5] = (wrd_macaddr[1]) & 0xFF;
  }
  else {
  // get unique 24bits id from otp, thanks Sam !
    OTPId = ethernet_gethalfmac();
    macaddr[0] = 0x0;
    macaddr[1] = 0x22;
    macaddr[2] = 0x97;
    // reformat that into XMOS mac address and send it out

    if ((OTPId & 0xffffff)==0xffffff) {
      unsigned int time;
      unsigned int a=1664525;
      unsigned int c=1013904223;
      unsigned int j;
      // create a randomish address
      printstr("rand\n");
      tmr :> time;
      j = time & 0xf;
      for (int i=0;i<j;i++)
        time = a * time + c;
      OTPId = time;
    }
    macaddr[3] = (OTPId >> 16) & 0xFF;
    macaddr[4] = (OTPId >> 8) & 0xFF;
    macaddr[5] = OTPId & 0xFF;       
  }
  

  return;
}
