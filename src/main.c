#include <stdio.h>
#include <avr/io.h>
#include <util/delay.h>

static int uart_putchar(char c, FILE *stream) {
	if (c == '\n') uart_putchar('\r', stream);
	loop_until_bit_is_set(UCSR0A, UDRE0);
	UDR0 = c;
	return 0;
}

static FILE serialout = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

#define BLINK_DELAY_MS 1000
 
int main (void)
{
	int count = 0;

	stdout = &serialout;

	/* set pin 5 of PORTB for output*/
	DDRB |= _BV(DDB5);

	while(1) {
		printf("count: %d\n", count++);

		/* set pin 5 high to turn led on */
		PORTB |= _BV(PORTB5);
		_delay_ms(BLINK_DELAY_MS);

		/* set pin 5 low to turn led off */
		PORTB &= ~_BV(PORTB5);
		_delay_ms(BLINK_DELAY_MS);
	}
}
