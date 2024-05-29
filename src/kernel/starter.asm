bits 16                       ; Set the assembly mode to 16-bit, suitable for a bootloader
extern kernel_main            ; Declare an external reference to the kernel's main function
extern interrupt_handler      ; Declare an external reference to the interrupt handler function
extern scheduler              ; Declare an external reference to the scheduler function
extern run_next_process       ; Declare an external reference to the function to run the next process

start:                        ; Label marking the start of the bootloader
    mov ax, cs                ; Copy the Code Segment register's value into AX
    mov ds, ax                ; Set the Data Segment register to AX's value (same as CS)

    call load_gdt             ; Call the function to load the Global Descriptor Table
    call init_video_mode      ; Call the function to initialize the video display mode
    call enter_protected_mode ; Call the function to switch the CPU to protected mode
    call setup_interrupts     ; Call the function to set up the interrupt handlers
    call load_task_register   ; Call the function to load the task register with the proper value

    call 08h:start_kernel     ; Call the kernel's start function with segment selector 08h
	
load_gdt:                     ; Function to load the Global Descriptor Table
    cli                       ; Clear the interrupt flag to disable interrupts
    lgdt [gdtr - start]       ; Load the GDT register with the address of the GDT
	
    ret                       ; Return from the function
	
enter_protected_mode:         ; Function to switch to protected mode
    mov eax, cr0              ; Move the value of control register CR0 into EAX
    or eax, 1                 ; Set the protection enable bit (PE) of CR0
    mov cr0, eax              ; Move the updated value back into CR0
	
    ret                       ; Return from the function
	
init_video_mode:              ; Function to initialize the video mode
    mov ah, 0h                ; Set function number for video mode control to 0h (set mode)
    mov al, 03h               ; Set video mode to 03h (80x25 text mode)
    int 10h                   ; Call BIOS interrupt 10h to set the video mode
	
    mov ah, 01h               ; Set function number for setting cursor shape
    mov cx, 2000h             ; Set cursor size (disable blinking and set size)
    int 10h                   ; Call BIOS interrupt 10h to set the cursor shape
	
    ret                       ; Return from the function
	
setup_interrupts:             ; Function to set up interrupts
    call remap_pic            ; Call the function to remap the PIC
    call load_idt             ; Call the function to load the IDT
	
    ret                       ; Return from the function
	
remap_pic:                    ; Function to remap the Programmable Interrupt Controller (PIC)
    mov al, 11h               ; Prepare PIC for initialization with ICW1
	
	send_init_cmd_to_pic_master: 	
		out 0x20, al
		
	send_init_cmd_to_pic_slave: 	
		out 0xa0, al
		
	; ... ;
	
	make_irq_starts_from_intr_32_in_pic_master:		
		mov al, 32d
		out 0x21, al
	
	make_irq_starts_from_intr_40_in_pic_slave:
		mov al, 40d
		out 0xa1, al 
	
	; ... ;
	
	tell_pic_master_where_pic_slave_is_connected:
		mov al, 04h
		out 0x21, al
	
	tell_pic_slave_where_pic_master_is_connected:
		mov al, 02h
		out 0xa1, al
	
	; ... ;
	
	mov al, 01h
	
	tell_pic_master_the_arch_is_x86:
		out 0x21, al
	
	tell_pic_slave_the_arch_is_x86:
		out 0xa1, al
	
	; ... ;
	
	mov al, 0h
	
	make_pic_master_enables_all_irqs:
		out 0x21, al
	
	make_pic_slave_enables_all_irqs:
		out 0xa1, al
	
	; ... ;

	
    ret                       ; Return from the function
	
load_idt:                     ; Function to load the Interrupt Descriptor Table (IDT)
    lidt [idtr - start]       ; Load the IDT register with the address of the IDT
	
    ret                       ; Return from the function

load_task_register:
    mov ax, 40d
    ltr ax
    
    ret

bits 32                       ; Switch to 32-bit assembly mode, suitable for the kernel
start_kernel:                 ; Label marking the start of the kernel
    mov eax, 10h              ; Set EAX to 10h, which is the selector for the data segment
    mov ds, eax               ; Set the Data Segment register to EAX's value
    mov ss, eax               ; Set the Stack Segment register to EAX's value

    mov eax, 0h               ; Clear EAX to zero
    mov es, eax               ; Set the Extra Segment register to zero
    mov fs, eax               ; Set the FS segment register to zero
    mov gs, eax               ; Set the GS segment register to zero

    sti                       ; Enable interrupts by setting the interrupt flag

    call kernel_main          ; Call the kernel's main function

%include "gdt.asm"            ; Include the Global Descriptor Table definitions
%include "idt.asm"            ; Include the Interrupt Descriptor Table definitions

tss:                          ; Task State Segment definition
    dd 0                      ; Initialize the TSS with zero
