.data
	;------------------------DRAW FRAME DATA--------------------------------
	whitespaceWAttrs	equ 9100h

	upLeft		dw	0FC9h
	upRight		dw	0FBBh
	downLeft	dw	0FC8h
	downRight	dw	0FBCh
	verticalPipe	dw	0FBAh
	horizontalPipe	dw	0FCDh
	;------------------------END OF DRAW FRAME DATA------------------------

	;------------
	endOfString	db	00h
	;----------
.code

;------------------------------------------------------------------------------
; Description: Frame drawing procedure
; Preparation: Video memory address should be in ES segment register
; Changed registers: ax, cx, bx, di, si
;------------------------------------------------------------------------------		
drawFrame proc
;ARG fillSymbolWAttrs:word

	mov ax, whiteSpaceWAttrs	; Rectangle fill symbols

	mov cx, 76
	mov bx, 23
	mov di, 81
	xor si, si

winWidth:
	stosw
	loop winWidth

winHeight:
	inc si

	mov cx, 76
	cmp si, bx
	jne winHeight	

;another
	mov cx, x2 - x1			; window width
	mov bx, y2 - y1			; window height

	mov di, (80 * y1 + x1) * 2	; offset of start of y1 line
	xor si, si			; counter

;---------------Reset all memory cells that will be used by our frame-----------
x1_to_x2:
	stosw				; placing chars directly to video mem
	loop x1_to_x2

y1_to_y2:
	add di, (80d - (x2 - x1)) * 2
	inc si
	
	mov cx, x2 - x1
	cmp si, bx
	jne x1_to_x2
;-------------------------------------------------------------------------------

;------------------------DRAWING FIRST HORIZONTAL LINE--------------------------
	mov di, (80 * y1 + x1 - 1 - 80) * 2
	mov ax, word ptr [upLeft]	
	stosw

	mov ax, word ptr [horizontalPipe]
	mov cx, x2 - x1
	rep stosw

	mov ax, word ptr [upRight]
	stosw
;---------------------END DRAWING FIRST HORIZONTAL LINE-------------------------
	
;----------------DRAW BOTH LEFT AND RIGHT VERTICALS RECTANGLE SIDES-------------
	mov di, (80 * y1 + x1 - 1) * 2
	mov ax, word ptr [verticalPipe]
	xor si, si			; drawn vertical rectangle side counter
	
rightVerticals:
	mov cx, y2 - y1
verticals:
	stosw
	
	add di, 79d * 2
	loop verticals

	; If loop completed then we've drawn one side (left side), now draw
	; right side	
	inc si				; we successfully draw one (left) side

	mov di, (80 * y1 + x2) * 2
	cmp si, 2d
	jne rightVerticals
;---------------END DRAWING BOTH RECTANGLE VERTICAL SIDES-----------------------

;---------------------DRAW BOTTOM RECTANGLE HORIZONTAL LINE---------------------
	mov ax, word ptr [downLeft]
	mov di, (80 * y2 + x1 - 1) * 2
	stosw

	mov ax, word ptr [horizontalPipe]
	mov cx, x2 - x1
	rep stosw

	mov ax, word ptr [downRight]
	stosw
;-------------------END DRAWING BOTTOM RECTANGLE HORIZONTAL LINE----------------

	ret	

drawFrame endp		

;-------------------------------------------------------------------------------
;---------------------------END OF DRAW FRAME PROCEDURE-------------------------
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Description: Prints any string to the screen
; Used registers:
;	1) Segment: ds, es
;	2) Common: ax, si, di
; Preparation: 
;	1) Video memory address should be in ES segment register;
;	2) di (reg) - offset by ES (ES contains video memory address), where
;	   character will be printed;
;	3) si (reg) - string address.			
; Changed registers: ax
;-------------------------------------------------------------------------------

printString proc
	
	mov ah, stringColor	; attributes of output characters
	 
placeChars:
	lodsb			; Copying each string character to al
	
	cmp al, endOfString
	je done

	stosw			; place each non-end string character directly
				; into video memory
	jmp placeChars

done: 
	ret

printString endp		



disableBgBlink	proc
	mov ax, 1003h
	xor bl, bl
	int 10h	
	
	ret

disableBgBlink	endp