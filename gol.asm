section .rodata
	align 	16
	str_frmt: 		DB "%s ", 10, 0
	chr_frmt: 		DB "%c ", 10, 0
	dgt_frmt:		DB "%d ", 10, 0
	fopen_read:		DB "r", 0
	length_str:		DB "length=%s",10, 0
	width_str:		DB "width=%s",10, 0
	number_of_generations_str: DB "number of generations=%s",10, 0
	print_frequency_str: DB "print frequency=%s",10, 0
	CODEP 	equ 	0
	SPP		equ 	4

section .data
	align 		16
	STKSIZE 	equ 1024 		;(8 Kb)

section .bss
	align 		16
	CHARFILE:	RESB 1
	CURR: 		RESD 1
	SPT:		RESD 1
	SPMAIN:	 	RESD 1

%macro print_str 1 			; print string
	push	dword %1
	push	str_frmt
	call	printf
	add		esp, 8
%endmacro

%macro print_dgt 1 			; print digit
	push	dword %1
	push	str_frmt
	call	printf
	add		esp, 8
%endmacro

%macro print_chr 1 			; print char
	push 	dword %1
	push 	str_frmt
	call 	printf
	add 	esp, 8
%endmacro

%macro set_cell_value 3 ; 1 - i, 2 - j, 3 - new value
	push 	eax

	mov 	eax, %1
	shl 	eax, 2
	add 	eax, [cellsCurrentStates]	; post:eax value of the cell
	mov		eax, [eax]
	add  	eax, %2
	mov 	byte [eax], %3

	pop 	eax
%endmacro

%macro mmalloc 2
	push 	eax
	;push 	dword %2
	push 	dword %1
	call 	malloc
	add 	esp, 4
	;pop 	dword %2
	mov		%2, eax
	pop 	eax
%endmacro


section .text
	align 	16
	extern 	main
	global 	resume
	extern 	printf
	extern 	debug
	extern 	WorldLength
	extern 	WorldWidth
	extern 	cors
	global 	dFlag
	extern 	cellsCurrentStates
	global 	init_cors
	extern 	scheduler
	extern 	printer
	global 	init_cells_threads
	global 	init_scheduler
	global 	init_printer
	global 	fill_cells_current_states
	extern 	fgetc
	extern 	fopen
	extern 	malloc
	global 	init_co_from_c
	global 	do_resume
	extern 	fclose
	global 	print_debug
	global 	start_co_from_c
	global 	end_co

print_debug:
	push 	dword [esp+4]
	push 	length_str
	call 	printf
	add 	esp, 8
	push 	dword [esp+8]
	push 	width_str
	call 	printf
	add 	esp, 8
	push 	dword [esp+12]
	push 	number_of_generations_str
	call 	printf
	add 	esp, 8
	push 	dword [esp+16]
	push 	print_frequency_str
	call 	printf
	add 	esp, 8
	ret

init_cors:
	mov		eax, [esp+4] 				; amount of cors needed
	mmalloc	eax, [cors]
	ret

init_co_from_c:
	push 	ebp
	mov 	ebp, esp
	pushad
	mov 	ebx, [ebp+8] 				; get co-routine ID number
	shl 	ebx, 2
	add 	ebx, [cors] 				; get COi pointer

	mmalloc 8, [ebx]					; every co-routine has a pointig structure which includes: 
										; pointer to it's stack,
	mov 	ebx, [ebx]
	mmalloc STKSIZE, [ebx+SPP]			; initialize stack
	add 	dword [ebx+SPP], STKSIZE	; stack starts from the higher address and forwards to the lower
	sub 	dword [ebx+SPP], 4

	cmp 	dword [ebp+8], 1 			; if it has id above to 1, it is a cell
	ja 		init_co_from_c_cell

	cmp 	dword [ebp+8], 1 			; if it has id equals to 1, it is printer
	je 		init_co_from_c_printer
										
										; otherwise, it is a scheduler
	mov 	dword [ebx+CODEP], scheduler; pushing pointer to the code the scheduler should run
	call 	co_init
	jmp 	init_co_from_c_finish
	
init_co_from_c_printer:
	mov 	dword [ebx+CODEP], printer	; pushing pointer to the code the scheduler should run
	call 	co_init
	jmp 	init_co_from_c_finish
