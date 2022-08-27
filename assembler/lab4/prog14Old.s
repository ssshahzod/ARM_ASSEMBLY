	.arch armv8-a
	.data
mes1:
	.string	"Input the x: "
	.equ	mes1len, .-mes1
mes2:
	.string	"Input the precision: "
	.equ	mes2len, .-mes2
	.text
	.align	2
	.global _start	
	.type	_start, %function
_start:
	ldr	x0, [sp]
	cmp	x0, #1
	beq	0f
	mov	x0, #0
	b	8f
0:
	mov	x0, #1
	adr	x1, mes1
	mov	x2, mes1len
	mov	x8, #64
	svc	#0
	mov	x0, #0
	adr	x1, name1
	mov	x2, #1024
	mov	x8, #63
	svc	#0
	cmp	x0, #1
	ble	1f
	cmp	x0, #1024
	blt	2f
1:
	mov	x0, #1
	b	8f
2:
	sub	x2, x0, #1
	mov	x0, #-100
	adr	x1, name1
	strb	wzr, [x1, x2]
	mov	x2, #0
	mov	x8, #56
	svc	#0
	cmp	x0, #0
	blt	8f
	adr	x1, fd1
	str	x0, [x1]
	mov	x0, #1
	adr	x1, mes2
	mov	x2, mes2len
	mov	x8, #64
	svc	#0
	mov	x0, #0
	adr	x1, name2
	mov	x2, #1024
	mov	x8, #63
	svc	#0
	cmp	x0, #1
	ble	3f
	cmp	x0, #1024
	bl	4f
3:
	mov	x0, #1
	b	9f
4:
	sub	x2, x0, #1
	mov	x0, #-100
	adr	x1, name2
	strb	wzr, [x1, x2]
	mov	x2, #0xc1
	mov	x3, #0600
	mov	x8, #56
	svc	#0
	cmp	x0, #0
	bge	7f
	cmp	x0, #-17
	bne	9f
	mov	x0, #1
	adr	x1, mes3
	mov	x2, mes3len
	mov	x8, #64
	svc	#0
	mov	x0, #0
	adr	x1, ans
	mov	x2, #3
	mov	x8, #63
	svc	#0
	cmp	x0, #2
	beq	5f
	mov	x0, #-17
	b	9f
5:
	adr	x1, ans
	ldrb	w0, [x1]
	cmp	w0, 'Y'
	beq	6f
	cmp	w0, 'y'
	beq	6f
	mov	x0, #-17
	b	9f
6:
	mov	x0, #-100
	adr	x1, name2
	mov	x2, #0x201
	mov	x8, #56
	svc	#0
	cmp	x0, #0
	blt	9f
7:
	adr	x1, fd2
	str	x0, [x1]
	adr	x0, fd1
	ldr	x0, [x0]
	adr	x1, fd2
	ldr	x1, [x1]
	bl	work
	cbnz	x0, 0f
	adr	x0, fd1
	ldr	x0, [x0]
	mov	x8, #57
	svc	#0
	adr	x0, fd2
	ldr	x0, [x0]
	mov	x8, #57
	svc	#0
	mov	x0, #0
	b	1f
8:
	bl	writeerr
	mov	x0, #1
	b	1f
9:
	bl	writeerr
	adr	x0, fd1
	ldr	x0, [x0]
	mov	x8, #57
	svc	#0
	mov	x0, #1
	b	1f
0:
	bl	writeerr
	adr	x0, fd1
	ldr	x0, [x0]
	mov	x8, #57
	svc	#0
	adr	x0, fd2
	ldr	x0, [x0]
	mov	x8, #57
	svc	#0
	mov	x0, #1
1:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
	.type	work, %function
	.equ	f1, 16
	.equ	f2, 24
	.equ	tmp, 32
	.equ	flg, 40
	.equ	wrd, 44
	.equ	bufin, 48
	.equ	bufout, 4144
	.text
	.align	2
work:
	ret
	.size	work, .-work
	
	.type	writeerr, %function
	.data
usage:
	.string	"Program does not require parameters\n"
	.equ	usagelen, .-usage
unknown:
	.string	"Unknown error\n"
	.equ	unknownlen, .-unknown
	.text
	.align	2
writeerr:
	cbnz	x0, 0f
	adr	x1, usage
	mov	x2, usagelen
	b	7f
0:
	cmp	x0, #-2
	bne	1f
	adr	x1, nofile
	mov	x2, nofilelen
	b	7f
1:
	adr	x1, unknown
	mov	x2, unknownlen
7:
	mov	x0, #2
	mov	x8, #64
	svc	#0
	ret
	.size	writeerr, .-writeerr
