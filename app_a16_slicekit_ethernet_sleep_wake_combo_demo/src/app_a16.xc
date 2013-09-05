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
#include <xscope.h>
#include <print.h>
#include "webclient.h"
#include "ethernet_board_conf.h"
#include "xtcp.h"
#include "analog_tile_support.h"
#include "ms_sensor.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define AWAKE_TIME 20000  //Time awake in ms
#define SLEEP_TIME 50000  //Time asleep in ms

#define WAKE_SOURCE_TIMER   1
#define WAKE_SOURCE_LDR     1

#define DELAY 100000000000
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
xtcp_ipconfig_t ipconfig = {
  {0, 0, 0, 0},
  {0, 0, 0, 0},
  {0, 0, 0, 0}
};

server_config_t server_config = {
  {169, 254, 202, 189},
  500,
  501
};

char ws_data_sleep[100] = "Going to sleep.";
char ws_data_wake[100] = "Wake from sleep.";

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
#if 0
  char from_sleep = 0;

  // If just woke up fom sleep, check sleep memory for any data
  if(at_pm_memory_is_valid())
  {
    // Read server configuration from sleep memory
    at_pm_memory_read(server_config);
    from_sleep = 1;
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

  if(from_sleep)
  {
    // Inform webserver that I just woke up from sleep
    webclient_send_data(c_xtcp, ws_data_wake);
  }

#if WAKE_SOURCE_TIMER

  timer tmr;
  int sys_start_time;
  unsigned int rtc_start_time, rtc_end_time, alarm_time;

  tmr :> sys_start_time;
  rtc_start_time =  at_rtc_read();
  tmr when timerafter(sys_start_time + (AWAKE_TIME * 100000)) :> void;
  rtc_end_time = at_rtc_read();

  alarm_time = rtc_end_time + SLEEP_TIME;
  at_pm_set_wake_time(alarm_time);
  at_pm_enable_wake_source(RTC);

#endif // #if WAKE_SOURCE_TIMER

#if WAKE_SOURCE_LDR

  at_pm_enable_wake_source(WAKE_PIN_HIGH);

#endif // #if WAKE_SOURCE_LDR

  // Inform webserver that I am going to sleep
  webclient_send_data(c_xtcp, ws_data_sleep);
  // Close connection
  webclient_request_close(c_xtcp);

  at_pm_sleep_now();
#endif

  int x;
  unsigned time;
  timer t;


  while(1)
  {
    x = c_sensor.ms_sensor_get_button_state();
    printstr("Button state = "); printintln(x);
    x = c_sensor.ms_sensor_get_temperature();
    printstr("Temperature = "); printintln(x);
    x = c_sensor.ms_sensor_get_joystick_position();
    printstr("Joystick = "); printintln(x);
    printstrln("=============================");

    t :> time;
    t when timerafter (time + DELAY) :> void;
  }
}

/*---------------------------------------------------------------------------
 xscope init
 ---------------------------------------------------------------------------*/
void xscope_user_init(void) {
   xscope_register(0, 0, "", 0, "");
   xscope_config_io(XSCOPE_IO_BASIC);
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
    on ETHERNET_DEFAULT_TILE: ethernet_xtcp_server(xtcp_ports, ipconfig, c_xtcp, 1);
    on tile[0]: ethernet_sleep_wake_handler(c_sensor, c_xtcp[0]);
    on tile[0]: mixed_signal_slice_sensor_handler(c_sensor, c_adc, trigger_port, p_sw1);
    xs1_a_adc_service(c_adc);
  }
  return 0;
}

/*==========================================================================*/
