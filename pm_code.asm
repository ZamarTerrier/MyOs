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
    
    call set_pages
    
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
    
set_pages:
    .set_cat:
        mov edi,PAGE_DIR_BASE_ADDRESS;базовый адрес директории
        mov eax,PAGE_TABLES_BASE_ADDRESS;базовый адрес таблицы страниц и флаги
        mov cx,8 ;8*4Мб=32Мб
    .fill_cat_usef: ;опишем таблицы страниц
        stosd
        add eax,1000h
        loop .fill_cat_usef
        mov cx,1016 ;а остальное забьём нулями
        xor eax,eax
        rep stosd
        mov eax,00000007h
        mov ecx,1024*8;32Mb
    .fill_page_table: ;теперь опишем страницы
        stosd
        add eax,1000h
        loop .fill_page_table
    ;End;         100000h
        mov eax,PAGE_DIR_BASE_ADDRESS;1 Mb;и установим базовый адрес первого каталога в cr3
        mov cr3,eax
        mov eax,cr0
        or eax,80000000h
        mov cr0,eax
        
        mov esi, message1
        mov edi, 0B8000h
        mov ecx,message2-message1
        rep movsb
        
        mov esi, message2
        mov ecx,message3-message2
        rep movsb
        
        mov esi, message3
        mov ecx,end_messages-message3
        rep movsb
        
    ret
    
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

PAGE_DIR_BASE_ADDRESS equ 0x100000
PAGE_TABLES_BASE_ADDRESS equ 0x101007
USER_PM_CODE_BASE_ADDRESS equ 0x1000
INT_GATE equ 1000111000000000b

message1 db "152535455565758595 5 5"
message2 db "A5d5r5F5F5050505050505 5"
message3 db "A5d5r5E5E5050505050505 5"
end_messages: