bits	64
section .data

msg1_enter_x:
	db	"enter x: ", 0
msg2_enter_p:
	db	"enter p: ", 0
msg3_result:
	db	"your result: %f", 0x0a, 0
msg4_lib_result:
	db	"lib    atan: %f", 0x0a, 0

msg_enter_f:
	db	"%f", 0
msg_enter_u:
	db	"%u", 0

qwrd_sz		equ	8
qwrd_sz_x2	dq	8+qwrd_sz

one		equ	1

argv	dq	0x0


var_name:
	db	"out_file", 0

buf:
	db 20 dup (0)
convert_mode:
	db	"%.10f", 0
convert_mode_d:
	db	"%d", 0
mode:
	db	"w", 0
save_delta_mode:
	db	"%d: %0.10lf", 0x0a, 0


sep:
	db	": ", 0
sep_size:
	dq	2


; errors
err1_invalid_x:
	db	"your x is invalid. try agane", 0x0a, 0
err2_invalid_p:
	db	"your precision is invalid. try agane", 0x0a, 0
err3_file_name:
	db	"output file name hasn't been passed", 0x0a, 0

section	.bss

file_name:
	resb	100
res:
	resq	1
desc:
	resq	1


section .text
global main

extern	printf
extern	scanf
extern	atanf
extern	get_env_value
extern	fopen
extern	write_file
extern	fclose
extern	fprintf
extern	sprintf
extern	pow
extern	fabs

%define	abs	fabs
%define	pow	pow

; pow - возведение в степень
; xmm0 - основание
; xmm1 - степень
my_pow:
	push	rbp
	mov	rbp, rsp

	; подгружаем на стек основание и степень
	sub	rsp, 16
	movq	qword[rsp], xmm0
	movq	qword[rsp+8], xmm1
	fld	qword[rsp+8]
	fld	qword[rsp]

	fyl2x
	fld	st0
	frndint
	fsub	st1, st0
	fxch
	f2xm1
	fld1
	faddp
	fscale

	fstp	qword[rsp]
	movq	xmm0, qword[rsp]
	add	rsp, 16

	leave
	ret


; xmm0 - число, одуль которого ищем
abs_f:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 8

	fldz
	fstp	qword[rsp]
	ucomisd	xmm0, qword[rsp]

	ja	return_abs_f
	mov	qword[rsp], -1
	fild	qword[rsp]
	fstp	qword[rsp]
	mulsd	xmm0, qword[rsp]

return_abs_f:
	add	rsp, 8

	leave
	ret


; xmm0 - x
; rdi - p
formula:
	push	rbp
	mov	rbp, rsp

	mov	rsi, rdi
	movq	rdi, xmm0

	push	rdi
	push	rsi

	; cvtss2sd	qword[rsp], dword[rsp]

	; открываем файл для записи
	mov	rdi, file_name
	mov	rsi, mode
	mov	rax, 511
	enter	8, 0
	sub	rsp, 8
	and	rsp, -16
	call	fopen
	mov	[desc], rax
	leave

	pop	rsi
	pop	rdi

	; выделил на всякий случай место под локальные переменные
	sub	rsp, 4*qwrd_sz

	mov	rax, 10
	mov	rdx, 1

	mov	qword[rbp-8], rdi
	mov	qword[rbp-16], rdx
	fild	qword[rbp-16]
	fstp	qword[rbp-16]

	; xmm6  = y = x;
	; xmm7  = S = 0
	; xmm8  = n = 1
	; xmm9  = sign = 1
	; xmm10 = e = 1/pow(10, n)
	; xmm11 = delta = 0

	; rbp-8  = x^2
	; rbp-16 = 2
	; rbp-24 = temp
	; rbp-32 = counter{1}

	; 10^(p+1)
	cvtsi2sd	xmm0, rax
	cvtsi2sd	xmm1, rsi
	addsd		xmm1, qword[rbp-16]
	call		pow
	mov		rax, 0
	fstp		qword[rbp-24]

	; 10^(-p-1)
	movq		[rbp-24], xmm0
	fld		qword[rbp-24]
	frndint
	fstp		qword[rbp-24]
	movq		xmm8, qword[rbp-24]
	movq		xmm7, qword[rbp-16]
	divsd		xmm7, xmm8
	movq		xmm10, xmm7

	; инициализируем
	movsd		xmm6, qword[rbp-8]	; x
	cvtsi2sd	xmm7, rax		; 0
	movq		xmm8, qword[rbp-16]	; 1
	movq		xmm9, qword[rbp-16]	; 1
	cvtsi2sd	xmm11, rax		; 0

	; = x^2
	movq	xmm0, qword[rbp-8]
	mulsd	xmm0, qword[rbp-8]
	movq	qword[rbp-8], xmm0
	; = 2
	movq	xmm0, qword[rbp-16]
	addsd	xmm0, qword[rbp-16]
	movq	qword[rbp-16], xmm0
	; = 1
	mov	qword[rbp-32], 1

