sliceKIT Ethernet Sleep Wake Combo Demo
=======================================

:scope: Example
:description: A simple demo of sleep and wake features
:keywords: sleep

This is a simple demo using the Sleep and Wake feature of U and A series of XMOS devices. In this 
demo, a webclient running on the XMOS device would inform a webserver running on a PC that it is 
going to sleep and has woken up from sleep.

Hardware requirements
---------------------

- XP-SKC-U16 1V1
- XA-SK-E100 1V0
- XTAG2
- Ethernet cable and power supplies (12V)

Software requirements
---------------------

- Python installed on the host PC
- xTIMEcomposer Studio version 13.0.0beta2

Required Repositories
---------------------

- sc_ethernet https://github.com/xcore/sc_ethernet.git
- sc_otp https://github.com/xcore/sc_otp.git
- sc_periph https://github.com/vinithmundhra/sc_periph
- sc_slicekit_support https://github.com/xcore/sc_slicekit_support.git
- sc_util https://github.com/xcore/sc_util.git
- sc_webclient git://git/apps/sc_webclient.git
- sc_xtcp https://github.com/xcore/sc_xtcp.git

Setup
-----

- Connect ``XA-SK-E100`` to the ``SQUARE`` slot of the ``XP-SKC-U16`` sliceKIT core board.
- Connect ``XTAG2`` to ``XSYS`` slot on ``XP-SKC-U16`` sliceKIT core board.
- Connect an Ethernet cable between ``XA-SK-E100`` and your PC.
- Connect the 12V power supply to ``XP-SKC-U16`` sliceKIT core board.

- In the xTIMEcpomposer Studio, import ``app_a16_slicekit_ethernet_sleep_wake_combo_demo``
- Build the project and run it once on the XMOS device.
- Terminate and close the run and open ``app_a16.xc``.

- Navigate to ``$\sc_periph\app_a16_slicekit_ethernet_sleep_wake_combo_demo\xmos_python_webserver``
- Run ``server.py`` and note down the Server IP address.
- Terminate the Python run.

- In the xTIMEcomposer Studio, navigate to line 59 of ``app_a16.xc``
- Change the IP address to that noted down previously
- Build the project and *Flash* it on the XMOS device
- After successful flash, power cycle the ``XP-SKC-U16`` sliceKIT core board.
- Remove the ``XTAG2`` from the core board.

Demo
----

#. Switch ON the power supply to ``XP-SKC-U16`` sliceKIT core board.
#. Run ``server.py`` on your PC
#. After a while, below mentioned messages will appear on the Python console::
   
    Server Address = 169.254.202.189
    Incoming ('169.254.216.175', 1026)
    XMOS: Going to Sleep...zzz
    Incoming ('169.254.193.54', 1026)
    XMOS: Rise and shine....
    XMOS: Going to Sleep...zzz
    Incoming ('169.254.143.18', 1026)
    XMOS: Rise and shine....
    XMOS: Going to Sleep...zzz

What this means is

#. The XMOS connects to webserver at start
#. Informs webserver that it is going to sleep (Going to Sleep...zzz)
#. Sleeps for some time
#. Wakes up and finds Server IP address in the sleep memory
#. Connects to webserver again
#. Informs that it has woken up from sleep ('Rise and shine....')
#. Informs webserver that it is going to sleep (Going to Sleep...zzz)
#. Loops
