.model tiny
.code		
					
org 100h

start:
	mov bx, word ptr [videoMemAddr]
	mov es, bx
	
	mov ax, word ptr [whitespace]	; Rectangle fill symbols - whitespace
																																				
	mov cx, x2 - x1			; window width
	mov bx, y2 - y1			; window height
	
	mov di, (80 * y1 + x1) * 2	; offset of start of each line
	xor si, si			; counter


;-----------------------------------------------------------------------------
;---Whitespace all memory cells (video memory) where rectangle will be drawn--
x1_to_x2:
	; 2 lines below are stosw instruction
	mov es:[di], ax			; placing chars directly to video mem
	add di, 2
	
	loop x1_to_x2			; loop is:
					;	1. dec cx
					;	2. cmp cx, 0
					;	2. jnz <label_name>

y1_to_y2:
	add di, (80d - (x2 - x1)) * 2
	inc si

	mov cx, x2 - x1
	cmp si, bx			
	jne x1_to_x2
;-----------------------------------------------------------------------------

;------------------------------------DRAW-------------------------------------
; 3 lines below are drawing an up left corner
	mov di, (80 * y1 + x1 - 1 - 80) * 2
	mov ax, word ptr [upLeft]
	stosw

	mov ax, word ptr [horizontalPipe]
	mov cx, x2 - x1

; ----------------------DRAWING first horizontal line--------------------------
; Loop below is rep stosw instruction
	loopVertical:
	mov es:[di], ax
	add di, 2	

	dec cx
	cmp cx, 0
	jnz loopVertical	
	
	mov ax, word ptr [upRight]
	stosw
;-----------------------END DRAWING first horizontal line---------------------

;--------------DRAW BOTH LEFT AND RIGHT VERTICAL RECTANGLE SIDES--------------	
	mov di, (80 * y1 + x1 - 1) * 2
	mov ax, word ptr [verticalPipe]
	xor si, si			; drawn vertical rectangle side counter

rightVerticals:
	mov cx, y2 - y1
verticals:
	stosw

	add di, 79d * 2
	loop verticals

; IF loop completed then we've drawn one side (left side), now draw right side	
	inc si				; we successfully draw one (left) side	

	mov di, (80 * y1 + x2) * 2
	cmp si, 2d	
	jne rightVerticals
; ----------------END DRAWING BOTH RECTANGLE VERTICAL SIDES--------------------

; --------------------DRAW BOTTOM RECTANGLE HORIZONTAL LINE--------------------	
	mov ax, word ptr [downLeft]
	mov di, (80 * y2 + x1 - 1) * 2
	stosw
			
	mov ax, word ptr [horizontalPipe]
	mov cx, x2 - x1
	rep stosw	

	mov ax, word ptr [downRight]
	stosw
; ----------------END DRAWING BOTTOM RECTANGLE HORIZONTAL LINE-----------------
								
exit:
	mov ax, 4c00h																					
	int 21h

.data
	videoMemAddr	dw	0B800h
	
	x1		equ	1
	y1		equ	1
	x2		equ	70
	y2		equ	10

	whitespace	equ	0e00h

	; TODO: command line arguments (determine color, user frame)
	upLeft		dw 	0FC9h																							
	downLeft	dw	0FC8h
	upRight		dw	0FBBh
	downRight	dw	0FBCh
	verticalPipe	dw	0FBAh
	horizontalPipe	dw	0FCDh

end start