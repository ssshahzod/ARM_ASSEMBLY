	.arch armv8-a

	.data
	.align 2
mas:
	.word  10, 12, 25, 9, 0, 1, 92, 11, 34, 44, 67, 88, 3, 23, 74, 7
n: 
	.word 16
max: 
	.word 92
	.text
	.global _start
	.type _start, %function
	
_start: 
	adr x0, max
	adr x1, n	
	ldr x1, [x1] //

	mov x3, #0 // ;i
	


move_row:  


exit:
	mov x0, #0
	mov x8, #93
	svc #0	
	.size _start, .-_start	   
