.model tiny

.data
	destString	db	"Hello, my dear", 0
	string		db	"Hi!", 0
	actualStrLen	equ	$ - string - 1

	actualMsg	db 	"actual ", 0
	strlenMsg	db 	"strlen: ", 0

	number		dw	12345
	buffer		db	6 dup (0)

	strNumber	db	"1288845", 0

.code
org 100h

_start:
	; Push for constant doesn't exist
	push word 0000h
	push word 0007h
	push offset destString
	push word 0B800h
	call printStr_cdecl	

	; STRLEN_CDECL
	;push offset string
	;call strlen_cdecl
	;add sp, 2

	; ATOI_CDECL
	;push offset strNumber
	;call atoi_cdecl	
	;add sp, 2

	; PRINT STRING
	;mov ax, 0B800h
	;mov es, ax
	;xor di, di

	;mov si, offset strNumber	; string to print
	;mov ah, 07h			; string color
	;call printStr


	; FIND CHAR
	;mov ax, ds
	;mov es, ax

	;mov di, offset string
	;mov al, '!'
	;call strchr
	; END FIND CHAR

	;mov ax, 0B800h
	;mov es, ax
	;mov al, [di]
	;mov si, di
	;mov di, 160
	;mov ah, 0Eh
	;call printChar
exit:
	mov ax, 4C00h
	int 21h		

include 04strlib.asm
include W:\PROGS\05STACK\05wraps.asm

length_of_program	equ	$ - _start

end _start