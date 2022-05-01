	.arch armv8-a

	.data
	.align 2

num_column:
	.word 5
num_rows:
	.word 4

matrix: //;matrix
	.word  10, 12, 25, 9, 14
	.word  0, 1, 92, 11, 2
	.word  34, 44, 67, 88, 5
	.word  3, 23, 74, 7, 4

mins:
	.skip 40
	.text
	.align 2
	.global _start
	.type _start, %function

_start:
	adr x5, num_column
	ldr w0, [x5]
	adr x5, num_rows
	ldr w1, [x5]
	adr x2, mins
	adr x3, matrix
	mov x4, x3
	mov x5, #0 // i
	mov x6, #0 // j

//finding mins for each line
 process_line:
	cmp x5, x0
	bge reset_index //
	cmp x5, #0
	beq process_first_elem
	ldr w8, [x4, x5, lsl #2] 
	cmp w7, w8
	bgt new_min
	add x5, x5, #1
	b process_line

new_min:
	mov x7, x8
	b process_line

process_first_elem:
	ldr w7, [x4, x5, lsl #2]
	add x5, x5, #1
	b process_line
	

reset_index:
	str w7, [x2, x6, lsl #2] //str x3, x7 
	add x4, x4, x5, lsl #2
	mov x5, #0
	add x6, x6, #1
	cmp x6, x1
	bge heapsort0
	b process_line

//sort the array of the mins
heapsort_set_matr:
	mov x4, x3 //beginning of the matrix

heapsort_set_index:
	cmp x6, x1 
	beq exit //exit if processed all lines
	add x4, x4, x0, lsl #2 //get next line beginning
	lsr x5, x0, #1 //get i = size / 2
	sub x6, x0, #1
	
heapsort2: //L0
	cbz x5, heapsort3
	sub x5, x5, #1
	b heapsort4	
	
heapsort3: //L1
	cbz x6, heapsort8 //L6
	ldr w7, [x2, x5, lsl #2]
	ldr w8, [x2, x6, lsl #2]
	str w8, [x2, x5, lsl #2]
	str w7, [x2, x6, lsl #2]
	sub x6, x6, #1
	cbz x3, heapsort8

heapsort4: //L2
	ldr w7, [x2, x5, lsl #2]
	mov x10, x5

heapsort5: //L3
	mov x9, x10
	lsl x10, x10, #1
	add x10, x10, #1
	cmp x10, x6
	bgt heapsort7 //L5
	ldr w8, [x2, x10, lsl #2]
	beq heapsort6 //L4
	add x11, x10, #1
	ldr w12, [x2, x11, lsl #2]
	cmp w8, w12
	bge heapsort6
	add x10, x10, #1
	mov x8, x12

heapsort6: //L4
	cmp x7, x8
	bge heapsort7
	str w8, [x2, x9, lsl #2]
	b heapsort5

heapsort7: //L5
	str w7, [x2, x9, lsl #2]
	b heapsort2

exit:
	mov x5, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
