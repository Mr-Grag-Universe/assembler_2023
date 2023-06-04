bits	64

section .data
a	dw	32767; 10
b	dw	32767; 3
c	dw	1; 4
d	dw	-1; 10
e	dw	32767; 8

numirator   dq	0
denominator dq	0

res	dq	0

section .text
global _start

; (a*(b+c) - (e+a)*d) / (d^2 - c^2*b)

return_1:
	mov	rax, 60
	mov	rdi, 1
	syscall
	ret

_start:
	; (e_16 + a_16) -> ebx_32
	movsx	ebx, word[e]
	movsx	ecx, word[a]
	add	ebx, ecx

	; (e + a)_32*d_16 -> rsi_64
	movsx	rax, word[d]
	movsx	rbx, ebx
	imul	rbx
	mov	rsi, rax
	
	; (b_16 + c_16) -> ebx_32
	movsx	ebx, word[b]
	movsx	ecx, word[c]
	add	ebx, ecx

	; (b + c)_32*a_16 -> rax_64
	movsx	rax, word[a]
	movsx	rbx, ebx
	imul	rbx

	; (((b + c)*a)_64 - ((e + a)*d)_64) ?-> numirator
	sub	rax, rsi
	; need to check overflow
	jo	return_1
	mov	QWORD[numirator], rax	

	; (c_16^2 * b_16) -> rdi
	movsx	rax, word[c]
	imul	rax
	movsx	rbx, word[b]
	imul	rbx
	mov	rdi, rax

	; d_16^2 -> eax
	movsx	eax, word[d]
	imul	eax

	; (d_16^2 - c_16^2*b_16) ?-> denominator
	movsx	rax, eax
	sub	rax, rdi
	jo	return_1
	mov	QWORD[denominator], rax

	; res -> rsi
	mov	rax, QWORD[numirator]
	mov	rcx, QWORD[denominator]
	; check devision by zero
	cmp	rcx, 0
	jz	return_1
	cqo
	idiv	rcx
	mov	QWORD[res], rax

	mov	rax, 60
	mov	rdi, 0
	syscall

