bits	64
section	.data

precision_control_word:
	dw 0x037F  ; установка точности вычислений на 64 бита

M:	dd	-1, 1, 2, 3, 4, -7, 3
	dd	2, 3, -2, 10, 2, 3, 1000
	dd	3, -2, 4, 22, 1, -9, 6000
	dd	3, -2, 4, 22, 1, -9, 222

size:
	dd	4, 7

global	_start
section	.text

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

; rdi - i
; rsi - j
swap_columns:
	push	rbp
	mov	rbp, rsp

	push	rdi
	push	rsi

	movsx	rcx, dword[size+0*4]
for_swap_columns:
	mov	rdi, rcx
	dec	rdi
	mov	rsi, [rsp]
	call	get_i_j
	push	rax

	mov	rdi, rcx
	dec	rdi
	mov	rsi, [rsp+16]
	call	get_i_j
	push	rax

	mov	rdi, rcx
	dec	rdi
	pop	rbx
	mov	rsi, [rsp+8]
	call	set_i_j

	mov	rdi, rcx
	dec	rdi
	pop	rbx
	mov	rsi, [rsp+8]
	call	set_i_j

	loop for_swap_columns

	leave
	ret

for_swap_stack:
	mov	r13, rcx
	dec	r13
	sal	r13, 3			; индекс байта

	mov	rax, rdi
	mul	r10
	add	rax, r8			; адрес элемента
	push	rax
	push	qword[rax + r13]	; сохраняем значение
	
	mov	rax, rsi
	mul	r10
	add	rax, r8			; адрес 2 элемента

	; меняем местами
	pop	rbx
	xchg	rbx, qword[rax+r13]
	pop	rax
	xchg	rbx, qword[rax+r13]

	loop	for_swap_stack
	mov	rcx, r12		; возвращаем старый rcx

	ret

; rdi - i
; rsi - j
swap_stack:
	mov	r12, rcx	; сохраняем старый счётчик
	push	rdi
	push	rsi
	call	swap_columns
	pop	rsi
	pop	rdi
	mov	rcx, r10	; размер 1 элемента
	sar	rcx, 3
	call	for_swap_stack
	ret

if_1:
	ret

; rdi - индекс элемента кучи i
; rsi - кол-во элементов n
heapify:
	push	rbp
	mov	rbp, rsp

	mov	r11, 1

	;сохраняем
	push	r9
	mov	r9, rsi
	push	rdi

	; longest = i
	mov	rdx, rdi		; = r
	mov	rsi, rdi		; = l
	mov	rdi, rdi		; = largest
	; l = 2*i + 1
	; r = 2*i + 2
	sal	rsi, 1
	inc	rsi
	inc	rdx
	sal	rdx, 1
	push	rdx

	; l < n
	mov	r14, 0
	mov	r15, 0
	cmp	rsi, r9
	cmovl	r15, r11

	; arr[l] < arr[largest]
	; offset для l
	mov	rax, rsi
	mul	r10
	mov	r13, rax

	; offset для largest
	mov	rax, rdi
	mul	r10

	pop	rdx

	mov	r13, qword[r8 + r13 + 8]
	cmp	r13, qword[r8 + rax + 8]
%ifndef	ReversedOrder
	cmovg	r14, r11
%else
	cmovl	r14, r11
%endif
	; movsx	rax, byte[ORDER]
	; xor	r14, rax

	; (l < n) and (arr[l] > arr[large])
	and	r15, r14
	cmp	r15, 0
	jle	not_zero_1
	mov	rdi, rsi
not_zero_1:

	; r < n
	mov	r14, 0
	mov	r15, 0
	cmp	rdx, r9
	cmovl	r15, r11

	push	rdx

	; arr[r] > arr[largest]
	; offset для r
	mov	rax, rdx
	mul	r10
	mov	r13, rax

	; offset для largest
	mov	rax, rdi
	mul	r10

	pop	rdx

	mov	r13, qword[r8 + r13 + 8]
	cmp	r13, qword[r8 + rax + 8]
