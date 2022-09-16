    .arch armv8-a

    .text
    .align 2

    .global process_asm
    .type process_asm, %function

process_asm:
    // x0 = uint8_t *image
    // x1 = uint8_t *copy
    // w2 = uint32_t width
    // w3 = uint32_t height

    mov x4, #3
    mov x15, #2
    mul x4, x2, x4 // line = w * 3

    add x0, x0, x4
    add x0, x0, #3  // index = &image[line + 3]
    add x1, x1, x4
    add x1, x1, #3 

    //sub w3, w3, #1 // height -= 1
    //sub w2, w2, #1 // width -= 1

    mov x5, x0 // i = &image[0]
    mov x6, #1 // y = 1

rows:
    cmp x6, x3
    bge exit_process_arm

    mov x7, #1 // x = 1

pixels1:
    cmp x7, x2
    bge end_pixels

    ldrb w8, [x5], #1 //read R, G, B in w8, w9, w10
    ldrb w9, [x5], #1
    ldrb w10, [x5], #1
    mov w11, w8 //store max here
    mov w12, w9 //store min here
    b max
max:
    cmp w9, w11
    bge max1
1:
    cmp w11, w10
    bge max2
    b min
max1:
    mov w11, w9
    b 1b
max2:
    mov w11, w10
    b min

min:
    cmp w8, w12
    blt min1
1:
    cmp w12, w10
    blt min2
    b gray
min1:
    mov w12, w8
    b 1b
min2:
    mov w12, w10
    
gray:
	//w11 - max
	//w12 - min
	//w13 - gray res
	add w11, w11, w12
	udiv w11, w11, w15

    sub x5, x5, #3 // index - line
   	strb w11, [x1], #1
   	strb w11, [x1], #1
   	strb w11, [x1], #1

   	add x7, x7, #1
	b pixels1
	
end_pixels:

	add x6, x6, #1
	b rows
	
exit_process_arm:
	ret
	.size   process_asm, (. - process_asm)
