#include "at_periph.h"
#include "debug_print.h"


static unsigned int convert_ms_to_ticks (unsigned int milliseconds){
  unsigned int read_val_32;
  unsigned long long ticks;
  read_node_config_reg(xs1_su_periph, XS1_SU_CFG_SYS_CLK_FREQ_NUM, read_val_32);
  read_val_32 = XS1_SU_CFG_SYS_CLK_FREQ(read_val_32);   //Mask off upper bits
  ticks = (unsigned long long) milliseconds * (unsigned long long) read_val_32 * 1000;
  return ticks;
}
static unsigned int convert_ticks_to_ms (unsigned long long ticks){
  unsigned int read_val_32;
  unsigned int milliseconds;
  read_node_config_reg(xs1_su_periph, XS1_SU_CFG_SYS_CLK_FREQ_NUM, read_val_32);
  read_val_32 = XS1_SU_CFG_SYS_CLK_FREQ(read_val_32);   //Mask off upper bits
  milliseconds = (unsigned int) (ticks / (1000 * read_val_32));
  return milliseconds;
}


//128B deep sleep memory access
void at_pm_memory_read_impl(unsigned char data[], unsigned char size){
  if (size > XS1_SU_NUM_GLX_PER_MEMORY_BYTE); //TODO
  read_periph_8 (xs1_su_periph, XS1_SU_PER_MEMORY_CHANEND_NUM, XS1_SU_PER_MEMORY_BYTE_0_NUM,
      size, data);
}
void at_pm_memory_write_impl(unsigned char data[], unsigned char size){
  write_periph_8 (xs1_su_periph, XS1_SU_PER_MEMORY_CHANEND_NUM, XS1_SU_PER_MEMORY_BYTE_0_NUM,
      size, data);
}

char at_pm_memory_is_valid(void){
  char val[1];
  read_periph_8 (xs1_su_periph, XS1_SU_PER_MEMORY_CHANEND_NUM, XS1_SU_PER_MEMORY_VALID_NUM, 1, val);
  return val[0];
}
void at_pm_memory_set_valid(char isvalid){
  char val[1];
  if (isvalid) val[0] = 0xed; //magic value for valid
  else val[0] = 0x00;        //magic value for invalid
  write_periph_8 (xs1_su_periph, XS1_SU_PER_MEMORY_CHANEND_NUM, XS1_SU_PER_MEMORY_VALID_NUM, 1, val);
}


//Sleep and wake control
void at_pm_enable_wake_source(wake_sources_t wake_source){
  unsigned int write_val;
  read_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_MISC_CTRL_NUM, 1, &write_val);
  switch (wake_source){
    case RTC:
      write_val = XS1_SU_PWR_TMR_WAKEUP_64_SET(write_val, 1);   //Set timer to 64b mode
      write_val = XS1_SU_PWR_SLEEP_CLK_SEL_SET(write_val, 0);   //Use 31KHz source as clock for timer
      write_val = XS1_SU_PWR_TMR_WAKEUP_EN_SET(write_val, 1);   //Enable timer wake
      break;

    case WAKE_PIN_LOW:
      write_val = XS1_SU_PWR_PIN_WAKEUP_EN_SET(write_val, 1);   //Enable pin wake
      write_val = XS1_SU_PWR_PIN_WAKEUP_ON_SET(write_val, 0);   //Wake on low level
      break;

    case WAKE_PIN_HIGH:
      write_val = XS1_SU_PWR_PIN_WAKEUP_EN_SET(write_val, 1);   //Disable pin wake
      write_val = XS1_SU_PWR_PIN_WAKEUP_ON_SET(write_val, 1);   //Wake on high level
      break;

    case USB_RESUME:
      write_val = XS1_SU_PWR_USB_PU_EN_SET(write_val, 1);       //Enable USB resume wake
      break;
  }
