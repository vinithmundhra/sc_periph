Peripheral Tile Support Library
...............................

:Latest release: 1.1.0alpha0
:Maintainer: pthedinger ed-xmos
:Description: Collection of functions to support peripheral tiles.


The Peripheral Tile Support Library provides a set of functions and 
datatypes which aid the use of the xCORE peripheral tiles.

Key Features
============

module_usb_tile_support:
 
* Support for the U-Series Analog to Digital Converters (ADCs)

*Note: support for USB devices is provided by the USB Device Component*

module_analog_tile_support:
 
* Support for the A-Series Analog to Digital Converters (ADCs)
* Support for A-Series Watchdog Timer (WDT)
* Library functions supporting sleep mode and the Real Time Clock (RTC)



Known Issues
============

None.

      
Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any
issues submitted as at the discretion of the maintainer for this line.

Required software (dependencies)
================================

  * sc_util (git://github.com/xcore/sc_util)
  * sc_slicekit_support (https://github.com/xcore/sc_slicekit_support.git)
  * sc_pwm (https://github.com/xcore/sc_pwm.git)

