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

sort_mins:
	.skip 40
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
	adr x2, sort_mins
	adr x13, mins
	adr x3, matrix
	mov x4, x3
	mov x5, #0 // i
	mov x6, #0 // j

//finding sort_mins for each line
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
	str w7, [x13, x6, lsl #2]
	add x4, x4, x5, lsl #2
	mov x5, #0
	add x6, x6, #1
	cmp x6, x1
	bge heapsort_set_index
	b process_line

//sort the array of the sort_mins
heapsort_set_index:
	lsr x5, x1, #1 //get i = size / 2
	sub x6, x1, #1
	
heapsort0:
	cbz x5, heapsort1 //if(x5 == 0) => heapsort1
	sub x5, x5, #1
	b heapsort2	
	
heapsort1: //store top of the heap
	cbz x6, prepare_to_move //if(sort_mins.length == 0) => exit
	ldr w7, [x2, x5, lsl #2]
	ldr w8, [x2, x6, lsl #2]
	str w8, [x2, x5, lsl #2]
	str w7, [x2, x6, lsl #2]
	sub x6, x6, #1
	cbz x6, prepare_to_move

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
	mov x8, x12
	//x7 - x5; x8 - x10

heapsort4: //
	cmp x7, x8
	.ifdef ascending
	bge heapsort5
	.else
	ble heapsort5
	.endif
	str w8, [x2, x9, lsl #2]
	b heapsort3

heapsort5:
	str w7, [x2, x9, lsl #2]	
	b heapsort0

prepare_to_move:
	// x0 - num_column; x1 - num_lines; x2 - sort_mins
	// x3 - matrix; x13 - mins
	mov x5, #0 
	sub x6, x1, #1 //index for sort_mins array
	mov x7, #0 //index for elems in line
	ldr w8, [x2, x6, lsl #2]


compare_arrays_elems:
	cmp x6, #0
	ble exit
	ldr w9, [x13, x5, lsl #2]
	cmp x8, x9
	beq comp_indexes
	add x5, x5, #1
	b compare_arrays_elems

comp_indexes:
	cmp x5, x6
	beq update_index
	mul x14, x0, x5
	mul x15, x0, x6
	add x14, x3, x14, lsl #2 //get addresses of the lines
	add x15, x3, x15, lsl #2
	b move_lines

move_lines:
	cmp x7, x0
	bge update_index
	ldr w10, [x14, x7, lsl #2]
	ldr w11, [x15, x7, lsl #2]
	str w10, [x15, x7, lsl #2]
	str w11, [x14, x7, lsl #2]
	add x7, x7, #1
	b move_lines

update_index:
	sub x6, x6, #1
	ldr w8, [x2, x6, lsl #2]
	mov x5, #0
	mov x7, #0
	b compare_arrays_elems



exit:
	mov x5, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
