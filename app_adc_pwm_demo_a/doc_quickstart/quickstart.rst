xCORE-Analog ADC PWM loopback demo quick start guide
====================================================

.. _app_adc_pwm_demo_a_quick_start:

This application demonstrates how to use the ADC on xCORE-Analog (A-Series) sliceKIT core board.

The application reads one channel of the ADC connected to one axis of the analog joystick and uses this value to drive a PWM signal on a 1b port. The filtered PWM is then read by a second ADC channel, and both results are printed to the console whenever the second ADC value changes.

Host computer / other setup
---------------------------

* Download and install the latest xTIMEcomposer Studio (Community or Enterprise) from `XMOS website <https://www.xmos.com/en/support/downloads/xtimecomposer>`_. Please note that this demo is not supported on Tools 13 beta(x) or earlier releases.

Hardware setup
--------------

Required hardware:

* XP-SKC-A16: xCORE-Analog sliceKIT core board
* XA-SK-MIXED SIGNAL: mixed signal sliceCARD
* XTAG-2: XTAG2
* XA-SK-XTAG2: adapter
* USB cable
* 12V DC power supply

Setup (:ref:`app_adc_pwm_demo_a_hw`):

#. Connect the adapter to the xCORE-Analog sliceKIT core board.
#. Set the ``XMOS LINK`` to ON on the adapter. This enables the debug XMOS Link and allows xSCOPE functionality.
#. Connect XTAG2 to ``XSYS`` side of the adapter.
#. Connect the other end of XTAG2 to your computer using a USB cable.
#. Connect the mixed signal sliceCARD to the xCORE-Analog sliceKIT core board using the connector marked with ``A``.
#. Connect a flying lead between ADC4 input (J2 pin 1) and PWM2 (J4 pin 1). This connects the filtered PWM output to ADC input channel 4 so it can be read.
#. Connect the 12V power supply to the xCORE-Analog sliceKIT core board and switch it ON.

.. note:: The demo will run without the flying lead from the PWM2 to ADC4 input, however the two ADC values will not track as intended.

.. _app_adc_pwm_demo_a_hw:

.. figure:: images/hardware_setup.*

   Hardware Setup for ADC PWM Loopback Demo

Import and Build the Application
--------------------------------

#. Launch the xTIMEcomposer Studio and check that it is operating in online mode. Open the edit perspective (Window->Open Perspective->XMOS Edit).
#. Locate the ``'PWM DAC to ADC analog loopback example'`` item in the xSOFTip pane on the bottom left of the window and drag it into the Project Explorer window in the xTIMEcomposer. This will also cause dependent modules (in this case, module_analog_tile_support) to be imported as well.
#. Click on the ``app_adc_pwm_demo_a`` item in the Project Explorer pane then click on the build icon (hammer) in xTIMEcomposer. Check the console window to verify that the application has built successfully.

For help using xTIMEcomposer Studio, try the xTIMEcomposer tutorial, which you can find by selecting Help->Tutorials from the xTIMEcomposer menu.

Note that the Developer Column in the xTIMEcomposer on the right hand side of your screen provides information on the xSOFTip components you are using. Select the ``module_analog_tile_support`` component in the Project Explorer, and you will see its description together with API documentation. Having done this, click the `back` icon until you return to this quickstart guide within the Developer Column.

Run the application
-------------------

Now that the application has been compiled, the next step is to run it on the xCORE-Analog sliceKIT core board using the tools to load the application over JTAG (via the XTAG2 and XTAG Adapter card) into the xCORE multicore microcontroller.

#. Select the file ``main.xc`` in the ``app_adc_pwm_demo_a`` project from the Project Explorer. This resides in the /src directory.
#. From the ``Run`` pull down menu, select ``Run Configurations``. In the left hand pane of the run configurations dialogue, you will see the ``xCORE Application``. Double click (or right click-new) ``xCORE Application``. You will see the ``Main`` tab of the right hand pane containing target options. Ensure that ``hardware`` is selected from the ``Device options`` box. If you only see ``Simulator`` as the available target then please check to ensure the XTAG-2 debug adapter is properly connected to your host workstation. Next choose ``Run xSCOPE output server`` from the I/O options selection near the bottom. This will enable collection of debug print lines from the application, using low-intrusiveness printing via xSCOPE.
#. Now run the application by clicking on the ``Run`` button at the bottom right. When the application is running, click on the ``Console`` tab at the bottom of xTIMEcomposer to view print output.
#. You should see the text ``Analog loopback demo started.`` in the console window followed by ``ADC joystick : <value>  ADC header : <value>`` showing the read values from the joystick and header ADC inputs.

