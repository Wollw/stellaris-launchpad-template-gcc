/*
 * Code taken from:
 * http://recursive-labs.com/blog/2012/10/28/stellaris-launchpad-gnu-linux-getting-started/
 */

#include <inc/hw_gpio.h>
#include <inc/hw_memmap.h>
#include <inc/hw_sysctl.h>
#include <inc/hw_types.h>
#include <driverlib/gpio.h>
#include <driverlib/rom.h>
#include <driverlib/sysctl.h>

#define LED_RED GPIO_PIN_1
#define LED_BLUE GPIO_PIN_2
#define LED_GREEN GPIO_PIN_3

int main() {
    /* Set clock to 80MHz */
    ROM_SysCtlClockSet(
            SYSCTL_SYSDIV_2_5
           |SYSCTL_USE_PLL
           |SYSCTL_XTAL_16MHZ
           |SYSCTL_OSC_MAIN
    );

    /* Enabled LED pins as outputs */
    ROM_SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
    ROM_GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, LED_RED|LED_BLUE|LED_GREEN);

    for (;;) {
        // Alternate the blue and red LEDs
        ROM_GPIOPinWrite(GPIO_PORTF_BASE, LED_RED|LED_GREEN|LED_BLUE, LED_BLUE);
        ROM_SysCtlDelay(10000000);
        ROM_GPIOPinWrite(GPIO_PORTF_BASE, LED_RED|LED_GREEN|LED_BLUE, LED_RED);
        ROM_SysCtlDelay(10000000);
    }
}
