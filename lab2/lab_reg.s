bits	64
section .data

size	dd	3, 3

matrix:
	dd	1, 2, 3
	dd	4, 5, 6
	dd	7, 8, 9

section .text
global _start

return_0:
	mov	rdi, 0
	mov	rax, 60
	syscall
	ret

return_1:
	mov	rdi, 1
	mov	rax, 60
	syscall
	ret

brk:
	mov	rax, 12
	syscall
	ret

allocate_memory:
	mov	rax, rdi

	mov	rdi, 0
	call	brk
	mov	r8, rax

	;mov	rdi, 2024
	; mov	rax, rdi	; [rsp+24]
	mul	rsi		; QWORD[rsp+16]
	mul	QWORD[64]
	add	rdi, rax

	mov	rdi, rax
	call	brk

	cmp	rax, -1
	jz	return_0

	leave
	ret	16

deallocat_memory:
	; movb	r8
	ret

heap_sort:
	; push	ebp
	; mov	ebp, esp
	enter	0, 0

	leave
	ret

_start:
	; movsx	rdi, DWORD[size + 4]
	; sub	rsp, 32
	movsx	rax, DWORD[size]
	mov	rdi, rax
	mov	rsi, 64
	; выделяем память под массивчик [(i, ai), ...]
	call	allocate_memory

	call	heap_sort

	call	return_0


