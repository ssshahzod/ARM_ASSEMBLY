	.arch armv8-a

	.data
	.align 2

numcolumn:
	.word 5
numrows:
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
	adr x5, numcolumn
	ldr w0, [x5]
	adr x5, numrows
	ldr w1, [x5]
	adr x2, mins
	adr x3, matrix
	mov x4, x3
	mov x5, #0 // i
	mov x6, #0 // j

//пройтись по матрице и составить массив минимальных элементов из каждой строки
/* process_line:
	cmp x5, x1
	bge reset_index //
	cmp x5, #0
	beq process_first_elem
	ldr x8, [x4, x5, lsl #2]
	cmp x7, x8
	bgt new_min
	add x5, x5, #1
	b process_line

new_min:
	mov x7, x8
	b process_line

process_first_elem:
	ldr x7, [x4, x5, lsl #2]
	add x5, x5, #1
	b process_line
	

reset_index:
	str x3, x7 
	mov x4, [x10, x5, lsl #2]
	mov x5, #0
	add x6, x6, #1
	cmp x6, x2
	//bge heapsort

	b process_line

//отсортировать этот самый массив, перемещая строки и в самой матрице
//heapsort:
*/

exit:
	mov x5, #0
	mov x8, #93
	svc #0
	.size _start, .-_start
