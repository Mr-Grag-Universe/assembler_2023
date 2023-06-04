bits	64

section .data
err1	dw	0

buf	resb	10

hello_str:
			db	"Hello! Enter your str here: ", 0
hello_str_len	equ	$-hello_str

error_env:
			db	"there is not ofn in environment!", 0x0a, 0
error_env_len	equ	$-error_env

delimiters1:
	db	' ', 0x09, 0x0a, ",;.", 0
delimiters2:
	db	' ', 0x09, ",;.", 0

chr			db	0
chr_uninit		db	1

delim			db	1
new_delim		db	1

s_delim			db	0
new_s_delim		db	0

d_1			dq	0
d_2			dq	0

input_file:
	db	"input1", 0
output_file:
	resb	100			; db	"output.txt", 0
file_val:
	db	"ofn", 0

section .text
global	_start

; syscalls for file handling
extern	read_from_file
extern	write_to_file
extern	open_file
extern	close_file

; str functions
extern	symbol_in_str

extern	get_env_value

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


;==================================<{ collaps }>===============================


; rsi - указатель на строку
; rdx - размер буфера
collaps_spaces:
	push	rbp
	mov	rbp, rsp

	cmp	rdx, 0
	jle	return_cs

	push	rdx

	sub	rsp, 8
	push	rdx
	mov	dl, byte[delim]
	mov	byte[rsp+8], dl		; flag
	pop	rdx

	mov	rbx, 0
	mov	rcx, rdx
for:
	cmp	rbx, qword[rsp+8]
	jl	else_norm

	mov	rbx, 0

else_norm:
	lodsb				; читаем символ в al

	push	rax
	push	rsi
	mov	rsi, delimiters2
	call	symbol_in_str
	pop	rsi
	mov	dl, al
	pop	rax
	cmp	dl, 1
	jne	if_is_not_sep

	mov	rax, 0x20

if_is_not_sep:

; if (s[i] == ' ') {
	push	rax
	push	rsi
	mov	rsi, delimiters1
	call	symbol_in_str
	pop	rsi
	cmp	al, 1
	jne	if_not_space

	pop	rax
	; if (flag == 1) {
	cmp	byte[rsp], 1
	jne	if_first_space

	cmp	al, 0x0a
	jne	if_not_endl_cs_1

	cmp	rbx, 0
	jle	if_rbx_0

	cmp	byte[buf+rbx-1], 0x0a
	je	if_endl_before

	mov	byte[buf+rbx-1], 0x0a
	jmp	if_not_endl_cs_1

if_endl_before:
	mov	byte[buf+rbx], 0x0a
	inc	rbx
	jmp	if_not_endl_cs_1
		; continue

if_rbx_0:
	mov	byte[buf], 0x0a
	inc	rbx

if_not_endl_cs_1:
	jmp	continue_cs
	; }
	; else {
if_first_space:
	; flag = 1
	mov	byte[rsp], 1
	jmp	end_if
	; }
; }
; else {
if_not_space:
	pop	rax
	; flag = 0
	mov	byte[rsp], 0
; }
end_if:
	mov	byte[buf+rbx] , al
	inc	rbx

continue_cs:
	dec	rcx
	cmp	rcx, 0
	jg	for

	pop	rdx

	mov	rax, rbx

return_cs:
	leave
	ret
; rax - возвращаем новый размер строки


; ==============================<{ handler }>===============================


; rdi - первый символ слова
; rsi - указатель на строку
; rdx - размер буфера
handle_str:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 16
	mov	ch, 0
	mov	r10, 1

	; ставим начальный флаг разделителя
	xor	rax, rax
	mov	al, byte[buf]
	push	rsi
	push	rdx
	mov	rsi, delimiters1
	call	symbol_in_str
	mov	byte[rbp-8], al
	pop	rdx
	pop	rsi

	; выставляем флаг плохого слова
	; mov	byte[rbp], 0
	; mov	rcx, 0
	; cmp	al, byte[chr]
	; cmovne	rcx, r10
	; mov	byte[rbp], cl
	; pop	rsi

	; количество итераций = размеру куска
	mov	rcx, rdx
	; другой итератор для строки
	mov	rbx, rsi

	; согласуем флаг плохого слова с предыдущим куском (строкой)
	mov	qword[rbp], r12
	movsx	r8, byte[delim]
	mov	qword[rbp-8], r8

