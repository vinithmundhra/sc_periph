// Copyright (c) 2013, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

#ifndef __ms_sensor_h__
#define __ms_sensor_h__

/*---------------------------------------------------------------------------
 nested include files
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/
/**
 * The mixed signal slice interface
 */
interface i_ms_sensor
{
  int ms_sensor_get_button_state();       /**< Get button state */
  int ms_sensor_get_temperature();        /**< Get temperature */
  int ms_sensor_get_joystick_position();  /**< Get joystick position */
};

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 extern variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 prototypes
 ---------------------------------------------------------------------------*/

/*==========================================================================*/
/**
 *  Handles events from the mixed-signal sliceCARD.
 *
 *  \param c_sensor       The mixed signal sensor server interface
 *  \param c_adc          The chanend to which all ADC samples will be sent.
 *  \param trigger_port   The port connected to the ADC trigger pin.
 *  \param p_sw1          SW1 button port on the mixed signal slice
 *  \return None
 **/
void mixed_signal_slice_sensor_handler(server interface i_ms_sensor c_sensor,
                                       chanend c_adc,
                                       port trigger_port,
                                       in port p_sw1);

#endif // __ms_sensor_h__
/*==========================================================================*/