init_co_from_c_cell:
	mov 	dword [ebx+CODEP], evolution; pushing pointer to the code the co-routine should run from.
	mov		ecx, [ebx+SPP] 				; push i and j to the cell stack
	sub 	ecx, 4

	mov 	edx, 0
	mov 	eax, [ebp+8]
	sub 	eax, 2
	div 	dword [WorldWidth] 			; eax 4 is holds the i, edx 8 the j

	mov 	[ecx], edx
	sub 	ecx, 4
	mov 	[ecx], eax
	mov		[ebx+SPP], ecx
	call 	co_init

init_co_from_c_finish:
	popad
	pop 	ebp
	ret

co_init:	; initiates the stack
	pusha

	mov 	eax, [ebx+CODEP]
	mov 	[SPT], esp 			; save old esp
	mov 	esp, [ebx+SPP]
	mov 	ebp, esp
	push 	eax 				; push initial “return” address
	pushf 						; push flags
	pusha						; push all other registers
	mov 	[ebx+SPP], esp
	mov 	esp, [SPT] 			; Restore old SP

	popa
	ret

resume: 						; save state of caller
	pushf
	pusha
	mov		edx, [CURR]
	mov 	[edx+SPP], esp 		; save current SP
do_resume:				 		; load SP for resumed co-routine
	mov 	esp, [ebx+SPP]
	mov 	[CURR], ebx
	popa 						; restore resumed co-routine state
	popf
	ret 						; "return" to resumed co-routine! 

start_co_from_c:
	push 	ebp
	mov 	ebp, esp
	pushad
	mov 	[SPMAIN], esp 				; save ESP of main ()
	;mov 	ebx, 0 						; gets ID ebp number of a scheduler
	mov 	ebx, [cors] 				; gets a pointer to a scheduler structure
	mov 	ebx, [ebx]
	jmp 	do_resume 					; resume a scheduler co-routine

evolution:
	mov 	ecx, 0 				; counter for surroundings
	mov 	edx, [esp]			; i: 1 if odd, 0 if even
	and 	edx, 1

	; top - left
	mov 	ebx, [esp+4]		; j - coordinate
	dec 	ebx
	add 	ebx, edx
	push 	ebx
	mov 	ebx, [esp+4]		; i - coordinate
	dec 	ebx
	push 	ebx
	call 	cell_value_correct
	add 	esp, 8
	add 	ecx, eax
	sub 	ecx, '0'

	; top - right
	mov 	ebx, [esp+4]		; j - coordinate
	add 	ebx, edx
	push 	ebx
	mov 	ebx, [esp+4]		; i - coordinate
	dec 	ebx
	push 	ebx
	call 	cell_value_correct
	add 	esp, 8
	add 	ecx, eax
	sub 	ecx, '0'

	; left
	mov 	ebx, [esp+4]		; j - coordinate
	dec 	ebx
	push 	ebx
	mov 	ebx, [esp+4]		; i - coordinate
	push 	ebx
	call 	cell_value_correct
	add 	esp, 8
	add 	ecx, eax
	sub 	ecx, '0'

	; right
	mov 	ebx, [esp+4]		; j - coordinate
	inc 	ebx
	push 	ebx
	mov 	ebx, [esp+4]		; i - coordinate
	push 	ebx
	call 	cell_value_correct
	add 	esp, 8
	add 	ecx, eax
	sub 	ecx, '0'

	; bottom - left
	mov 	ebx, [esp+4]		; j - coordinate
	dec 	ebx
	add 	ebx, edx
	push 	ebx
	mov 	ebx, [esp+4]		; i - coordinate
	inc 	ebx
	push 	ebx
	call 	cell_value_correct
	add 	esp, 8
	add 	ecx, eax
	sub 	ecx, '0'

	; bottom - right
	mov 	ebx, [esp+4]		; j - coordinate
	add 	ebx, edx
	push 	ebx
	mov 	ebx, [esp+4]		; i - coordinate
	inc 	ebx
	push 	ebx
	call 	cell_value_correct
	add 	esp, 8
	add 	ecx, eax
	sub 	ecx, '0'
	
								; ecx holds how many surroundings
	call 	cell_value 			; eax holds current cell state
	cmp 	eax, '0'
	je 		cell_dead
	; alive
	cmp 	ecx, 3
	je 		next_is_alive
	cmp 	ecx, 4
	je 		next_is_alive
	jmp 	next_is_dead

