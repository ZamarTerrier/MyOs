align 8          
gdt_start:
        dq 0x0
    CODE_descr:
        db 0FFh,0FFh,00h,00h,00h,10011010b,11001111b,00h
    DATA_descr:
        db 0FFh,0FFh,00h,00h,00h,10010010b,11001111b,00h
    VIDEO_descr:
        db 0FFh,0FFh,00h,80h,0Bh,10010010b,01000000b,00h
gdt_end:
    
gdt_descriptor:
    dw gdt_end - gdt_start ; size (16 bit)
    dd gdt_start ; address (32 bit)
    
CODE_SEG equ CODE_descr - gdt_start
DATA_SEG equ DATA_descr - gdt_start
VIDEO_SEG equ VIDEO_descr - gdt_start