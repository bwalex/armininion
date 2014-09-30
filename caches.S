.section .text
.global inval_all_caches

// inval_all_caches
inval_all_caches:
	// Save callee-saved registers used in this function
	stp x19,x20,[sp,#-0x10]!
	stp x21,x30,[sp,#-0x10]!

	mrs x19, clidr_el1
	mov w20, wzr
loop_cache:
	ands w21, w19, #7
	beq next_cache
	mov w1, w20
	bl inval_cache
next_cache:
	add w20, w20, #1
	lsr w19, w19, #3
	cmp w20, #6
	bne loop_cache

	ic iallu
	dsb sy

	ldp x21,x30,[sp],#0x10
	ldp x19,x20,[sp],#0x10
	ret


// inval_cache
//   Takes cache level in w1
inval_cache:
	lsl x9, x1, #1
	msr csselr_el1, x9
	isb
	mrs  x10, ccsidr_el1
	and  w11, w10, 0x7
	add  w11, w11, #4
	ubfx w12, w10, #3,  #10
	clz w14, w12
	ubfx w13, w10, #13, #15
loop_way:
	mov w15, w13
loop_set:
	// Current way: w12, current set: w15, line size: w11, 32-log2(associativity): w14, cache level: x1
	// Set up way
	lsl x9, x12, x14
	// Set up set
	lsl x16, x15, x11
	orr x9,  x9,  x16
	bfi x9,  x1,  #1, #3

	dc  isw, x9

	cbz w15, next_way
	sub w15, w15, #1
	b loop_set
next_way:
	cbz w12, done
	sub w12, w12, #1
	b loop_way
done:
	dsb sy
	ret

.balign 8
.ltorg