while_formula:
	; delta = y*sign/n
	movq	xmm5, xmm6
	mulsd	xmm5, xmm9
	divsd	xmm5, xmm8
	movq	xmm11, xmm5

	; записываем delta в файл
	mov	rdi, qword[desc]
	mov	rsi, save_delta_mode
	mov	rdx, qword[rbp-32]
	movq	xmm0, xmm11
	mov	rax, 1
	enter	8, 0
	and	rsp, -16
	call	fprintf
	leave

	; S += delta
	addsd	xmm7, xmm11

	; y *= x*x
	mulsd	xmm6, qword[rbp-8]

	; n += 2
	addsd	xmm8,  qword[rbp-16]

	; sign = -sign
	cvtsd2si	rax, xmm9
	neg		rax
	cvtsi2sd	xmm9, rax

	; delta = abs(delta)
	movq	xmm0, xmm11
	call	abs
	movq	xmm11, xmm0

	inc	qword[rbp-32]
	ucomisd	xmm11, xmm10
	ja	while_formula
end_while_formula:

	mov	rdi, qword[desc]
	call	fclose

	add	rsp, 4*qwrd_sz
	movq	qword[rbp+16], xmm7

	leave
	ret


; rdi - error code
print_error:
	push	rbp
	mov	rbp, rsp

	cmp	rdi, 1
	jne	not_1
	mov	rdi, err1_invalid_x
not_1:
	cmp	rdi, 2
	jne	not_2
	mov	rdi, err2_invalid_p
not_2:
	cmp	rdi, 3
	jne	not_3
	mov	rdi, err3_file_name
not_3:

	mov	rax, 0
	sub	rsp, 8
	and	rsp, -16
	call	printf

	leave
	ret


main:
	mov	qword[argv], rsi

	push	rbp
	mov	rbp, rsp

	sub	rsp, 16

	; просим ввести x
	mov	rdi, msg1_enter_x
	xor	rax, rax
	call	printf

	; вводим x
	mov	rdi, msg_enter_f
	lea	rsi, [rbp-4]
	xor	rax, rax
	call	scanf

	; проверяем наличие ошибок ввода
	cmp	rax, 0
	jge	if_scanf_ok_1_main

	mov	rdi, 1
	call	print_error
	leave
	ret

if_scanf_ok_1_main:

	; проверяем, что x <= 1
	cvtss2sd	xmm0, dword[rbp-4]
	call		abs_f
	mov		rax, 1
	cvtsi2sd	xmm1, rax
	ucomisd		xmm0, xmm1
	jbe		x_is_fine_main

	mov	rdi, 1
	call	print_error
	leave
	ret

x_is_fine_main:

	; просим ввести точность (кол-во знаков после запятой)
	mov	rdi, msg2_enter_p
	xor	rax, rax
	call	printf

	; вводим p
	mov	rdi, msg_enter_u
	lea	rsi, [rbp-16]
	xor	rax, rax
	call	scanf

	; проверяем наличие ошибок ввода
	cmp	rax, 0
	jle	if_scanf_not_ok_2_main

	; если беззнаковое число слишком большое (например введено отрицательное)
	cmp	qword[rbp-16], 10
	jle	if_scanf_ok_2_main

if_scanf_not_ok_2_main:
	mov	rdi, 2
	call	print_error
	leave
	ret

if_scanf_ok_2_main:

	mov	rdi, qword[argv]
	mov	rsi, var_name
	mov	rdx, file_name
	call	get_env_value
	cmp	rax, 0
	jge	file_name_found

	mov	rdi, 3
	call	print_error
	leave
	ret

file_name_found:

	sub		rsp, 8
	mov		edi, [rbp-4]
	cvtss2sd	xmm6, [rbp-4]
	movq		xmm0, xmm6
	mov		rdi, [rbp-16]
	; считаем наш результат
	call		formula
	pop		qword[res]

	; выводим непосредственно результат
	mov	rdi, msg3_result
	movq	xmm0, qword[res]
	mov	rsi, [res]
	mov	rax, 1

	push	rbp
	mov	rbp, rsp
	sub	rsp, 8
	and	rsp, -16
	call	printf
	leave

	; пользуемся atan из libm
	movd	xmm0, dword[rbp-4]
	xor	rax, rax
	call	atanf

	; результат библиотечного вызова
	mov	rdi, msg4_lib_result
	cvtss2sd	xmm0, xmm0
	mov	rax, 1
	push	rbp
	mov	rbp, rsp
	sub	rsp, 8
	and	rsp, -16
	call	printf
	leave

	add	rsp, 24

	leave
	xor	rax, rax
	ret
