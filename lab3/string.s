bits	64
section .text
global	symbol_in_str

; al - symbol
; rsi - 0-terminated string of symbols
symbol_in_str:
	push	rbp
	mov	rbp, rsp

	sub	rsp, 8
	mov	byte[rsp], al
while_symbol_in_str:
	lodsb
	cmp	al, 0
	je	end_while_symbol_in_str

	cmp	al, byte[rsp]
	jne	continue_while_symbol_in_str

	mov	al, 1
	add	rsp, 8
	leave
	ret
continue_while_symbol_in_str:
	jmp	while_symbol_in_str
end_while_symbol_in_str:
	xor	al, al

	add	rsp, 8
	leave
	ret
; rax - 1/0 if symbol is/isn't in string
