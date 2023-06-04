bits	64

section .data
err1	dw	0

buf	resb	10

hello_string:
			db	"Hello! Enter your string here: ", 0
hello_string_len	equ	$-hello_string

space:
	db	" "
endl:
	db	"\n"
tab:
	db	"\t"

delimiters:
	db	' ', 0x09, 0x0a, ",;.", 0

chr			resb	1

input_file:
	db	"input", 0

section .text
global	_start

return_0:
	mov	rax, 60
	mov	rdi, 0
	syscall
	ret


; rdi - файловый дескриптор
; rsi - адрес буфера
; rdx - размер буфера
read_from_file:
	mov	rax, 0
	syscall
	ret
; rax - возвращает количество считанных байт


; rdi - файловый дескриптор
; rsi - адрес буфера, откуда записываем
; rdx - размер буфера
write_to_file:
	mov	rax, 1
	syscall
	ret
; rax - возвращает количество записанных байт


; rdi - адрес названия файла
; rsi - флаг (0 - читать, 1 - писать, 2 - что угодно)
; rdx - права доступа
open_file:
	mov	rax, 2
	syscall
	ret
; rax - возвращает файловый дескриптор


; rdi - дескриптор
close_file:
	mov	rax, 3
	syscall
	ret


; rsi - указатель на строку
; rdx - размер буфера
collaps_spaces:
	push	rbp
	mov	rbp, rsp

	; выделяем место под хранение последнего символа
	sub	rsp, 8
	mov	byte[rsp], 0

	mov	rbx, 0
	mov	rcx, rdx
for:
	lodsb				; читаем символ в al

; if (s[i] == ' ') {
	cmp	al, byte[space]
	jne	if_not_space

	; if (flag == 1) {
	cmp	byte[rsp], 1
	jne	if_first_space

		; continue
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
	; flag = 0
	mov	byte[rsp], 0
; }
end_if:
	mov	byte[buf+rbx] , al
	inc	rbx

continue_cs:
	loop	for

	mov	rax, rbx
	leave
	ret
; rax - возвращаем новый размер строки


; rdi - первый символ слова
; rsi - указатель на строку
; rdx - размер буфера
handle_string:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 16
	mov	ch, 0
	mov	r10, 1

	mov	al, byte[buf]
	cmp	al, byte[space]
	cmove	rcx, r10
	mov	byte[rbp-8], cl

	mov	byte[rbp], 0

	mov	rcx, 0
	cmp	al, byte[chr]
	cmovne	rcx, r10
	mov	byte[rbp], cl

	mov	rcx, rdx
	mov	rbx, rsi

	mov	qword[rbp], r12

for_hs:
	cmp	rcx, 0
	jg	rcx_positive

	mov	rcx, 0

rcx_positive:
	lodsb

	cmp	al, byte[space]		; if (s[i] == ' ')
	jne	else_1_hs

	mov	byte[rbp], 0
	mov	byte[rbx], al
	inc	rbx
	mov	byte[rbp-8], 1
	jmp	continue_for_hs

else_1_hs:
	cmp	byte[rbp], 1
	jne	else_2_hs

	jmp	continue_for_hs

else_2_hs:
	cmp	byte[rbp-8], 0
	jne	else_4_hs

	mov	byte[rbx], al
	inc	rbx
	jmp	continue_for_hs

else_4_hs:
	cmp	al, byte[chr]
	je	else_3_hs

	mov	byte[rbp], 1
	mov	byte[rbp-8], 0
	jmp	continue_for_hs

else_3_hs:
	mov	byte[rbp], 0
	mov	byte[rbp-8], 0
	mov	byte[rbx], al
	inc	rbx

continue_for_hs:
	loop	for_hs

	sub	rbx, buf
	mov	rax, rbx
	mov	r12, qword[rbp]

	add	rsp, 16
	leave
	ret
; rax - возвращает размер новой строчки


; al - символ
; rsi - символы разделители
symbol_in_string:
	xor	rdx, rdx
	mov	dl, al
while_sis:
	lodsb
	cmp	al, 0
	je	end_while_sis

	cmp	al, dl
	jne	continue_while_sis

	mov	rax, 1
	ret

continue_while_sis:
	jmp	while_sis
end_while_sis:

	xor	rax, rax
	ret
; rax - 0/1 в завивимости от того, есть или нет символа


%macro	calculate_offset 2
	push	rax
	mov	rax, %1
	sub	rax, %2
	xchg	qword[rsp], rax
%endmacro


; rsi - адрес на начало строки
; rdi - размер строки
strip:
	mov	rcx, 0
while_1:
	cmp	rcx, rdi
	jge	end_while_1

	lodsb
	inc	rcx

	push	rsi
	mov	rsi, delimiters
	call	symbol_in_string
	pop	rsi
	cmp	al, 1
	je	while_1

end_while_1:
	dec	rcx

	dec	rdi
while_2:
	cmp	rcx, rdi
	jge	end_while_2

	mov	al, byte[buf+rdi]
	dec	rdi

	push	rax
	push	rsi
	mov	rsi, delimiters
	call	symbol_in_string
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


; %define	foo(x, y) x-y

	calculate_offset    rbx, rcx
	pop	rax
	mov	dl, byte[buf+rax]

	calculate_offset   qword[rsp+8], rcx
	pop	rax
	mov	byte[buf+rax], dl

	loop	for_strip

	pop	rax

	ret


_start:
	; выводим приглашение к вводу
	mov	rdi, 1
	mov	rsi, hello_string
	mov	rdx, 31
	; call	write_to_file

	mov	r8, 0
	mov	r12, 0

	mov	rdi, input_file
	mov	rsi, 0
	mov	rdx, 0
	call	open_file
	mov	r15, rax

	mov	r14, 1

while:
	; читаем в буфер
	mov	rdi, r15
	mov	rsi, buf
	mov	rdx, 10
	call	read_from_file
	mov	r13, rax
	push	rax

	cmp	r8, 1
	je	if_not_first_symb

	mov	r8, 1
	mov	al, byte[buf]
	mov	byte[chr], al

if_not_first_symb:
	mov	rsi, buf
	pop	rdx
	call	collaps_spaces

	mov	rsi, buf
	mov	rdi, rax
	call	strip
	push	rax

	mov	rsi, buf
	pop	rdx
	call	handle_string
	push	rax

	; выводим обработанный кусочек на экран
	mov	rdi, 1
	mov	rsi, buf
	pop	rdx
	call	write_to_file

	; если конец строки - сбрасываем знаки
	mov	al, byte[buf+r13-1]
	cmp	al, byte[endl]
	jne	while

	mov	r8, 0
	mov	r12, 0

	jmp	while

	call	return_0
