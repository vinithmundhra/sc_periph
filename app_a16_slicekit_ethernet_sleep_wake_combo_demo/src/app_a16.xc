// Copyright (c) 2013, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*===========================================================================
 Info
 ----

 ===========================================================================*/

/*---------------------------------------------------------------------------
 include files
 ---------------------------------------------------------------------------*/
#include "webclient.h"
#include "ethernet_board_conf.h"
#include "xtcp.h"
#include "analog_tile_support.h"
#include "ms_sensor.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define AWAKE_TIME 60000  //Time awake in ms
#define SLEEP_TIME 10000  //Time asleep in ms

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
on ETHERNET_DEFAULT_TILE: ethernet_xtcp_ports_t xtcp_ports = {
  OTP_PORTS_INITIALIZER,
  ETHERNET_DEFAULT_SMI_INIT,
  ETHERNET_DEFAULT_MII_INIT_lite,
  ETHERNET_DEFAULT_RESET_INTERFACE_INIT
};

on tile[0]: in port p_sw1 = XS1_PORT_1F;
on tile[0]: port trigger_port = PORT_ADC_TRIGGER;

/*---------------------------------------------------------------------------
 typedefs
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 global variables
 ---------------------------------------------------------------------------*/
xtcp_ipconfig_t client_ipconfig = {
  {0, 0, 0, 0},
  {0, 0, 0, 0},
  {0, 0, 0, 0}
};

server_config_t server_config = {
  {169, 254, 202, 189},
  80,
  80
};

char ws_data_sleep[100] = "Going to sleep.";
char ws_data_notify[100] = "Program running! Sensor events will now be recorded.";
char ws_data_wake[100] = "Button = bbb; Temperature = ttt; Joystick X = xxx, Y = yyy";

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 tcp_handler
 ---------------------------------------------------------------------------*/
void ethernet_sleep_wake_handler(client interface i_ms_sensor c_sensor,
                                 chanend c_xtcp)
{
  unsigned char btn_state, temperature, j_x, j_y;
  unsigned short joystick_position;
  timer tmr;
  int sys_start_time;
  unsigned int rtc_start_time, rtc_end_time, alarm_time;

  // If just woke up fom sleep, check sleep memory for any data
  if(at_pm_memory_is_valid())
  {
    // Read server configuration from sleep memory
    at_pm_memory_read(server_config);
  }
  else
  {
    // Write server configuration to sleep memory
    at_pm_memory_write(server_config);
    at_pm_memory_validate();
  }

  // Set webserver paramters
  webclient_set_server_config(server_config);
  // Init web client
  webclient_init(c_xtcp);
  // Connect to webserver
  webclient_connect_to_server(c_xtcp);
  // Send notification to begin recording sensor data
  webclient_send_data(c_xtcp, ws_data_notify);

  tmr :> sys_start_time;
  rtc_start_time =  at_rtc_read();
  tmr when timerafter(sys_start_time + (AWAKE_TIME * 100000)) :> void;
  rtc_end_time = at_rtc_read();

  alarm_time = rtc_end_time + SLEEP_TIME;
  at_pm_set_wake_time(alarm_time);

  // Enable timer and LDR wake sources
  at_pm_enable_wake_source(RTC);
  at_pm_enable_wake_source(WAKE_PIN_HIGH);

  btn_state = c_sensor.ms_sensor_get_button_state();
  temperature = c_sensor.ms_sensor_get_temperature();
  joystick_position = c_sensor.ms_sensor_get_joystick_position();

  j_y = (unsigned char)(joystick_position & 0xFF);
  j_x = (unsigned char)((joystick_position >> 8u) & 0xFF);

  // Update string
  ws_data_wake[9] = btn_state/100 + '0';
  ws_data_wake[10] = (btn_state%100)/10 + '0';
  ws_data_wake[11] = btn_state%10 + '0';
  ws_data_wake[28] = temperature/100 + '0';
  ws_data_wake[29] = (temperature%100)/10 + '0';
  ws_data_wake[30] = temperature%10 + '0';
  ws_data_wake[46] = j_x/100 + '0';
  ws_data_wake[47] = (j_x%100)/10 + '0';
  ws_data_wake[48] = j_x%10 + '0';
  ws_data_wake[55] = j_y/100 + '0';
  ws_data_wake[56] = (j_y%100)/10 + '0';
  ws_data_wake[57] = j_y%10 + '0';

  // Send sensor data to web server
  webclient_send_data(c_xtcp, ws_data_wake);
  // Inform webserver that I am going to sleep
  webclient_send_data(c_xtcp, ws_data_sleep);
  // Close connection
  webclient_request_close(c_xtcp);
  // Sleep
  at_pm_sleep_now();
}

/*---------------------------------------------------------------------------
 main
 ---------------------------------------------------------------------------*/
int main(void)
{
  chan c_xtcp[1];
  chan c_adc;
  interface i_ms_sensor c_sensor;

  par
  {
    on ETHERNET_DEFAULT_TILE: ethernet_xtcp_server(xtcp_ports, client_ipconfig, c_xtcp, 1);
    on tile[1]: ethernet_sleep_wake_handler(c_sensor, c_xtcp[0]);
    on tile[0]: mixed_signal_slice_sensor_handler(c_sensor, c_adc, trigger_port, p_sw1);
    xs1_a_adc_service(c_adc);
  }
  return 0;
}

/*==========================================================================*/
