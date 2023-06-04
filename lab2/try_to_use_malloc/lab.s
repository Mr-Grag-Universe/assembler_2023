bits	64

extern	_malloc

section	.data

section .text
global	_start

return_0:
	mov	rdi, 0
	mov	rax, 60
	syscall

return_1:
	mov	rdi, 1
	mov	rax, 60
	syscall

_start:
	mov	rdi, 20
	call	_malloc

	call	return_0
