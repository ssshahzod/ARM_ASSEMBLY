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
mode:
	.string "w"
filestr:
	.string "%d:  %.17g\n"
testmes:
	.string "Filename entered: %s\n"
usagemes:
	.string "Usage: ./bin filename\n"
	.text
	.align	2
	.global	cos
	.type	cos, %function
cos:
	//ldr 	x0, [sp, filestruct]
	adr 	x1, filestr
	mov		x23, #0
	mov 	x2, #0
	fmov	d1, d0
	fmov 	d0, #1.0
	fmov 	d5, d0
	fadd	d10, d1, d0
	fadd	d3, d1, d0
0:
	add		x2, x2, #1
	fmov	d4, d0 //previous sum
	fmul	d1, d1, d1 //store multiplication
	fmov	d6, d1 //save abs value
	
	fdiv	d1, d1, d3  //divide to factorial
	fneg 	d1, d1
	fadd	d0, d0, d1 
	
	fadd	d10, d10, d5
	fmul	d3,	d3, d10
	fadd	d10, d10, d5
	fmul	d3, d3, d10
	b 2f

1:
	adr x0, mes12
	bl printf
	cmp 	x22, x23
	bgt		0b
	b 		5f


2:
	fsub	d8, d4, d0
	//ldr		x0, [sp, filestruct]
	fcmp	d8, d7
	//d0 - current sum
	bgt		3f
3:
	mov 	x22, #1
	b 1b
4:
	mov		x22, #0
	b 1b
5:
	fmov	d0, d4
	ret
	.size	cos, .-cos
	.global	main
	.type	main, %function
	.equ	x, 16
	.equ	p, 24
	.equ	y, 32
	.equ	tmp, 40
	.equ 	progname, 48
	.equ 	filename, 56
	.equ 	filestruct, 64
main:
	stp	x29, x30, [sp, #-32]!
	mov	x29, sp
	cmp w0, #2
	bne 2f //exit if no parameters were passed

	ldr x0, [x1]
	str x0, [sp, progname]
	ldr x0, [x1, #8]
	str x0, [sp, filename]

	ldr	x0, [sp, filename] 
	adr x1, mode
	bl fopen
	cbnz x0, 1f 
	ldr x0, [sp, #8]
	bl perror
	b 3f
	
1:
	str x0, [sp, filestruct]

	adr x0, mes1
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
	ldr x0, [sp, filestruct]
	bl fclose
	
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