for_hs:
; ====================
	; if (i <= 0) i = 0 - глупая страховка
	cmp	rcx, 0
	jg	rcx_positive
	mov	rcx, 0
	jmp	end_for_hs
	rcx_positive:
; ====================

	lodsb				; подгружаем новый символ

	; if (s[i] == ' ')
	push	rsi
	push	rax
	push	rdx
	mov	rsi, delimiters1
	call	symbol_in_str
	mov	r13, rax
	pop	rdx
	pop	rax
	pop	rsi
	cmp	r13, 1			; if (s[i] == ' ')
	jne	else_1_hs

	cmp	al, 0x0a
	jne	not_endl_hs_1

	mov	r9, 1

	mov	byte[chr_uninit], 1
	mov	byte[chr], 0

	mov	byte[rbx], 0x0a
	inc	rbx
	mov	byte[delim], 1
	mov	byte[s_delim], 0

	mov	byte[rbp], 0
	mov	byte[rbp-8], 0

while_2_hs:
	mov	r13, rsi
	sub	r13, buf
	cmp	r13, rdx
	jge	end_for_hs

	lodsb
	dec	rcx
	cmp	al, 0x0a
	jne	else_while_2_hs

	mov	byte[rbx], 0x0a
	mov	byte[s_delim], 0
	inc	rbx
	jmp	continue_while_2_hs

else_while_2_hs:
	push	rsi
	push	rdx
	mov	r13, rax
	mov	rsi, delimiters2
	call	symbol_in_str
	pop	rdx
	pop	rsi
	cmp	al, 1
	je	continue_while_2_hs_1

	mov	rax, r13
	mov	byte[chr], al
	mov	byte[chr_uninit], 0
	mov	byte[rbx], al
	inc	rbx
	mov	byte[delim], 0
	mov	byte[s_delim], 0

	jmp	continue_for_hs

continue_while_2_hs_1:
	mov	byte[s_delim], 1

continue_while_2_hs:
	mov	byte[delim], 1
	; dec	rcx
	jmp	while_2_hs
end_while_2_hs:

not_endl_hs_1:
	mov	r9, 0

	mov	byte[rbp], 0		; flag = 0
	mov	byte[rbx], al		; s[j] = s[i]
	inc	rbx			; ++j
	mov	byte[rbp-8], 1		; space = 1
	mov	byte[delim], 1
	mov	byte[s_delim], 1
	jmp	continue_for_hs		; continue

	; добавить условие на '\n'

else_1_hs:				; else if (s[i] != ' ')
	mov	r9, 0

	cmp	byte[rbp], 1		; if (flag == 1) - если мы идём по плохому слову
	jne	else_2_hs

	jmp	continue_for_hs		; continue

else_2_hs:				; else if (flag == 0) - если мы идём по хорошему слову
	cmp	byte[rbp-8], 0		; if (space == 0)
	jne	else_4_hs		; 

	mov	byte[rbx], al		; s[j] = s[i]
	inc	rbx			; ++j
	jmp	continue_for_hs		; continue

else_4_hs:				; else if (space == 1) если мы наступили на новое слово
	cmp	al, byte[chr]		; if (s[i] != chr) - новое слово плохое
	je	else_3_hs

	mov	byte[rbp], 1		; flag = 1
	mov	byte[rbp-8], 0		; space = 0
	jmp	continue_for_hs		; continue

else_3_hs:				; else if (s[i] == chr) - новое слово хорошее
	mov	byte[rbp], 0		; flag = 0
	mov	byte[rbp-8], 0		; space = 0
	mov	byte[delim], 0
	mov	byte[s_delim], 0
	mov	byte[rbx], al		; s[j] = s[i]
	inc	rbx			; ++j

continue_for_hs:
	dec	rcx
	jmp	for_hs
	; loop	for_hs			; }
end_for_hs:

	; вычисляем новую длину слова
	sub	rbx, buf
	mov	rax, rbx
	mov	r12, qword[rbp]
	mov	r8, qword[rbp-8]

	add	rsp, 16
	leave
	ret
; rax - возвращает размер новой строчки


; ================================================================================


%macro	calculate_offset 2
	push	rax
	mov	rax, %1
	sub	rax, %2
	xchg	qword[rsp], rax
%endmacro


; ===========================| strip |==========================

; rsi - адрес на начало строки
; rdi - размер строки
strip:
	mov	rcx, 0
	push	rdi
while_1:
	cmp	rcx, rdi
	jge	end_while_1

	lodsb
	inc	rcx

	push	rsi
	mov	rsi, delimiters2
	call	symbol_in_str
	pop	rsi
	cmp	al, 1
	je	while_1

end_while_1:
	pop	rdi
	dec	rcx

	dec	rdi
while_2:
	cmp	rcx, rdi
	jge	end_while_2

	mov	al, byte[buf+rdi]
	dec	rdi

	push	rax
	push	rsi
	mov	rsi, delimiters2
	call	symbol_in_str
	pop	rsi
	cmp	al, 1
	je	else_strip

	pop	rax
	jmp	end_while_2
else_strip:

	pop	rax
	jmp	while_2
end_while_2:
	add	rdi, 2

	; rcx = длина нового слова
	; rbx = отступ = rcx0 + длина слова
	; rdx = длина нового слова

	; новая длина слова
	mov	r10, rdi
	sub	r10, rcx
	xchg	r10, rcx

	; отступ
	mov	rbx, rdi

	; новая длина строки
	mov	rdx, rcx

	push	rdx
for_strip:

	calculate_offset    rbx, rcx
	pop	rax
	mov	dl, byte[buf+rax]

	calculate_offset   qword[rsp+8], rcx
	pop	rax
	mov	byte[buf+rax], dl

	loop	for_strip

	pop	rax

	ret

; ==========================<{ strip right }>===============================


; rsi - адрес на начало строки
; rdi - размер строки
strip_right:
	dec	rdi
while_sr_2:
	cmp	rdi, 0
	jle	end_while_sr_2

	mov	al, byte[buf+rdi]
	dec	rdi

	push	rax
	push	rsi
	mov	rsi, delimiters2
	call	symbol_in_str
	pop	rsi
	cmp	al, 1
	je	else_sr

	pop	rax
	inc	rdi
	jmp	end_while_sr_2
else_sr:
	pop	rax
	jmp	while_sr_2

end_while_sr_2:
	inc	rdi

	; новая длина слова
	mov	rax, rdi
	ret


; ==========================<{ find not delim }>===========================


; rsi - str
; rdi - delimiters
; rdx - size
find_not_delim:
	mov	al, 0

	cmp	rdx, 0
	jle	return_fnd

	mov	rcx, rdx
for_fnd:
	lodsb
	cmp	al, 0x0a
	je	return_fnd

	push	rsi
	mov	rsi, rdi
	call	symbol_in_str

	pop	rsi
	cmp	al, 0
	jne	else_fnd

	mov	al, 1
	ret
else_fnd:
	loop	for_fnd

return_fnd:
	mov	al, 0
	ret
; al - True/False


; ==============================| start |====================================

_start:
	; выводим приглашение к вводу
	mov	rdi, 1
	mov	rsi, hello_str
	mov	rdx, 31
	; call	write_to_file

	mov	rdi, output_file
	mov	rsi, file_val
	mov	rcx, qword[rsp]
	lea	rdx, [rsp+8*rcx+16]
	push	rdx
	xchg	rdi, qword[rsp]
	call	get_env_value
	pop	rdx

	cmp	rax, -1
	jne	else1__start

	mov	rdi, 1
	mov	rsi, error_env
	mov	rdx, error_env_len
	call	write_to_file
	call	return_1