cell_dead:
	cmp 	ecx, 2
	je 		next_is_alive
	jmp 	next_is_dead

next_is_alive:
	mov 	edx, '1'
	jmp 	call_scheduler_from_cell
next_is_dead:
	mov 	edx, '0'
	jmp 	call_scheduler_from_cell


cell_value_correct:
	mov 	eax, [esp+4]					;check i
	cmp		eax, -1
	jne		cell_value_correct_i_no_add
	add 	eax, [WorldLength]
cell_value_correct_i_no_add:
	cmp		eax, [WorldLength]
	jb 		cell_value_correct_i_no_sub
	sub 	eax, [WorldLength]
cell_value_correct_i_no_sub:
	mov 	[esp+4], eax

	mov 	eax, [esp+8]					;check j
	cmp		eax, -1
	jne		cell_value_correct_j_no_add
	add 	eax, [WorldWidth]
cell_value_correct_j_no_add:
	cmp		eax, [WorldWidth]
	jb 		cell_value_correct_j_no_sub
	sub 	eax, [WorldWidth]
cell_value_correct_j_no_sub:
	mov 	[esp+8], eax

cell_value:								; pre: i [esp+4] 
										;	   j [esp+8] 
	mov 	eax, [esp+4]
	shl 	eax, 2
	add 	eax, [cellsCurrentStates]	; post:eax value of the cell
	mov		eax, [eax]
	add  	eax, [esp+8]
	mov 	eax, [eax]
	and 	eax, 255
	ret

; granting preemption
call_scheduler_from_cell:
	mov 	ebx, [cors]
	mov 	ebx, [ebx]
	call  	resume
	set_cell_value [esp+4], [esp+8], dl

	mov 	ebx, [cors]
	mov 	ebx, [ebx]
	push 	evolution
	jmp 	resume


fill_cells_current_states:
	push 	ebp
	mov 	ebp, esp

	mov 	eax, [ebp+8]
	lea 	ebx, [fopen_read]
	push 	ebx 			; O_RDWR
	push 	eax
	call 	fopen
	add 	esp, 8

	push 	eax 							; push FILE pointer

	mov 	edx, [WorldLength]
	shl 	edx, 2
	mmalloc edx, [cellsCurrentStates]

	mov 	ebx, [cellsCurrentStates]
	mov 	edx, [WorldWidth]
	mov 	ecx, [WorldLength]
fill_cells_current_states_malloc_array:
	pushad
	dec 	ecx
	
	shl  	ecx, 2
	add 	ebx, ecx
	mmalloc edx, [ebx]

	popad
	loop 	fill_cells_current_states_malloc_array

	mov 	ecx, 0
fill_cells_current_states_read_char:
	mov 	edx, [WorldLength]
	imul 	edx, [WorldWidth]
	cmp 	ecx, edx
	je 		fill_cells_current_states_finish
	
	pop 	eax 			; The pointer to FILE
	push 	ecx
	push 	eax
	call 	fgetc
	mov 	[CHARFILE], eax
	pop 	eax
	pop 	ecx
	push 	eax


	cmp 	byte [CHARFILE], 10
	je 		fill_cells_current_states_read_char
	cmp 	byte [CHARFILE], 13
	je 		fill_cells_current_states_read_char
	cmp 	byte [CHARFILE], ' '
	je 		fill_cells_current_states_read_char

	push 	eax
	push 	ecx
	
	mov 	edx, 0
	mov 	eax, ecx

	div 	dword [WorldWidth] 	; eax holds the i, edx the j

	mov 	ebx, [cellsCurrentStates]
	shl 	eax, 2
	add 	ebx, eax
	mov 	ebx, [ebx]
	add 	ebx, edx

	mov 	cl, [CHARFILE]
	mov 	[ebx], cl

	pop 	ecx
	pop 	eax
	inc 	ecx
	jmp 	fill_cells_current_states_read_char

fill_cells_current_states_finish:
	call 	fclose
	add 	esp, 4
	pop 	ebp
	ret




end_co:
	mov 	esp, [SPMAIN] ; restore state of main code
	popad
	pop 	ebp
	ret
