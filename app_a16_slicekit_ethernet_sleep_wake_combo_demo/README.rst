A16 sliceKIT Ethernet sleep wake combo demo
===========================================

:scope: Example
:description: A simple demo of sleep and wake features
:keywords: sleep
:boards: XA-SK-E100, XA-SK-MIXED SIGNAL, A16

Demo Overview
-------------

This is a simple demo using the Sleep and Wake feature of A series XMOS devices. In this demo, a web client running on the XMOS device informs a web server running on a host workstation when it is going to sleep and has woken up from sleep. The XMOS device can be woken up using: timer, pin value, etc...

Software requirements
---------------------

- Python installed on host workstation (2.7.3 or newer)
- xTIMEcomposer Studio version 13 Community or Enterprise

Required Repositories
---------------------

- sc_ethernet https://github.com/xcore/sc_ethernet.git
- sc_otp https://github.com/xcore/sc_otp.git
- sc_periph https://github.com/xcore/sc_periph.git
- sc_slicekit_support https://github.com/xcore/sc_slicekit_support.git
- sc_util https://github.com/xcore/sc_util.git
- sc_xtcp https://github.com/xcore/sc_xtcp.git

Support
-------

Issues may be submitted via the Issues tab in this github repository. Response to any issues submitted as at the discretion of the maintainer for this line.
