#include "subr.h"

void hi_there(void)
{
	uart_write("Hi there!\n");
}

void kern(void)
{
	uart_write("moo\n");
	kprintf("Hello from C, %s\n", "mate");
	hi_there();
	return;
}
