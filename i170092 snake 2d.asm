left equ 0
top equ 2
row equ 15
col equ 40
right equ left+col
bottom equ top+row

.model small
.data          
    msg db "Welcome!!",0
    inst db 0AH,0DH,"Use a, s, d and f to control your snake",0AH,0DH,"Use q anytime to quit",0DH,0AH, "Press any key to continue$"
   
    sar db '^',10,10
    jism db '*',10,11, 3*15 DUP(0)
    
    fruitobjectx db 8
    fruitobjecty db 8

    segcount db 1
    fruitttt db 1

    gameover db 0
    quit db 0   
    latqaotime db 5
    qmsg db "Byeeeeeeeeeeeeee!!",0
    gameomsg db "OOPS!! your snake is no longer alive!", 0
    smsg db "Score: ",0


.stack

    dddd   128  dup(0)


.code

main proc far
	mov ax, @data
	mov ds, ax 
	
	mov ax, 0b800H
	mov es, ax
	
	;clearing the screen
	mov ax, 0003H
	int 10H
	
	lea bx, msg
	mov dx,00
	call writestringat
	
	lea dx, inst
	mov ah, 09H
	int 21h
	
	mov ah, 07h
	int 21h
	mov ax, 0003H
	int 10H
    call printdaba      
    
    
mainloop:       

    call rukjaaaa             
    lea bx, msg
    mov dx, 00
    call writestringat
    call shiftsnake
    cmp gameover,1
    je gameover_mainloop
    
    call keyBfunctions
    cmp quit, 1
    je quitpressed_mainloop
    call fruitpaida
    call draw
    
    jmp mainloop
    
gameover_mainloop: 
    mov ax, 0003H
	int 10H
    mov latqaotime, 100
    mov dx, 0000H
    lea bx, gameomsg
    call writestringat
    call rukjaaaa    
    jmp quit_mainloop    
    
quitpressed_mainloop:
    mov ax, 0003H
	int 10H    
    mov latqaotime, 100
    mov dx, 0000H
    lea bx, qmsg
    call writestringat
    call rukjaaaa    
    jmp quit_mainloop    

    
    

quit_mainloop:
;first clear screen
mov ax, 0003H
int 10h    
mov ax, 4c00h
int 21h  



         


rukjaaaa proc 
    
    mov ah, 00
    int 1Ah
    mov bx, dx
    
jmp_rukjaaaa:
    int 1Ah
    sub dx, bx
   
    cmp dl, latqaotime                                                      
    jl jmp_rukjaaaa    
    ret
    
rukjaaaa endp
   
   


fruitpaida proc
    mov ch, fruitobjecty
    mov cl, fruitobjectx
regen:
    
    cmp fruitttt, 1
    je ret_fruitttt
    mov ah, 00
    int 1Ah
    
    push dx
    mov ax, dx
    xor dx, dx
    xor bh, bh
    mov bl, row
    dec bl
    div bx
    mov fruitobjecty, dl
    inc fruitobjecty
    
    
    pop ax
    mov bl, col
    dec dl
    xor bh, bh
    xor dx, dx
    div bx
    mov fruitobjectx, dl
    inc fruitobjectx
    
    cmp fruitobjectx, cl
    jne nevermind
    cmp fruitobjecty, ch
    jne nevermind
    jmp regen             
nevermind:
    mov al, fruitobjectx
    ror al,1
    jc regen
    
    
    add fruitobjecty, top
    add fruitobjectx, left 
    
    mov dh, fruitobjecty
    mov dl, fruitobjectx
    call readcharat
    cmp bl, '*'
    je regen
    cmp bl, '^'
    je regen
    cmp bl, '<'
    je regen
    cmp bl, '>'
    je regen
    cmp bl, 'v'
    je regen    
    
ret_fruitttt:
    ret
fruitpaida endp


dispdigit proc
    add dl, '0'
    mov ah, 02H
    int 21H
    ret
dispdigit endp   
   
dispnum proc    
    test ax,ax
    jz retz
    xor dx, dx
    ;ax contains the number to be displayed
    ;bx must contain 10
    mov bx,10
    div bx
    ;dispnum ax first.
    push dx
    call dispnum  
    pop dx
    call dispdigit
    ret
retz:
    mov ah, 02  
    ret    
dispnum endp   



setcursorpos proc
    mov ah, 02H
    push bx
    mov bh,0
    int 10h
    pop bx
    ret
setcursorpos endp



draw proc
    lea bx, smsg
    mov dx, 0109
    call writestringat
    
    
    add dx, 7
    call setcursorpos
    mov al, segcount
    dec al
    xor ah, ah
    call dispnum
        
    lea si, sar
draw_loop:
    mov bl, ds:[si]
    test bl, bl
    jz out_draw
    mov dx, ds:[si+1]
    call writecharat
    add si,3   
    jmp draw_loop 

out_draw:
    mov bl, 'F'
    mov dh, fruitobjecty
    mov dl, fruitobjectx
    call writecharat
    mov fruitttt, 1
    
    ret
    
    
    
draw endp



readchar proc
    mov ah, 01H
    int 16H
    jnz keybdpressed
    xor dl, dl
    ret
