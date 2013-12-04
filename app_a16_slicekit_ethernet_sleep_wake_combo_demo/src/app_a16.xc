#include "webclient.h"
#include "ethernet_board_conf.h"
#include "xtcp.h"
#include "analog_tile_support.h"
#include "ms_sensor.h"
#include <timer.h>

typedef struct client_data_t {
  unsigned btn_press_count;
} client_data_t;


#define AWAKE_MILLISECS 60000
#define SLEEP_MILLISECS 30000


on tile[0]: in port p_sw1 = XS1_PORT_1F;
on tile[0]: port trigger_port = PORT_ADC_TRIGGER;
on ETHERNET_DEFAULT_TILE: ethernet_xtcp_ports_t xtcp_ports = {
  OTP_PORTS_INITIALIZER,
  ETHERNET_DEFAULT_SMI_INIT,
  ETHERNET_DEFAULT_MII_INIT_lite,
  ETHERNET_DEFAULT_RESET_INTERFACE_INIT
};

xtcp_ipconfig_t client_ipconfig = {
  {169, 254, 202, 190},
  {255, 255, 0, 0},
  {0, 0, 0, 0}
};

server_config_t server_config = {
  {169, 254, 202, 189},
  80,
  80
};

client_data_t client_data = { 0 };

char ws_data_sleep[] = "Going to sleep.\n";
char ws_data_notify[] = "Program running! Sensor events will now be recorded.\n";
char ws_data_wake[] = "Button = bbb; Temperature = ttt; Joystick X = xxx, Y = yyy\n";

/*---------------------------------------------------------------------------
 ethernet_sleep_wake_handler
 ---------------------------------------------------------------------------*/
void ethernet_sleep_wake_handler(chanend c_sensor, chanend c_xtcp)
{
  timer tmr;
  unsigned int sys_start_time, alarm_time;
  sensor_data_t sensor_data;
  char fresh_start = 1;

  // If just woke up fom sleep, check sleep memory for any data
  if(at_pm_memory_is_valid())
  {
    // Read server configuration from sleep memory
    at_pm_memory_read(client_data);
    fresh_start = 0;
  }

  // Reset the RTC
  at_rtc_reset();
  // Enable wake pin
  at_pm_enable_wake_source(WAKE_PIN_HIGH);
  // Enable timer and LDR wake sources
  at_pm_enable_wake_source(RTC);
  // Delay for some time to start web server on the host computer
  if(fresh_start) delay_seconds(10);
  // Set webserver paramters
  webclient_set_server_config(server_config);
  // Init web client
  webclient_init(c_xtcp);
  // Connect to webserver
  webclient_connect_to_server(c_xtcp);
  // Send notification to begin recording sensor data
  webclient_send_data(c_xtcp, ws_data_notify);
  // Connected to server. The sensor handler can now begin to record data.
  c_sensor <: 1;

  tmr :> sys_start_time;

  while(1)
  {
    select
    {
      case tmr when timerafter(sys_start_time + (AWAKE_MILLISECS * 100000)) :> void:
      {
        // Inform webserver that I am going to sleep
        webclient_send_data(c_xtcp, ws_data_sleep);
        // Close connection
        webclient_request_close(c_xtcp);

        // Store the current client status to sleep memory
        client_data.btn_press_count += sensor_data.btn_press_count;
        at_pm_memory_write(client_data);
        at_pm_memory_validate();

        // Set up time for timer wake up
        alarm_time = at_rtc_read() + SLEEP_MILLISECS;
        at_pm_set_wake_time(alarm_time);
        // Sleep
        at_pm_sleep_now();
        break;
      } //case timer

      case ms_sensor_data_changed(c_sensor, sensor_data):
      {
        unsigned btn_press_count = sensor_data.btn_press_count + client_data.btn_press_count;

        // Update string
        ws_data_wake[9] = btn_press_count/100 + '0';
        ws_data_wake[10] = (btn_press_count%100)/10 + '0';
        ws_data_wake[11] = btn_press_count%10 + '0';
        ws_data_wake[28] = sensor_data.temperature/100 + '0';
        ws_data_wake[29] = (sensor_data.temperature%100)/10 + '0';
        ws_data_wake[30] = sensor_data.temperature%10 + '0';
        ws_data_wake[46] = sensor_data.joystick_x/100 + '0';
        ws_data_wake[47] = (sensor_data.joystick_x%100)/10 + '0';
        ws_data_wake[48] = sensor_data.joystick_x%10 + '0';
        ws_data_wake[55] = sensor_data.joystick_y/100 + '0';
        ws_data_wake[56] = (sensor_data.joystick_y%100)/10 + '0';
        ws_data_wake[57] = sensor_data.joystick_y%10 + '0';
        // Send sensor data to web server
        webclient_send_data(c_xtcp, ws_data_wake);
        break;
      } // case ms_sensor_data_changed
    } //select
  } //while(1)
}

/*---------------------------------------------------------------------------
 main
 ---------------------------------------------------------------------------*/
int main(void)
{
  chan c_xtcp[1], c_adc, c_sensor;

  par
  {
    on ETHERNET_DEFAULT_TILE: ethernet_xtcp_server(xtcp_ports, client_ipconfig, c_xtcp, 1);
    on tile[1]: ethernet_sleep_wake_handler(c_sensor, c_xtcp[0]);
    on tile[0]: mixed_signal_slice_sensor_handler(c_sensor, c_adc, trigger_port, p_sw1);
    xs1_a_adc_service(c_adc);
  } // par
  return 0;
}
