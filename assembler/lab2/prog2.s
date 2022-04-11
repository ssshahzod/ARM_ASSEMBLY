	.arch armv8-a

	.data
	.align 2
matrix: //;matrix
	.word  10, 12, 25, 9, 14
	.word  0, 1, 92, 11, 2
	.word  34, 44, 67, 88, 5
	.word  3, 23, 74, 7, 4
n:
	.word 5
m:
	.word 4
mins:
	.skip 40

	.text
	.align 2
	.global _start
	.type _start, %function

_start:
	adr x0, n
	ldr x1, [x0] // number of columns
	adr x0, m
	ldr x2, [x0] // number of rows
	adr x3, mins
	adr x4, matrix
	mov x5, #0 // i
	mov x6, #0 // j

process_line:
		
process_line2:
	cmp x5, x1
	bge reset_index
	

reset_index:
	//str x9, 
	mov x5, #0
	add x6, x6, #1
	cmp x6, x2
	bge heapsort
	b process_line
	
heapsort:
	

exit:
	mov x0, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
