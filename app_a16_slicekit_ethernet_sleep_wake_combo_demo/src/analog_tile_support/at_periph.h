#ifndef AT_PERIPH_H_
#define AT_PERIPH_H_

#include <xs1_su_registers.h>
#include <platform.h>

//Macro to allow arbitrary struct/array to be passed to sleep mem functions, using XC cast (x, y)
#define at_pm_memory_read(x) at_pm_memory_read_impl((x, char[]), sizeof(x))
//#define at_pm_memory_write(x) at_pm_memory_write_impl((char *) &x, sizeof(x))
#define at_pm_memory_write(x) at_pm_memory_write_impl((x, char[]), sizeof(x))

#define SI_OSCILLATOR_FREQ_31K 31250

typedef enum  {
SILICON_OSCILLATOR_20M,
SILICON_OSCILLATOR_31K,
CRYSTAL_OSCILLATOR,
EXTERNAL_OSCILLATOR} osc_sources_t;

typedef enum  {
USB_RESUME,
RTC,
WAKE_PIN_LOW,
WAKE_PIN_HIGH} wake_sources_t;

//128B deep sleep memory access. See above macro for user API
void at_pm_memory_read_impl(char data[], unsigned char size);
//void at_pm_memory_write_impl(char * data, unsigned char size);
void at_pm_memory_write_impl(char dara[], unsigned char size);

char at_pm_memory_is_valid(void);
void at_pm_memory_set_valid(char isvalid);

//Sleep and wake control
void at_pm_enable_wake_source(wake_sources_t wake_source);
void at_pm_disable_wake_source(wake_sources_t wake_source);
void at_pm_set_wake_time(unsigned int alarm_time);
void at_pm_set_min_sleep_time(unsigned int min_sleep_time);
void at_pm_sleep_now(void);

//RTC (real time clock)
unsigned int at_rtc_read(void);
void at_rtc_clear(void);

//General power saving options
void at_pm_sswitch_prescaler (int prescaler);
void at_pm_xcore_voltage_set(unsigned int millivolts); //could use RTC clock rather than global timer


//Watchdog timer
void at_watchdog_enable(void);
void at_watchdog_disable(void);
void at_watchdog_set_timeout(unsigned short milliseconds);
unsigned short at_watchdog_kick(void);


#endif /* AT_PERIPH_H_ */
