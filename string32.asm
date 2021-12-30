print:
    mov ah, 0x03             ; attrib = white on black
    
    mov edi, 0xb8000         ; start of video memory
    
    mov word [ds:edi], ax
 
    ret

dochar:
    call cprint              ; print one character
sprint:
    mov eax, [esi]          ; string char to AL
    lea esi, [esi+1]
    cmp al, 0
    jne dochar               ; else, we're done
    cmp byte [xpos], 80
    jl .jump_block
    add byte [ypos], 1       ; down one row
.jump_block:
    mov byte [xpos], 0       ; back to left
    ret
 
cprint:
    mov ah, 0x05             ; attrib = white on black
    mov ecx, eax             ; save char/attribute
    movzx eax, byte [ypos]
    mov edx, 320             ; 2 bytes (char/attrib)
    mul edx                  ; for 80 columns
    movzx ebx, byte [xpos]
    shl ebx, 1               ; times 2 to skip attrib
 
    mov edi, 0xb8000         ; start of video memory
    add edi, eax             ; add y offset
    add edi, ebx             ; add x offset
 
    mov eax, ecx             ; restore char/attribute
    mov word [ds:edi], ax
    add byte [xpos], 1       ; advance to right
 
    ret
                
;------------------------------------

xpos db 0
ypos db 0
reg32 dd 0 