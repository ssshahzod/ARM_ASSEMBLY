    .arch armv8-a
    .data

errmes1:
    .string "Usage "
    .equ    errlen1, .-errmes1
errmes2:
    .string "filename\n"
    .equ    errlen2, .-errmes2
    .text
    .align 2
    .global _start
    .type _start, %function

_start:
    ldr x0, [sp]
    cmp x0, #2
    beq 2f
    mov x0, #2
    adr x1, errmes1
    mov x2, errlen1
    mov x8, #64
    svc #0
    mov x0, #2
    ldr x1, [sp, #8]
    mov x2, #0

0:
    ldrb w3, [x1, x2]
    cbz w3, 1f
    add x2, x2, #1
    b 0b

1:
    mov x8, #64
    svc #0
    mov x0, #2
    adr x1, errmes2
    mov x2, errlen1
    mov x8, #64
    svc #0
    mov x0, #1
    b 3f

2:
    ldr x0, [sp, #16]
    bl work

3:
    