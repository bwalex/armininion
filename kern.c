void hi_there(void)
{
	uart_write("Hi there!\n");
}

void kern(void)
{
	uart_write("Hello from C!\n");
	hi_there();
	return;
}
