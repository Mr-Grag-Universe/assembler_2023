; -------------------------------
section .data
; Храним здесь инициализированные данные (переменные)

; это строчка 
str1    db  'Here is string 1', 0xA 

; это константа (длина объявленной выше строчки)
str1_len    equ $ - str1            

; это двухбайтовая инициализированная переменная
pi      dw  0x123d

; Это четырехбайтовая переменная
ksi     dd  0x12345678

; Можно и так
ksi2   dd  'acde'

; -------------------------------
section .bss
; Область неинициализированных данных (резерв)
mem     resb    12800

; -------------------------------
section .text

; elf entry point
global _start

_start:
    ; system write -> stdout
    ; аргументы для системного вызова write помещаются в регистры
    ;  ebx(куда) , ecx (что), edx (какой длины)
    mov eax, 4         ; номер системного вызова write
    mov ebx, 1         ; номер потока вывода (stdout)
    mov ecx, str1      ; адрес, по которому лежит строчка
    mov edx, str1_len  ; количество байт (символов), которые нужно вывести
    int 80h            ; системный вызов 


    ; а теперь просто для тренировки
    ; скопируем строчку в раздел неинициализированых данных
    mov ecx, str1_len

.loop:                      ; посимвольно копируем строчку 
    mov esi, ecx            ; ecx — "переменная" цикла
    mov al, byte [str1+esi]
    mov byte [mem+esi], al
    loop .loop              ; эта команда уменьшает ecx на 1 и стравнивает с 0
                            ; если 0, то переходит к следующей команде


    mov eax, 4              ; Напечатаем строчку из того места,
    mov ebx, 1              ; куда мы её скопировали
    mov ecx, mem            ;
    mov edx, str1_len
    int 80h

    push 1234abc1h          ; вызовем функцию print_hex,
    call print_hex          ; которая описана ниже

    ; system exit 0
    mov eax, 1
    mov ebx, 0
    int 80h

print_hex:
    push rbp
    mov ebp, esp
    sub esp, 8h
    ; берем первый (и последний аргумент)
    mov ecx, [ebp+8]
    mov esi, 8

.loop:
    mov eax, ecx
    and eax, 0xf                    ; эквивалентно eax = eax % 16 
                                    ; (остаток от деления на 16)

    cmp al, 9                       ; результат стравнения сохраняется в специальном
                                    ; регистре флагов
    jle .print_decimal              ; jump if less or equal
                                    ; — смотрит результат сравнения в регистре флагов
                                    ; и переходит на метку .print_decimal, если  al <= 9
.print_hex:
    sub al, 10
    add al, 'a'
    jmp .print1
.print_decimal:
    add al, '0'
.print1:
    dec esi
    mov byte [esp+esi], al
    shr ecx, 4                ; эквивалентно ecx = ecx / 16
    jz  .ret
    jmp .loop
.ret
    mov eax, 4
    mov ebx, 1
    mov ecx, esp
    mov edx, 8
    int 80h
    leave
    ret
