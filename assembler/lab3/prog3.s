        .arch armv8-a
        
        .data
mes1:
        .string "Input filename for read\n"
        .equ    len1, .-mes1
mes2:
        .string " filename\n"
        .equ    len2, .-mes2
resstr:
        .skip 4096
name:
		.skip 1024
buffer:
		.skip 15 
reading_buf_size:
		.word 15
        .text
        .align  2
        .global _start
        .type   _start, %function
_start:
        ldr     x0, [sp]
        cmp     x0, #1
        beq     2f //continue
        mov     x0, #0
        bl 		writeerr
        mov 	x0, #1
        mov 	x15, #1
        b 		3f //branch to exit
0:
        ldrb    w3, [x1, x2]
        cbz     w3, 1f
        add     x2, x2, #1
        b       0b 	//cycle
1:
        mov     x8, #64
        svc     #0
        mov     x0, #2
        adr     x1, mes2
        mov     x2, len2
        mov     x8, #64
        svc     #0
        mov     x0, #1
        b       3f //branch to exit
2:
        //ldr     x0, [sp, #16]
        mov		x0, #1
        adr		x1, mes1
        mov		x2, len1
        mov		x8, #64
        svc		#0

        mov		x0, #0
        adr		x1, name
        mov		x2, #1024
        mov		x8, #63
        svc 	#0

		cmp 	x0, #1
		ble		3f
		cmp		x0, #1024
		sub		x2, x0, #1
		adr		x1, name
		strb	wzr, [x1, x2]
		mov		x0, x1
        bl      work
3:
        mov     x8, #93
        svc     #0
        .size   _start, .-_start
        .type   work, %function
        .text
        .align  2
        .equ    filename, 16
        .equ    fd, 24
        .equ    buf, 32
work:
        //prepare new stackframe
        mov     x16, #4128
        sub     sp, sp, x16
        
        stp     x29, x30, [sp]
        mov     x29, sp
        str     x0, [x29, filename]
        mov     x1, x0

        //open file
        mov     x0, #-100
        mov     x2, #0
        mov     x8, #56
        svc     #0
        cmp     x0, #0

        bge     0f
        bl      writeerr
        b       11f //leave function
0:
        str     x0, [x29, fd]
        adr 	x3, resstr
        mov 	x20, x3
        adr		x0, reading_buf_size
        ldr 	x21, [x0]
        adr		x19, buffer
        mov 	w12, '\''
        mov 	w10, ' '
        mov 	w11, ' '
//        strb 	w12, [x3], #1 //;write ' to beginning of the string
1:
        //read from file
        ldr     x0, [x29, fd]
        add     x1, x29, buf
        mov     x2, #15 //reading buffer size
        mov     x8, #63
        svc     #0

		mov 	x17, #0
		adr 	x14, buffer
        
        cmp     x0, #0
        beq     9f //write to stdout and close file
        bgt     2f

        str     x0, [sp, #-16]!
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        ldr     x0, [sp], #16
        bl      writeerr
        mov     x0, #1
        b       11f //leave function
2:	
		//beginning of the word
        mov 	x4, x1
        ldrb 	w8, [x1], #1
        //cbz 	w8, 9f 
        cbz		w8, 5f
        cmp 	w8, '\t'
        beq 	2b  
//        cmp 	w8, '\n'
//        beq 	2b
        cmp 	w8, ' '
        beq 	2b
        strb	w8, [x14], #1	

3:
        ldrb 	w9, [x1]
        cmp 	w9, '\t'
    	beq 	4f
        cmp 	w9, '\n'
        beq 	4f
        cmp 	w9, ' '
        beq 	4f
        cbz 	w9, 5f
        strb	w9, [x14], #1 //after this cycle buffer contains probably full word
        add		x1, x1, #1
        b 		3b

4:  
        //work with word from buffer
	    //strb	w10, [x14]
		sub 	x14, x14, #1 //end of the word
		adr 	x16, buffer
        ldrb 	w9, [x14] //work with the last letter of the word
        cmp 	w10, ' ' //save the last letter of the first word
        beq 	6f
        cbz 	w9, 2b
        cmp 	w10, w9
        bne 	7f
        adr		x14, buffer
        b 		2b
//        add 	x1, x1, #1
5:	
		//read file after previous part of the word saved in the buffer
		ldr     x0, [x29, fd]
        add     x1, x29, buf
        mov     x2, #15 //reading buffer size
        mov     x8, #63
        svc     #0
        cmp     x0, #0
        beq 	9f //work with word from buffer //finish
        cmp 	x14, x19
        beq 	2b
        b 3b
6:
        //save the last letter of the first word
        mov		w10, w9
7:
		//put the word in the res string
		cmp 	x16, x14
		bgt 	8f
		add 	x15, x15, #1 //count num of the symbols in the res string
		ldrb 	w6, [x16], #1
		strb 	w6, [x3], #1
		b 7b
		
8:
		//put space after word
		strb 	w11, [x3], #1
		add 	x15, x15, #1
		adr		x14, buffer
		cmp		x0, #0
		bgt 	2b
	
9:
		//close the string
		mov 	w13, '\n'
//		strb 	w12, [x3, #-1]!
//		strb 	w13, [x3, #-1]!
		//strb	wzr, [x3, #-1]!
		strb	wzr, [x3, #-1]!
		//write the text to stdout
		//mov     x2, x0
		//add 	x15, x15, #1 //count how much symbols write to the output
		mov 	x2, x15
        mov     x0, #1
        mov 	x1, x20
        mov     x8, #64
        svc     #0
10:
        //close the file
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        mov     x0, #0
11:
        //close function
        ldp     x29, x30, [sp]
        mov     x16, #4128
        add     sp, sp, x16
        ret
        .size   work, .-work
        .type   writeerr, %function

        .data
usage:
		.string "Program does not require parameters\n"
		.equ 	usagelen, .-usage
nofile:
        .string "No such file or directory\n"
        .equ    nofilelen, .-nofile
permission:
        .string "Permission denied\n"
        .equ    permissionlen, .-permission
isdir:
		.string "Is a directory\n"
		.equ	isdirlen, .-isdir
toolong:
		.string "File name too long\n"
		.equ	toolonglen, .-toolong
readerror:
		.string "Error reading filename\n"
		.equ	readerrorlen, .-readerror
unknown:
        .string "Unknown error\n"
        .equ    unknownlen, .-unknown
        .text
        .align  2
writeerr:
		cbnz 	x0, 0f
		adr		x1, usage
		mov 	x2, usagelen
		b 		6f

0:
        cmp     x0, #-2
        bne     1f
        adr     x1, nofile
        mov     x2, nofilelen
        b       6f
1:
        cmp     x0, #-13
        bne     2f
        adr     x1, permission
        mov     x2, permissionlen
        b       6f
2:
		cmp 	x0, #-21
		bne		3f
		adr 	x1, isdir
		mov		x2, isdirlen
		b 		6f		
3:
		cmp 	x0, #-36
		bne		4f
		adr 	x1, toolong
		mov 	x2, toolonglen
		b 		6f
4:
		cmp 	x0, #1
		bne		5f
		adr		x1, readerror
		mov 	x2, readerrorlen
		b 		6f

5:
        adr     x1, unknown
        mov     x2, unknownlen
6:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret
        .size   writeerr, .-writeerr
