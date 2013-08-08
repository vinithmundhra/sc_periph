#include <xscope.h>
#include "analog_tile_support.h"
#include "pwm_tutorial_example.h"
#include "debug_print.h"

#define LOOP_PERIOD     10000000 // 100ms for printing and ADC trigger
#define PWM_PERIOD           200 // Set PWM period to 2us, 500KHz

#define pwm_duty_calc(x) ((x * PWM_PERIOD) >> 8) //duty calc, 255 = full scale

//Port and clock definitions
//Note that these assume use of XP-SKC-U16 + XA-SK-MIXED-SIGNAL hardware
on tile[0]: port trigger_port = PORT_ADC_TRIGGER; //Port 1I, D24
on tile[0]: port pwm_dac_port = XS1_PORT_1G;      //D22
on tile[0]: clock cl = XS1_CLKBLK_2;

void xscope_user_init(void) {
   xscope_register(2,
           XSCOPE_CONTINUOUS, "Joystick ADC",
           XSCOPE_UINT, "8b value",
           XSCOPE_CONTINUOUS, "Header ADC",
           XSCOPE_UINT, "8b value");
   xscope_config_io(XSCOPE_IO_BASIC);
}

void adc_pwm_dac_example(chanend c_adc, chanend c_pwm_dac)
{
    timer        loop_timer;
    unsigned int loop_time;
    unsigned data[2]; //Array for storing ADC results

    unsigned char joystick, header, header_old; //ADC values

    debug_printf("Analog loopback demo started.\n");

    at_adc_config_t adc_config = { { 0, 0, 0, 0, 0, 0, 0, 0 }, 0, 0, 0 };
    adc_config.input_enable[4] = 1; //Input 4 is an analog input on header
    adc_config.input_enable[2] = 1; //Input 2 is one axis of the joystick
    adc_config.bits_per_sample = ADC_8_BPS;
    adc_config.samples_per_packet = 2;
    adc_config.calibration_mode = 0;

    at_adc_enable(usb_tile, c_adc, trigger_port, adc_config);

    c_pwm_dac <: PWM_PERIOD;         //Set PWM period
    c_pwm_dac <: pwm_duty_calc(0);   //Set initial duty cycle

    loop_timer :> loop_time;         //Set timer for first loop tick
    loop_time += LOOP_PERIOD;

    at_adc_trigger_packet(trigger_port, adc_config); //Fire the ADC!

    while (1)
    {
        select
        {
            case loop_timer when timerafter(loop_time) :> void:
                if (header != header_old){ //only do if something has changed
                    debug_printf("ADC joystick : %u\t", joystick);
                    debug_printf("ADC header : %u\r", header);
                    header_old = header;
                    xscope_probe_data(0, joystick);
                    xscope_probe_data(1, header);
                }
                c_pwm_dac <: pwm_duty_calc((unsigned int)joystick); //send to PWM
                at_adc_trigger_packet(trigger_port, adc_config);    //Trigger ADC
                loop_time += LOOP_PERIOD;
                break;

            case at_adc_read_packet(c_adc, adc_config, data):
                joystick = data[0]; //First value in packet
                header = data[1];   //Second value in packet
                break;
        }
    }
}

int main()
{
    chan c_adc, c_pwm_dac;

    par {
        on tile[0]: adc_pwm_dac_example(c_adc, c_pwm_dac);
        on tile[0]: pwm_tutorial_example ( c_pwm_dac, pwm_dac_port, 1);
        xs1_su_adc_service(c_adc);
    }
    return 0;
}

