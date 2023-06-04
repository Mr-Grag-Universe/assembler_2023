bits	64

section .data
a	dw	32000
b	dw	32000
c	dw	32000
d	dw	-32000
e	dw	32000

section .text
global _start

return_1:
	mov	rax, 60
	mov	rdi, 0
	syscall
	ret

_start:
	; (e + c) -> ebx
	movsx	ebx, word[e]
	movsx	ecx, word[a]
	add	ebx, ecx

	; (e+c)*d -> rsi
	movsx	rax, word[d]
	movsx	rbx, ebx
	imul	rbx
	mov	rsi, rax
	
	; (b + c) -> ebx
	movsx	ebx, word[b]
	movsx	ecx, word[c]
	add	ebx, ecx

	; (b + c)*a -> rax
	movsx	rax, word[a]
	imul	rbx

	; ((b + c)*a - (e + c)*d) -> rsi
	sub	rax, rsi
	; need to check overflow
	jo	return_1
	mov	rsi, rax
	
	; (c^2 * b) -> rdi
	movsx	rax, word[c]
	imul	rax
	imul	word[b]
	mov	rdi, rax

	; d*d -> eax
	movsx	eax, word[d]
	imul	eax

	; (d^2 - c^2*b) -> rdi
	sub	rdi, rax
	neg	rdi

	; res -> rsi
	mov	rax, rsi
	idiv	rdi
	; need to check overflow
	mov	rsi, rax

	;or	rax, rax
	;or	rdi, rdi
	mov	rax, 60
	mov	rdi, 0
	syscall

