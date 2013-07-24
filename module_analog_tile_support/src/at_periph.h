#ifndef AT_PERIPH_H_
#define AT_PERIPH_H_

#include <xs1_su_registers.h>
#include <platform.h>

//Macro to allow arbitrary struct/array to be passed to sleep mem functions
//Uses XC cast (x, y) operation
#define at_pm_memory_read(x) at_pm_memory_read_impl((x, char[]), sizeof(x))
#define at_pm_memory_write(x) at_pm_memory_write_impl((x, char[]), sizeof(x))

//Speed of 31KHz silicon oscialtor (approx)
#define SI_OSCILLATOR_FREQ_31K 31250

/** Enumerated type containing possible wake sources from sleep mode
 *
 * Each source type can be enabled or disabled.
 * RTC and WAKE_PIN_x may be used together however,
 * WAKE_PIN_LOW or HIGH are mutually exclusive. Ie. enabling wake
 * on WAKE_PIN_LOW will disable WAKE_PIN_HIGH
 */
typedef enum  {
RTC,
WAKE_PIN_LOW,
WAKE_PIN_HIGH} wake_sources_t;

//////////128B deep sleep memory access. See above macro for user API//////////

/** Function that writes an array of size up to 128B to sleep memory.
 * Note, for types other than char[], please use above macro
 *
 * \param reference to the charater array to be written
 *
 * \param size of array to be written in bytes
 */
void at_pm_memory_read_impl(char data[], unsigned char size);

/** Function that reads an array of size up to 128B from sleep memory.
 * Note, to pass types other than char[], please use above macro
 *
 * \param reference to the charater array to be written
 *
 * \param size of array to be written in bytes
 */
void at_pm_memory_write_impl(char dara[], unsigned char size);

/** Function that test to see if the deep sleep memory contents are valid.
 *  Use before reading sleep memory to see if it has been previously initialised.
 *  Note that the chip initialises this to zero on reset.
 *
 * \returns boolean result. 1 = Valid, 0 = Invalid.
 */
char at_pm_memory_is_valid(void);

/** Function that sets the validity of the sleep memory
 * Use only after a write to sleep memory to set as valid.
 *  Note that the defaults to invalid on reset.
 *
 * \param boolean status.  1 = Valid, 0 = Invalid.
 */
void at_pm_memory_set_validation(char isvalid);

//////////Sleep and wake control//////////

/** Function that enables the chip to be woken by specific sources
 * Each wake source type can be enabled or disabled.
 * RTC and WAKE_PIN_x may be used together however,
 * WAKE_PIN_LOW or HIGH are mutually exclusive. Ie. enabling wake
 * on WAKE_PIN_LOW will disable WAKE_PIN_HIGH and vice versa.
 *
 * \param enumerated type wake_sources_t specifying wake source to enable
 */
void at_pm_enable_wake_source(wake_sources_t wake_source);

/** Function that disables the chip to be woken by specific sources
 * Each wake source type can be enabled or disabled.
 * Disabling either WAKE_PIN_LOW or WAKE_PIN_HIGH will have the same
 * effect of diabling wake from pin
 *
 * \param enumerated type wake_sources_t specifying wake source to disable
 */
void at_pm_disable_wake_source(wake_sources_t wake_source);

/** Function that sets the wake time in milliseconds, measured by the RTC clock.
 * It is recommended to reset the RTC before setting the wake time
 * to avoid issues with overflow if the application has been running
 * for some time before.
 * The time may be up to about 4E6 seconds from reset, or approx 48 days
 * before overflow occurs.
 *
 * \param time to set alarm/wake up in milliseconds
 */
void at_pm_set_wake_time(unsigned int alarm_time);

/** Function that sets the minimum time to stay asleep in milliseconds.
 * Default time on power up is 2^16 sleep clocks, or about 2s.
 * Note this function truncates to the value to the nearest
 * power of 2, so is +100% - 50% accurate, due to hardware.
 * This value is not critical but can be used to ignore pin events until
 * a certain time.
 *
 * \param time to set alarm/wake up in milliseconds
 */
void at_pm_set_min_sleep_time(unsigned int min_sleep_time);

/** Function that instructs the chip to go to sleep immediately.
 * Sleep is a very deep state that switches off everything except
 * the RTC and deep sleep memory, so the application should have exited
 * gracefully before this function is called, including all peripheral functions.
 * This must be the last function to be called before sleep. When waking, the
 * chip will go through the reset sequence. Use deep sleep memory to
 * steer the application at boot time, to recover from sleep, and determine state.
 *
 */
void at_pm_sleep_now(void);

//////////RTC (real time clock)//////////

/** Function that reads the rtc value.
 * Takes the counter and scales to milliseconds.
 * The time may be up to about 4E6 seconds from reset, or approx 48 days
 * before overflow occurs.
 *
 * \returns time in milliseconds.
 */
unsigned int at_rtc_read(void);

/** Function that clears the rtc value.
 * Sets the time to zero.
 */
void at_rtc_reset(void);


//////////Watchdog timer//////////

/** Function that enables the watchdog timer. On overflow, it reset the xCORE
 * tile only. The analog tile is not reset.
 * By default, the WDT is disabled by the chip.
 */
void at_watchdog_enable(void);

/** Function that disables the watchdog timer.
 * By default, the WDT is disabled by the chip.
 *
 */
void at_watchdog_disable(void);

/** Function that sets the overflow time in milliseconds, from now.
 * Calling this function will automatically clear the WDT and start counting from zero ms.
 * It is a 16b counter which allows up to 65535 milliseconds, or about 65 seconds.
 *
 * \param watchdog overflow time in milliseconds
 */
void at_watchdog_set_timeout(unsigned short milliseconds);

/** Function that kicks the watchdog timer, Ie. sets it counting from zero.
 * This function should be periodically called to prevent overflow and system reset, during
 * normal operation.
 * It returns the current time in the watchdog timer, to allow the application to see
 * how close it is to a reset caused by WDT overflow
 *
 * \returns WDT time in milliseconds.
 */
unsigned short at_watchdog_kick(void);


#endif /* AT_PERIPH_H_ */
