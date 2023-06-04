bits	64
section	.data

name:
	db	"ofn", 0
name_len:
	dq	$-name-1

file_name:
	resb	100

section	.text
global	print_env_value


return_0:
	mov	rax, 60
	mov	rdi, 0
	syscall
	ret
return_1:
	mov	rax, 60
	mov	rdi, 1
	syscall
	ret


; rdi - дескриптор
; rsi - буфер
; rdx - размер
write_to_file:
	mov	rax, 1
	syscall
	ret


; rdi - s1
; rsi - s2
; rdx - max size
strcmp:
	push	rbp
	mov	rbp, rsp

	mov	rax, 0
	mov	rcx, 0
	push	rdx
while_strcmp:
	lodsb
	mov	dl, byte[rdi+rcx]
	inc	rcx

	cmp	dl, 0
	je	end_of_str_strcmp
	cmp	al, 0
	je	end_of_str_strcmp

	cmp	dl, al
	jne	return_0_strcmp

	cmp	rcx, qword[rbp-8]
	jge	end_of_str_strcmp

	jmp	while_strcmp

end_of_str_strcmp:
	cmp	al, dl
	jne	return_0_strcmp
	mov	al, 1
	add	rsp, 8
	leave
	ret

return_0_strcmp:
	add	rsp, 8
	mov	al, 0
	leave
	ret


; rsi - строка имя переменной
; rdi - база стека
get_env:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 24
	mov	qword[rbp-8], rdi
	mov	qword[rbp-16], rsi
	mov	qword[rbp-24], 0

while_get_env:
	mov	rax, qword[rbp-8]

	mov	rsi, qword[rbp-16]
	mov	rdi, qword[rax]
	mov	rdx, 3
	call	strcmp

	cmp	al, 1
	je	end_while_get_env

	inc	qword[rbp-24]
	add	qword[rbp-8], 8
	jmp	while_get_env
end_while_get_env:
	mov	rsi, qword[rbp-8]
	mov	rsi, qword[rsi]
	mov	rax, rsi
	add	rsp, 24
	leave
	ret

	add	rsi, qword[name_len]
	inc	rsi

	mov	rdx, 3
	mov	rdi, 1
	syscall

	add	rsp, 24

	leave
	ret
; rax - адрес хранения переменной


; rsi - название переменной
; rdi - буфер
; rdx - откуда начинать
print_env_value:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 8
	mov	qword[rsp], rdi
	; mov	rsi, name
	
	mov	rdi, rdx
	call	get_env

	add	rax, qword[name_len]
	inc	rax

	cmp	rax, 34
	je	return_1

	mov	rsi, rax
	mov	rax, 0
	mov	rdi, qword[rsp] ; file_name
while_start:
	lodsb
	cmp	al, 0
	je	end_while_start

	mov	byte[rdi], al
	inc	rdi
	jmp	while_start

end_while_start:
	; mov	rsi, file_name
	mov	rdx, rdi
	mov	rcx, file_name
	sub	rdx, rcx
	add	rsp, 8
	mov	rax, rdx

	leave
	ret
	; mov	rdi, 1
	; call	write_to_file

	; call	return_0
