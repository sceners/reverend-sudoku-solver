;===============================================================================
;       Opis dzialania:
;
;       1. Struktury
;          FIELD - struktura opisuje kazde z 81 pol planszy do sudoku; pierwsze
;                  9 pol to kazda z mozliwosci (0 = mozna wpisac dana cyfre,
;                  1 = cyfry nie mozna wpisac); pole 'Count' mowi ile jest
;                  mozliwych wpisow; pole 'Number' podaje wartosc jaka zostala
;                  rozwiazana
;
;       2. Dane
;          Zadeklarowana jest 81 razy struktura FIELD. Oprocz tego jest tablica
;          wskaznikow do kolejnych pol generowana w czasie dzialania. Aby
;          znacznie ulatwic pozniejsze dzialanie najpierw obliczam wskazniki do
;          kolejnych pol w poziomie, nastepnie do kolejnych pol w pionie a na
;          koniec do kolejnych pol w danym kwadracie.
;
;       3. Kod
;          a - wczytanie danych z pliku i wypelnienie pol w strukturze
;          ---------------------------------------------------------------------
;     +--> b - wykreslenie cyfr w poziomie, pionie i kwadracie, ktore nei beda
;     |        mogly byc wpisane
;     |    c - sprawdzenie czy ktores pole ma teraz tylko 1 mozliwosc
;     |    d - znowu wykreslanie niemozliwych cyfr
;     |    e - sprawdzenie linii poziomej, pionowej i kwadratu pod wzgledem tego
;     |        czy dana cyfra wystepuje tam tylko raz
;     +--< f - petla do b, az do skutku :)
;
;       Wielkosc kodu: 575
;       Wielkosc danych zainicjowanych: 44
;       Wielkosc danych niezainicjowanych: 1863
;       Lacznie: 2482
;===============================================================================
	format	PE GUI 4.0 on 'stub.exe'
	entry	sudoku_start

	include 'include/win32a.inc'
	include 'include/extras.inc'

;===============================================================================
;       struktury i makra
;===============================================================================
struct	FIELD
  1		db ?
  2		db ?
  3		db ?
  4		db ?
  5		db ?
  6		db ?
  7		db ?
  8		db ?
  9		db ?
  Count 	db ?
  Number	db ?
ends

macro disp10 arg {
 local ..tmp
 ..tmp = arg
 virtual at 0
  repeat 32
   if ..tmp > 0
    db ..tmp mod 10
    ..tmp = ..tmp / 10
   end if
  end repeat
  repeat $
   load ..tmp byte from $-%
   display '0' + ..tmp
  end repeat
 end virtual
 display 13, 10
}

display 'Wielkosc kodu: '
disp10	CODE_SIZE
display 'Wielkosc danych zainicjowanych: '
disp10	IDATA_SIZE
display 'Wielkosc danych niezainicjowanych: '
disp10	UDATA_SIZE
display 'Lacznie: '
disp10	CODE_SIZE + IDATA_SIZE + UDATA_SIZE

;===============================================================================
;       dane
;===============================================================================
idata {
  idata_begin:
	_sudoku_filename_output db 'output.bin', 0

	_sudoku_mode_input	db 'r', 0
	_sudoku_mode_output	db 'w', 0

	_sudoku_format_output	db '%d %d %d %d %d %d %d %d %d', 10, 0
	_sudoku_count_fields	db 81
  idata_end:
      }
udata {
  udata_begin:
	_sudoku_pointers	rd 9*9*3
	_sudoku_array		FIELD
				rb sizeof.FIELD*80
  udata_end:
      }

	IDATA_SIZE		= idata_end - idata_begin
	UDATA_SIZE		= udata_end - udata_begin
	CODE_SIZE		= code_end - code_begin

;===============================================================================
;       kod
;===============================================================================
code_begin:
proc	sudoku_start
  locals
	argc			dd ?
	argv			dd ?
	hfile_input		dd ?
	hfile_output		dd ?

	buffer_input		rb 200
  endl
	pushad
