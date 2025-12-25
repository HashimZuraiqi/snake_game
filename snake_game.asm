.data
    snake_length db 1   ; current length of the snake starts at 1 (just the head)
    snake_x db 40 ,99 dup(?)  ; array to store x coordinates of snake segments, starts at column 40, max 100 segments
    snake_y db 12 ,99 dup(?)  ; array to store y coordinates of snake segments, starts at row 12, max 100 segments
    game_msg db 'GAME OVER'  ; message to display when player loses
    direction db 0 ; iam implemnting the directions as values 0 for Right, 1 for down, 2 for left and 3 for up
    food_x db ?  ; x coordinate of the food on screen
    food_y db ?  ; y coordinate of the food on screen
    food_exists db 0  ; flag to check if food is currently on screen, 0 means no food, 1 means food exists
.stack
    dw 128 dup(?)  ; allocating 128 words for the stack to store return addresses and local data
.code
    ;code init - initializing the data segment so we can access our variables
    mov ax, @data  ; loading the address of data segment into ax
    mov ds, ax  ; moving it to ds register to set up data segment
    
    ;video text mode - setting up 80x25 text mode for the game
    video:
    mov ah, 0  ; function 0 of int 10h is set video mode
    mov al, 03h  ; mode 03h is 80x25 text mode with 16 colors
    int 10h  ; calling bios video interrupt to set the mode
    
    draw_border:
        ;set cursor posotion at start of the screen (0,0)
        mov ah, 2
        mov dh, 0 ;row
        mov dl, 0 ;column
        mov bh, 0 ;page
        int 10h
        
        ;write upper left corner on that cursor location using teletype interupt (it updates the cursor automatically)
        mov ah, 0Eh  ; teletype output function
        mov al, 218  ; ascii extended character for upper left corner (┌)
        int 10h  ; print the character
             
        ;upper border - drawing horizontal line across the top
        mov cx, 78  ; need to draw 78 characters to fill the space between corners
        upper_border:
            mov ah, 0Eh  ; teletype output function
            mov al, 196  ; ascii extended character for horizontal line (─)
            int 10h  ; print the character
        loop upper_border  ; repeat 78 times, cx decrements automatically
        
        ;upper right corner - completing the top border
        mov ah, 0Eh  ; teletype output function
        mov al, 191  ; ascii extended character for upper right corner (┐)
        int 10h  ; print the character
        
        
        ;right column we need to make a loop making sure that the row location are changing not the columns
        mov cx, 23  ; need 23 vertical characters for the right side (rows 1-23)
        mov dh, 1  ; starting at row 1
        right_column:
            mov ah, 2  ; set cursor position function
            mov dl, 79  ; column 79 is the rightmost column
            mov bh, 0  ; page number 0
            int 10h  ; set the cursor position
            
            mov ah, 0Eh  ; teletype output function
            mov al, 179  ; ascii extended character for vertical line (│)
            int 10h  ; print the character
            
            inc dh  ; move to next row down
            
        loop right_column  ; repeat 23 times
        
        ;lower right corner - starting the bottom border
        mov ah, 2  ; set cursor position function
        mov dh, 24  ; row 24 is the bottom row
        mov dl, 79  ; column 79 is the rightmost column
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position
        
        mov ah, 0Eh  ; teletype output function
        mov al, 217  ; ascii extended character for lower right corner (┘)
        int 10h  ; print the character
        
        ;lower border - drawing horizontal line across the bottom
        mov ah, 2  ; set cursor position function
        mov dh, 24  ; row 24 is the bottom row
        mov dl, 1  ; starting at column 1 (after the corner)
        mov bh, 0  ; page number 0
        mov cx, 78  ; need to draw 78 characters to fill the bottom
        int 10h  ; set the cursor position
        lower_border:
            mov ah, 0Eh  ; teletype output function
            mov al, 196  ; ascii extended character for horizontal line (─)
            int 10h  ; print the character
        loop lower_border  ; repeat 78 times
        
        ;lower left corner - completing the bottom border
        mov ah, 2  ; set cursor position function
        mov dh, 24  ; row 24 is the bottom row
        mov dl, 0  ; column 0 is the leftmost column
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position
        mov ah, 0Eh  ; teletype output function
        mov al, 192  ; ascii extended character for lower left corner (└)
        int 10h  ; print the character
        
        ;left column - drawing vertical line on the left side going upward
        mov cx, 23  ; need 23 vertical characters for the left side
        mov dh, 23  ; starting at row 23 and going upward to row 1
        left_column:
            mov ah, 2  ; set cursor position function
            mov dl, 0  ; column 0 is the leftmost column
            mov bh, 0  ; page number 0
            int 10h  ; set the cursor position
            
            mov ah, 0Eh  ; teletype output function
            mov al, 179  ; ascii extended character for vertical line (│)
            int 10h  ; print the character
            
            dec dh  ; move to next row up
        loop left_column  ; repeat 23 times
        
    initial_snake:  ; drawing the snake at its starting position in the center of the screen
        ;set cursor posotion at start of the screen (40,12)
        mov si, 0  ; index 0 is the head of the snake
        mov ah, 2  ; set cursor position function
        mov dh, snake_y[si]  ; row 12 (middle of screen vertically)
        mov dl, snake_x[si]  ; column 40 (middle of screen horizontally)
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position
        
        mov ah , 0Eh  ; teletype output function
        mov al , '@'  ; the snake head is represented by @ symbol
        int 10h  ; print the snake head

     
    food_generation:  ; generating random position for food on the screen
        cmp food_exists, 1  ; checking if food already exists on screen
        je main_loop  ; if food exists skip generation and go to main loop
        
        x_location:  ; generating random x coordinate for food
            mov ah , 00h  ; form this we get the system time it will be number of tickes till the mid night 18.2 tickes
            int 1Ah  ; bios time interrupt, returns ticks in cx:dx (we use dl as random seed)
            
            mov al, dl  ; it will be in dl so we move it to al so we can use div operand to get the modulus
            mov bl, 78  ; bl is going to be the divisor how much space we are going to have through x div bl means --> ax / bl mod will be saved in ah and dividness will be in al
            mov ah, 0  ; makmeing sure ah is zero so it dont affect the dividation and moduclus
            div bl  ; dividing al by 78, quotient in al, remainder (modulus) in ah
            
            inc ah  ; here we increment 1 beacuse the mod operation will give us 0-77 0 will be collision so we need to increment 1 so it be all inside the borders 1-78
            mov food_x, ah  ; storing the random x coordinate (1-78)
            
        y_location:  ; generating random y coordinate for food
            mov ah, 00h  ; get system time function
            int 1Ah  ; bios time interrupt, returns ticks in cx:dx (we use dl as random seed)
            
            mov al, dl  ; moving low byte of time to al for division
            mov bl, 23  ; dividing by 23 because playable area is 23 rows high (excluding top and bottom borders)
            mov ah, 0  ; clearing ah to ensure clean division
            div bl  ; dividing al by 23, quotient in al, remainder (modulus) in ah
            
            inc ah  ; incrementing by 1 so result is 1-23 (avoiding row 0 which is border)
            mov food_y, ah  ; storing the random y coordinate (1-23)
         
        jmp draw_food  ; now draw the food at the generated coordinates

    draw_food:  ; drawing the food on the screen at the generated position
        mov ah, 2  ; set cursor position function
        mov dh, food_y  ; moving cursor to food y coordinate
        mov dl, food_x  ; moving cursor to food x coordinate
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position

        mov ah, 0Eh  ; teletype output function
        mov al, '*'  ; food is represented by * symbol
        int 10h  ; print the food

        mov food_exists, 1  ; setting flag to 1 indicating food is now on screen
        jmp main_loop  ; jump to main game loop
     
     
     
     
    main_loop:  ; main game loop that handles input and movement
        ; here we will put the user input to determine the movement location of the sanke
        mov si, 0  ; resetting index to 0 for head access
        mov ah, 1  ; check keyboard status function (non-blocking)
        int 16h  ; keyboard interrupt, sets zero flag if no key pressed
        jz no_key  ; if no key pressed (zero flag set) skip to automatic movement
        
        mov ah, 0  ; read keyboard input function (blocking)
        int 16h  ; reads the key and removes it from buffer, ascii in al
        
        cmp al, 'a'  ; checking if player pressed 'a' key
        je left_direction  ; if 'a' pressed rotate direction counter-clockwise
        
        cmp al, 's'  ; checking if player pressed 's' key
        je right_direction  ; if 's' pressed rotate direction clockwise
        
        jmp no_key  ; if neither key pressed continue with current direction
        
    no_key:    ;here we need to make the automatic movement for the snake just erase the head at old position and draw it in new position
        mov ah, 02h  ; set cursor position function
        mov dh, snake_y[si]  ; moving cursor to current head y position
        mov dl, snake_x[si]  ; moving cursor to current head x position
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position
        
        
        mov ah, 0Eh  ; teletype output function
        mov al, ' '  ; erasing the head by printing a space
        int 10h  ; print the space
        
        cmp direction, 0  ; checking if direction is 0 (right)
        je right  ; if right move snake to the right
        
        cmp direction, 1  ; checking if direction is 1 (down)
        je down  ; if down move snake downward
        
        cmp direction, 2  ; checking if direction is 2 (left)
        je left  ; if left move snake to the left
        
        cmp direction, 3  ; checking if direction is 3 (up)
        je up  ; if up move snake upward

    jmp main_loop  ; safety jump back to main loop
    

    left_direction:  ; rotating the direction counter-clockwise (right->up->left->down->right)
        dec direction  ; decrementing direction value (0->3, 1->0, 2->1, 3->2)
        cmp direction, 0FFh  ; checking if direction underflowed (went below 0, becomes 255)
        jne no_key  ; if no underflow continue with new direction
        mov direction, 3  ; if underflowed wrap around to 3 (up)
        jmp no_key  ; continue to movement
        
    right_direction:  ; rotating the direction clockwise (right->down->left->up->right)
        inc direction  ; incrementing direction value (0->1, 1->2, 2->3, 3->0)
        cmp direction, 4  ; checking if direction overflowed (went above 3)
        jne no_key  ; if no overflow continue with new direction
        mov direction, 0  ; if overflowed wrap around to 0 (right)
        jmp no_key  ; continue to movement   
        
    right:  ; moving snake to the right (increasing x coordinate)
        call erase_tail  ; erasing the last segment of snake
        call shift_body  ; shifting all body segments to follow the head
        add snake_x[0], 1  ; moving head one column to the right
        jmp check_wall_collision  ; checking if new position hits wall
    down:  ; moving snake downward (increasing y coordinate)
        call erase_tail  ; erasing the last segment of snake
        call shift_body  ; shifting all body segments to follow the head
        add snake_y[0], 1  ; moving head one row down
        jmp check_wall_collision  ; checking if new position hits wall
    left:  ; moving snake to the left (decreasing x coordinate)
        call erase_tail  ; erasing the last segment of snake
        call shift_body  ; shifting all body segments to follow the head
        sub snake_x[0], 1  ; moving head one column to the left
        jmp check_wall_collision  ; checking if new position hits wall
    up:  ; moving snake upward (decreasing y coordinate)
        call erase_tail  ; erasing the last segment of snake
        call shift_body  ; shifting all body segments to follow the head
        sub snake_y[0], 1  ; moving head one row up
        jmp check_wall_collision  ; checking if new position hits wall
                       
                       
                       
    draw_new:  ; drawing the snake at its new position after movement
        mov ah, 02h  ; set cursor position function
        mov dh, snake_y[0]  ; moving cursor to new head y position
        mov dl, snake_x[0]  ; moving cursor to new head x position
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position

        mov ah, 0Eh  ; teletype output function
        mov al, '@'  ; drawing the head with @ symbol
        int 10h  ; print the head
                      
        mov cl, snake_length  ; loading current snake length
        dec cx  ; decrementing by 1 because head is already drawn
        jz done_drawing  ; if length is 1 (only head) skip body drawing
        
        mov si, 1  ; starting at index 1 (first body segment after head)
        draw_body_loop:  ; looping through all body segments
            mov ah, 02h  ; set cursor position function
            mov dh, snake_y[si]  ; moving cursor to body segment y position
            mov dl, snake_x[si]  ; moving cursor to body segment x position
            mov bh, 0  ; page number 0
            int 10h  ; set the cursor position
            
            mov ah, 0Eh  ; teletype output function
            mov al, 'O'  ; drawing body segment with O symbol
            int 10h  ; print the body segment
            inc si  ; moving to next body segment
        loop draw_body_loop  ; repeat for all body segments
                  
    done_drawing:  ; finished drawing the entire snake
        jmp main_loop  ; return to main game loop
        
                       
    erase_tail:  ; erasing the last segment of the snake from the screen
        mov cx, 0  ; clearing cx register
        mov cl, snake_length  ; loading snake length into cl
        mov si, cx  ; copying length to si to use as index
        dec si  ; decrementing to get index of last segment (length-1)
        
        mov ah, 2  ; set cursor position function
        mov dh, snake_y[si]  ; moving cursor to tail segment y position
        mov dl, snake_x[si]  ; moving cursor to tail segment x position
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position
        
        mov ah, 0Eh  ; teletype output function
        mov al, ' '  ; erasing tail by printing a space
        int 10h  ; print the space
        
       ret  ; returning to caller
                          
                       
    shift_body:  ; shifting all body segments to follow the head (moving backwards from tail)
        mov cx, 0  ; clearing cx register
        mov cl, snake_length  ; loading snake length into cl
        dec cx  ; decrementing because we process length-1 segments
        jz shift_done  ; if length is 1 (only head) nothing to shift
        
        mov si, cx  ; starting at the tail index (last segment)
        shift_loop:  ; looping through segments from tail to head
            mov al, snake_x[si - 1]  ; getting x coordinate of segment in front
            mov snake_x[si], al  ; moving it to current segment position
            
            mov al, snake_y[si - 1]  ; getting y coordinate of segment in front
            mov snake_y[si], al  ; moving it to current segment position
            
            dec si  ; moving to previous segment
            jnz shift_loop  ; continue until we reach the head (si = 0)
                           
    shift_done:  ; finished shifting all segments
        ret  ; returning to caller
        
        
        
    check_wall_collision:  ; checkss if the head is at 0 or 79 or y in 0 or 24 so it did hit the wall so the player lost
        cmp snake_x[0], 0  ; checking if head hit left border (column 0)
        je game_over  ; if yes player loses
        
        cmp snake_x[0], 79  ; checking if head hit right border (column 79)
        je game_over  ; if yes player loses
        
        cmp snake_y[0], 0  ; checking if head hit top border (row 0)
        je game_over  ; if yes player loses
        
        cmp snake_y[0], 24  ; checking if head hit bottom border (row 24)
        je game_over  ; if yes player loses
        
        jmp check_food_collision  ; if no wall collision check if snake ate food
        
        
    check_food_collision:  ; checking if snake head is at same position as food
        mov dl, food_x  ; loading food x coordinate
        cmp snake_x[0], dl  ; comparing head x with food x
        jne draw_new  ; if not equal snake didn't eat food, just draw and continue
        mov dl, food_y  ; loading food y coordinate
        cmp snake_y[0], dl  ; comparing head y with food y
        jne draw_new  ; if not equal snake didn't eat food, just draw and continue
        
        mov food_exists, 0  ; snake ate food so remove it from screen
        inc snake_length  ; incrementing snake length by 1 because it ate food
        jmp food_generation  ; generating new food at random location
        
    game_over:  ; if the player hit the wall he loses and then print game over message
        mov ah, 02h  ; set cursor position function
        mov dh, 12  ; row 12 (middle of screen vertically)
        mov dl, 35  ; column 35 (centering the message horizontally)
        mov bh, 0  ; page number 0
        int 10h  ; set the cursor position
        
        
        mov ah, 0Eh  ; teletype output function
        mov si, 0  ; starting at index 0 of game_msg string
        mov cx, 9  ; game_msg is 9 characters long ('GAME OVER')
        print_msg:  ; looping through each character of the message
            mov al, game_msg[si]  ; loading current character
            int 10h  ; printing the character
            inc si  ; moving to next character
        loop print_msg  ; repeat for all 9 characters
        
    wait_restart:  ; after losing it waits until the user presses r to restart
        mov ah, 00h  ; read keyboard input function (blocking)
        int 16h  ; waiting for key press, ascii value in al
        
        cmp al, 'r'  ; checking if player pressed 'r' key
        je restart_game  ; if 'r' pressed restart the game
        jmp wait_restart  ; if any other key pressed keep waiting for 'r'
        
    restart_game:  ; restart the variables to its itial state before starting the game
        mov food_exists, 0  ; resetting food flag to 0 (no food on screen)
        mov snake_length, 1  ; resetting snake length back to 1 (just the head)
        mov snake_x, 40  ; resetting snake head x to center column (40)
        mov snake_y, 12  ; resetting snake head y to center row (12)
        mov direction, 0  ; resetting direction to 0 (moving right)
        
        ;now we need to reset the video mode to clear the screen and draw the border
        jmp video  ; jumping back to video mode setup to restart the game
        
;int to end the program - commented out because game loops infinitely
;mov ax, 4C00h  ; dos terminate program function
;int 21h  ; dos interrupt to exit

                                                             



