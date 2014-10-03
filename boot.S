.section .text.boot, "x"
.global _start

#define CUREL_EL3	(0x03 << 2)
#define CUREL_EL2	(0x02 << 2)
#define CUREL_EL1	(0x01 << 2)
#define CUREL_EL0	(0x00 << 2)

_start:
	// We are only equipped to do an EL1 boot, so spin otherwise
	mrs x0, CurrentEL
	cmp x0, #CUREL_EL1
	bne .

	// Set up the stack
	adr x0, __stack_top
	mov sp, x0

zero_bss_loop:
	// Zero BSS (XXX: inefficient, byte-by-byte)
	adr x1, __bss_start
	adr x2, __bss_end
	cmp x1, x2
	beq zero_bss_done
	strb wzr, [x1]
	add  x1, x1, #1
	b   zero_bss_loop
zero_bss_done:

	// Flush caches
	adr x0, str_inval_caches
	bl  uart_write
	bl  inval_all_caches
	adr x0, str_done
	bl  uart_write

	// Set up pagetables & translation registers
	// We are splitting the address space so that the top 512 GB are for the kernel
	// -> corresponds to T1Sz of 25
	// For now, we use the bottom part of the address space for the identity mapping.
	// -> on this particular machine (qemu's virt) we'll need 2x 1GB mappings to cover
	//    everything we need (using the biggest mappings)
	//    the lower 1 GB needs to be set up with dev-nGnRnE
	//    the next 1GB doesn't matter, but we'd benefit from at least normal NC
	//    mapping.
	// Later on, we can reuse them for user-space
	adr x0, str_setup_pt
	bl uart_write

	// Write MAIR_EL1:
	//  idx 0: device nGnRnE
	//  idx 1: InnerWB, OuterWB, RW allocate (inner + outer)
	mov x0, xzr
	mov x1, #0xff
	bfi x0, x1, #8, #8
	msr mair_el1, x0

	// Set up TTBR0_EL1
	adr x0, pt_idmap_l1
	msr ttbr0_el1, x0
	// Set up TTBR1_EL1
	// Set up TCR_EL1
	//  T0SZ: 4GB
	//  IRGN0: Normal, Inner WB, Write-Allocate
	//  ORGN0: Normal, Outer WB, Write-Allocate
	//  SH0: Inner shareable
	//  EPD1: disable
	//  IPS: 48 bits (XXX: should use actual PA size)
	//  AS: 16 bits
	mov x0, #32
	mov x1, #35
	bfi x0, x1, #8, #6
	orr x0, x0, #(1 << 23)
	mov x1, #5
	bfi x0, x1, #32, #3
	orr x0, x0, #(1 << 36)
	msr tcr_el1, x0
	isb

	tlbi vmalle1
	dsb sy


	// XXX: still need to set up proper kernel mappings via TTBR1

	adr x0, str_done
	bl uart_write


	// Set up exception vector table
	// fault handler: read ESR_EL1, FAR_EL1
	adr x0, str_enable_exceptions
	bl uart_write
	// Use the VA for VBAR_EL1 already...
	ldr x0, =exception_vectors
	msr vbar_el1, x0
	adr x0, str_done
	bl uart_write


	// Enable MMU & caches
	adr x0, str_enable_mmu
	bl uart_write
	mrs x0, sctlr_el1
	orr x0, x0, #1
	orr x0, x0, #(1 << 2)
	orr x0, x0, #(1 << 12)
	msr sctlr_el1, x0
	isb
	adr x0, str_done
	bl uart_write


	// Say hello
	adr x0, str_hello
	bl  uart_write

	// Execute C
	bl  kern

	// loop forever
	b   .

ev_unhandled:
	adr x0, str_unhandled
	bl  uart_write
	b   .

ev_unhandled_usr:
	adr x0, str_unhandled_usr
	bl  uart_write
	b   .

ev_sync_kern:
	b   .

ev_irq_kern:
	b   .

ev_sync_usr64:
	b   .

ev_irq_usr64:
	b   .


// source		Synchronous	IRQ/vIRQ	FIQ/vFIQ	SError/vSError
// current EL (SP_EL0)	0x000		0x080		0x100		0x180
// current EL (SP_ELx)	0x200		0x280		0x300		0x380
// lower EL (AArch64)	0x400		0x480		0x500		0x580
// lower EL (AArch32)	0x600		0x680		0x700		0x780
.align 11
exception_vectors:
	.align 7
	b ev_unhandled
	.align 7
	b ev_unhandled
	.align 7
	b ev_unhandled
	.align 7
	b ev_unhandled
	.align 7
	b ev_sync_kern
	.align 7
	b ev_irq_kern
	.align 7
	b ev_unhandled
	.align 7
	b ev_unhandled
	.align 7
	b ev_sync_usr64
	.align 7
	b ev_irq_usr64
	.align 7
	b ev_unhandled_usr
	.align 7
	b ev_unhandled_usr
	.align 7
	b ev_unhandled_usr
	.align 7
	b ev_unhandled_usr
	.align 7
	b ev_unhandled_usr
	.align 7
	b ev_unhandled_usr



.balign 8
.ltorg

.section .data
str_hello:
	.asciz "Up and running (sort of)\n"
str_inval_caches:
	.asciz "Invalidating caches...          "
str_setup_pt:
	.asciz "Setting up translation...       "
str_enable_mmu:
	.asciz "Enabling MMU & caches...        "
str_enable_exceptions:
	.asciz "Enabling exception handling...  "
str_done:
	.asciz "done!\n"
str_unhandled:
	.asciz "Oh noes! Unhandled exception!\n"
str_unhandled_usr:
	.asciz "Oh noes! Unhandled user-mode exception!\n"

.balign 4096
pt_idmap_l1:
	.quad 0x0000000000000721 /* Using MAIR idx 0 */
	.quad 0x0000000040000725 /* Using MAIR idx 1 */
	.quad 0x0000000000000000 /* Invalid entry */
	.quad 0x0000000000000000 /* Invalid entry */
pt_idmap_l1_end:
