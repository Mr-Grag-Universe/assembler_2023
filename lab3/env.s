bits	64

section	.text
global	get_env_value


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
get_env_ptr:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 24
	mov	qword[rbp-8], rdi
	mov	qword[rbp-16], rsi
	mov	qword[rbp-24], 0

while_get_env_ptr:
	mov	rax, qword[rbp-8]
	cmp	qword[rax], 0
	je	end_of_env_get_env_ptr

	mov	rsi, qword[rbp-16]
	mov	rdi, qword[rax]
	mov	rdx, 3
	call	strcmp

	cmp	al, 1
	je	end_while_get_env_ptr

	inc	qword[rbp-24]
	add	qword[rbp-8], 8
	jmp	while_get_env_ptr
end_while_get_env_ptr:
	mov	rsi, qword[rbp-8]
	mov	rsi, qword[rsi]
	mov	rax, rsi
	add	rsp, 24
	leave
	ret
end_of_env_get_env_ptr:
	mov	rax, -1
	leave
	ret
; rax - адрес хранения переменной


; rsi - название переменной
; stack1=[rbp+16] - буфер
; rdi - откуда начинать
get_env_value:
	push	rbp
	mov	rbp, rsp

	; sub	rsp, 8
	; mov	qword[rsp], qword[rbp+16]

	; mov	rdi, rdx
	call	get_env_ptr
	cmp	rax, -1
	jne	else_get_env_value
	leave
	ret

else_get_env_value:

	push	rax

	mov	rsi, rax
	xor	rax, rax
	; serching for place where value starts
while1_get_env_value:
	lodsb
	cmp	al, '='
	je	end_while1_get_env_value
	jmp	while1_get_env_value
end_while1_get_env_value:
	push	rsi

	mov	rax, 0
	mov	rdi, qword[rbp+16] ; buffer
while_get_env_value:
	lodsb
	mov	byte[rdi], al
	cmp	al, 0
	je	end_while_get_env_value
	inc	rdi
	jmp	while_get_env_value

end_while_get_env_value:
	mov	rdx, rsi
	pop	rcx		; saver pointer on the start
	sub	rdx, rcx
	; add	rsp, 8
	mov	rax, rdx

	leave
	ret

