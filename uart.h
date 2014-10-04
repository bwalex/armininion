#ifndef _UART_H
#define _UART_H
void uart_write(const char *);
void uart_putc(int cc, void *arg);

static inline int putchar(int c)
{
	uart_putc(c, NULL);
	return c;
}
#endif
