bits	64

section	.text
global _handle_image
global _strange_handle_image

; rdi - a
; rsi - b
max:
	enter	0, 0
	mov	rax, rdi
	cmp	rsi, rdi
	cmova	rax, rsi
	leave
	ret
; rax - max(a, b)
	

; rdi - new_data
; rsi - data
; rdx - x
; rcx - y
; r8 - n
_handle_image:
	enter	20, 0

	mov	rax, rdx
	cqo
	mul	rcx
	mul	r8
	mov	rcx, rax

	xor	rax, rax
for:
	lodsb
	mov	byte[rbp-17], al
	lodsb
	mov	byte[rbp-18], al
	lodsb
	mov	byte[rbp-19], al

	push	rdi
	push	rsi
	movsx	rdi, byte[rbp-17]
	movsx	rsi, byte[rbp-18]
	call	max
	mov	rdi, rax
	movsx	rsi, byte[rbp-19]
	call	max
	pop	rsi
	pop	rdi

	mov	byte[rdi], al
	inc	rdi
	mov	byte[rdi], al
	inc	rdi
	mov	byte[rdi], al
	inc	rdi

	mov	byte[rdi], -1
	cmp	r8, 4
	jne	not_alpha
	mov	al, byte[rsi]
	mov	byte[rdi], al
	inc	rdi
not_alpha:

continue:
	sub	rcx, r8
	add	rsi, r8
	sub	rsi, 3
	cmp	rcx, 0
	jg	for
end_for:

	mov	rax, 1
	leave
	ret


; rdi - new_data
; rsi - data
; rdx - x
; rcx - y
; r8 - n
_strange_handle_image:
	enter	64, 0

	; -8  = i
	; -16 = j
	; -24 = ind
	; -32 = char buf[]
	; -40 = x
	; -48 = y
	; -56 = n
	; -64 = ind

	mov	qword[rbp-40], rdx
	mov	qword[rbp-48], rcx
	mov	qword[rbp-56], r8

	mov	rax, rdx
	cqo
	mul	rcx
	mul	r8
	; mov	rcx, rax

	xor	rax, rax
	mov	qword[rbp-8], 0
	for_1_shi:
		mov	qword[rbp-16], 0
		for_2_shi:
			mov	rax, qword[rbp-8]	; = x
			imul	qword[rbp-40]		; *= i
			add	rax, qword[rbp-16]	; += j
			imul	qword[rbp-56]		; *= n
			mov	qword[rbp-64], rax

			mov	rax, qword[rbp-48]
			sub	rax, qword[rbp-8]
			cvtsi2sd	xmm0, rax
			mov	rax, qword[rbp-40]
			sub	rax, qword[rbp-16]
			cvtsi2sd	xmm1, rax
			divsd	xmm0, xmm1

			cvtsi2sd	xmm2, qword[rbp-48]
			cvtsi2sd	xmm3, qword[rbp-40]
			divsd	xmm2, xmm3

			; if ((y-i) / (x-j) < y / x) {
			; jmp	if_above_shi
			ucomisd		xmm0, xmm2
			jae	if_above_shi

				mov	eax, dword[rsi]
				mov	dword[rdi], eax
				add	rdi, r8
				add	rsi, r8
				jmp	continue_2_shi
			; } else
			if_above_shi:

			lodsb
			mov	byte[rbp-18], al
			lodsb
			mov	byte[rbp-19], al
			lodsb
			mov	byte[rbp-20], al

			push	rdi
			push	rsi
			movsx	rdi, byte[rbp-18]
			movsx	rsi, byte[rbp-19]
			call	max
			mov	rdi, rax
			movsx	rsi, byte[rbp-20]
			call	max
			pop	rsi
			pop	rdi

			mov	byte[rdi], al
			inc	rdi
			mov	byte[rdi], al
			inc	rdi
			mov	byte[rdi], al
			inc	rdi

			mov	byte[rdi], -1
			cmp	r8, 4
			jne	not_alpha_shi
				lodsb
				mov	byte[rdi], al
				inc	rdi
			not_alpha_shi:

			continue_2_shi:
				inc	qword[rbp-16]
				mov	rax, qword[rbp-40]
				cmp	qword[rbp-16], rax
				jl	for_2_shi
		end_for_2_shi:	

		continue_1_shi:
		inc	qword[rbp-8]
		mov	rax, qword[rbp-48]
		cmp	qword[rbp-8], rax
		jl	for_1_shi
	end_for_shi:

	mov	rax, 1
	leave
	ret
