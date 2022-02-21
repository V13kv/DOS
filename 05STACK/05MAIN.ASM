.model tiny

.code
org 100h

_start:
	;mov sp, 100h + length_of_program + 200h
	
	push 0AAAAh
	push 0BBBBh

exit:
	mov ax, 4C00h
	int 21h


length_of_program	equ 	$ - _start

end _start