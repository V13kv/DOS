.code

;------------------------------------------------------------------------------
; Description: construct string representation of command line
; Preparation: not needed
; Changed registers:
; Return: command prompt string address in 'dx' register with the length of 'di'
;------------------------------------------------------------------------------
	
promptStart	db 	"keklshell:"
driveLetter	db	"C:"
currwd		db	64 dup (?)
promptEnd	db 	"$", 0
promptLength	equ	$ - promptStart

cmdPromptCtor proc

	; Get current drive letter (as string)
	mov ah, 19h
	int 21h
	add al, 'A'

	mov byte ptr [driveLetter], al
	
	; Get current directory (cwd)
	mov ah, 47h
	mov dl, 00h
	mov si, offset currwd
	int 21h

	; Get string length (DO PROCEDURE, LIB for string procedures)
	mov al, 00h			; find 0 - end of cwd string
	mov di, offset promptStart
	mov cx, promptLength
	repne scasb
	dec di				; now di points to 0 byte (end of cwd)

	; Concatenate promptEnd with other prompt parts
	mov al, promptEnd
	mov [di], al
	inc di

	; Get actual length of command prompt
	mov dx, offset promptStart
	sub di, dx			; di - length of command line prompt
	
	ret
	
cmdPromptCtor endp