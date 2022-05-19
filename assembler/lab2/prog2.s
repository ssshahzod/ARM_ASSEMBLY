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
index:
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
	bge heapsort_set_matr
	b process_line

//sort the array of the mins
//also sort array of indexes
heapsort_set_matr:
	mov x4, x3 //beginning of the matrix
	//prepare indexes to fill index array
	adr x5, index
	mov x6, #0

fill_index_array:
	cmp x6, x1
	bge heapsort_set_index
	str w6, [x5, x6, lsl #2]
	add x6, x6, #1
	b fill_index_array

heapsort_set_index:
	lsr x5, x1, #1 //get i = size / 2
	sub x6, x1, #1
	adr x13, index
	//x5 - array of indexes

heapsort0: //beginning of the sort
	cbz x5, heapsort1
	sub x5, x5, #1
	b heapsort2	
	
heapsort1: //
	cbz x6, set_index_to_move //if(mins.length == 0) => exit
	ldrsw x7, [x2, x5, lsl #2]
	ldrsw x8, [x2, x6, lsl #2]

	ldr w14, [x13, x5, lsl #2]
	ldr w15, [x13, x6, lsl #2]
	str w14, [x13, x6, lsl #2]
	str w15, [x13, x5, lsl #2]

	str w8, [x2, x5, lsl #2]
	str w7, [x2, x6, lsl #2]
	sub x6, x6, #1
	cbz x6, set_index_to_move

heapsort2: //load value from index
	ldrsw x7, [x2, x5, lsl #2] //get parent tree node
	ldr w14, [x13, x5, lsl #2]
	mov x10, x5

heapsort3: //
	mov x9, x10
	lsl x10, x10, #1
	add x10, x10, #1 //getting index of the left tree node
	cmp x10, x6 //if index is greater than max index
	bgt heapsort5 
	ldrsw x8, [x2, x10, lsl #2]
	ldr w15, [x13, x10, lsl #2]
	beq heapsort4 
	add x11, x10, #1 //getting index of the right tree node
	ldrsw x12, [x2, x11, lsl #2]
	ldr w16, [x13, x11, lsl #2]
	cmp w8, w12
	.ifdef ascending
	bge heapsort4
	.else 
	ble heapsort4
	.endif
	add x10, x10, #1
	mov x8, x12
	mov x15, x16

heapsort4: //
	cmp x7, x8
	.ifdef ascending
	bge heapsort5
	.else
	ble heapsort5
	.endif
	str w8, [x2, x9, lsl #2]
	str w15, [x13, x9, lsl #2]
	b heapsort3

heapsort5: //store the top of the heap
	str w7, [x2, x9, lsl #2]
	str w14, [x13, x9, lsl #2]	
	b heapsort0
	
set_index_to_move:
	//x0 - x3 are taken (x0 - number of columns, x1 - number of lines, x2 - mins array, x3 - matrix)
	adr x4, index
	mov x5, #1 
	mvn x10, x5
	mov x5, #0 //number of lines that were read
	mov x6, #0 //index to read index array
	mov x7, #0 //index to read/store lines

count_matrix_adr:
	mul x8, x5, x0
	add x8, x3, x8, lsl #2 
read_line:
	cmp x7, x0
	bge reset_ind
	ldrsw x8, [x8, x7, lsl #2]
	str w8, [x2, x7, lsl #2]
	add x7, x7, #1
	b read_line

reset_ind:
	mov x7, #0
find_new_index:
	cmp x6, x1
	bge  update_index//index was already used
	ldrsw x8, [x4, x6, lsl #2]
	cmp x8, x5
	beq count_new_adr//index found
	add x6, x6, #1
	b find_new_index

count_new_adr:
	str x10, [x4, x6, lsl #2]
	mul x6, x6, x0
	add x8, x3, x6, lsl #2 

move_matrix_line:
	cmp x7, x0
	bge save_tmp_index
	ldrsw x9, [x8, x7, lsl #2]
	ldrsw x6, [x2, x7, lsl #2]
	str x6, [x8, x7, lsl #2]
	str x9, [x8, x7, lsl #2]
	b move_matrix_line

save_tmp_index:
	mov x8, x5
	b reset_ind

update_index:
	cmp x5, x1
	bge exit
	add x5, x5, #1
	mov x6, #0
	mov x7, #0
	b count_matrix_adr

exit:
	mov x5, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
