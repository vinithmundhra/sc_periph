A16 sliceKIT Ethernet Sleep Wake Combo Demo Quickstart Guide
============================================================

This simple demonstration of xTIMEcomposer Studio functionality that uses the ``XA-SK-E100`` and ``XA-SK-MIXED SIGNAL``sliceCARDs together with the xSOFTip ``module_analog_tile_support`` and ``module_xtcp`` to demonstrate how the chip can be made to sleep and wake up using different sources. The app also runs a TCP web client and informs web server before going to sleep and after waking up from sleep.

Hardware Setup
++++++++++++++

The A16 sliceKIT Ethernet Sleep Wake Combo Demo Application requires the following items:

- XP-SKC-A16 sliceKIT core board.
- XA-SK-E100 Ethernet sliceCARD
- XA-SK-MIXED SIGNAL sliceCARD
- XTAG-2 & XA-SK-XTAG2 adapter board
- Ethernet and USB cables
- 12V DC power supply

To setup the system:

#. Ensure that the room (in which is demo is presented) is well lit as in this demo the LDR will be used to detect light.
#. Connect ``XA-SK-XTAG2`` to sliceKIT Core board and ``XTAG-2`` to the adapter board.
#. Connect the ``XTAG-2`` to host PC using USB cable. Note that the USB cable is not provided with the sliceKIT starter kit.
#. Connect ``XA-SK-E100`` sliceCARD to the sliceKIT Core board using the connector marked with the ``SQUARE``.
#. Connect ``XA-SK-E100`` sliceCARD and host computer using Ethernet cable.
#. Connect ``XA-SK-MIXED SIGNAL`` sliceCARD to the sliceKIT Core board using the connector marked with the ``A``.
#. Switch on the power supply to the sliceKIT Core board.

.. figure:: images/hardware_setup.jpg
   :align: center

   Hardware Setup for A16 sliceKIT Ethernet Sleep Wake Combo Demo Application

Host Computer Setup
+++++++++++++++++++

- Install Python on the host computer from http://www.python.org/.
- Required Python version to be 2.7.3 or newer.
- If you are planning to connect the Ethernet cable directly to your host computer's Ethernet port, it may be required to setup a static IP configuration. Please configure your wired connection IPv4 settings to provide a static IP address. For example, IP address = 169.254.202.189; Netmask = 255.255.0.0; Gateway = 255.255.255.0 
   - For Mac: Navigate to ``System Preferences -> Network -> Ethernet -> Configure IPv4 -> Manually``
   - For Linux (Ubuntu): Navigate to ``System Settings -> Network -> Wired -> Edit a Wired Connection -> IPv4 Settings -> Manually`` and provide the IP address in the space below it.
   - For Windows: No need to configure.

To test the web server setup, a simple client is provided in ``$/app_a16_slicekit_ethernet_sleep_wake_combo_demo/xmos_python_webserver``:

#. Navigate to ``$/app_a16_slicekit_ethernet_sleep_wake_combo_demo/xmos_python_webserver``
#. Run ``server.py``. The server IP address will be displayed in the console.
#. Run ``test_client.py`` with server IP address as argument.
#. The client would open, send a message to web server close the connection, twice!
#. Look for the message *Hi from test client* in the Server console. If this message is displayed (twice), the web server setup is alright.

Please note 

- administrator privileges may be required to run the ``server.py`` and ``test_client.py``. 
   - For Windows: start command prompt as an administrator and then execute the python scripts.
   - For Mac / Linux: run the scripts with *sudo*. 
- ``test_client.py`` could be run on a different workstation provided that the two workstations are connected via a Ethernet cable.

Import and Build the Application
++++++++++++++++++++++++++++++++

#. Open xTIMEcomposer and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
#. Locate the ``A16 sliceKIT Ethernet Sleep Wake Combo Demo`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause the modules on which this application depends to be imported as well.
#. Open the file ``$/app_a16_slicekit_ethernet_sleep_wake_combo_demo/src/app_a16.xc``
#. Go to line:54 and change the IP address of the web server (``server_config``) that the web client will try to connect to.
#. This XMOS application will also acquire an IP address on the network, using the IP configuration (``client_ipconfig``) present on line:50. This can configured to get the IP address dynamically or by providing a static IP.
   - Make it all zeroes to use DHCP
   - Or, specify an IP address according to the network. Usually, this would be the web server IP address + 1. For example, if the web server IP address is 169.254.202.189, then this IP address would be 169.254.202.190.
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

- Navigate to ``$/app_a16_slicekit_ethernet_sleep_wake_combo_demo/xmos_python_webserver``
- Double click or Run the python script: ``server.py``
- The following message is displayed in the Python console::

   Web Server Address = 169.254.202.189
   *Note: This IP address may change depending on your network.*
   
- Wait until the following message is displayed::

   XMOS: Program running! Sensor events will now be recorded.
   
- The client will print the initial values of sensors::
   
   XMOS: Button = 000; Temperature = 124; Joystick X = 112, Y = 121
   
- On the ``XA-SK-MIXED SIGNAL`` sliceCARD, try to:
   - click (press and release) button - SW1
   - Move the Joystick to different positions
  
- As and when the sensor (button clicks, joystick position) values change, the python console is updated with their values::

   XMOS: Button = 000; Temperature = 124; Joystick X = 112, Y = 121
   XMOS: Button = 001; Temperature = 124; Joystick X = 112, Y = 121
   XMOS: Button = 002; Temperature = 124; Joystick X = 112, Y = 121
   XMOS: Button = 003; Temperature = 124; Joystick X = 112, Y = 121
   XMOS: Button = 004; Temperature = 124; Joystick X = 112, Y = 121
   XMOS: Button = 005; Temperature = 124; Joystick X = 112, Y = 121
   XMOS: Button = 005; Temperature = 124; Joystick X = 117, Y = 135
   XMOS: Button = 005; Temperature = 124; Joystick X = 204, Y = 214
   XMOS: Button = 005; Temperature = 124; Joystick X = 207, Y = 216
   XMOS: Button = 005; Temperature = 124; Joystick X = 113, Y = 121
   XMOS: Button = 005; Temperature = 124; Joystick X = 113, Y = 119
   XMOS: Button = 005; Temperature = 124; Joystick X = 111, Y = 113
   XMOS: Button = 005; Temperature = 124; Joystick X = 028, Y = 035

- After a while (AWAKE TIME = 1 minute) the following message is displayed::
   
   XMOS: Going to sleep.
   Connection closed
   Expecting Wakeup in (seconds)...
   
- At this point, the chip enters sleep mode and could be woken up by two sources:
   
   - If the room gets dark - LDR triggers wake signal on low light
   - The internal sleep timer expires - currently set to 10 seconds
   
- Meanwhile, the python server is waiting for the chip to wake up and request a new connection.

- Once woken up, the program will try to connect to the running web server, display the sensor data and go back to sleep.
   
*Note:*

- The web server configuration is stored in sleep memory. When the chip wakes up, the program will look in the sleep memory for valid data.
- The sleep timer can be changed at line 25: ``$/app_a16_slicekit_ethernet_sleep_wake_combo_demo/src/app_a16.xc``::
   
   #define SLEEP_TIME 10000 //Time asleep in ms

Next Steps
++++++++++

- Review the ``app_a16_slicekit_ethernet_sleep_wake_combo_demo`` application code, ``module_analog_tile_support`` module code. Refer to the documentation for each of them to see the API details and usage.
