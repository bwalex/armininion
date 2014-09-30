ENTRY(_start)
SECTIONS
{
	/*
	 * Using the VA at which the code will be (after turning on the MMU).
	 * Code before the MMU setup *has* to be position-independent.
	 */
	. = 0xffffff8000000000;
	. = ALIGN(4);
	.text : {
		*(.text.boot)
		. = ALIGN(4);
		*(.text*)
	}

	. = ALIGN(8);

	.rodata : {
		*(SORT_BY_ALIGNMENT(SORT_BY_NAME(.rodata*)))
	}


	. = ALIGN(8);

	.data : {
		*(.data*)
	}

	. = .;

	.got : {
		*(.got)
	}

	num_got_entries = SIZEOF(.got) >> 2;

	. = ALIGN(8);

	.sdata : {
		*(.sdata*)
	}

	. = ALIGN(8);

	.rel.dyn : {
		__rel_dyn_start = .;
		*(.rel.dyn)
		__rel_dyn_end = .;
	}


	.dynsym : {
		*(.dynsym)
	}


	.bss __rel_dyn_start (OVERLAY) : {
		__bss_start = .;
		*(.sbss.*)
		*(.bss.*)
		*(COMMON)
		. = ALIGN(8);
		__bss_end = .;
	}

	. = ALIGN(16);
	. = . + 0x1000;
	__stack_top = .;

	/DISCARD/ : {
		*(.dynbss)
		*(.dynstr)
		*(.dynamic)
		*(.interp)
		*(.hash)
		*(.gnu.*)
		*(.plt)
		*(.got.plt)
		*(.rel.plt)
		*(.ARM.attributes)
	}
}
