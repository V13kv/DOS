.model tiny
.code	

org 100h

start:
	; Set video mode
	mov ax, 0013h
	int 10h

	mov di, 0
	
	mov cx, 1
	mov bl, color
	mov ah, 0Eh

mainLoop:
	mov al, byte ptr [msg + di]
	int 10h

	inc di
	cmp di, len
	jne mainLoop

exit:
	mov ax, 4c00h
	int 21h

.data
	msg	db	"Hello, world!) ahahah FATHER", '$'
	len	equ	$ - msg - 1
	color 	db 	05h

end start