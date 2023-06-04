bits	64

section .data
a	dw	10
b	dw	3
c	dw	4
d	dw	10
e	dw	8

numirator   dd	0
denominator dd	0

res	dd	0

section .text
global _start

; my_proc proc:
	; my code
;	ret
; endp

return_1:
	mov	rax, 60
	mov	rdi, 1
	syscall
	ret

_start:
	; (e + a) -> ebx
	movsx	ebx, word[e]
	movsx	ecx, word[a]
	add	ebx, ecx

	; (e + a)*d -> esi
	movsx	eax, word[d]
	imul	ebx
	; bad
	jo	return_1
	mov	esi, eax
	
	; (b + c) -> ebx
	movsx	ebx, word[b]
	movsx	ecx, word[c]
	add	ebx, ecx

	; (b + c)*a -> eax
	movsx	eax, word[a]
	imul	ebx
	jo	return_1

	; ((b + c)*a - (e + a)*d) -> esi
	sub	eax, esi
	; need to check overflow
	jo	return_1
	mov	esi, eax
	mov	DWORD[numirator], eax	

	; (c^2 * b) -> rdi
	movsx	eax, word[c]
	imul	eax
	imul	word[b]
	jo	return_1
	mov	edi, eax

	; d*d -> eax
	movsx	eax, word[d]
	imul	eax

	; (d^2 - c^2*b) -> rdi
	sub	eax, edi
	jo	return_1
	mov	edi, eax
	mov	DWORD[denominator], edi

	; res -> rsi
	mov	eax, esi
	; check devision by zero
	cmp	edi, 0
	jz	return_1
	mov	ecx, DWORD[denominator]
	cdq
	idiv	ecx
	; need to check overflow
	jo	return_1
	mov	DWORD[res], eax

	mov	rax, 60
	mov	rdi, 0
	syscall