;       --------------------------------------------------------
;       zapisz wskazniki do kolejnych pol w wierszach
;       zaznacz, ze na poczatku kazde pole ma 9 mozliwosci
	mov	eax, _sudoku_array
	push	81
	pop	ecx
	mov	edx, eax
	mov	ebx, eax
	mov	edi, _sudoku_pointers
	mov	esi, eax
    @@:
	stosd
	add	eax, sizeof.FIELD
	mov	[edi + FIELD.Count], 9
	loop	@B
;       --------------------------------------------------------
;       zapisz wskazniki do kolejnych pol w kolumnach
	push	9
	pop	eax
	xchg	eax, edx
    .for:
	push	9
	pop	ecx
    @@:
	stosd
	add	eax, sizeof.FIELD*9
	loop	@B
	add	ebx, sizeof.FIELD
	mov	eax, ebx
	dec	edx
	jnz	.for
;       --------------------------------------------------------
;       zapisz wskazniki do kolejnych pol w kwadratach
	push	eax
	push	9 + 1
	pop	ebx
	push	3
	pop	edx
   .1:
	push	3
	pop	ecx
   @@:
	push	esi
	add	esi, sizeof.FIELD*3
	loop	@B
	add	esi, sizeof.FIELD*(27 - 9)
	dec	edx
	jnz	.1
	jmp	.while

   .while_loop:
	push	3
	pop	ecx
   @@:
	stosd
	add	eax, sizeof.FIELD
	loop	@B

	add	eax, sizeof.FIELD*6
	dec	edx
	jnz	.while_loop
   .while:
	pop	eax
	push	3
	pop	edx
	dec	ebx
	jnz	.while_loop
;       --------------------------------------------------------
;       pobierz argumenty linii polecen
	lea	eax, [argc]
	lea	edx, [argv]
	invoke	__getmainargs, eax, edx, esp, ebx, eax
	cmp	[argc], 2
	jnz	.finish
;       --------------------------------------------------------
;       otworz plik wejsciowy i wyjsciowy
	mov	eax, [argv]
	invoke	fopen, [eax + 04], _sudoku_mode_input
	mov	[hfile_input], eax

	invoke	fopen, _sudoku_filename_output, _sudoku_mode_output
	mov	[hfile_output], eax
;       --------------------------------------------------------
;       czytaj zawartosc pliku
	lea	esi, [buffer_input]
	invoke	fread, esi, 4, 50, [hfile_input]
;       --------------------------------------------------------
;       wypelniaj dane pola w strukturze
	push	81
	pop	ecx
	mov	edx, _sudoku_array
    @@:
	lodsb
	cmp	al, 13
	jz	.omit
	cmp	al, 10
	jz	.omit
	cmp	al, 'x'
	jz	.next
	sub	al, '0'
	mov	dword [edx + 00], 01010101h
	mov	dword [edx + 04], 01010101h
	mov	word  [edx + 08], 0001h
	mov	[edx + FIELD.Number], al
	dec	[_sudoku_count_fields]
    .next:
	add	edx, sizeof.FIELD
    .omit:
	inc	esi
	loop	@B
;       --------------------------------------------------------
;       NAJWAZNIEJSZA PETLA W PROGRAMIE :)
      @@:
	call	sudoku_rip
	call	sudoku_fill_1
	call	sudoku_rip
	call	sudoku_fill_2
	cmp	[_sudoku_count_fields], 0
	jnz	@B
;       --------------------------------------------------------
;       zapisz wyniki w pliku
	mov	ebx, _sudoku_array
	push	9
	pop	edi

      .loop_output:
	push	9
	pop	ecx
	add	ebx, sizeof.FIELD*8

      @@:
	movzx	eax, [ebx + FIELD.Number]
	push	eax
	sub	ebx, sizeof.FIELD
	loop	@B

	add	ebx, sizeof.FIELD*10
	push	_sudoku_format_output
	push	[hfile_output]
	call	[fprintf]
	dec	edi
	jnz	.loop_output

	invoke	fclose, [hfile_input]
	invoke	fclose, [hfile_output]
	add	esp, 8 + 8 + 8 + 16 + ((9 + 2)*4)*9

  .finish:
	add    esp, 20
	popad
	ret
endp
	include 'sudoku.inc'
code_end:

	IncludeAllImports
	IncludeAllData