bits	64
section .data
input_file:
	db	"input", 0
output_file:
	db	"output", 0

section .text
global	_start

return_0:
	mov	rax, 60
	mov	rdi, 0
	syscall
	ret

; rdx - rights
; rsi - flags
; rdi - name
open_file:
	mov	rax, 2
	syscall
	ret
; rax - descriptor

; rdi - descriptor
close_file:
	mov	rax, 3
	syscall
	ret

_start:
	mov	rdx, 0
	mov	rsi, 100
	mov	rdi, output_file
	call	open_file


	call	return_0
