bits	64
section .data ; выделяем секцию данных
msg:
	db	'!!!', 10
a:
	dd	10
b:
	dd	10
c:
	dd	10
d:
	dd	10
e:
	dd	10

section .text ; секция кода (подсказка для линковщика)
global _start ; метка для входа в программу
global print

print:
	mov eax, 1
        mov edi, 1
        mov esi, msg
        mov edx, 3
        syscall
	ret

_start:
	call print

	

	mov eax, 60
	mov edi, 0
	syscall


