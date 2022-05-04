# Sudoku solver

From 2006

[Original package](https://defacto2.net/f/ae1f84b)


![Screenshot 2022-05-05 091056](https://user-images.githubusercontent.com/513842/166839916-dd424c8a-af31-4683-8bdd-0f4121606339.png)

---

Translated from Google

```
; ================================================= ==============================
; A description of the action:
;
; 1. Structures
; FIELD - the structure describes each of the 81 fields of the sudoku board; first
; 9 half is each of the possibilities (0 = you can enter the given number,
; 1 = digits cannot be entered); the 'Count' field tells you how much there is
; possible entries; the 'Number' field gives the value that was left
; resolved
;
; 2. Data
; The FIELD structure is declared 81 times. In addition to this, there is an array
; pointers to the next fields generated during the operation. To
; to make later operation much easier, first I calculate the pointers to
; consecutive squares horizontally, then to consecutive squares vertically and on
; end to the next fields in the square.
;
; 3. Code
; a - loading data from a file and filling in the fields in the structure
; -------------------------------------------------- -------------------
; + -> b - misinterpretation of figures horizontally, vertically and square, which will not be
; | could be typed
; | c - checking if any field has only 1 possibility now
; | d - again punching impossible digits
; | e - checking the horizontal, vertical and square lines against this
; | whether a given digit appears only once there
; + - <f - loop to b until good :)
;
; Code size: 575
; Initialized Data Size: 44
; Uninitialized Data Size: 1863
; Total: 2482
; Size of the created file: 1.5 kB
; ================================================= ==============================

To recompile, all you need to do is:
fasm solver.asm

We use the program as required, but repeat here:
sudoku1.txt solver

The result is the file: output.bin with solved sudoku.

The code has some comments, hopefully the above general description
Actions and rudimentary comments in the code help to understand the ambiguities
:)

Reverend // HTBTeam
```
