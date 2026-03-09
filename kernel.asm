[bits 16]
[org 0x7e00]

    xor ax,ax
    mov ds,ax
    mov bx,MS
    
    mov bx,MS
    call print_string


    jmp main_loop

print_string:       ; The actual working loop
    mov ah, 0x0e
.loop:
    mov al,[bx]
    cmp al,0
    je .done
    mov ah,0x0e
    int 0x10
    inc bx
    jmp .loop
.done:
    ret
main_loop:
    mov bx,buffer

.get_char:
    mov ah, 0x00
    int 0x16
    cmp al,13
    je .correct
    mov ah,0x0e
    int 0x10
    mov [bx],al
    inc bx
    jmp .get_char
.correct:
    mov byte [bx],0
    ;ver
    mov si,buffer
    mov di,cmd_ver
    call strcmp
    je .show_version
    ;cls
    mov si,buffer
    mov di,cmd_cls
    call strcmp
    je .clear
    ;unknown
    mov bx,unknown
    call print_string
    jmp main_loop
    
.show_version:
    mov bx, v_msg
    call print_string
    jmp main_loop 
.clear:
    mov ax, 0x0003    
    int 0x10
    
    jmp main_loop

strcmp:
.loop:
    mov al,[si]
    mov bl,[di]
    cmp al,bl
    jne .noequal
    cmp al,0
    je .equal
    inc si
    inc di
    jmp .loop
.noequal:
    mov al,1
    cmp al,0
    ret
.equal:
    xor al,al
    cmp al,0
    ret
MS db "Successfully landed in the Kernel!", 13, 10, 0
v_msg  db 13, 10,'AssemblyOS v0.0.1', 13, 10, 0
unknown db 'This is not an executable command', 13, 10, 0
cmd_ver db '/ver',0
cmd_cls db '/clear',0
buffer times 32 db 0 
times 512-($-$$) db 0