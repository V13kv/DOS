;-----------------------------------------------------------------------------
;			Exercise #1. File printwo2.asm
;	Program prints string without using 21h interrupt
;-----------------------------------------------------------------------------
.model tiny	; only one physical segment (for .com program format)
.code

org 100h 	; needed for .com program format (says that machine code starts
	 	; from address (offset) 100h in this segment (.code), effective
		; address is CS:100h.

start:	
	mov di, 0	; counter

	mov cx, 1	; how many symbols to print during each iteration
	mov ah, 0Eh	; video - teletype output

mainLoop:
	mov al, byte ptr [msg+di]	; retrieve character to print
	int 10h				; output character, advancing the cursor

	inc di		; increment counter (because we output 1 char)
	cmp di, len	; compare with the actual string length
	jne mainLoop	; if we didn't display all characters then display them

exit:
	mov ax, 4c00h	; ah = 4ch - exit routine; al = 00h - exit ERRORLEVEL 0
	int 21h		; exit


.data
	msg	db 	"Hello, world! KEKL xD)) MOTHER", '$'
	len	equ	$ - msg - 1	; length of 'msg' string

end start                             
	