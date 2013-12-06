xCORE-Analog sliceKIT Ethernet sleep wake combo demo quickstart guide
=====================================================================

This application uses the ``XP-SKC-A16`` xCORE-Analog sliceKIT core board plus  ``XA-SK-E100`` and ``XA-SK-MIXED SIGNAL`` sliceCARDs together with the xSOFTip ``module_analog_tile_support`` and ``module_xtcp`` to demonstrate how the chip can be made to sleep and wake up using different sources. The application also runs a TCP web client and informs a web server before going to sleep and after waking up from sleep.

Host computer / other setup
---------------------------

* Required a computer with Python (2.7.3 or newer) installed. Get Python from: http://www.python.org/
* Download and install the latest xTIMEcomposer Studio (Community or Enterprise) from XMOS website. Please note that this demo is not supported on Tools 13 beta(x) or earlier releases.
* Configure your wired connection IPv4 settings to use a static IP address. For example, IP address = 169.254.202.189; and Netmask = 255.255.0.0;

   - For Mac: Navigate to *System Preferences -> Network -> Ethernet -> Configure IPv4 -> Manually* and provide the IP address.

   - For Linux (Ubuntu): Navigate to *System Settings -> Network -> Wired -> Edit a Wired Connection -> IPv4 Settings -> Manually* and provide the IP address in the space below it.

   - For Windows: Navigate to *Start -> Control Panel -> Network and Sharing Center -> Change Adapter Settings (on the left pane)*

      - Double click on *Local Area Connection*

      - Double click on *Internet Protocol Version 4*

      - Select the option 'Use the following IP address'

      - Provide the IP address and Subnet mask (gateway can be blank)

      - Click *OK*

Hardware setup
--------------

Required hardware:

* XP-SKC-A16: xCORE-Analog sliceKIT core board
* XA-SK-E100: Ethernet sliceCARD
* XA-SK-MIXED SIGNAL: mixed signal sliceCARD
* XTAG-2: XTAG2
* XA-SK-XTAG2: adapter
* Ethernet and USB cables
* 12V DC power supply

Setup:

#. Connect the adapter to the core board.
#. Set the ``XMOS LINK`` to ON on the adapter.
#. Connect XTAG2 to ``XSYS`` side of the adapter.
#. Connect the other end of XTAG2 to your computer using a USB cable.
#. Ensure that the room (in which is demo is presented) is well lit as in this demo the LDR will be used to detect light.
#. Connect the Ethernet sliceCARD to the xCORE-Analog sliceKIT core board using the connector marked with the ``SQUARE``.
#. Connect the other end of Ethernet sliceCARD and host computer using Ethernet cable.
#. Connect mixed signal sliceCARD to the xCORE-Analog sliceKIT core board using the connector marked with the ``A``.
#. On the mixed signal sliceCARD:

   - To use LDR as wake up source, attach jumpers on (or short):

      - Pins 1 & 2 of ``J6``

      - Pins 2 & 3 (LDR_COMP) of ``J7``

   - To use button (SW2) as wake up source, do not attach any jumpers.

   - This demo will use LDR as the wake up source. If you'd like to use the button (SW2) as a wake up source, please remove the jumpers (J6 and J7) on the mixed signal sliceCARD.

#. Connect the 12V power supply to the xCORE-Analog sliceKIT core board and switch it ON.

.. figure:: images/hardware_setup.*

   Hardware setup

.. figure:: images/ms_slicecard.*

   mixed signal sliceCARD jumper settings

Import and build the application
--------------------------------
Importing the xCORE-Analog sliceKIT Ethernet sleep wake combo demo application:

* Open the xTIMEcomposer Studio and ensure that it is operating in online mode.
* Open the *Edit* perspective (Window -> Open Perspective -> XMOS Edit).
* Open the *xSOFTip* view from (Window -> Show View -> xSOFTip). An *xSOFTip* window appears on the bottom-left.
* Find the *xCORE-Analog sliceKIT Ethernet Sleep Wake Combo Demo*.
* Click and drag it into the *Project Explorer* window. Doing this will open a *Import xTIMEcomposer Software* window. Click on *Finish* to download and complete the import.
* This will also automatically import dependencies for this application.
* The application is called as *app_a16_slicekit_ethernet_sleep_wake_combo_demo* in the *Project Explorer* window.