Enable Real-Time xSCOPE
-----------------------

The xTIMEcomposer Studio includes xSCOPE, a tool for instrumenting your program with real-time probes. This tool allows you to collect data and display it graphically within xTIMEcomposer. As well as a graphical output, the xSCOPE mechanism provides very low intrusiveness console printing.

#. Enable real-time xSCOPE. From the ``Run`` pull down menu, select ``Run Configurations``. In the left hand pane of the run configurations dialogue, you will see the ``xCORE Application -> app_adc_pwm_demo_a.xe`` tree, which was created from the previous run. Select  ``app_adc_pwm_demo_a.xe``, and in the ``xSCOPE`` tab, select ``Real-Time [XRTScope] Mode``. This will instruct the tool to render received xSCOPE data in real time. Click ``Apply`` followed by ``Run``.
#. Open the xSCOPE window. When the program is running, click on the ``Real-time Scope`` window at the bottom and drag it away from the xTIMEcomposer window. This allows a separate xSCOPE window to be viewed at the same time as console printing. Re-size the xSCOPE window so that all of the buttons and both signal source bars can be seen in the left hand pane.
#. Configure the xSCOPE vertical axes. Because the signals being viewed are not periodic, auto setting is not effective. Consequently, you will need to set the gain, offset and time-base. Using your left and right mouse buttons, right-click first on ``Offset:`` in the Joystick ADC2 trace to set it to ``-500``. Next right-click on ``Samples/Div:`` for both the Joystick ADC2 and Header ADC4 traces and set them to ``200``. Try moving the joystick - you will see both traces track up and down together.
#. Configure the xSCOPE horizontal axis. Left-click on the ``Window:`` text at the bottom left, until it reads ``Window: 1.00s``. This slows down the horizontal axis to one second per screen. Try waggling the joystick quickly. You should see two traces oscillating, clearly showing the centering effect of the spring inside the joystick.
#. Configure the xSCOPE trigger. Left-click on the square to the left of the signal ``Joystick ADC``. Next click on the number just to the right of the button that says ``Falling``. Set this to 100. The scope is now set to trigger as the Joystick ADC passes through the value 100 on the rising edge. Finally set the vertical axis to 100ms (or 10ms per division) and try holding the joystick right over, then let it ping back to centre. You should see traces - the sampled joystick value and the generated PWM/DAC value which lags due to the timed delay within the software loop, which is about 1ms. You may also see a slight overshoot, which shows that the joystick oscillates slightly when pinging back to centre.

.. figure:: images/xscope.*

   xSCOPE display showing sampled ADC values

For further details about real-time, in circuit debugging with xSCOPE, please refer to `xTIMEcomposer User Guide
<http://www.xmos.com/trace-data-xscope-0/>`_.

Next steps
----------

Change the printing update rate to 25 milliseconds. Locate and change the following line in ``main.xc`` from::

  #define PRINT_PERIOD     10000000 // 100ms printing rate

to::

  #define PRINT_PERIOD      2500000 // 25ms printing rate

Run the program again. Note the update rate of printing in the console window.

Change the input from joystick to the Light Dependent Resistor (LDR). Locate and change the following line from::

  adc_config.input_enable[2] = 1; //Input 2 is one axis of the joystick

to::

  adc_config.input_enable[0] = 1; //Input 0 is the LDR

First check that Jumper J7 is set to ADC0 (to connect the LDR to ADC0) and run the program again. Wave your hand over the mixed signal slice, or shine a light on the board. Notice the output in the console window, or the traces in xSCOPE, as you do.
