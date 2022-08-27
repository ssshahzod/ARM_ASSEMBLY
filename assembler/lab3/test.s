        .arch armv8-a
//      Print text file
        .data
errmes1:
        .string "Usage: "
        .equ    errlen1, .-errmes1
errmes2:
        .string " filename\n"
        .equ    errlen2, .-errmes2
resstr:
        .skip 4096

        .text
        .align  2
        .global _start
        .type   _start, %function
_start:
        ldr     x0, [sp]
        cmp     x0, #2
        beq     2f
        mov     x0, #2
        adr     x1, errmes1
        mov     x2, errlen1
        mov     x8, #64
        svc     #0
        mov     x0, #2
        ldr     x1, [sp, #8]
        mov     x2, #0
0:
        ldrb    w3, [x1, x2]
        cbz     w3, 1f
        add     x2, x2, #1
        b       0b
1:
        mov     x8, #64
        svc     #0
        mov     x0, #2
        adr     x1, errmes2
        mov     x2, errlen2
        mov     x8, #64
        svc     #0
        mov     x0, #1
        b       3f
2:
        ldr     x0, [sp, #16]
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
        //save 
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
        b       10f //leave function
0:
        str     x0, [x29, fd]
        adr 	x3, resstr
        mov 	x20, x3
        mov 	w12, '\''
        mov 	w10, ' '
        mov 	w11, ' '
        strb 	w12, [x3], #1 
1:
        //read from file
        ldr     x0, [x29, fd]
        add     x1, x29, buf
        mov     x2, #4096
        mov     x8, #63
        svc     #0
        cmp     x0, #0
        beq     9f //close file
        bgt     2f

        str     x0, [sp, #-16]!
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        ldr     x0, [sp], #16
        bl      writeerr
        mov     x0, #1
        b       10f //leave function
2:
        mov 	x4, x1 //beginning of the word
        ldrb 	w8, [x1], #1
        cbz 	w8, 8f //write to stdout
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
		strb 	w12, [x3, #-1]!
		strb	wzr, [x3, #1]!
        //write the text to stdout
        mov     x2, x0
        mov     x0, #1
        mov 	x1, x20
        mov     x8, #64
        svc     #0
        b       1b
9:
        //close the file
        ldr     x0, [x29, fd]
        mov     x8, #57
        svc     #0
        mov     x0, #0
10:
        //close function
        ldp     x29, x30, [sp]
        mov     x16, #4128
        add     sp, sp, x16
        ret
        .size   work, .-work
        .type   writeerr, %function


        .data
nofile:
        .string "No such file or directory\n"
        .equ    nofilelen, .-nofile
permission:
        .string "Permission denied\n"
        .equ    permissionlen, .-permission
unknown:
        .string "Unknown error\n"
        .equ    unknownlen, .-unknown
        .text
        .align  2
writeerr:
        cmp     x0, #-2
        bne     0f
        adr     x1, nofile
        mov     x2, nofilelen
        b       2f
0:
        cmp     x0, #-13
        bne     1f
        adr     x1, permission
        mov     x2, permissionlen
        b       2f
1:
        adr     x1, unknown
        mov     x2, unknownlen
2:
        mov     x0, #2
        mov     x8, #64
        svc     #0
        ret
        .size   writeerr, .-writeerr