Building the xCORE-Analog sliceKIT Ethernet sleep wake combo demo application:

* Open the file *app_a16_slicekit_ethernet_sleep_wake_combo_demo/src/app_a16.xc*
* Go to line 32 and change the IP address of the web server (``server_config``) that the web client will try to connect to.
* This XMOS application will also acquire an IP address on the network, using the IP configuration (``client_ipconfig``) present on line 26. This should be configured to use a static IP address by:

   - Specify an IP address according to the network. Usually, this would be the web server IP address + 1. For example, if the web server IP address is 169.254.202.189, then this IP address would be 169.254.202.190.

* Save the application using *File -> Save*.
* Click on the *app_a16_slicekit_ethernet_sleep_wake_combo_demo* item in the *Project Explorer* window.
* Click on the *Build* (indicated by a 'Hammer' picture) icon.
* Check the *Console* window to verify that the application has built successfully.

Run the application
-------------------
Flash the Application:

* In the *Project Explorer* window, locate the *app_a16_slicekit_ethernet_sleep_wake_combo_demo.xe* in the (app_a16_slicekit_ethernet_sleep_wake_combo_demo -> Binaries).
* Right click on *app_a16_slicekit_ethernet_sleep_wake_combo_demo.xe* and click on (Flash As -> xCORE Application).
* A *Select Device* window appears.
* Select *XMOS XTAG-2 connected to L1* and click OK.
* Check the *Console* window to verify flashing progress.
* After successful flashing, switch OFF the xCORE-Analog sliceKIT core board.

Demo:

* On the *Terminal* or *Command Line* navigate to *app_a16_slicekit_ethernet_sleep_wake_combo_demo/xmos_python_webserver*.
* Run the Python script with the web server address (*Note:* administrator privileges may be required to run ``server.py``.)

     - For Windows: start command prompt as an administrator and then execute the Python scripts.

     - For Mac / Linux: run the scripts with *sudo*.

::

   python server.py 169.254.202.189

* The following message is displayed in the Python console::

   Server: Logging temperature data to temperature.log
   Server: Waiting to start web server
   Server: Press CTRL+C to exit.

* Switch ON the power supply to xCORE-Analog sliceKIT core board. The link will come up and the server will then start::

   Server: Web server started with IP address = 169.254.202.189
   -----------------------------------------

* Wait until the following message is displayed::

   XMOS: Program running! Sensor events will now be recorded.

* The client will print the initial values of sensors::

   XMOS: Button = 000; Temperature = 124; Joystick X = 112, Y = 121

* On the ``XA-SK-MIXED SIGNAL`` sliceCARD, try to:

   - click (press and release) button - SW1

   - move the Joystick to different positions

* As and when the sensor (button clicks, joystick position) values change, the Python console is updated with their values::

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

* After 1 minute the following message is displayed::

   XMOS: Going to sleep.
   -----------------------------------------
   Server: Client closed connection, expecting wakeup in 30 seconds...
   30
   29

* At this point, the chip enters sleep mode and could be woken up by two sources:

   - Depending on the jumper settings configured above; Either the LDR waking on low light or SW2 being pressed.

   - The internal sleep timer expires - currently set to 30 seconds

* Meanwhile, the Python server is waiting for the chip to wake up and request a new connection.

* Once woken up, the program will connect to the running web server, display the sensor data and go back to sleep.

* The Python server will log the temperature values to ``temperature.log``. It will write out a value every 10 seconds and every time the temperature changes.

*Note:* The button press count is stored in sleep memory. When the chip wakes up, the program will look in the sleep memory for valid data and continue counting button presses from the last value.

Next Steps
++++++++++

* Review the ``app_a16_slicekit_ethernet_sleep_wake_combo_demo`` application code, ``module_analog_tile_support`` module code. Refer to the documentation for each of them to see the API details and usage.

* The sleep timer can be changed at line 14 in the file: (*/app_a16_slicekit_ethernet_sleep_wake_combo_demo/src/app_a16.xc*)::

   #define SLEEP_MILLISEC 30000

  Try changing this to *60000* and note that the sleep time will now be increased to 60 seconds. This will cause the Python server to complain about the chip now waking up in time.