%ifndef	ReversedOrder
	cmovg	r14, r11
%else
	cmovl	r14, r11
%endif
	; movsx	rax, byte[ORDER]
	; xor	r14, rax

	; (r < n) and (arr[r] < arr[large])
	and	r15, r14
	cmp	r15, 0
	jle	not_zero_2
	mov	rdi, rdx
not_zero_2:
	pop	rsi
	cmp	rdi, rsi
	je	equal

	push	rdi
	call	swap_stack
	mov	rdi, [rsp]
	mov	rsi, r9
	call	heapify
	pop	rdi
equal:
	pop	r9
	leave
	ret

; rdi - количество элементов
; rsi - размер одного элемента в байтах
heap_sort:
	push	rbp
	mov	rbp, rsp

	; сохраняем адрес начала массива
	mov	r8, rsp
	add	r8, 16
	; сохраняем размеры массива
	mov	r9, rdi
	mov	r10, rsi

	; выставляем счётчик циклов
	sar	rdi, 1
	mov	rcx, rdi

	; вызываем первый for, где сортируем нашу кучу/массив
	
for_heap_sort_1:
	mov	rdi, rcx
	dec	rdi
	mov	rsi, r9
	call	heapify
	loop	for_heap_sort_1

	movsx	rcx, dword[size+1*4]
for_heap_sort_2:
	mov	rdi, 0
	mov	rsi, rcx
	dec	rsi
	call	swap_stack

	mov	rsi, rcx
	dec	rsi
	mov	rdi, 0
	call	heapify
	loop	for_heap_sort_2

	;mov	rax, rdi
	;mul	rsi
	;sub	rsp, rax

	leave
	ret	


; функция возвращает элемент M(i, j)
; rdi : i
; rsi : j
get_i_j:
	mov	rax, rdi
	movsx	rdx, DWORD[size+1*4]
	mul	rdx
	add	rax, rsi

	sal	rax, 2
	; push	rax

	movsx	rax, DWORD[M + rax]

	ret
; rdi : i
; rsi : j
; ebx : x
set_i_j:
	mov	rax, rdi
	movsx	rdx, DWORD[size+1*4]
	mul	rdx
	add	rax, rsi

	sal	rax, 2
	; push	rax

	mov	DWORD[M + rax], ebx

	ret


find_max_for:
	push	rdx		; сохраняем rax - предыдущий максимум
	push	rdi

	mov	rsi, rdi	; j
	mov	rdi, rcx	; i
	dec	rdi
	call	get_i_j

	pop	rdi
	pop	rdx

	cmp	rdx, rax	; сравниваем текущий элемент с предыдущим максимумом
	cmovl	rdx, rax	; записываем в rdx наибольшее

	loop	find_max_for
	
	mov	rax, rdx

	ret

; функция поиска максимума в столбце с заданным индексом
; rdi : индекс столбца
find_max_j:
	push	rbp
	mov	rbp, rsp
 
	push	rdi

	movsx	rcx, DWORD[size]	; инициализируем счётчик

	mov	rsi, rdi		; передаём j
	mov	rdi, rcx		; передаём i
	dec	rdi			; rcx было на 1 больше чем надо

	call	get_i_j			; извлекаем последний элемент матрицы и инициализируем им max

	pop	rdi
	mov	rdx, rax
	call	find_max_for

	leave
	ret	

; для каждого столбца поочереди находим его максимум и кладём на стек
find_max_loop:
	push	rcx		; сохраняем на стеке счётчик
	mov	rdi, rcx	; передаём в функцию j столбца
	dec	rdi

	movsx	rcx, DWORD[size]
	dec	rcx
	call	find_max_j	; ищем максимум в j-ом столбце и кладём результат в rax
	pop	rcx		; возвращаем счётчик со стека

	mov	rdx, rax	; сохраняем полученный максимум

	; считаем отступ для записи результата на стек
	mov	rax, rcx
	sal	rax, 4

	mov	QWORD[rsp + rax - 8], rcx	; кладём номер перед максимумом - для сортировки
	mov	QWORD[rsp + rax], rdx		; кладём максимум
	loop	find_max_loop			; итерируемся дальше

	ret

