XK-XMP-64 example software
..........................

:Stable release:  unreleased

:Status:  feature complete

:Maintainer:  https://github.com/henkmuller

:Description:  Collection of example programs and basic documents on the XMP-64


Key Features
============

* Program that shows an ethernet bridge
* Program that tests all links
* Program that test all leds
* Document that analyses network performance

To Do
=====

None

Repo Overview
=============

This repo contains a set of test programs for the XMP-64, and some
programs that demonstrate its functionality. It also contains some
documentation on the XMP-64. 

* app_ethernetExample: executing this program will bridge the two ethernet
  ports

* app_multipleLeds: switches all leds on and off

* app_linkTest: tests all the links. Leds should in turn switch on and off

* app_singleLed: simplest example.

Known Issues
============

* The XK-XMP-64.xn file is tool-version specific.

Required Repositories
================

* sc_ethernet
* xcommon

Support
=======

Please raise an issue
