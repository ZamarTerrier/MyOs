[bits 16]
[org 0x7c00]

STACK_BASE_ADDRESS equ 0x9000
USER_PM_CODE_BASE_ADDRESS equ 0x1000

mov [BOOT_DRIVE], dl

; setup stack
mov bp, STACK_BASE_ADDRESS
mov sp, bp

call _start

jmp $ 
    
%include "disk.asm"
%include "string.asm"
%include "gdt.asm"

_start:
    mov ax,3
    int 10h
    
    in al, 92h
    or al, 2
    out 92h, al
        
    mov bx, USER_PM_CODE_BASE_ADDRESS ; bx -> destination
    mov dh, 5             ; dh -> num sectors
    mov dl, [BOOT_DRIVE]  ; dl -> disk
            
    call disk_load
        
    cli
    
    lgdt [gdt_descriptor]
    in al,70h
    or al,80h
    out 70h,al
    
    mov eax, cr0
    or al, 1
    mov cr0, eax 
        
    jmp  CODE_SEG:PROTECTED_MODE_ENTRY_POINT;  
    
[bits 32]
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

BOOT_DRIVE db 0

PROTECTED_MODE_ENTRY_POINT:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, STACK_BASE_ADDRESS
    
    call delta
 delta:
    pop ebx
    add ebx, USER_PM_CODE_BASE_ADDRESS - delta
    mov esi, ebx
    mov edi, USER_PM_CODE_BASE_ADDRESS
    rep movsb
       
    mov eax, USER_PM_CODE_BASE_ADDRESS
    jmp eax       



times 510 - ($ -$$) db 0

dw 0xaa55