_start:
	mov	eax, dword[size+1*4]
	cmp	eax, 1
	jg	if_n_o_c_g_t_1
	call	return_0

if_n_o_c_g_t_1:
	movsx	rcx, DWORD[size+1*4]
	movsx	rax, DWORD[size+1*4]
	sal	rax, 4
	sub	rsp, rax
	call	find_max_loop

	; получили на стеке массив из максимумов, причем [rsp+i] = max(M(i))

	movsx	rdi, DWORD[size+1*4]
	mov	rsi, 16
	call	heap_sort

	call	return_0

; rax ~ t1 = arr[ind]
; rdx ~ t2 = 
; rbx ~ arr[]
; rdi ~ j
; rsi ~	i
; rcx ~ counter

	mov	rbx, rsp		; rbx = arr; 	// берём адрес начала массива
        movsx	rsi, dword[size+1*4]	; i = h; 	// берём количество элементов в массиве
        mov     rdi, rsi		; //
        dec     rdi			; j = h-1
        or      rdi, rdi		; if (j == 0)
        jle     return_0		; -> выходим, ибо 1 элемент
        sar     rsi, 1			; i *= 2
m1:
        or      rsi, rsi		; if_1 (rsi == 0)
        jnz     m2			; then
        cmp     rdi, 1			; if_2 (rdi != 1)
        jz      swap_m7			; then { swap 2 elements }
        mov     rax, qword[rbx]		; rax = arr[0]
	sal	rdi, 1
        xchg    rax, qword[rbx+rdi*8]	; swap(rax, arr[rdi])
        mov     qword[rbx], rax		; arr[0] = rax
	mov	rax, qword[rbx+8]
	xchg	rax, qword[rbx+rdi*8+8]
	mov	qword[rbx+8], rax
	sar	rdi, 1	
        dec     rdi			; --rdi
        jmp     m3			; 
m2:					; else_1 if (rdi* != 0)
        dec     rsi			; --rsi
m3:					; else_2 if (rdi == 1)
	sal	rsi, 1
        mov     rax, qword[rbx+rsi*8]	; rax = arr[rsi]
	sar	rsi, 1

        push    rsi
        mov     rcx, rsi		; counter = rsi
m4:
        sal     rcx, 1			; counter /= 2
        inc     rcx			; counter += 1
        cmp     rcx, rdi		; if (counter < rdi
        je      m5
        jg      m6
	sal	rcx, 1
        mov     rdx, qword[rbx+rcx*8]		; rdx = arr[counter]
        cmp     rdx, qword[rbx+rcx*8+16]	; if (arr[counter] < arr[counter+1]
	sar	rcx, 1
        jge     m5
        inc     rcx			; ++counter
m5:					; else if (arr[counter*] >= arr[counter*+1])
	sal	rcx, 1
        cmp     rax, qword[rbx+rcx*8]	; if (rax < arr[counter])
	sar	rcx, 1
        jge     m6
	sal	rcx, 1
        mov     rdx, qword[rbx+rcx*8]	; rdx = arr[counter]
	sar	rcx, 1
        mov     [rbx+rsi*8], rdx	; arr[rsi] = rdx
        mov     rsi, rcx		; rsi = counter
        jmp     m4			; }
m6:					;
	sal	rsi, 1
        mov     [rbx+rsi*8], rax
	sar	rsi, 1
        pop     rsi
        jmp     m1
swap_m7:
        mov     rax, [rbx+8]
        cmp     rax, [rbx+24]
        jle     return_0		; if (arr[0] <= arr[1]) return 0
        xchg    rax, [rbx+24]		; else swap(arr[0], arr[1])
        mov     [rbx+8], rax

	mov	rax, [rbx]
	xchg	rax, [rbx+16]
	mov	[rbx], rax

	call return_0
