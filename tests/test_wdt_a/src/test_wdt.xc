#include "at_periph.h"
#include "debug_print.h"


void init_sleep_mem(char write_val, char memory[], unsigned char size ){
  for (unsigned i = 0; i < size; i++){
    memory[i] = write_val;
  }
}

void sleep_demo(void){

  timer tmr;
  int sys_start_time;
  unsigned int rtc_start_time, rtc_end_time, alarm_time;
  int my_sleep_mem[XS1_SU_NUM_GLX_PER_MEMORY_BYTE/4], my_sleep_mem2[XS1_SU_NUM_GLX_PER_MEMORY_BYTE/4];
  init_sleep_mem(0xed, (my_sleep_mem, char[]), sizeof(my_sleep_mem));
  init_sleep_mem(0x00, (my_sleep_mem2, char[]), sizeof(my_sleep_mem2));

  struct save_this{
    int foo;
    char bar;
    long long something;
  };


  at_pm_memory_write(my_sleep_mem);
  at_pm_memory_read(my_sleep_mem2);

  at_watchdog_set_timeout(0xf055);
  at_watchdog_enable();
  debug_printf("Sleep demo started, and I'm currently awake\n");

  at_rtc_clear();

  tmr :> sys_start_time;
  rtc_start_time =  at_rtc_read();
  debug_printf("RTC time now = %u ms\n", rtc_start_time);
  tmr when timerafter(sys_start_time + (AWAKE_TIME * 100000)) :> void;
  rtc_end_time = at_rtc_read();

  at_pm_set_min_sleep_time(150); //Set min sleep period to about 150ms

  at_watchdog_set_timeout(0xf055);
  at_watchdog_disable();

  debug_printf("RTC elapsed time measured in %ums = %ums\n", AWAKE_TIME, rtc_end_time-rtc_start_time);

  alarm_time = rtc_end_time + SLEEP_TIME;
  debug_printf("RTC time now = %u ms\n", rtc_end_time);
  debug_printf("Going to sleep now for %u ms, alarm time = %ums\n", SLEEP_TIME, alarm_time);

  at_pm_set_wake_time(alarm_time);

  at_pm_enable_wake_source(RTC);
  at_pm_enable_wake_source(WAKE_PIN_HIGH);
  at_pm_sleep_now();
}


void something(void){
   while(0);
}

int main (void)
{
  par{
    sleep_demo();
    something();
  }
  return 0;
}
/* what about this in sleep??? from test code
 *
 *
   // Reconfig the X-Link delays to slow the link down
#if ( defined XVBGX1 )
   write_sswitch_reg_noresp(MYID, XS1_SSWITCH_XLINK_3_NUM, ( 0x3 << 30
| (1023 << 11) | 2047 ) );
#elif ( defined MCM ) || ( defined XVBS1 ) || ( defined XVBA1 )
   write_sswitch_reg_noresp(MYID, XS1_SSWITCH_XLINK_5_NUM, ( 0x3 << 30
| (1023 << 11) | 2047 ) );
#else
   write_sswitch_reg_noresp(MYID, XS1_SSWITCH_XLINK_7_NUM, ( 0x3 << 30
| (1023 << 11) | 2047 ) );
#endif

*/

