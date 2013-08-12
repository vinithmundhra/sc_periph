// Copyright (c) 2011, XMOS Ltd., All rights reserved
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
#include <platform.h>
#include <xs1.h>
#include <string.h>
#include <stdlib.h>
#include "webclient.h"
#include "ethernet_board_conf.h"
#include "debug_print.h"
#include "xtcp.h"
#include "analog_tile_support.h"

/*---------------------------------------------------------------------------
 constants
 ---------------------------------------------------------------------------*/
#define AWAKE_TIME 2000  //Time awake in ms
#define SLEEP_TIME 5000  //Time asleep in ms

/*---------------------------------------------------------------------------
 ports and clocks
 ---------------------------------------------------------------------------*/
on ETHERNET_DEFAULT_TILE: ethernet_xtcp_ports_t xtcp_ports = {
  OTP_PORTS_INITIALIZER,
  ETHERNET_DEFAULT_SMI_INIT,
  ETHERNET_DEFAULT_MII_INIT_lite,
  ETHERNET_DEFAULT_RESET_INTERFACE_INIT
};

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

char ws_data_sleep[100] = "Going to sleep...zzz";
char ws_data_wake[100] = "Rise and shine....";

/*---------------------------------------------------------------------------
 static variables
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 static prototypes
 ---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------
 tcp_handler
 ---------------------------------------------------------------------------*/
static void ethernet_sleep_wake_handler(chanend c_xtcp)
{
  timer tmr;
  int sys_start_time;
  unsigned int rtc_start_time, rtc_end_time, alarm_time;
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

  tmr :> sys_start_time;
  rtc_start_time =  at_rtc_read();
  tmr when timerafter(sys_start_time + (AWAKE_TIME * 100000)) :> void;
  rtc_end_time = at_rtc_read();

  alarm_time = rtc_end_time + SLEEP_TIME;
  at_pm_set_wake_time(alarm_time);
  at_pm_enable_wake_source(RTC);
  at_pm_enable_wake_source(WAKE_PIN_LOW);

  // Inform webserver that I am going to sleep
  webclient_send_data(c_xtcp, ws_data_sleep);
  // Close connection
  webclient_request_close(c_xtcp);

  at_pm_sleep_now();

}

/*---------------------------------------------------------------------------
 main
 ---------------------------------------------------------------------------*/
int main(void)
{
  chan c_xtcp[1];
  par
  {
    on ETHERNET_DEFAULT_TILE: ethernet_xtcp_server(xtcp_ports, ipconfig, c_xtcp, 1);
    on tile[1]: ethernet_sleep_wake_handler(c_xtcp[0]);
  }
  return 0;
}

/*==========================================================================*/
