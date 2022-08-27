    .arch armv8-a

    .text
    .align 2
    .global _start
    .type _start, %function

_start:
    mov x0, #1
    mov x1, #2
    mov x2, #3
    mov x3, #4
    mov x4, #5
    mov x5, #6
    mov x10, x0
 	str x0, [sp]
 	str x1, [sp, #4]
 	str x2, [sp, #8]
 	str x3, [sp, #12]   

1:
	ldr x6, [sp, x10, lsl #3]
	cmp x6, x0
	beq 2f
	b 1b
2:
	mov x0, x6
3:
	mov x8, #93
	svc #0
    .size _start, .-_start
