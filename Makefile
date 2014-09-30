TOOLCHAIN?=aarch64-linux-gnu-

boot.bin: boot.elf
	$(TOOLCHAIN)objcopy -O binary boot.elf boot.bin

boot.elf: boot.S uart.S caches.S boot.ld kern.c
	$(TOOLCHAIN)gcc boot.S -c -o boot.o
	$(TOOLCHAIN)gcc uart.S -c -o uart.o
	$(TOOLCHAIN)gcc caches.S -c -o caches.o
	$(TOOLCHAIN)gcc -fPIC -fPIE kern.c -c -o kern.o
	$(TOOLCHAIN)ld -T boot.ld boot.o uart.o caches.o kern.o -o boot.elf

clean:
	rm -f boot.elf boot.bin *.o

run: boot.bin
	qemu-system-aarch64 -serial stdio -M virt -cpu cortex-a57 -m 512 -kernel boot.bin -display none
