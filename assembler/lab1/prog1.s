	.arch armv8-a
//	res = (a^3 + b^3) / (a^2 * c - b^2 * d + e)  signed = ((a + b)(a^2 - ab + b^2))/
	.data
res: 
	.skip   8
a:
	.hword	10
b:
	.hword	10
d:
	.hword	20
	.align 2
c:
	.word	20
e:
	.word	30
	.text
	.align	2
	.global _start	
	.type	_start, %function
_start:
	adr	x0, a
	ldrsh	w1, [x0] //;ldrsh - load register signed half word
	adr	x0, b
	ldrsh	w2, [x0]
	adr	x0, c
	ldrsw	x3, [x0]
	adr	x0, d
	ldrsh	w4, [x0]
	adr	x0, e
	ldrsw	x5, [x0]
	smull 	x9, w1, w2 //a*b 
	smull   x10, w1, w1 //a^2
	smull	x11, w2, w2 //b^2
	adds 	x12, x10, x11 //a^2 + b^2
	subs 	x12, x12, x9 //; x12 = (a^2 - ab + b^2)
	adds    x9, x1, x2
	
	mul     x12, x12, x9 //;numerator result
	BEQ zeroNum
	
	mul     x10, x10, x3 //a^2 * c
	mul     x11, x11, x4 //b^2 * d
	subs    x10, x10, x11 //a^2 * c - b^2 * d
	adds    x10, x10, x5
	BEQ zeroDen

	sdiv    res, x12, x10
	adr     x0, res
	str     x8, [x0]	
	b exit

overFlow:
	mov x0, #2
	mov x8, #93
	svc #0
	.size _start, .-_start

zeroNum:
	mov res, #0
    adr x0, res
    str x1, [x0]
	b exit

zeroDen:
    mov x0, #1
    mov x8, #93
    svc #0
    .size _start, .-_start
exit:	
	mov	x0, #0
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
