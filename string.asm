outstring:
    push ax
    push si
    
    mov ah, 0eh
    
    jmp short .out
    
.loop:
    int 10h
.out:
    lodsb
    or al,al
    jnz .loop
    
    pop si
    pop ax
    ret