LOCALS @@

stringEndByte	equ	00h

.data
	base	db	10d

.code


; TODO: 2, 8, 16 radix using shifting not div (or mul)


;-------------------------------------------------------------------------------
; Description: get string length (works as strlen C function)
; Preparation: ax - string address
; Changed registers: di, ax, si
; Return: ax - length of string
;-------------------------------------------------------------------------------
strlen proc
	mov di, ax
	mov si, ax
	mov al, stringEndByte
	cld

;TODO: rep scasb (use cx)
@@findEndOfStrPos:
	scasb				; cmp es:[di], al
					; inc di
	jne @@findEndOfStrPos
	
	dec di				; di now contains address of stringEndByte byte 
	sub di, si			; di now contains actual string length (without stringEndByte)

	mov ax, di			; string length

	ret

strlen endp


;-------------------------------------------------------------------------------
; Description: Output String
; Preparation: 	es - video memory address (0B800h)
;		si - string address
;		ah - string color
;		di - offset by 0B800 (video memory address), output start position
; Changed registers: DF (direction flag), al, si, di
; Return: none
;-------------------------------------------------------------------------------
printStr proc

	cld

@@cycle:
	lodsb			; mov al, ds:[si]
				; inc si
	cmp al, stringEndByte
	je @@done

	call printChar
	jmp @@cycle

@@done:
	ret

printStr endp


;-------------------------------------------------------------------------------
; Description: Output Single Char
; Preparation:	es - video memory address (0B800h)
;		di - offset by 0B800h (video memory address), output start position
;		ah - char color
;		al - char to output
; Changed registers:
; Return:
;-------------------------------------------------------------------------------
printChar 	proc

		stosw

		ret

printChar 	endp
	
;-------------------------------------------------------------------------------
; Description: Find the first occurrence of given char in string (like strchr C func) 
; Preparation:	di - string address
;		al - char to search for
; Changed registers:
; Return: di - address of first occurrence of given char
;-------------------------------------------------------------------------------
strchr proc
	
	cld

@@loop:
	stosb		; cmp al, es:[di]
			; inc di
	jne @@loop
	dec di

@@done:
	ret

strchr endp


;--------------------------------------------------------------------------------
; Description: strncpy C-function
; Preparation: 	di - destination character array address
;		si - source character array address
;		cx - count of characters to copy
; Changed registers:
; Return:
;--------------------------------------------------------------------------------
strncpy proc

	cld

	; Save needed registers
	mov bx, di
	mov dx, si

	; Determine source string length (not including stringEndByte)
	mov ax, si
	call strlen

	; Restore saved registers (cx is not changed by strlen function)
	mov di, bx
	mov si, dx

	; Determine in which loop to go
	cmp cx, ax
	jle @@copyWOfill

@@copyWfill:
	mov bx, cx		; save cx how many bytes user wants to copy to
	mov cx, ax		; save actual src string length
	
	; Self modification code to reconstruct jmp instr
	mov dl, 0EBh
	mov dh, @@fillWStrEndBytes - (jmpStartAddr + jmpInstrLen)
	mov word ptr [jmpStartAddr], dx		; ax contains opcode bytes in reversed order because of little-endian format
	jmp @@copyWOfill 
 
@@fillWStrEndBytes:
	sub bx, ax		; bx contains number of stringEndByte's to write to the destination character array
	mov cx, bx

	mov al, stringEndByte	; with what symbol to fill the rest of the dest string
	rep stosb		; move cx stringEndByte characters
	
	jmp @@done

@@copyWOfill:
	repz movsb		; mov es:[di], ds:[si]
				; inc si
				; inc di
				; dec cx
				; jnz <exit>
				; cmp cx, 0
				; jz <exit>
	jmpStartAddr		equ	$
	jmp @@done
	jmpInstrLen		equ 	$ - jmpStartAddr
	
; TODO: return a copy of dest character array
@@done:
	ret

strncpy endp



;-------------------------------------------------------------------------------
; Description: strncmp C-function
; Preparation: 	si - first string ended with stringEndByte
;		di - second string ended with stringEndByte
;		cx - maximum number of characters to compare
; Changed registers:
; Return:  al = -1 if si appears before di in lexographical order
;	   al = 0 if si and di compare equal, or if cx is zero
;	   al = 1 if si appears after di in lexographical order			
;-------------------------------------------------------------------------------
strncmp proc
	
	cmp cx, 0
	jz @@done

@@cycle:
	; Check for not equivalence
	mov al, [si]
	cmp al, [di]
	jne @@done1

	; Check for string end
	cmp al, stringEndByte
	je @@done1

	; Take another characters
	inc si
	inc di
	
	dec cx
	jcxz @@done2
		
	jmp @@cycle

@@done1:
	sub al, [di]
	jmp @@done

@@done2:
	xor al, al
	jmp @@done

@@done:
	ret

strncmp endp



;-------------------------------------------------------------------------------
; Description: itoa C-function
; Preparation: 	ax - number which will be translated into string
;		di - address of the buffer where the string will be placed
;		bl - radix value:
;			1) 10 - DECIMAL
;			2) 16 - HEX
; Changed registers:
; Return: di - pointer to the beginning of the string
;-------------------------------------------------------------------------------
itoa proc
	
	mov si, di		; save start address of the buffer

	; TODO: decide whether to use 10 or 16 depending on bl
	xor ch, ch
	mov cl, bl		; radix value to cx
@@divloop:
	xor dx, dx		; zero out the remainder
	idiv cx			; ax - quotient
				; dx - remainder

	add dx, '0'		; convert remainder to char representation
	mov [di], dl		; move remainder to the buffer
	inc di	

	cmp ax, 0
	jnz @@divloop

@@reverseBuffer:
	mov dx, si	; save start address of the buffer

	mov cx, di
	sub cx, si	; ax - length of the string
	shr cx, 1	; div string length by 2

	dec di
@@xchgCycle:
	; Exchange values (4 moves are still cheeper than 1 mov + 1 xchg)
	mov al, [si]
	mov bl, [di]

	mov [si], bl
	mov [di], al

	inc si
	dec di

	loop @@xchgCycle

@@done:
	mov di, dx	; pointer to the char buffer
	
	ret

itoa endp



;-------------------------------------------------------------------------------
; Description: atoi C-function
; Preparation: 	si - string address (ending with stringEndByte)
; Changed registers: ax, bx, cx, dx, si, di
; Return: ax - number
;-------------------------------------------------------------------------------
atoi proc
	xor dx, dx		; dx - final number translated from string
	mov bx, si		; save si

	; Get string length
	mov ax, si
	call strlen

	mov cx, ax		; cx - unproceeded chars counter (not including stringEndByte)
	mov si, bx		; restore si
	xor ax, ax

	cld

@@cycle:
	lodsb			; mov al, ds:[si]		
				; inc si

	; Check for the end
	cmp bl, stringEndByte
	je @@done

	sub al, '0'		; al - digit representation

	mov bx, cx		; save cx (unproceeded chars counter)
	dec bx
	
@@degreeCycle:
	mul [base]		; ax - multiplication result, 10 - radix
	loop @@degreeCycle
	
	add dx, ax		; construction of the number

	mov cx, bx		; restore unproceeded chars counter
	loop @@cycle

@@done:
	mov ax, dx		; ax - final number (result)

	ret

atoi endp