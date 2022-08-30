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
	fmov	d5, #1.0
	fmov 	d2, #1.0
	fmov	d1, d2
	fadd	d10, d1, d2
	fadd	d3, d1, d2
0:
	add		x10, x10, #1
	fmov	d4, d2 //previous sum
	
	fmul	d1, d0, d0 //store multiplication
	fmov	d6, d1 //save abs value
	fneg 	d1, d1
	b 3f
2:
	fdiv	d1, d1, d3  //divide to factorial
	fadd	d4, d4, d1 
	
	fadd	d10, d10, d5
	fmul	d3,	d3, d10
	fadd	d10, d10, d5
	fmul	d3, d3, d10
3:
	fsub	d8, d2, d4
	fcmp	d8, d7
	bgt		0b
	fmov	d0, d2
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