//  debug_printf("Wrting value to power control reg = 0x%x\n", write_val);
  write_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_MISC_CTRL_NUM, 1, &write_val);
}
void at_pm_disable_wake_source(wake_sources_t wake_source)
{
  unsigned int write_val;
  read_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_MISC_CTRL_NUM, 1, &write_val);
  switch (wake_source){
    case RTC:
      write_val = XS1_SU_PWR_TMR_WAKEUP_64_SET(write_val, 1);   //Set timer to 64b mode
      write_val = XS1_SU_PWR_SLEEP_CLK_SEL_SET(write_val, 0);   //Use 31KHz source as clock for timer
      write_val = XS1_SU_PWR_TMR_WAKEUP_EN_SET(write_val, 0);   //Disable timer wake
      break;

    case WAKE_PIN_LOW:
      write_val = XS1_SU_PWR_PIN_WAKEUP_EN_SET(write_val, 0);   //Disable pin wake
      write_val = XS1_SU_PWR_PIN_WAKEUP_ON_SET(write_val, 0);   //Wake on low level
      break;

    case WAKE_PIN_HIGH:
      write_val = XS1_SU_PWR_PIN_WAKEUP_EN_SET(write_val, 0);   //Disable pin wake
      write_val = XS1_SU_PWR_PIN_WAKEUP_ON_SET(write_val, 1);   //Wake on high level
      break;

    case USB_RESUME:
      write_val = XS1_SU_PWR_USB_PU_EN_SET(write_val, 0);       //Disable USB resume wake
      break;
  }
//  debug_printf("Wrting value to power control reg = 0x%x\n", write_val);
  write_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_MISC_CTRL_NUM, 1, &write_val);
}

void at_pm_set_wake_time(unsigned int alarm_time){
  unsigned int write_val[2];
  unsigned long long alarm_ticks;
  alarm_ticks = convert_ms_to_ticks(alarm_time);
  write_val[0] = alarm_ticks & 0xFFFFFFFF;
  write_val[1] = alarm_ticks >> 32;
  debug_printf("wake_at[1..0]  is 0x%x, 0x%x\n", write_val[1], write_val[0]);
  write_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_WAKEUP_TMR_LWR_NUM, 2, write_val);
}

void at_pm_sleep_now(void){
  unsigned char write_val, osc_good = 0;
  unsigned int read_val_32, write_val_32;

  //Setup 20MHz on chip oscilator
  write_val = XS1_SU_GEN_OSC_SEL_SET(0, 1);              //Ensure Si OSC is enabled
  write_val = XS1_SU_GEN_OSC_RST_EN_SET(write_val, 0);   //Select 20MHz osc
  write_periph_8(xs1_su_periph, XS1_SU_PER_OSC_CHANEND_NUM, XS1_SU_PER_OSC_ON_SI_CTRL_NUM, 1, &write_val);

  //wait until oscillator is stable
  while (!osc_good){
    read_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_PMU_DBG_NUM, 1, &read_val_32);
    osc_good = XS1_SU_PWR_ON_SI_STBL(read_val_32);
  }

  //Switch to silicon oscilator
  write_val = XS1_SU_GEN_OSC_RST_EN_SET(0, 0);           //Disable reset on clock change
  write_val = XS1_SU_GEN_OSC_SEL_SET(write_val, 1);      //Switch to silicon oscialtor
  write_periph_8(xs1_su_periph, XS1_SU_PER_OSC_CHANEND_NUM, XS1_SU_PER_OSC_GEN_CTRL_NUM, 1, &write_val);

  //Disable XTAL bias and oscillator
  write_val = XS1_SU_XTAL_OSC_EN_SET(0, 0);              //Switch off crysal oscillator
  write_val = XS1_SU_XTAL_OSC_BIAS_EN_SET(write_val, 0); //Disable crystal bias circuit
  write_periph_8(xs1_su_periph, XS1_SU_PER_OSC_CHANEND_NUM, XS1_SU_PER_OSC_XTAL_CTRL_NUM, 1, &write_val);

  //Disable all supplies except DC-DC2 (peripheral tile supply)
  write_val_32 = XS1_SU_PWR_WAKEUP_TMR_LWR_SET(0, 8);           //set to 256 cycles min time asleep
  write_val_32 = XS1_SU_PWR_WAKEUP_TMR_UPR_SET(write_val_32, 0);//set to 256 cycles min time asleep
  write_val_32 = XS1_SU_PWR_EXT_CLK_MASK_SET(write_val_32, 0);  //Disable xCore clock
  write_val_32 = XS1_SU_PWR_VOUT1_EN_SET(write_val_32, 0);      //Disable DC-DC1
  write_val_32 = XS1_SU_PWR_VOUT1_MOD_SET(write_val_32, 0);     //Set to PWM mode
  write_val_32 = XS1_SU_PWR_VOUT2_EN_SET(write_val_32, 1);      //Enable DC-DC2
  write_val_32 = XS1_SU_PWR_VOUT2_MOD_SET(write_val_32, 1);     //Set to PFM mode
  write_val_32 = XS1_SU_PWR_VOUT5_EN_SET(write_val_32, 0);      //Disable LDO5
  write_val_32 = XS1_SU_PWR_VOUT6_EN_SET(write_val_32, 0);      //Disable LDO6
  write_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_STATE_ASLEEP_NUM, 1, &write_val_32);

  //go to sleep
  read_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_MISC_CTRL_NUM, 1, &write_val_32);
  write_val_32 = XS1_SU_PWR_SLEEP_INIT_SET(write_val_32, 1);    //Initiate sleep bit
  write_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_MISC_CTRL_NUM, 1, &write_val_32);
}

