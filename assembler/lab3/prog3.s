	.arch armv8-a
//	Copy all odd words in each string from file1 to file2
	.data
mes1:
	.string	"Input filename for read\n"
	.equ	mes1len, .-mes1
ans:
	.skip	3
name1:
	.skip	1024
	.align	3
fd1:
	.skip	8
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
	mov	x0, #1 //file descriptor stdout
	adr	x1, mes1
	mov	x2, mes1len
	mov	x8, #64
	svc	#0
	mov	x0, #0 //file descriptor stdin
	adr	x1, name1
	mov	x2, #1024
	mov	x8, #63
	svc	#0
	cmp	x0, #1
	ble	1f //if error
	cmp	x0, #1024
	blt	2f

1:
	mov	x0, #1
	b	8f
2:
	sub	x2, x0, #1
	mov	x0, #-100 //open file to read
	adr	x1, name1
	strb	wzr, [x1, x2] //move 0-byte to the end of the string
	mov	x2, #0
	mov	x8, #56
	svc	#0
	cmp	x0, #0
	bl writeerr //x0 < 0 is error
	adr	x1, fd1
	str	x0, [x1]
	
8:
	bl	writeerr
	mov	x0, #1
	b	1f

work:    

8:
	str	x0, [x29, tmp]
	ldr	x0, [x29, f2]
	mov	x1, #0
	mov	x8, #46
	svc	#0
	ldr	x0, [x29, tmp]
9:
	ldp	x29, x30, [sp]
	mov	x16, #8240
	add	sp, sp, x16
	ret
	.size	work, .-work
	.type	writeerr, %function
	.data
usage:
	.string	"Program does not require parameters\n"
	.equ	usagelen, .-usage
nofile:
	.string	"No such file or directory\n"
	.equ	nofilelen, .-nofile
permission:
	.string	"Permission denied\n"
	.equ	permissionlen, .-permission
isdir:
	.string	"Is a directory\n"
	.equ	isdirlen, .-isdir
toolong:
	.string	"File name too long\n"
	.equ	toolonglen, .-toolong
readerror:
	.string "Error readig filename\n"
	.equ	readerrorlen, .-readerror
unknown:
	.string	"Unknown error\n"
	.equ	unknownlen, .-unknown
	.text
	.align	2
writeerr:
	cbnz	x0, 0f
	adr	x1, usage
	mov	x2, usagelen
	b	6f
0:
	cmp	x0, #-2
	bne	1f
	adr	x1, nofile
	mov	x2, nofilelen
	b	6f
1:
	cmp	x0, #-13
	bne	2f
	adr	x1, permission
	mov	x2, permissionlen
	b	6f
2:
	cmp	x0, #-21
	bne	3f
	adr	x1, isdir
	mov	x2, isdirlen
	b	6f
3:
	cmp	x0, #-36
	bne	4f
	adr	x1, toolong
	mov	x2, toolonglen
	b	6f
4:
	cmp	x0, #1
	bne	5f
	adr	x1, readerror
	mov	x2, readerrorlen
	b	6f
5:
	adr	x1, unknown
	mov	x2, unknownlen
6:
	mov	x0, #2
	mov	x8, #64
	svc	#0
	ret
	.size	writeerr, .-writeerr
