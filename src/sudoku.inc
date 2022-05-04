;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;       wykresla niemozliwe cyfry do wpisania
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
sudoku_rip:
;        pushad
	mov	esi, _sudoku_pointers
	push	9*3
	pop	edi
    .for:
	mov	ebx, esi
	push	9
	pop	ecx
    .loop:
	lodsd
	movzx	edx, [eax + FIELD.Number]
	test	edx, edx
	jz	.while

	pushad
	mov	esi, ebx
	push	9
	pop	ecx
      .loop_inner:
	lodsd
	cmp	byte [eax + edx - 1], 0
	jnz	.next
	mov	byte [eax + edx - 1], 1
	dec	[eax + FIELD.Count]
      .next:
	loop	.loop_inner
	popad

    .while:
	loop	.loop
	dec	edi
	jnz	.for
    .end:
;        popad
	ret

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;       sprawdza kazde pole pod wzgledem tego, czy jest tam tylko jedna mozliwosc
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
sudoku_fill_1:
;        pushad
	mov	ecx, 9*9*3
	mov	esi, _sudoku_pointers
    .loop:
	lodsd
	cmp	[eax + FIELD.Count], 1
	jnz	.while
	xor	edx, edx
    @@:
	inc	edx
	cmp	byte [eax + edx - 1], 0
	jnz	@B
	mov	byte [eax + edx - 1], 1
	shl	edx, 8
	mov	word [eax + FIELD.Count], dx	; zeruje 'Count', ustawia 'Number'
						; poprawnie
	dec	[_sudoku_count_fields]
    .while:
	loop	.loop
;        popad
	ret

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;       sprawdza linie i kwadraty pod wzgledem tego, czy dana cyfra jest tylko raz
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
sudoku_fill_2:
;        pushad
	xor	edx, edx
	mov	edi, _sudoku_pointers
    .for:
	xor	ebx, ebx
	push	9
	pop	ecx
	inc	edx
	cmp	edx, 9 + 1
	jnz	.before
	push	1
	pop	edx
	add	edi, 9*4
	cmp	edi, _sudoku_pointers + 9*9*3*4
	jz	.end
    .before:
	mov	esi, edi
    .loop:
	lodsd
	cmp	byte [eax + edx - 1], 0
	jnz	.while
	test	ebx, ebx
	jnz	.double
	xchg	ebx, eax
	jmp	.while
    .double:
	or	ebx, -1
    .while:
	loop	.loop
	inc	ebx
	jz	.for
	dec	ebx
	jz	.for
	mov	dword [ebx + 00], 01010101h
	mov	dword [ebx + 04], 01010101h
	mov	word  [ebx + 08], 0001h
	mov	[ebx + FIELD.Number], dl
	dec	[_sudoku_count_fields]
    .end:
;        popad
	ret