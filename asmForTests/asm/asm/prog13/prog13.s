	.arch armv8-a
//	Copy all odd words in each string from file1 to file2
	.data
mes1:
	.string	"Input filename for read\n"
	.equ	mes1len, .-mes1
mes2:
	.string	"Input filename for write\n"
	.equ	mes2len, .-mes2
mes3:
	.string	"File exists. Rewrite(Y/N)?\n"
	.equ	mes3len, .-mes3
resstr:
	.skip 4096
ans:
	.skip	3
name1:
	.skip	1024
name2:
	.skip	1024
	.align	3
fd1:
	.skip	8
fd2:
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
	sub	x2, x0, #1
	adr	x1, name1
	strb	wzr, [x1, x2]
	mov x0, x1
	blt work
1:
	mov	x0, #1
	b	8f
2:
	mov	x2, #0
	mov	x8, #56
	svc	#0
	cmp	x0, #0
	blt	8f
	adr	x1, fd1
	str	x0, [x1]
	//mov	x0, #1
//	adr	x1, mes2
	//mov	x2, mes2len
	//mov	x8, #64
//	svc	#0
//	mov	x0, #0
//	adr	x1, name2
//	mov	x2, #1024
//	mov	x8, #63
//	svc	#0
//	cmp	x0, #1
//	ble	3f
	cmp	x0, #1024
	b	7f
3:
	mov	x0, #1
	b	9f
4:
//	sub	x2, x0, #1
///	mov	x0, #-100
///	adr	x1, name2
///	strb	wzr, [x1, x2]
//	mov	x2, #0xc1
//	mov	x3, #0600
///	mov	x8, #56
//	svc	#0
	//cmp	x0, #0
	//bge	7f
	//cmp	x0, #-17
	//bne	9f
	//mov	x0, #1
	//adr	x1, mes3
	//mov	x2, mes3len
	//mov	x8, #64
	//svc	#0
	//mov	x0, #0
	//adr	x1, ans
	//mov	x2, #3
	//mov	x8, #63
	//svc	#0
	//cmp	x0, #2
	//beq	5f
	mov	x0, #-17
	b	9f
5:
	//adr	x1, ans
	//ldrb	w0, [x1]
	//cmp	w0, 'Y'
	//beq	6f
	//cmp	w0, 'y'
	//beq	6f
	//mov	x0, #-17
	//b	9f
6:
	//mov	x0, #-100
	//adr	x1, name2
	//mov	x2, #0x201
	//mov	x8, #56
	//svc	#0
//	cmp	x0, #0
//	blt	9f
7:
	//adr	x1, fd2
	str	x0, [x1]
	adr	x0, fd1
	ldr	x0, [x0]
	//adr	x1, fd2
	//ldr	x1, [x1]
	bl	work
	cbnz	x0, 0f
	adr	x0, fd1
	ldr	x0, [x0]
	mov	x8, #57
	svc	#0
	//adr	x0, fd2
	//ldr	x0, [x0]
	//mov	x8, #57
	//svc	#0
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
	//adr	x0, fd2
	//ldr	x0, [x0]
	//mov	x8, #57
	//svc	#0
	mov	x0, #1
1:
	mov	x8, #93
	svc	#0
	.size	_start, .-_start
	.type	work, %function
	.equ	f1, 16
	.equ	f2, 24
	.equ	buf, 32
	.equ	flg, 40
	.equ	wrd, 44
	.equ	bufin, 48
	.equ	bufout, 4144
	.text
	.align	2
work:
    //prepare new stackframe
    mov     x16, #4128
    sub     sp, sp, x16
        
    stp     x29, x30, [sp]
    mov     x29, sp
    str     x0, [x29, f1]
    mov     x1, x0

    //open file
    mov     x0, #-100
    mov     x2, #0
    mov     x8, #56
    svc     #0
    cmp     x0, #0

    bge     0f
    bl      writeerr
    b       10f //leave function
0:
    str     x0, [x29, fd1]
    adr 	x3, resstr
    mov 	x20, x3
    mov 	w10, ' '
    mov 	w11, ' '
    strb 	w12, [x3], #1 
1:
        //read from file
    ldr     x0, [x29, fd1]
    add     x1, x29, buf
    mov     x2, #4096
    mov     x8, #63
    svc     #0
    cmp     x0, #0
    beq     9f //write to stdout and close file
    bgt     2f

    str     x0, [sp, #-16]!
    ldr     x0, [x29, fd1]
    mov     x8, #57
    svc     #0
    ldr     x0, [sp], #16
    bl      writeerr
    mov     x0, #1
    b       10f //leave function
2:
    mov 	x4, x1 //beginning of the word
    ldrb 	w8, [x1], #1
    cmp 	w8, '\t'
    beq 	2b  
    cmp 	w8, '\n'
    beq 	2b
    cmp 	w8, ' '
    beq 	2b

3:
    ldrb 	w9, [x1], #1
    cmp 	w9, '\t'
    beq 	4f
    cmp 	w9, '\n'
    beq 	4f
    cmp 	w9, ' '
    beq 	4f
    cbz 	w9, 4f
    b 		3b

4:
    ldrb	 w9, [x1, #-2]!
    mov 	x5, x1  //end of the word
    cmp 	w10, ' ' //save the last letter of the first word
    beq 	5f
    cmp 	w9, w10
    beq 	6f
    add 	x1, x1, #1
    b 		2b
5:
   //save the last letter of the first word
    mov		w10, w9
6:
	//put the word in the res string
	cmp 	x4, x5
	bgt 	7f
	ldrb 	w6, [x4], #1
	strb 	w6, [x3], #1
	b 6b

7:
	//put space after word
	strb 	w11, [x3], #1
	add 	x1, x1, #1
	b 		2b
	
8:
		//close the string
	mov 	w13, '\n'
	strb 	w12, [x3, #-1]!
	strb 	w13, [x3, #1]!
	strb	wzr, [x3, #1]!
	//write the text to stdout
	mov     x2, x0
    mov     x0, #1
    mov 	x1, x20
    mov     x8, #64
    svc     #0
9:
    //close the file
    ldr     x0, [x29, fd1]
    mov     x8, #57
    svc     #0
    mov     x0, #0
10:
    //close function
    ldp     x29, x30, [sp]
    mov     x16, #4128
    add     sp, sp, x16
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
exist:
	.string	"File exists\n"
	.equ	existlen, .-exist
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
	b	7f
0:
	cmp	x0, #-2
	bne	1f
	adr	x1, nofile
	mov	x2, nofilelen
	b	7f
1:
	cmp	x0, #-13
	bne	2f
	adr	x1, permission
	mov	x2, permissionlen
	b	7f
2:
	cmp	x0, #-17
	bne	3f
	adr	x1, exist
	mov	x2, existlen
	b	7f
3:
	cmp	x0, #-21
	bne	4f
	adr	x1, isdir
	mov	x2, isdirlen
	b	7f
4:
	cmp	x0, #-36
	bne	5f
	adr	x1, toolong
	mov	x2, toolonglen
	b	7f
5:
	cmp	x0, #1
	bne	6f
	adr	x1, readerror
	mov	x2, readerrorlen
	b	7f
6:
	adr	x1, unknown
	mov	x2, unknownlen
7:
	mov	x0, #2
	mov	x8, #64
	svc	#0
	ret
	.size	writeerr, .-writeerr
