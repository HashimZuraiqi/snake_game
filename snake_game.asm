.data
    
.stack
    dw 128 dup(?)
.code
    ;code init
    mov ax, @data
    mov ds, ax
    
    ;video text mode
    mov ah, 0
    mov al, 03h
    int 10h
    
    draw_border:
        ;set cursor posotion at start of the screen (0,0)
        mov ah, 2
        mov dh, 0 ;row
        mov dl, 0 ;column
        mov bh, 0 ;page
        int 10h
        
        ;write upper left corner on that cursor location using teletype interupt (it updates the cursor automatically)
        mov ah, 0Eh
        mov al, 218
        int 10h
             
        ;upper border
        mov cx, 78
        upper_border:
            mov ah, 0Eh
            mov al, 196
            int 10h
        loop upper_border
        
        ;upper right corner       
        mov ah, 0Eh
        mov al, 191
        int 10h
        
        
        ;right column we need to make a loop making sure that the row location are changing not the columns
        mov cx, 23
        mov dh, 1
        right_column:
            mov ah, 2
            mov dl, 79
            mov bh, 0
            int 10h
            
            mov ah, 0Eh
            mov al, 179
            int 10h
            
            inc dh
            
        loop right_column
        
        ;lower right corner
        mov ah, 2
        mov dh, 24
        mov dl, 79
        mov bh, 0
        int 10h
        
        mov ah, 0Eh
        mov al, 217
        int 10h
        
        ;lower border
        mov ah, 2
        mov dh, 24
        mov dl, 1
        mov bh, 0
        mov cx, 78
        int 10h
        lower_border:
            mov ah, 0Eh
            mov al, 196
            int 10h
        loop lower_border
        
        ;lower left corner
        mov ah, 2
        mov dh, 24
        mov dl, 0
        mov bh, 0
        int 10h
        mov ah, 0Eh
        mov al, 192
        int 10h
        
        ;left column
        mov cx, 23
        mov dh, 23
        left_column:
            mov ah, 2
            mov dl, 0
            mov bh, 0
            int 10h
            
            mov ah, 0Eh
            mov al, 179
            int 10h
            
            dec dh
        loop left_column
        
        
;int to end the program
mov ax, 4C00h
int 21h