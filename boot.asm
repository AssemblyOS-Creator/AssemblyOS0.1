[bits 16]
[org 0x7c00]

KERNEL_OFFSET equ 0x7e00 

start:
    ; 1. Clean environment
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ax, 0x0000
    mov ss, ax
    mov bp, 0x9000    ; Stack base
    mov sp, 0xFFFF; Stack pointer
    sti
    cld

    mov [BOOT_DRIVE], dl    ; Save boot drive

    ; 2. Print Message
    mov bx, MS              ; Put string address in BX
    call print_string       ; Call the function

    ; 3. Load Kernel
    call load_kernel        
    
    ; 4. Jump to Kernel
    jmp KERNEL_OFFSET       

load_kernel:
    mov ah, 0x02            
    mov al, 1               
    mov ch, 0x00            
    mov dh, 0x00            
    mov cl, 0x02            
    mov dl, [BOOT_DRIVE]    
    mov bx, KERNEL_OFFSET   
    int 0x13                
    jc disk_error           
    ret

disk_error:
    mov bx, MSG_ERROR
    call print_string
    jmp $

print_string:               ; FIXED FUNCTION
    mov ah, 0x0e
.loop:
    mov al, [bx]            ; Get char from BX
    cmp al, 0               ; End of string?
    je .done                ; IF ZERO, GO TO DONE (not load_kernel)
    int 0x10                
    inc bx                  ; Next char
    jmp .loop               
.done:
    ret                     ; THIS IS REQUIRED to go back to 'start'

BOOT_DRIVE db 0
MS db "Loading Kernel...", 13, 10, 0
MSG_ERROR db "Disk Error!", 0

times 510-($-$$) db 0
dw 0xAA55
