%macro print_char 1
	pushad
	push 	%1
	call 	putchar
	add 	esp, 4
	popad
%endmacro

section .bss
	SPMAIN: RESB 4

section .text
	global 	printer
	extern 	cors
	extern 	resume
	extern 	cellsCurrentStates
	extern 	WorldLength
	extern 	WorldWidth
	extern	putchar

printer:
	mov 	eax, 0
print_line:
	mov 	ebx, eax
	and 	ebx, 1
	cmp 	ebx, 0
	je 		even_line
	print_char ' '

even_line:
	mov 	ebx, eax
	shl 	ebx, 2
	add 	ebx, [cellsCurrentStates]
	mov 	ebx, [ebx]
	mov 	ecx, 0

print_line_cell:
	add 	ecx, ebx
	print_char dword [ecx]
	sub 	ecx, ebx

	inc 	ecx
	cmp 	ecx, [WorldWidth]
	je 		print_line_finish

	print_char ' '
	jmp 	print_line_cell

print_line_finish:
	print_char 10
	inc 	eax
	cmp 	eax, [WorldLength]
	jne		print_line

printer_finish:
	print_char 10
	mov 	ebx, [cors]
	mov 	ebx, [ebx]
	push 	printer
	jmp 	resume