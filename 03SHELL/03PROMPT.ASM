.model tiny

.data
	; Up left rectangle corner coordinates
	x1	equ 	20
	y1	equ 	4
	
	; Down right rectangle corner coordinates																										
	x2 	equ	60
	y2	equ	14

	;---------------------Command line prompt data-------------------------
	stringColor	db	95h
	calcPosOfText	equ	(80 * y1 + x1) * 2	
	;----------------------------------------------------------------------

.code
org 100h

; TODO: remove basic command line prompt
; TODO: frame animation
_start:
	mov sp, 100h + length_of_program + 200h

	mov ah, 4Ah
	stack_shift = 100h + length_of_program + 200h
	mov bx, (stack_shift shr 4) + 1
	int 21h

	;-------------------DISABLE BACKGROUND BLINK---------------------------
	; TODO: docs
	call disableBgBlink
	;------------------END DISABLING BACKGROUND BLINK----------------------
	
	;-------------------------DRAW FRAME-----------------------------------
	mov bx, 0B800h
	mov es, bx	      ; prepare ES segment register - video mem address 
	
	call drawFrame
	;------------------------END DRAW FRAME--------------------------------

	;----------GET STRING REPRESENTATION OF COMMAND LINE PROMPT------------	
	;TODO: refactor + docs
	call cmdPromptCtor
	;------END GETTING STRING REPRESENTATION OF COMMAND LINE PROMPT--------

	push di		; save command line length

	;-----------------CONSTRUCTED COMMAND LINE PROMPT OUTPUT---------------
	; TODO: refactor + docs	
	mov di, calcPosOfText
	mov si, dx	
	call printString
	;------END CONSTRUCTION OF COMMAND LINE PROMPT OUTPUT------------------	

	; Set cursor position
	mov ah, 02h
	xor bh, bh
	mov dh, 1
	mov dl, 20
	int 10h 
exit:
	mov ax, 4C00h
	int 21h	

include 03dlib.asm
include 03shlib.asm													

length_of_program	equ	$ - _start + 124

end _start				