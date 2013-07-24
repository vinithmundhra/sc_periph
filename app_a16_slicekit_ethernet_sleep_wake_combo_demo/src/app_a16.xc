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
#include "common.h"
#include "util.h"
#include "webclient.h"
#include "ethernet_board_conf.h"
#include "debug_print.h"
#include "xtcp.h"
#include "at_periph.h"

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

on tile[1]: out port ptemp = XS1_PORT_1D;

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

char sleep_mem[XS1_SU_NUM_GLX_PER_MEMORY_BYTE];
char ws_data_sleep[100] = "Going to Sleep...zzz";
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
static void tcp_handler(chanend c_xtcp)
{
  timer tmr;
  int sys_start_time;
  unsigned int rtc_start_time, rtc_end_time, alarm_time;
  char from_sleep = 0;

  // If just woke up fom sleep, check sleep memory for any data
  if(at_pm_memory_is_valid())
  {
    // Read server configuration from sleep memory
    at_pm_memory_read(sleep_mem);
    copy_char_array_to_server_config(server_config, sleep_mem);
    from_sleep = 1;
    ptemp <: 1;
  }
  else
  {
    // Write server configuration to sleep memory
    copy_server_config_to_char_array(server_config, sleep_mem);
    at_pm_memory_write(sleep_mem);
    at_pm_memory_set_valid(1);
    ptemp <: 1;
  }

  // Set webserver paramters and connect
  webclient_set_server_ip(server_config.server_ip);
  webclient_set_in_port(server_config.tcp_in_port);
  webclient_set_out_port(server_config.tcp_out_port);
  webclient_connect_to_server(c_xtcp);

  if(from_sleep)
  {
    // Inform webserver that I just woke up from sleep
    webclient_send_data(c_xtcp, ws_data_wake);
  }

  at_watchdog_set_timeout(0xf055);
  at_watchdog_enable();
  tmr :> sys_start_time;
  rtc_start_time =  at_rtc_read();
  tmr when timerafter(sys_start_time + (AWAKE_TIME * 100000)) :> void;
  rtc_end_time = at_rtc_read();
  at_watchdog_set_timeout(0xf055);
  at_watchdog_disable();
  alarm_time = rtc_end_time + SLEEP_TIME;
  at_pm_set_wake_time(alarm_time);
  at_pm_enable_wake_source(RTC);
  at_pm_enable_wake_source(WAKE_PIN_LOW);

  // Inform webserver that I am going to sleep
  webclient_send_data(c_xtcp, ws_data_sleep);

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
    on tile[1]: tcp_handler(c_xtcp[0]);
  }
  return 0;
}

/*==========================================================================*/
