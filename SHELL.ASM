.model tiny
.186
.code
org 100h

prompt_end	equ	"$"

_start:
	mov sp, 100h + length_of_program + 200h	; Move stack by 200h after
						; program end (additional 100h
						; for PSP)
	
	; TODO: Use mask to determine what to add
	mov ah, 4Ah
	stack_shift = 100h + length_of_program + 200h
	mov bx, (stack_shift shr 4) + 1
	int 21h

	; Fill EPB (Execution Program Block) containing segment addresses
	mov ax, cs
	mov word ptr EPB+4, ax			; Command prompt segment address
	mov word ptr EPB+8, ax			; First FCB (1st cmd parameter) segment address
	mov word ptr EPB+0Ch, ax		; Second FCB (2nd cmd parameter) segment address

main_loop:
	; Getting drive letter (as a char)
	mov ah, 19h
	int 21h	
	add al, 'A'
	mov [drive_letter], al

	; Get current working directory (default directory <=> path)
	mov ah, 47h
	mov dl, 00
	mov si, offset pwd_buffer	; place current path to pwd_buffer (64 bytes)	
	int 21h

	; Get the pointer to the null byte (end of the my command prompt)
	mov al, 0
	mov di, offset prompt_start
	mov cx, prompt_l 
	repne scasb
	dec di

	mov al, prompt_end
	mov [di], al
	inc di

	; Get length of my command prompt
	mov dx, offset prompt_start
	sub di, dx
	
	; Output my command prompt to stdout file
	mov cx, di
	mov bx, 1
	mov ah, 40h
	int 21h

	; Output prompt end symbol to stdout file
;	mov al, prompt_end
;	int 29h

; GET && PROCESS USER INPUT CODE
	; Get user input
	mov ah, 0Ah
	mov dx, offset command_buffer	; buffer contains input terminated with CR (0Dh)
	int 21h

	; Set cursor to start of the line (outputs al character (0Dh <=> \r))	
	mov al, 0Dh
	int 29h

	; Set cursor to next line (outputs al char (0Ah (LF - Line Feed <=> \n (scroll if needed))
	mov al, 0Ah
	int 29h

	; Check if user has typed non-zero length string (command)
	cmp byte ptr command_buffer+1, 0	; command_buffer + 1 store actual length of input (not counting END 0Dh (CR) symbol)
	je main_loop

	; Check input for 'exit' command
	mov di, offset command_buffer+2
	mov si, offset cmd_exit
	mov cx, cmd_exit_l
	repe cmpsb
	jcxz got_exit				; If it is an 'exit' command then exit 	


	; Copy inputed command to allocated command_text buffer	
	xor cx, cx
	mov si, offset command_buffer+2
	mov di, offset command_text
	
	; 2 bottom lines are computing inputed command length (including 0Dh (CR) symbol)
	mov cl, byte ptr command_buffer+1
	inc cl
	rep movsb				; copy

	; Call && Execute 'command.com' with the inputed command
	mov ax, 4B00h
	mov dx, offset command_com
	mov bx, offset EPB
	int 21h

	jmp short main_loop

got_exit:
	int 20h

; My own commands that are handled by my own code
cmd_exit	db	"exit", 0Dh
cmd_exit_l	equ	$ - cmd_exit

; My command line prompt
prompt_start	db	'tinyshell:'
drive_letter	db 	"S", ":"		; Current drive buffer
pwd_buffer	db	64 dup (?)		; Current path buffer 
prompt_l	equ	$-prompt_start

command_com	db	"Z:/COMMAND.COM", 0	; child program that will be executed (in ASCIIZ-string format)
	
EPB		dw	0000			; Segment of environment for child (0000=current environment)
		dw	offset commandline, 0	; Address of command line text to place			
		dw	005Ch, 0, 006Ch, 0	; 005Ch - address of first FCB passed from DOS to our program
						; 006Ch - address of second FCB passerd from DOS to our program
						; this unopened FCBs addresses will be copied to the childs's PSP							

; Lstring format string (first byte - Length in bytes)
commandline	db 	125			; Max length of command line
		db	" /C "			; Text to be passed to the child program
						; It will be copied to the child's PSP at offset 80h	

command_text	db	122 dup (?)		; Inputed command
command_buffer	db 	122			; Maximum acceptable input (in bytes)

length_of_program	equ	$ - _start + 124

end _start	