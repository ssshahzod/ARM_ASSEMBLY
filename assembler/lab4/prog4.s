	.arch armv8-a
	.data
mes1:
	.string	"Input x\n"
mes12:
	.string "Input precision\n"
mes2:
	.string	"%lf" //input format
mes3:
	.string	"cos(%.17g) = %.17g\n"

testmes:
	.string "Filename entered: %s\n"
usagemes:
	.string "Usage: ./bin filename\n"
	.text
	.align	2
	.global	cos
	.type	cos, %function
cos:
	//d7 - precision d0 - x
	//ldr 	x11, [sp, filename]
	mov 	x10, #0
	fmov	d9, #1.0
	fmov	d5, #1.0
	fmov	d6, #-1.0
	fmov	d1, d5
	fmov	d2, d5
	fmov	d3, d5
0:
	add		x10, x10, #1
	fmov	d4, d2 //previous sum
	fmul	d1, d1, d0 //store multiplication
	fdiv	d1, d1, d3
	fadd	d2, d2, d1
	fadd	d3, d3, d5 //factorial
	fcmp	d2, d4
	bne	0b
	fmov	d0, d2
	//str 	x10, [x29, p] //return counter number for testing
	ret
	.size	cos, .-cos
	.global	main
	.type	main, %function
	.equ	x, 16
	.equ	p, 24
	.equ	y, 32
	.equ 	filename, 40
main:
	ldr x0, [sp]
	stp	x29, x30, [sp, #-32]!
	mov	x29, sp
	cmp x0, #2
//	blt 2f //exit if no parameters were passed
//	ldr x20, [sp, #16] //store name of the file
//	str x20, [sp, filename]

//test filename
//	adr x0, testmes
// 	mov x1, x20
//	bl printf

	adr	x0, mes1
	bl	printf
	
	adr	x0, mes2 //read x
	add	x1, x29, x
	bl	scanf
	ldr	d0, [x29, x] //load res of scanf to d7 register
	
	adr x0, mes12
	bl printf	
	adr x0, mes2 //read precision
	add x1, x29, y
	bl scanf
	ldr d7, [x29, y] //prepare parameters for cos function
	ldr d0, [x29, x]
	
	bl	cos
	str	d0, [x29, p]
	adr	x0, mes3
	ldr	d0, [x29, x]
	ldr	d1, [x29, p]
	bl	printf
	b 3f
2:
	adr x0, usagemes
	bl printf
3:
	ldp	x29, x30, [sp], #32
	mov	w0, #0
	ret
	.size	main, .-main
