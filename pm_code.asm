[bits 32]
[org 0x1000]

%macro define_gate 2
    mov eax, %1
    mov esi, eax
    mov [idt+%2*8],ax
    mov word [idt+%2*8+2],CODE_SEG
    mov word [idt+%2*8+4],0x8E00
    shr eax,16
    mov [idt+%2*8+6],ax
%endmacro
    
    lidt [idt_descriptor]
    
    define_gate syscall_handler, 1
    define_gate irq0_handler, 32
    define_gate int_EOI, 33
    define_gate int_EOI, 34
    define_gate int_EOI, 35
    define_gate int_EOI, 36
    define_gate int_EOI, 37
    define_gate int_EOI, 38
    define_gate int_EOI, 39
    define_gate int_EOI, 40
    define_gate int_EOI, 41
    define_gate int_EOI, 42
    define_gate int_EOI, 43
    define_gate int_EOI, 44
    define_gate int_EOI, 45
    define_gate int_EOI, 46
        
    mov bx, 2820h
    
    mov al, 00010001b
    out 020h, al
    out 0A0h, al
    mov al, bl
    out 021h, al
    mov al, bh
    out 0A1h, al
    mov al, 00000100b
    out 021h, al
    mov al, 2
    out 0A1h, al
    mov al, 00000001b
    out 021h, al
    out 0A1h, al
    
    in al,70h
    or al,7Fh
    out 70h,al
    sti
        
    mov eax, 0x0F
    mov ecx, 0820h
    mov edi, 0xb8000
    rep stosw

    mov ah, 0x03   
    mov edi, 0xb8000
    mov al, "0"
    mov word [es:edi], ax
    add edi, 2
    mov word [es:edi], ax
    add edi, 2
    mov word [es:edi], ax
    add edi, 2
    mov word [es:edi], ax 
    
    mov dword [cursor], 8
    
    mov esi, message1
    int 1
    mov dword [cursor], 160
    mov esi, message2
    int 1
    mov  dword [cursor], 340
    
    jmp $ 
            
%include "string32.asm"


syscall_handler:
    pushad
_puts:
    mov ax, word [cursor] 
    mov word [xpos], ax
    call sprint
    popad
    iretd 
    
irq0_handler:
    push eax
    push edx
    push ebx
    
    xor edx, edx
    inc dword [counter]
    mov eax, dword [counter]
    mov ebx, 18
    
    div ebx
    cmp edx, 0
    jnz .cont
    
    mov ah, 0x03   
    mov edi, 0xb8000
    add edi, 6
    inc byte [es:edi]
    cmp byte [es:edi],":"
    jnz .cont
    mov al, "0"
    mov word [es:edi],ax
    mov edi, 0xb8000
    add edi, 4
    inc byte [es:edi]
    
    cmp byte [es:edi], ":"
    jnz .cont
    mov word [es:edi],ax
    mov edi, 0xb8000
    add edi, 2
    inc byte [es:edi]
    
    cmp byte [es:edi], ":"
    jnz .cont
    mov word [es:edi], ax
    mov edi, 0xb8000
    inc byte [es:edi]
    
    cmp byte [es:edi], ":"
    jnz .cont    
    mov ah, 0x03   
    mov edi, 0xb8000
    mov al, "0"
    mov word [es:edi], ax
    add edi, 2
    mov word [es:edi], ax
    add edi, 2
    mov word [es:edi], ax
    add edi, 2
    mov word [es:edi], ax

.cont:
    pop ebx
    pop edx
    pop eax
    jmp int_EOI

    
int_EOI:
    push ax
    mov al, 20h
    out 020h, al
    out 0a0h, al
    pop ax
    iretd
    
%include "gdt.asm"
 
align 8

idt:
    resd 50*2
idt_end:
    
idt_descriptor:
    dw idt_end - idt
    dd idt

cursor db 0
counter db 0

USER_PM_CODE_BASE_ADDRESS equ 0x1000
INT_GATE equ 1000111000000000b

message: 
    db "152535455565758595"
    
message1:
    db "message1", 0
    
message2: 
    db "message2", 0