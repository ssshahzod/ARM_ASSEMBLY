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
	bge heapsort_set_index
	b process_line

//sort the array of the mins

heapsort_set_index:
	lsr x5, x1, #1 //get i = size / 2
	sub x6, x1, #1
	sub x13, x0, #1 //max index in the line
	mov x17, x1 //index of the last line
	
heapsort0: //beginning of the sort
	mov x14, #0 //counter of the moved elems
	cbz x5, heapsort1
	sub x17, x17, #1
	sub x5, x5, #1
	b heapsort2	
	
heapsort1: //processing last 2 lines
	cbz x6, exit //if(mins.length == 0) => exit
	ldr w7, [x2, x5, lsl #2]
	ldr w8, [x2, x6, lsl #2]
	str w8, [x2, x5, lsl #2]
	str w7, [x2, x6, lsl #2]
	sub x6, x6, #1
	cbz x6, exit
	//cbz x6, prep_line_index

heapsort2: //load value from index
	ldr w7, [x2, x5, lsl #2] //get parent tree node, i1 = x5
	mov x10, x5

heapsort3: //
	mov x9, x10
	lsl x10, x10, #1
	add x10, x10, #1 //getting index of the left tree node
	cmp x10, x6 //if index is greater than max index
	bgt heapsort5 
	ldr w8, [x2, x10, lsl #2]
	beq heapsort4 
	add x11, x10, #1 //getting index of the right tree node
	ldr w12, [x2, x11, lsl #2]
	cmp w8, w12 //if(w8 >= (<=) w12) => heapsort4; i2 = x10
	.ifdef ascending
	bge heapsort4
	.else 
	ble heapsort4
	.endif
	add x10, x10, #1 //as a result we have 2 indexes: x5 and x10
	//x7 - x5; x8 - x10
	mov x8, x12


heapsort4: //
	cmp x7, x8
	.ifdef ascending
	bge heapsort5
	.else
	ble heapsort5
	.endif
	str w8, [x2, x9, lsl #2]
	b heapsort3

heapsort5: //store the top of the heap
	str w7, [x2, x9, lsl #2]
	
move_matrix_lines:
	
	b heapsort0








@ heapsort4: //
@ 	cmp x7, x8
@ 	.ifdef ascending
@ 	bge heapsort5
@ 	.else
@ 	ble heapsort5
@ 	.endif //i = x10 line should be moved
@ 	mov x11, x10 
@ 	str w8, [x2, x9, lsl #2]
@ 	b prep_line_index

@ heapsort5: //store the top of the heap
@ 	//i = x5 line should be moved
@ 	mov x11, x5
@ 	str w7, [x2, x9, lsl #2]
	
@ prep_line_index:
@ 	add x4, x3, x17, lsl #2 //addr of the last, not sorted line
@ 	add x18, x3, x11, lsl #2

@ move_matrix_lines:
@ 	cmp x14, x13
@ 	bge next_iteration
@ 	ldr	w15, [x4, x14, lsl #2]//get 
@ 	ldr	w16, [x18, x14, lsl #2]//
@ 	str	w15, [x18, x14, lsl #2]
@ 	str	w16, [x4, x14, lsl #2]
@ 	add x14, x14, #1
@ 	b move_matrix_lines


@ next_iteration:
@     mov x4, x3
@ 	cmp x7, x8
@ 	.ifdef ascending
@ 	bge heapsort0
@ 	.else
@ 	ble heapsort0
@ 	.endif
@ 	b heapsort3

exit:
	mov x5, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