void at_pm_set_min_sleep_time(unsigned int min_sleep_time){
  int write_val_32;
  unsigned int calc, bit_posn = 0;
  calc = ((min_sleep_time * SI_OSCILLATOR_FREQ_31K) / 1000); //sleep time in 31KHz sleep clock ticks
  for (int i = 0; i < 32; i++) if ((calc >> i) & 0x1) bit_posn = i; //perform an approximate log2 calculation
  read_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_STATE_ASLEEP_NUM, 1, &write_val_32);
  write_val_32 = XS1_SU_PWR_INT_EXP_SET(write_val_32, bit_posn);
  write_periph_32(xs1_su_periph, XS1_SU_PER_PWR_CHANEND_NUM, XS1_SU_PER_PWR_STATE_ASLEEP_NUM, 1, &write_val_32);
}


//RTC
unsigned int at_rtc_read(void){
  unsigned int time_now[2] = {0, 0};
  unsigned long long ticks;
  read_periph_32(xs1_su_periph, XS1_SU_PER_RTC_CHANEND_NUM, XS1_SU_PER_RTC_LWR_32BIT_NUM, 2, time_now);
  debug_printf("ticks_now[1..0] is 0x%x, 0x%x\n", time_now[1], time_now[0]);
  ticks = (unsigned long long) ((time_now[1] * 0x100000000) + time_now[0]);
  return convert_ticks_to_ms(ticks);
}

void at_rtc_clear(void){
  unsigned int time_now[2] = {0, 0};
  write_periph_32(xs1_su_periph, XS1_SU_PER_RTC_CHANEND_NUM, XS1_SU_PER_RTC_LWR_32BIT_NUM, 2, time_now);
}


//Watchdog timer
void at_watchdog_enable(void){
  unsigned int write_val = 0x00000000; //Magic value ie. not 0x0D15AB1E
  write_node_config_reg(xs1_su_periph, XS1_SU_CFG_WDOG_DISABLE_NUM, write_val);
}

void at_watchdog_disable(void){
  unsigned int write_val = 0x0D15AB1E; //Magic value to disable
  write_node_config_reg(xs1_su_periph, XS1_SU_CFG_WDOG_DISABLE_NUM, write_val);
}


void at_watchdog_set_timeout(unsigned short milliseconds){
  unsigned int write_val;
  unsigned int read_val;
  write_val = milliseconds | (~milliseconds << 16); //Set upper 16b to 1's complement of lower
                                                    //This is the 'password' for accessing reg

  read_node_config_reg(xs1_su_periph, XS1_SU_CFG_WDOG_TMR_NUM, read_val);
  debug_printf("WDT timer before timeout write=%u\n", XS1_SU_CFG_WDOG_TMR(read_val));

  write_node_config_reg(xs1_su_periph, XS1_SU_CFG_WDOG_TMR_NUM, write_val); //write expiry value

  read_node_config_reg(xs1_su_periph, XS1_SU_CFG_WDOG_TMR_NUM, read_val);
  debug_printf("WDT timer after timeout write=%u\n", XS1_SU_CFG_WDOG_TMR(read_val));

}
unsigned short at_watchdog_kick(void){
  unsigned short expiry_val, wdt_timer;
  unsigned int write_val, read_val;
  read_node_config_reg(xs1_su_periph, XS1_SU_CFG_WDOG_TMR_NUM, read_val);    //Get current expiry value & timer
  expiry_val = (unsigned short) XS1_SU_CFG_WDOG_EXP(read_val);               //mask off expiry value
  write_val =  (unsigned int) expiry_val | (~(unsigned int)expiry_val << 16);//Set the password in upper 16b
  wdt_timer = (unsigned short) XS1_SU_CFG_WDOG_TMR(read_val);                //mask off and shift timer value
  write_node_config_reg(xs1_su_periph, XS1_SU_CFG_WDOG_TMR_NUM, write_val);  //rewrite expiry value to reset timer
  return wdt_timer;                                                          //return wdt value
}
