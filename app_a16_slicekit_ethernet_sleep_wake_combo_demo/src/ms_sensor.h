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
typedef struct sensor_data_t_
{
  unsigned char btn_press_count;  /**< Button press count */
  unsigned char joystick_x;       /**< Joystick X position */
  unsigned char joystick_y;       /**< Joystick Y position */
  unsigned char temperature;      /**< Temperature recorded by thermistor */
} sensor_data_t;

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
 *  Has the sensor data changed? This is a select handler.
 *
 *  \param c_sensor       The mixed signal sensor channel
 *  \param sensor_data    Get the sensor data in this variable
 *  \return None
 **/
#ifdef __XC__
#pragma select handler
void ms_sensor_data_changed(chanend c_sensor, sensor_data_t &sensor_data);
#endif

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
void mixed_signal_slice_sensor_handler(chanend c_sensor,
                                       chanend c_adc,
                                       port trigger_port,
                                       in port p_sw1);

#endif // __ms_sensor_h__
/*==========================================================================*/
