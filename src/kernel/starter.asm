bits 16                       ; Set the assembly mode to 16-bit for the bootloader
extern kernel_main            ; Declare an external reference to the kernel's main function
extern interrupt_handler      ; Declare an external reference to the interrupt handler function
extern scheduler              ; Special interrupt handler for 32 that calls the scheduler
extern run_next_process       ; Special interrupt handler for 32 that calls the scheduler

start:                        ; Label for the start of the bootloader
    mov ax, cs                ; Move the value of the Code Segment register into AX
    mov ds, ax                ; Set the Data Segment register to the same value as AX
        
    call load_gdt             ; Call the function to load the Global Descriptor Table
    call init_video_mode      ; Call the function to initialize the video mode
    call enter_protected_mode ; Call the function to switch to protected mode
    call setup_interrupts     ; Call the function to set up interrupts
	call load_task_register   ; Call the routine that oads the task register with the proper value

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
	
    ; Send initialization command to PIC master and slave
    out 0x20, al              ; Send ICW1 to PIC master command port
    out 0xa0, al              ; Send ICW1 to PIC slave command port
	
    ; ... ;                   ; Additional commands to configure PIC (omitted for brevity)
	
    ret                       ; Return from the function
	
load_idt:                     ; Function to load the Interrupt Descriptor Table (IDT)
    lidt [idtr - start]       ; Load the IDT register with the address of the IDT
	
    ret                       ; Return from the function

load_task_register:
    mov ax, 40d
    ltr ax
    
    ret
	
bits 32                       ; Set the assembly mode to 32-bit for the kernel
start_kernel:                 ; Label for the start of the kernel
    mov eax, 10h              ; Move the value 10h into EAX
    mov ds, eax               ; Set the Data Segment register to 10h
    mov ss, eax               ; Set the Stack Segment register to 10h
    
    mov eax, 0h               ; Move the value 0h into EAX
    mov es, eax               ; Set the Extra Segment register to 0h
    mov fs, eax               ; Set the FS register to 0h
    mov gs, eax               ; Set the GS register to 0h
	
    sti                       ; Set the interrupt flag to enable interrupts
	
    call kernel_main          ; Call the kernel's main function
	
%include "gdt.asm" ; Include the contents of the file "gdt.asm"
%include "idt.asm" ; Include the contents of the file "idt.asm"

tss:
    dd 0
