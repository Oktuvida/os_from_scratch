ASM = nasm
CC = gcc
BOOTSTRAP_FILE = bootstrap.asm 
SIMPLE_KERNEL = simple_kernel.asm
INIT_KERNEL_FILES = starter.asm
KERNEL_FILES = main.c
KERNEL_FLAGS = -Wall -m32 -c -ffreestanding -fno-asynchronous-unwind-tables -fno-pie
KERNEL_OBJECT = -o kernel.elf

BUILD_DIR = dist

build:
	rm -rf $(BUILD_DIR)
	mkdir $(BUILD_DIR)
	find ./src -type f -exec cp {} $(BUILD_DIR) \;
	cd $(BUILD_DIR); \
    	$(ASM) -f bin $(BOOTSTRAP_FILE) -o bootstrap.o && \
    	$(ASM) -f elf32 $(INIT_KERNEL_FILES) -o starter.o && \
    	$(CC) $(KERNEL_FLAGS) $(KERNEL_FILES) $(KERNEL_OBJECT) && \
    	$(CC) $(KERNEL_FLAGS) screen.c -o screen.elf && \
    	$(CC) $(KERNEL_FLAGS) process.c -o process.elf && \
    	$(CC) $(KERNEL_FLAGS) scheduler.c -o scheduler.elf && \
    	$(CC) $(KERNEL_FLAGS) heap.c -o heap.elf && \
    	$(CC) $(KERNEL_FLAGS) paging.c -o paging.elf && \
    	ld -melf_i386 -Tlinker.ld starter.o kernel.elf screen.elf process.elf scheduler.elf heap.elf paging.elf -o 539kernel.elf && \
    	objcopy -O binary 539kernel.elf 539kernel.bin && \
    	dd if=bootstrap.o of=kernel.img && \
    	dd seek=1 conv=sync if=539kernel.bin of=kernel.img bs=512 count=8 && \
    	dd seek=9 conv=sync if=/dev/zero of=kernel.img bs=512 count=2046

run:
		cd $(BUILD_DIR) && \
			qemu-system-x86_64 -s kernel.img

clean:
	rm -rf $(BUILD_DIR)