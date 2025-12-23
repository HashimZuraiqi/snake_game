.data
    snake_length db 1   
    snake_x db 40 ,99 dup(?)
    snake_y db 12 ,99 dup(?)
    game_msg db 'GAME OVER'
    direction db 0 ; iam implemnting the directions as values 0 for Right, 1 for down, 2 for left and 3 for up
.stack
    dw 128 dup(?)
.code
    ;code init
    mov ax, @data
    mov ds, ax
    
    ;video text mode
    video:
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
        
    initial_snake:
        ;set cursor posotion at start of the screen (40,12)
        mov si, 0
        mov ah, 2
        mov dh, snake_y[si] ;row
        mov dl, snake_x[si] ;column
        mov bh, 0 ;page
        int 10h
        
        mov ah , 0Eh
        mov al , '@'
        int 10h
    
    main_loop:
        ; here we will put the user input to determine the movement location of the sanke
        mov si, 0
        mov ah, 1
        int 16h
        jz no_key
        
        mov ah, 0
        int 16h
        
        cmp al, 'a'
        je left_direction
        
        cmp al, 's'
        je right_direction
        
        jmp no_key
        
    no_key:    ;here we need to make the automatic movement for the snake just erase the head at old position and draw it in new position
        mov ah, 02h
        mov dh, snake_y[si]
        mov dl, snake_x[si]
        mov bh, 0
        int 10h
        
        
        mov ah, 0Eh
        mov al, ' '
        int 10h
        
        cmp direction, 0
        je right
        
        cmp direction, 1
        je down
        
        cmp direction, 2
        je left
        
        cmp direction, 3
        je up

    jmp main_loop
    
    left_direction:
        dec direction
        cmp direction, 0FFh
        jne no_key
        mov direction, 3
        jmp no_key
        
    right_direction:
        inc direction
        cmp direction, 4
        jne no_key
        mov direction, 0
        jmp no_key   
        
    right:
        add snake_x[si], 1
        jmp check_wall_collision
    down:
        add snake_y[si], 1
        jmp check_wall_collision
    left:
        sub snake_x[si], 1
        jmp check_wall_collision
    up:
        sub snake_y[si], 1
        jmp check_wall_collision
        
    draw_new: ;draw the head location
        mov ah, 02h
        mov dh, snake_y[si]
        mov dl, snake_x[si]
        mov bh, 0
        int 10h

        mov ah, 0Eh
        mov al, '@'
        int 10h
        
        jmp main_loop
        
    check_wall_collision:;checkss if the head is at 0 or 79 or y in 0 or 24 so it did hit the wall so the player lost
        cmp snake_x[si], 0
        je game_over
        
        cmp snake_x[si], 79 
        je game_over
        
        cmp snake_y[si], 0
        je game_over
        
        cmp snake_y[si], 24
        je game_over
        
        jmp draw_new
        
    game_over:; if the player hit the wall he loses and then print game over message
        mov ah, 02h
        mov dh, 12
        mov dl, 35
        mov bh, 0
        int 10h
        
        
        mov ah, 0Eh
        mov si, 0
        mov cx, 9
        print_msg:
            mov al, game_msg[si]
            int 10h
            inc si
        loop print_msg
        
    wait_restart:;after losing it waits until the user presses r to restart 
        mov ah, 00h
        int 16h
        
        cmp al, 'r'
        je restart_game
        jmp wait_restart
        
    restart_game:;restart the variables to its itial state before starting the game
        mov snake_length, 1 
        mov snake_x, 40
        mov snake_y, 12
        mov direction, 0
        
        ;now we need to reset the video mode to clear the screen and draw the border
        jmp video
        
;int to end the program
;mov ax, 4C00h
;int 21h

                                                             



