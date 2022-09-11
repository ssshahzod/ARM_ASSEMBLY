
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
    mul x4, x2, x4 // line = w * 3

    add x0, x0, x4
    add x0, x0, #3  // index = &image[line + 3]
    add x1, x1, x4
    add x1, x1, #3 

    sub w3, w3, #1 // height -= 1
    sub w2, w2, #1 // width -= 1

    mov x5, x0 // i = &image[0]
    mov x6, #1 // y = 1
    rows:
        cmp x6, x3
        bge exit_process_arm

        mov x7, #1 // x = 1
        pixels:
            cmp x7, x2
            bge end_pixels

            // R
            ldrb w8, [x0]
            lsl w8, w8, 2

            sub x10, x0, x4 // index - line
            ldrb w9, [x10, #3]
            add w8, w8, w9
            ldrb w9, [x10]
            add w8, w8, w9, lsl 1
            ldrb w9, [x10, #-3]
            add w8, w8, w9

            ldrb w9, [x0, #3]
            add w8, w8, w9, lsl 1
            ldrb w9, [x0, #-3]
            add w8, w8, w9, lsl 1

            add x10, x0, x4 // index + line
            ldrb w9, [x10, #3]
            add w8, w8, w9
            ldrb w9, [x10]
            add w8, w8, w9, lsl 1
            ldrb w9, [x10, #-3]
            add w8, w8, w9

            lsr w8, w8, #4 // value/16
            strb w8, [x1]
            add x0, x0, #1
            add x1, x1, #1

            // G
            ldrb w8, [x0]
            lsl w8, w8, 2

            sub x10, x0, x4 // index - line
            ldrb w9, [x10, #3]
            add w8, w8, w9
            ldrb w9, [x10]
            add w8, w8, w9, lsl 1
            ldrb w9, [x10, #-3]
            add w8, w8, w9

            ldrb w9, [x0, #3]
            add w8, w8, w9, lsl 1
            ldrb w9, [x0, #-3]
            add w8, w8, w9, lsl 1

            add x10, x0, x4 // index + line
            ldrb w9, [x10, #3]
            add w8, w8, w9
            ldrb w9, [x10]
            add w8, w8, w9, lsl 1
            ldrb w9, [x10, #-3]
            add w8, w8, w9

            lsr w8, w8, #4 // value/16
            strb w8, [x1]
            add x0, x0, #1
            add x1, x1, #1

            // B
            ldrb w8, [x0]
            lsl w8, w8, 2

            sub x10, x0, x4 // index - line
            ldrb w9, [x10, #3]
            add w8, w8, w9
            ldrb w9, [x10]
            add w8, w8, w9, lsl 1
            ldrb w9, [x10, #-3]
            add w8, w8, w9

            ldrb w9, [x0, #3]
            add w8, w8, w9, lsl 1
            ldrb w9, [x0, #-3]
            add w8, w8, w9, lsl 1

            add x10, x0, x4 // index + line
            ldrb w9, [x10, #3]
            add w8, w8, w9
            ldrb w9, [x10]
            add w8, w8, w9, lsl 1
            ldrb w9, [x10, #-3]
            add w8, w8, w9

            lsr w8, w8, #4 // value/16
            strb w8, [x1]
            add x0, x0, #1
            add x1, x1, #1

            add x7, x7, #1
            b pixels
        end_pixels:

        add x6, x6, #1
        b rows
    exit_process_arm:
    ret

    .size   process_asm, (. - process_asm)
