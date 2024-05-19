start:
    mov ax, 07C0h               ; Set AX to 07C0h, the segment address where the bootloader is loaded
    mov ds, ax                  ; Set Data Segment (DS) to the value in AX

    mov si, title_string        ; Set SI to point to the 'title_string'
    call print_string           ; Call 'print_string' function to print the title string

    mov si, message_string      ; Set SI to point to the 'message_string'
    call print_string           ; Call 'print_string' function to print the message string

    call load_kernel_from_disk  ; Call 'load_kernel_from_disk' function to load the kernel into memory
    jmp 0900h:0000             ; Jump to the memory location 0900h:0000 to start executing the kernel

load_kernel_from_disk:
    mov ax, [curr_sector_to_load] ; Move the current sector to load into AX
    sub ax, 2                     ; Subtract 2 from AX (adjust for sector numbering starting at 1)
    mov bx, 512d                  ; Move 512 (bytes per sector) into BX
    mul bx                        ; Multiply AX by BX (calculate offset)
    mov bx, ax                    ; Move the result into BX (offset for loading)

    mov ax, 0900h                 ; Move segment address 0900h into AX
    mov es, ax                    ; Set Extra Segment (ES) to the value in AX

    mov ah, 02h                   ; Set function number for disk read
    mov al, 1h                    ; Set AL to read 1 sector
    mov ch, 0h                    ; Set CH to cylinder number 0
    mov cl, [curr_sector_to_load] ; Set CL to the current sector to load
    mov dh, 0h                    ; Set DH to head number 0
    mov dl, 80h                   ; Set DL to drive number (80h for the first HDD)
    int 13h                       ; Call interrupt 13h to read from disk

    jc kernel_load_error          ; If carry flag is set (error), jump to 'kernel_load_error'

    sub byte [number_of_sectors_to_load], 1 ; Subtract 1 from the number of sectors to load
    add byte [curr_sector_to_load], 1       ; Add 1 to the current sector to load
    cmp byte [number_of_sectors_to_load], 0 ; Compare the number of sectors to load with 0

    jne load_kernel_from_disk     ; If not equal, jump back to 'load_kernel_from_disk'

    ret                           ; Return from the function

kernel_load_error:
    mov si, load_error_string     ; Set SI to point to the 'load_error_string'
    call print_string             ; Call 'print_string' function to print the error string

    jmp $                         ; Jump to current address (infinite loop)

print_string:
    mov ah, 0Eh                   ; Set function number for teletype output

print_char:
    lodsb                         ; Load byte at address SI into AL, increment SI
    cmp al, 0                     ; Compare AL with 0 (end of string)
    je printing_finished          ; If equal, jump to 'printing_finished'

    int 10h                       ; Call interrupt 10h to print character in AL

    jmp print_char                ; Jump back to 'print_char' to print the next character

printing_finished:
    mov al, 10d                   ; Move newline character into AL
    int 10h                       ; Call interrupt 10h to print newline

    ; Reading current cursor position
    mov ah, 03h                   ; Set function number for reading cursor position
    mov bh, 0                     ; Set display page number to 0
    int 10h                       ; Call interrupt 10h to read cursor position

    ; Move the cursor to the beginning
    mov ah, 02h                   ; Set function number for setting cursor position
    mov dl, 0                     ; Set column number to 0
    int 10h                       ; Call interrupt 10h to set cursor position

    ret                           ; Return from the function

title_string        db  'Basic Bootloader', 0
message_string      db  'The kernel is loading...', 0   ; String to be printed (0 indicates end of string)
load_error_string   db  'The kernel cannot be loaded', 0
number_of_sectors_to_load  db  10d
curr_sector_to_load         db  2d

times 510-($-$$) db 0       ; Fill the remainder of the 512-byte sector with zeros

dw 0xAA55                   ; Boot signature (0xAA55) indicating a valid bootable disk
