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
	.string "Step: %d\n"
usagemes:
	.string "Usage: ./bin filename\n"
	.text
	.align	2

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
	bne 4f //exit if no parameters were passed

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
	b 5f
	
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
	ldr d9, [x29, y] //prepare parameters for cos 
	ldr d8, [x29, x]
cos:
	//d8 - x
	//d9 - 
	mov 	x22, #0
	fmov	d11, d8
	fmov 	d8, #1.0
	fmov 	d15, d8
	fadd	d10, d11, d8
	fadd	d13, d11, d8
0:
	add		x22, x22, #1
	fmov	d12, d8 //previous sum
	fmul	d11, d11, d11 //store multiplication
	//fmov	d6, d11 //save abs value
	
	fdiv	d11, d11, d13  //divide to factorial
	fneg 	d11, d11
	fadd	d8, d8, d11 
	
	fadd	d10, d10, d15
	fmul	d13, d13, d10
	fadd	d10, d10, d15
	fmul	d13, d13, d10

2:
	ldr 	x0, [sp, filestruct]
	adr x1, filestr
	mov x2, x22
	fmov d0, d8
	bl fprintf
	fsub	d0, d12, d8
	fcmp	d0, d9
	bgt		0b
	fmov	d0, d12
3:
	ldr x0, [sp, filestruct]
	bl fclose
	str	d0, [x29, p]
	adr	x0, mes3
	ldr	d0, [x29, x]
	ldr	d1, [x29, p]
	bl	printf
	b ccos
    b 5f
4:
	adr x0, usagemes
	bl printf
ccos:
	ldr d1, [x29, x]
	ldr d0, [x29, x]

	bl cos
	
	fmov d2, d0
	fmov d0, d1
	fmov d1, d2
	adr x0, mes3
	bl printf
	b 5f
5:
	ldp	x29, x30, [sp], #32
	mov	w0, #0
	ret
	.size	main, .-main
