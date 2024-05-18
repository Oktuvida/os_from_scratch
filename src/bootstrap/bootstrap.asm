start:
    mov ax, 07C0h ; Move hexadecimal 07C0 to the register ax
    mov ds, ax    ; Move value to ds (data segment) through ax

    mov si, title_string ; print title_string
    call print_string    ; memadd of the string as a parameter in register si

    mov si, message_string ; print message_string
    call print_string    ; memadd of the string as a parameter in register si

    ; MOST IMPORTANT PART OF BOOTLOADER
    call load_kernel_from_disk ; call function
    jmp 0900h:0000  ; gives control to kernel by jumping to starting point (same values set in ax and bx(offset) registers)  
    ; both parts combined represent the memory address that we have loaded our kernel into 

    




load_kernel_from_disk:
    mov ax, 0900h
    mov es, ax ; set 0900h on register es

    ; load kernel from the disk into memory
    ; by using BIOS Service 13h - related to hard disks
    mov ah, 02h ; in BIOS AH often holds function number, 02h specifies the function number for reading sectors from the hard disk
    mov al, 01h ; in BIOS AL often holds parameters, 01h is the number of sectors to read from the disk (1 sector as kernel won't exceed 512 bytes)
    mov ch, 0h  ; ch holds the number of tracks we'd like to read from, in this case, track 0
    mov cl, 02h ; register cl is the sector number that we would like to read its content (second)
    mov dh, 0h  ; head number
    mov dl, 80h ; register dl specifies type of disk to read, 80h means reading from hd #0
    mov bx, 0h  ; value of bx: memory address that the content will be loaded into (reading one sector and it will be stored on 0h)
    int 13h ; when all donce correctly, BIOS service will set cf = 0

    jc kernel_load_error ; conditional that jumps when cf = 1, when kernel isn't loaded correctly

    ret ; end function (return to main code)

kernel_load_error: ; function to print error when loading
    mov si, load_error_string
    call print_string

    jmp $ ; infinite loop to jump program to current address, halting the execution

print_string:
    mov ah, 0Eh ; BIOS service number is loaded in ah

print_char:
    lodsb ; transfer first character of string to al and increase value of si by 1 byte

    cmp al, 0 ; if al is zero then end of string has been reached
    je printing_finished ; then jump to  printing_finished label

    int 10h ; if not then 10h called to print content on register al
    
    jmp print_char ; jump to print char to repeat operation until end of string has been reached

printing_finished:
    mov al, 10d ; Print new line (represented by 10 in ASCII)
    int 10h
    
    ; Reading current cursor position
    mov ah, 03h
    mov bh, 0
    int 10h
    
    ; Move the cursor to the beginning
    mov ah, 02h
    mov dl, 0
    int 10h

    ret

title_string        db  'Basic Bootloader', 0
message_string      db  'The kernel is loading...', 0   ; string to be printed (0 indicates end of str)
load_error_string   db  'The kernel cannot be loaded', 0
times 510-($-$$) db 0 ; remaining empty space in bootloader
dw 0xAA55 ; set last 2 bytes of bootloader to 0xAA55 - standard used in x86 bl to indicate BIOS thisis a valid bootloader


