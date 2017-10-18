section .bss
	printRound:	RESD 1 		; should call printer when equals to zero


section .text
	global 		scheduler
	extern 		genNum
	extern 		printFreq
	extern 		numco
	extern 		cors
	extern 		resume
	extern 		end_co
	extern 		dFlag

scheduler:
	mov 	eax, [printFreq]
	mov 	[printRound], eax 				; we need to know when to print cells to screen
	shl 	dword [genNum], 1

	mov 	ebx, [cors]				; printer
	add 	ebx, 4
	mov 	ebx, [ebx]
	call 	resume

	cmp 	byte [dFlag], 0
	je 		reset_edx

	mov 	ebx, [cors]				; printer
	add 	ebx, 4
	mov 	ebx, [ebx]
	call 	resume
	
reset_edx:
	mov 	edx, 2
looper:
	
	cmp 	dword [printRound], 0
	jne 	do_not_print

	mov 	ebx, [cors]				; printer
	add 	ebx, 4
	mov 	ebx, [ebx]
	call 	resume
	
	mov 	eax, [printFreq]
	mov 	[printRound], eax 				; we need to know when to print cells to screen

do_not_print:
	dec 	dword [printRound]

	shl 	edx, 2
	add 	edx, [cors]
	mov 	ebx, edx 						;current cell - not sure if can sum that way
	mov 	ebx, [ebx]
	call 	resume
	sub 	edx, [cors]
	shr 	edx, 2
	inc 	edx
	cmp 	edx, [numco]
	jne 	looper


	dec 	dword [genNum]
	cmp 	dword [genNum], 0
	jne		reset_edx

	mov 	ebx, [cors]				; printer
	add 	ebx, 4
	mov 	ebx, [ebx]
	call 	resume

	jmp 	end_co
