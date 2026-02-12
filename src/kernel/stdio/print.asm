BITS 16

section _TEXT class=CODE

global _x86_div64_32:
_x86_div64_32:
    ; long divition algrothem (to controle the size of the registers )
    push bp
    mov bp, sp

    push bx

    mov eax, [bp+8] ; move the uppper 32 bits of dividend (becose its 64bits its gonna move only the upper bits into eax)
    mov ecx, [bp+12] ; divisor (becose its 32bit its gonna move the whole 32bits into ecx)
    xor edx,edx ; zero out the edx
    div ecx ; result in eax, reminder in edx

    mov bx, [bp+16] ; upper 32 bits of the quotient
    mov [bx+4], eax

    mov eax, [bp+4] ; the lower 32 bits of dividend (of 64bit "[bp+8]")
    div ecx 

    mov [bx], eax  ; store results in refrences
    mov bx, [bp+18]
    mov [bx], edx

    
    pop bx

    mov sp, bp
    pop bp

    ret

global _x86_Video_WriteCharTeletype
_x86_Video_WriteCharTeletype:
    PUSH bp
    MOV bp, sp

    PUSH bx

    MOV ah, 0x0E
    MOV al, [bp+4]
    MOV bh, [bp+6]

    INT 10h

    POP bx
    MOV sp, bp

    POP bp

    RET