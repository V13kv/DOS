.model tiny

.data
	text		db	"Hello, dear world! KEKL", '$'
	textlen		equ	$ - text - 1
	VRAMCharAttrs	equ 	0Fh	

.code
org 100h

start:
	mov bx, 0b800h
	mov es, bx

;--------------------------------PLACE TEXT INTO VRAM---------------------------
	xor si, si			; text character index
	xor di, di			; VRAM offset

	xor ax, ax
	mov ah, VRAMCharAttrs		; set fg && bg of an output chars

	mov cx, textlen			; total string length (without '$')

printText:
	mov al, byte ptr [text + si]	; char to print
	inc si				; get next char offset

	stosw				; mov es:[di], ax
					; add di, 2
	
	loop printText			; dec cx
					; cmp cx, 0
					; jnz printText
;---------------------------END OF PLACING TEXT INTO VRAM-----------------------

exit:
	mov ax, 4c00h
	int 21h

end start	