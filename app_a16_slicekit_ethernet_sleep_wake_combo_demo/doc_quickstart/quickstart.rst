A16 sliceKIT Ethernet Sleep Wake Combo Demo Quickstart Guide
============================================================

This simple demonstration of xTIMEcomposer Studio functionality that uses the ``XA-SK-E100`` sliceCARD together with the xSOFTip ``module_analog_tile_support`` and ``module_xtcp`` to demonstrate how the chip can be made to sleep and wake up using different sources. The app also runs a TCP web client and informs web server before going to sleep and after waking up from sleep.

Hardware Setup
++++++++++++++

The A16 sliceKIT Ethernet Sleep Wake Combo Demo Application requires the following items:

- XP-SKC-A16 sliceKIT core board.
- XA-SK-E100 Ethernet sliceCARD
- XTAG-2
- Ethernet and USB cables
- 12V DC power supply

To setup the system:

#. Connect the ``XTAG-2`` to sliceKIT Core board.
#. Connect the ``XTAG-2`` to host PC using USB cable. Note that the USB cable is not provided with the sliceKIT starter kit.
#. Connect ``XA-SK-E100`` sliceCARD to the sliceKIT Core board using the connector marked with the ``SQUARE``.
#. Connect ``XA-SK-E100`` sliceCARD and host computer using Ethernet cable.
#. Switch on the power supply to the sliceKIT Core board.

.. figure:: images/hardware_setup.jpg
   :align: center

   Hardware Setup for A16 sliceKIT Ethernet Sleep Wake Combo Demo Application

Host Computer Setup
+++++++++++++++++++

Install Python on the host computer from http://www.python.org/.

Note for Mac: Have a static Ethernet IP: System Preferences -> Network -> Ethernet -> Configure IPv4: Manually. Give an IP address.

Import and Build the Application
++++++++++++++++++++++++++++++++

#. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
#. Locate the ``A16 sliceKIT Ethernet Sleep Wake Combo Demo`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends to be imported as well.
#. Open the file ``$/app_a16_slicekit_ethernet_sleep_wake_combo_demo/src/app_a16.xc``
#. Go to line:55 and change the IP address (of the web server) that the web client will try to connect to.
#. Save the application using File -> Save.
#. Click on the ``app_a16_slicekit_ethernet_sleep_wake_combo_demo`` item in the Project Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help in using xTIMEcomposer, try the xTIMEcomposer tutorial, which you can find by selecting (Help->Tutorials) from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the ``module_analog_tile_support`` component in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quick start guide within the Developer Column.

Flash the Application
+++++++++++++++++++++

Now that the application has been compiled, the next step is to flash it on the sliceKIT Core Board using the tools to load the application over JTAG into the xCORE multicore microcontroller.

- Select the file ``app_a16.xc`` in the ``app_a16_slicekit_ethernet_sleep_wake_combo_demo`` project from the Project Explorer.
- Click on the ``Flash`` icon.
- At the ``Select Device`` dialog select ``XMOS XTAG-2 connect to L1[0..1]`` and click ``OK``.
- Flashing progress messages are displayed in the console.
- After a successful flash, power cycle the sliceKIT core board.

The Demo
++++++++

- Navigate to ``$/app_a16_slicekit_ethernet_sleep_wake_combo_demo/xmos_python_webserver``.
- Double click or Run the python script: ``server.py``.
- The following messages are displayed in the Python console::

   Server Address = 169.254.202.189
   XMOS: Going to sleep...zzz
   Connection closed
   XMOS: Rise and shine....
   XMOS: Going to sleep...zzz
   Connection closed
   XMOS: Rise and shine....
   XMOS: Going to sleep...zzz
   Connection closed
   XMOS: Rise and shine....
   XMOS: Going to sleep...zzz
   Connection closed
   XMOS: Rise and shine....
   XMOS: Going to sleep...zzz
   Connection closed

What this means is:


   +----------------------------------+------------------------------------------------------------+
   | Message in Python console        | xCORE app                                                  |
   +==================================+============================================================+
   | Server Address = 169.254.202.189 |                                                            |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Program starts                                             |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Looks for valid server configuration in sleep memory.      |
   |                                  | Since, this is power up, it takes the default Server       |
   |                                  | configuration and saves it to sleep memory.                |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Initializes web client, and connects to web server         |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Starts a sleep timer                                       |
   +----------------------------------+------------------------------------------------------------+
   | XMOS: Going to sleep...zzz       | Timer expires, sends message to web server that it will be |
   |                                  | going to sleep                                             |
   +----------------------------------+------------------------------------------------------------+
   | Connection closed                | Closes the TCP connection                                  |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Sleeps                                                     |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Wakes up upon timer expiry                                 |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Looks for valid server configuration in sleep memory. This |
   |                                  | time it finds valid data in sleep memory. Uses this server |
   |                                  | configuration.                                             |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Initializes web client, and connects to web server         |
   +----------------------------------+------------------------------------------------------------+
   | XMOS: Rise and shine....         | Informs web server that it just woke up from sleep         |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Starts a sleep timer                                       |
   +----------------------------------+------------------------------------------------------------+
   | XMOS: Going to sleep...zzz       | Timer expires, sends message to web server that it will be |
   |                                  | going to sleep                                             |
   +----------------------------------+------------------------------------------------------------+
   | Connection closed                | Closes the TCP connection                                  |
   +----------------------------------+------------------------------------------------------------+
   |                                  | Sleeps                                                     |
   +----------------------------------+------------------------------------------------------------+


Next Steps
++++++++++

- Review the ``app_a16_slicekit_ethernet_sleep_wake_combo_demo`` application code, ``module_analog_tile_support`` module code. Refer to the documentation for each of them to see the API details and usage.
