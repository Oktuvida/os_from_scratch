ASM = nasm
BOOTSTRAP_FILE = bootstrap.asm 
KERNEL_FILE = simple_kernel.asm

build: $(BOOTSTRAP_FILE) $(KERNEL_FILE)
	$(ASM) -f bin $(BOOTSTRAP_FILE) -o bootstrap.o
	$(ASM) -f bin $(KERNEL_FILE) -o kernel.o
	copy /b bootstrap.o + kernel.o kernel.img
	qemu-system-x86_64 -s kernel.img

clean:
	del *.o
	del kernel.img
