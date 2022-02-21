;-------------------------------CDECL CONVENTION--------------------------------
; Subroutine arguments are passed on the stack in reverse order.
; Integer values and memory addresses are returned in the AX register.
; Registers ax, cx, dx are caller-saved, and the rest are callee-saved.
; The caller cleans the stack after the function call returns.
;-------------------------------------------------------------------------------
strlen_cdecl proc
	; SAVE CONTEXT
	push bp
	mov bp, sp

	; Save used registers in the subroutine strlen
	push bx
	push si
	push di

	mov ax, [bp + 4]
	call strlen

	; RESTORE REGISTERS
	pop di
	pop si
	pop bx

	; RESTORE CONTEXT
	pop bp

	ret

strlen_cdecl endp


printStr_cdecl	proc
	push bp
	mov bp, sp

	push bx
	push si
	push di
	
	mov di, [bp + 10d] ; di - 0000h
	mov ax, [bp + 8d] ; ax - 0007h
	mov si, [bp + 6d] ; si - setString
	mov es, [bp + 4d] ; es = 0B800h
	call printStr

	pop di
	pop si
	pop bx

	pop bp

	ret

printStr_cdecl	endp


atoi_cdecl proc
	; SAVE CONTEXT
	push bp
	mov bp, sp
	
	; register, excluding ax, cx, dx are callee-saved
	push bx
	push si
	push di
	
	mov ax, [bp + 4]
	call atoi

	; restore saved registers
	pop di
	pop si
	pop bx	

	; RESTORE CONTEXT
	pop bp
	
	ret

atoi_cdecl endp


