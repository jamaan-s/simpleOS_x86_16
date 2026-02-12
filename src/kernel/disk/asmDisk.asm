
BITS 16

section _TEXT class=CODE

global _x86_Disk_Reset
_x86_Disk_Reset:

    push bp
    mov bp,sp

    mov ah,0
    mov dl, [bp+4] ; first prams
    stc
    int 13h
    JC reset_error

    mov cx, 0     ; error code
    mov bx,[bp+6] ; second prams (refrence). 6 becose its 8bits value
    mov [bx], cx  ; move cx (0) into refrence 
    jmp end_reset

reset_error: 
    mov cx, 1
    mov bx, [bp+6]
    mov [bx], cx

end_reset:
    mov sp,bp
    pop bp
    ret