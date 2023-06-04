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
output_file:
	db	"output", 0

section .text
global  _start


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


; rsi - указатель на строку
; rdx - размер буфера
collaps_spaces:
	push	rbp
	mov	rbp, rsp

	; 
	sub	rsp, 8
	mov	byte[rsp], 0

	mov	rbx, 0
	mov	rcx, rdx
for:
	lodsb				; читаем символ в al

; if (s[i] == ' ') {
	push	rax
	push	rsi
	mov	rsi, delimiters
	call	symbol_in_string
	pop	rsi
	cmp	al, 1
	jne	if_not_space

	pop	rax
	; if (flag == 1) {
	cmp	byte[rsp], 1
	jne	if_first_space

	cmp	al, 0x0a
	jne	else_111
	mov	byte[buf+rbx], 0x0a
		; continue

else_111:
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
	loop	for

	mov	rax, rbx
	leave
	ret
; rax - возвращаем новый размер строки


_start:
	; выводим приглашение к вводу
	mov	rdi, 1
	mov	rsi, hello_string
	mov	rdx, 31
	; call	write_to_file

	mov	rdi, input_file
	mov	rsi, 0
	mov	rdx, 0
	call	open_file
	mov	r15, rax

	mov	rdi, output_file
	mov	rsi, 1
	mov	rdx, 0x200
	call	open_file
	mov	r14, rax


while:
	; читаем в буфер
	mov	rdi, r15
	mov	rsi, buf
	mov	rdx, 10
	call	read_from_file
	mov	r13, rax
	push	rax

	mov	rsi, buf
	mov	rdx, rax
	call	collaps_spaces
	push	rax

	; выводим обработанный кусочек на экран
	mov	rdi, 1
	mov	rsi, buf
	pop	rdx
	push	rdx
	call	write_to_file

	mov	rdi, output_file
	mov	rsi, 1
	mov	rdx, 0x400
	call	open_file
	mov	rdi, rax

	mov	rsi, buf
	pop	rdx
	call	write_to_file

	mov	rdi, r14
	call	close_file

	jmp	while

	call	return_0