else1__start:

	mov	r8, 0
	mov	r12, 0

	mov	r14, 1
	mov	r9, 0
	mov	byte[chr], 0
	mov	byte[chr_uninit], 1

	; открываем файл
	mov	rdi, output_file
	mov	rsi, 0x40 | 0x200
	mov	rdx, 511
	call	open_file
	mov	[d_2], rax

	mov	rdi, rax
	call	close_file

	; 
	mov	rdi, output_file
	mov	rsi, 2
	mov	rdx, 0
	call	open_file
	mov	[d_2], rax

	; открываем ввод
	mov	rdi, input_file
	mov	rsi, 0
	mov	rdx, 0
	call	open_file
	mov	qword[d_1], rax

while:
	; читаем в буфер
	mov	rdi, 0 ; qword[d_1]
	mov	rsi, buf
	mov	rdx, 10
	call	read_from_file
	mov	r13, rax
	push	rax

	cmp	rax, 0
	je	return_0

	; если первый символ - разделитель, обновляем r12 - флаг плохого слова
	push	rsi
	mov	al, byte[buf]
	mov	rsi, delimiters1
	call	symbol_in_str
	mov	dl, al
	mov	rcx, 0
	cmp	dl, 1
	cmove	r12, rcx
	; если последний байт - разделитель
	mov	rcx, qword[rsp+8]
	mov	al, byte[buf+rcx]
	mov	rsi, delimiters1
	call	symbol_in_str
	mov	dl, al
	pop	rsi
	; pop	rax
	mov	rcx, 0
	cmp	dl, 1
	cmove	r12, rcx

	cmp	byte[chr_uninit], 0
	je	if_not_first_symb

	mov	rcx, 10
	mov	rsi, buf
for_main:
	lodsb

	push	rsi
	push	rax
	mov	rsi, delimiters1
	call	symbol_in_str
	mov	dl, al
	pop	rax
	pop	rsi
	cmp	dl, 1
	je	continue_for_main

	mov	byte[chr], al
	mov	byte[chr_uninit], 0
	jmp	end_for_main

continue_for_main:
	loop	for_main
end_for_main:

if_not_first_symb:

	; удаляем лишние разделители
	mov	rsi, buf
	pop	rdx
	call	collaps_spaces
	cmp	rax, 0
	je	while

	sub	rsp, 16
	mov	cl, byte[delim]
	mov	byte[rsp], cl
	mov	cl, byte[s_delim]
	mov	byte[rsp+8], cl

	; удаляем лишнее
	mov	rsi, buf
	mov	rdx, rax
	call	handle_str

	mov	cl, byte[delim]
	mov	byte[new_delim], cl
	mov	cl, byte[rsp]
	mov	byte[delim], cl

	mov	cl, byte[s_delim]
	mov	byte[new_s_delim], cl
	mov	cl, byte[rsp+8]
	mov	byte[s_delim], cl

	pop	rcx
	cmp	rax, 0
	je	while

	xor	rcx, rcx
	mov	qword[rsp], rax

	; ещё раз схлопываем пробелы
	mov	rsi, buf
	pop	rdx
	call	collaps_spaces
	cmp	rax, 0
	je	while
	push	rax

	; if (space (delim кроме \n)) and (buf is not empty (буквы)) { print(space) }

	cmp	byte[s_delim], 0
	je	else_not_delim_in_main

	mov	rsi, buf
	mov	rdi, delimiters1
	mov	rdx, qword[rsp]
	push	rax
	call	find_not_delim
	mov	dl, al
	pop	rax
	cmp	dl, 0
	je	else_not_delim_in_main

	; print(space)
	push	rax
	mov	rdi, qword[d_2]
	mov	rsi, delimiters1
	mov	rdx, 1
	call	write_to_file
	pop	rax

else_not_delim_in_main:
	mov	cl, byte[new_delim]
	mov	byte[delim], cl

	mov	cl, byte[new_s_delim]
	mov	byte[s_delim], cl

	mov	rsi, buf
	pop	rdi
	call	strip_right
	push	rax

	; выводим обработанный кусочек на экран/в файл
	mov	rdi, qword[d_2]
	mov	rsi, buf
	pop	rdx
	call	write_to_file

	jmp	while

; ========== типо конец цикла =========

	mov	rdi, qword[d_2]
	call	close_file

	call	return_0



