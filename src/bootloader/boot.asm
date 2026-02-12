ORG 0x7C00      ; load our code releteve to this address 
[bits 16]       ; set to 16bits

;================================
; headers for Floppy Image
;================================
JMP SHORT main
NOP

bdb_oem:                   DB 'MSWIN4.1'
bdb_bytes_per_sector:      DW 512
bdb_sectors_per_cluster:   DB 1
bdb_reserved_sectors:      DW 1
bdb_fat_count:             DB 2
bdb_dir_entries_count:     DW 0E0h
bdb_total_sectors:         DW 2880
bdb_media_descriptor_type: DB 0F0h
bdb_sectors_per_fat:       DW 9
bdb_sectors_per_track:     DW 18
bdb_heads:                 DW 2
bdb_hidden_sectors:        DD 0
bdb_large_sector_count:    DD 0

ebr_drive_number:          DB 0
                           DB 0
ebr_signature:             DB 29h
ebr_volume_id:             DB 12h,34h,56h,78h
ebr_volume_label:          DB 'simpleOS   '     ; must be 11
ebr_system_id:             DB 'FAT12   '        ; must be 8


main:
    mov ax,0            ; init the registers
    mov ds,ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7C00      ; set the begning of the stack to be "0x7C00" (our app starter address)
    
    ;test read Floopy Image
    mov [ebr_drive_number], dl 
    mov ax, 1
    mov cl, 1
    mov bx, 0x7E00
    call disk_read

    ; print start message
    mov si, os_starting_msg
    call print

    ; load kernel 
    mov ax, [bdb_sectors_per_fat]
    mov bl, [bdb_fat_count]
    xor bh,bh
    mul bx
    add ax, [bdb_reserved_sectors] ; LBA of root dir
    push ax

    mov ax, [bdb_dir_entries_count]
    shl ax,5 
    xor dx,dx
    div word [bdb_bytes_per_sector] 

    test dx,dx
    jz rootDirAfter
    inc ax

;================================
; load kernel 
;================================
rootDirAfter: ; read data from root dir
    mov cl,al
    pop ax
    mov dl, [ebr_drive_number]
    mov bx, buffer
    call disk_read

    xor bx,bx
    mov di,buffer ; we have done so fare load the whole root dir into memory

searchKernel: ; after loading the root dir, we search for the "KERNEL.BIN" file
    mov si, file_kernel_bin
    mov cx,11
    push di
    repe cmpsb ; repeatedly compare si and di untill the end of string (search)
    pop di
    je foundKernel ; if we found file (kernel)

    add di, 32
    inc bx
    cmp bx, [bdb_dir_entries_count] ; see if we reach the end  or not
    jl searchKernel

    jmp kernelNotFound

kernelNotFound:
    mov si, msg_kernel_not_found
    call print

    HLT
    jmp halt

foundKernel:
    mov ax, [di+26]
    mov [kernel_cluster], ax

    mov ax, [bdb_reserved_sectors]
    mov bx, buffer                  ; place we load kernel into
    mov cl, [bdb_sectors_per_fat]
    mov dl, [ebr_drive_number]

    call disk_read ; load file allocation table from disk into memory

    ; load kernel into memory
    mov bx, kernel_load_segment
    mov es,bx 
    mov bx, kernel_load_offset ; set up the memory to load the kernel into 

loadKernelLoop:
    mov ax, [kernel_cluster]
    add ax,31                   ; 31 is hard coded
    mov cl,1
    mov dl, [ebr_drive_number]

    call disk_read ; read one cluster at a time

    add bx, [bdb_bytes_per_sector]

    ; find next cluster
    mov ax, [kernel_cluster] ; (kernel cluster *3)/2 ; this will result into having a remainder or none (even, odd)
    mov cx,3
    mul cx
    mov cx,2
    div cx

    mov si, buffer
    add si, ax
    mov ax, [ds:si]

    or dx,dx
    jz even

odd:
    shr ax,4
    jmp nextClusterAfter

even:
    and ax,0xfff

nextClusterAfter:
    cmp ax, 0x0ff8
    jae readFinish

    mov [kernel_cluster],ax
    jmp loadKernelLoop

readFinish:
    mov dl, [ebr_drive_number]
    mov ax, kernel_load_segment
    mov ds, ax
    mov es,ax

    jmp kernel_load_segment:kernel_load_offset ; jump to other file (location of the kernel "main.asm")

    HLT

halt:           ; loop incase "HAL" failed
    jmp halt

;================================
; read disk (floopy image)
;================================
lba_to_chs:     ; convert LBA to CHS (cylender, head , sector)
    push ax 
    push dx

    xor dx,dx
    div word [bdb_sectors_per_track]
    inc dx
    mov cx,dx

    xor dx,dx
    div word [bdb_heads]

    mov dh,dl 
    mov ch,al
    shl ah,6
    or cl,ah

    pop ax
    mov dl,al
    pop ax

    ret

disk_read:      ; read from the disk after converting lba to chs
    push ax
    push bx
    push cx
    push dx
    push di

    call lba_to_chs

    ; try read disk 3 times
    mov ah, 02h 
    mov di, 3

retry:
    stc ; set the carry flag manually
    int 13h
    jnc doneRead

    call diskReset

    dec di
    test di,di
    jnz retry

failDiskRead:
    mov si,read_failure
    call print
    HLT
    jmp halt


diskReset:
    pusha
    mov ah,0
    stc
    int 13h
    jc failDiskRead
    popa
    ret

doneRead:
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;================================
; print to screen
;================================
print:
    push si
    push ax 
    push bx

print_loop:
    LODSB           ; load a singel char from "si" regs and put it in "al" regs
    or al,al        ; check if current char is 0 (0 == 0 = 0) ZE flag will be set
    JZ done_print   ; jump if zero

    mov ah, 0x0E    ; set option to be "print char to screen" from "al" regs
    mov bh, 0       ; page memory
    int 0x10        ; call the "video intreput" with option in "ah"

    jmp print_loop  ; loop back

done_print:         
    POP bx
    POP ax
    POP si
    RET

;================================
; data
;================================
os_starting_msg DB 'Bootloader: Loading...', 0x0D, 0x0A, 0 ; 0x0D and 0x0A is new line chars
read_failure DB 'Bootloader: Failed to read disk!', 0x0D, 0x0A, 0
file_kernel_bin DB 'KERNEL  BIN'
msg_kernel_not_found DB 'Bootloader: KERNEL.BIN not found!'
kernel_cluster DW 0

kernel_load_segment EQU 0x2000 ; use extra memory
kernel_load_offset EQU 0

TIMES 510-($-$$) DB 0       ; we want our code to be 512 size, this fills in the empty space with zeros up to 510
DW 0AA55h                   ; write last 2 bytes to be 0AA55h, for the BIOS 

buffer: ; define a buffer to use