
/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "ms_sensor.h"
#include "analog_tile_support.h"
#include <print.h>

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define DEBOUNCE_INTERVAL     XS1_TIMER_HZ/50
#define BUTTON_1_PRESS_VALUE  0x1

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 mixed_signal_slice_sensor_handler
 ---------------------------------------------------------------------------*/
void mixed_signal_slice_sensor_handler(server interface i_ms_sensor c_sensor,
                                       chanend c_adc,
                                       port trigger_port,
                                       in port p_sw1)
{
  unsigned data[3]; //Array for storing ADC results
  int sw1_state = 0;
  int temperature = 0;
  int joystick_x = 0;
  int joystick = 0;

  int scan_button_flag = 1;
  unsigned button_state_1 = 0;
  unsigned button_state_2 = 0;
  timer t_scan_button_flag;
  unsigned time;

  at_adc_config_t adc_config = { {0, 0, 0, 0, 0, 0, 0, 0}, 0, 0, 0}; //initialse all ADC to off

  adc_config.input_enable[1] = 1; //Input 1 is thermistor
  adc_config.input_enable[2] = 1; //Input 2 is horizontal axis of the joystick
  adc_config.input_enable[3] = 1; //Input 3 is vertical axis of the joystick

  adc_config.bits_per_sample = ADC_8_BPS;
  adc_config.samples_per_packet = 3; //Allow samples to be sent in one hit
  adc_config.calibration_mode = 0;

  at_adc_enable(analog_tile, c_adc, trigger_port, adc_config);
  at_adc_trigger_packet(trigger_port, adc_config); //Fire the ADC!

  set_port_drive_low(p_sw1);
  t_scan_button_flag :> time;
  p_sw1 :> button_state_1;

  // Get initial values
  at_adc_read_packet(c_adc, adc_config, data);
  temperature = data[0]; //First value in packet
  joystick_x  = data[1]; //Second value in packet
  joystick  = (joystick_x << 16) + (data[2] & 0xFF); //Third value in packet

  while(1)
  {
    select
    {
      //::Button Scan Start
      case scan_button_flag => p_sw1 when pinsneq(button_state_1) :> button_state_1:
      {
        t_scan_button_flag :> time;
        scan_button_flag = 0;
        break;
      }
      case !scan_button_flag => t_scan_button_flag when timerafter(time + DEBOUNCE_INTERVAL) :> void:
      {
        p_sw1 :> button_state_2;
        if(button_state_1 == button_state_2)
        {
          if(button_state_1 == BUTTON_1_PRESS_VALUE)
          {
            sw1_state++;
          }
        }
        scan_button_flag = 1;
        break;
      }
      //::Button Scan End

      case at_adc_read_packet(c_adc, adc_config, data): //if data ready to be read from ADC
      {
        printstrln("MS: change in ADC vals");
        printintln(data[0]);
        printintln(data[1]);
        printintln(data[2]);
        /*
        temperature = data[0]; //First value in packet
        joystick_x  = data[1]; //Second value in packet
        joystick  = (joystick_x << 16) + (data[2] & 0xFF); //Third value in packet
        */
        break;
      } // case at_adc_read_packet

      case c_sensor.ms_sensor_get_button_state() -> int rtn_val:
      {
        rtn_val = sw1_state;
        sw1_state = 0;
        break;
      } // case get_button_state

      case c_sensor.ms_sensor_get_temperature() -> int rtn_val:
      {
        rtn_val = temperature;
        break;
      } // case get_temperature

      case c_sensor.ms_sensor_get_joystick_position() -> int rtn_val:
      {
        rtn_val = joystick;
        break;
      } // case get_joystick
    } // select
  } // while(1)
}

/*==========================================================================*/
