disk_load:
    pusha
    push dx    
    
    mov ah, 0x02 ; read mode
    mov al, dh   ; read dh number of sectors
    mov dh, 0x00 ; head 0
    mov cl, 0x02 ; start from sector 2
                 ; (as sector 1 is our boot sector)
    mov ch, 0x00 ; cylinder 0
    
    ; dl = drive number is set as input to disk_load
    ; es:bx = buffer pointer is set as input as well
        
    int 0x13      ; BIOS interrupt
       
    jc disk_error ; check carry bit for error
    
    mov si, disk_msg
    call outstring 
    
    pop dx     ; get back original number of sectors to read
    cmp al, dh ; BIOS sets 'al' to the # of sectors actually read
               ; compare it to 'dh' and error out if they are !=
                   
    jne sectors_error
        
    mov si, success_msg
    call outstring   
    
    popa
    ret

disk_error:
    mov si, error_msg
    call outstring
    jmp disk_loop

sectors_error:
    mov si, error_msg
    call outstring
    jmp disk_loop

disk_loop:
    jmp $
    
error_msg:
    db 'error, loading', 0
    
disk_msg:
    db 'disk, loading', 0
        
success_msg:
    db 'success, loading',0