keybdpressed:
    ;extract the keystroke from the buffer
    mov ah, 00H
    int 16H
    mov dl,al
    ret


readchar endp                    
         
         
         
                  
                    


keyBfunctions proc
    
    call readchar
    cmp dl, 0
    je next_14
    
    ;so a key was pressed, which key was pressed then solti?
    cmp dl, 'w'
    jne next_11
    cmp sar, 'v'
    je next_14
    mov sar, '^'
    ret
next_11:
    cmp dl, 's'
    jne next_12
    cmp sar, '^'
    je next_14
    mov sar, 'v'
    ret
next_12:
    cmp dl, 'a'
    jne next_13
    cmp sar, '>'
    je next_14
    mov sar, '<'
    ret
next_13:
    cmp dl, 'd'
    jne next_14
    cmp sar, '<'
    je next_14
    mov sar,'>'
next_14:    
    cmp dl, 'q'
    je quit_keyBfunctions
    ret    
quit_keyBfunctions:   
    ;conditions for quitting in here please  
    inc quit
    ret
    
keyBfunctions endp


                    
                    
                    
                    
                    
                    
shiftsnake proc     
    mov bx, offset sar
    
    ;determine the where should the sar go solti?
    ;preserve the sar
    xor ax, ax
    mov al, [bx]
    push ax
    inc bx
    mov ax, [bx]
    inc bx    
    inc bx
    xor cx, cx
l:      
    mov si, [bx]
    test si, [bx]
    jz outside
    inc cx     
    inc bx
    mov dx,[bx]
    mov [bx], ax
    mov ax,dx
    inc bx
    inc bx
    jmp l
    
outside:    
    
   
    pop ax
    
    push dx    
    
    lea bx, sar
    inc bx
    mov dx, [bx]
    
    cmp al, '<'
    jne next_1
    dec dl
    dec dl
    jmp done_checking_the_sar
next_1:
    cmp al, '>'
    jne next_2                
    inc dl 
    inc dl
    jmp done_checking_the_sar
    
next_2:
    cmp al, '^'
    jne next_3 
    dec dh               
                   
    
    jmp done_checking_the_sar
    
next_3:
    ;must be 'v'
    inc dh
    
done_checking_the_sar:    
    mov [bx],dx
    call readcharat ;dx

    
    cmp bl, 'F'
    je i_ate_fruit
    

    mov cx, dx
    pop dx 
    cmp bl, '*'    ;the snake bit itself, gameover
    je game_over
    mov bl, 0
    call writecharat
    mov dx, cx
    
    
    
    
    
    cmp dh, top
    je game_over
    cmp dh, bottom
    je game_over
    cmp dl,left
    je game_over
    cmp dl, right
    je game_over
    
    
    
    
    ret
game_over:
    inc gameover
    ret
i_ate_fruit:    

    ; add a new segment then
    mov al, segcount
    xor ah, ah
    
    
    lea bx, jism
    mov cx, 3
    mul cx
    
    pop dx
    add bx, ax
    mov byte ptr ds:[bx], '*'
    mov [bx+1], dx
    inc segcount 
    mov dh, fruitobjecty
    mov dl, fruitobjectx
    mov bl, 0
    call writecharat
    mov fruitttt, 0   
    ret 
shiftsnake endp
   
   
                               
                               
                               
                               
                               
                               
                               
                               
                               
   
         
;Printdaba
printdaba proc
;Draw a box around
    mov dh, top
    mov dl, left
    mov cx, col
    mov bl, '*'
l1:                 
    call writecharat
    inc dl
    loop l1
    
    mov cx, row
l2:
    call writecharat
    inc dh
    loop l2
    
    mov cx, col
l3:
    call writecharat
    dec dl
    loop l3

    mov cx, row     
l4:
    call writecharat    
    dec dh 
    loop l4    
    
    ret
printdaba endp
              
              
              
              
              
              
              
              

writecharat proc
    ;80x25
    push dx
    mov ax, dx
    and ax, 0FF00H
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    
    
    push bx
    mov bh, 160
    mul bh 
    pop bx
    and dx, 0FFH
    shl dx,1
    add ax, dx
    mov di, ax
    mov es:[di], bl
    pop dx
    ret    
writecharat endp
            
            
            
            
            
            
            
            

readcharat proc
    push dx
    mov ax, dx
    and ax, 0FF00H
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1    
    push bx
    mov bh, 160
    mul bh 
    pop bx
    and dx, 0FFH
    shl dx,1
    add ax, dx
    mov di, ax
    mov bl,es:[di]
    pop dx
    ret
readcharat endp        





writestringat proc
    push dx
    mov ax, dx
    and ax, 0FF00H
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    shr ax,1
    
    push bx
    mov bh, 160
    mul bh
    
    pop bx
    and dx, 0FFH
    shl dx,1
    add ax, dx
    mov di, ax
loop_writestringat:
    
    mov al, [bx]
    test al, al
    jz exit_writestringat
    mov es:[di], al
    inc di
    inc di
    inc bx
    jmp loop_writestringat
    
    
exit_writestringat:
    pop dx
    ret
    
writestringat endp
     
     
main endp
          
end main
