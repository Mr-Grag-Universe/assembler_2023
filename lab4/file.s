bits	64

section .text
global	open_file
global	read_from_file
global	write_to_file
global	close_file

; rdi - file descriptor
; rsi - buffer address
; rdx - buffer size
read_from_file:
	push	rbp
	mov	rbp, rsp
	mov	rax, 0
	syscall
	leave
	ret
; rax - n bytes've been read


; rdi - file descriptor
; rsi - buffer address
; rdx - buffer size
write_to_file:
	push	rbp
	mov	rbp, rsp
	mov	rax, 1
	syscall
	leave
	ret
; rax - n bytes've been written


; rdi - file name address (0-terminated)
; rsi - flags
; rdx - permission rights
open_file:
	push	rbp
	mov	rbp, rsp
	mov	rax, 2
	syscall
	leave
	ret
; rax - file descriptor

; rdi - descriptor
close_file:
	push	rbp
	mov	rbp, rsp
	mov	rax, 3
	syscall
	leave
	ret
; rax - code of execution
