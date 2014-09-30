.section .text
.global uart_write

#define UART_BASE	0x09000000

// uart_write
//   Takes zero-terminated string to write in x0
//   Modifies: x0 (saves & uses: x19,x20,x21)
uart_write:
	stp x19,x20, [sp,#-0x10]!
	stp x21,x22, [sp,#-0x10]!

	adr x19, uart_base
	ldr x19, [x19]

uart_write_loop:
	ldrb w20, [x0]
	cbz w20, uart_write_done

uart_write_wait:
	// Check TXFF flag
	ldrb w21, [x19, #0x018]
	tbnz w21, #5, uart_write_wait

	// Write to data register
	strb w20, [x19]

	// Increment char pointer and loop
	add x0, x0, #1
	b   uart_write_loop

uart_write_done:
	ldp x21,x22, [sp],#0x10
	ldp x19,x20, [sp],#0x10

	ret

.balign 8
.ltorg

.section .data
.balign 8
uart_base:
	.quad UART_BASE
