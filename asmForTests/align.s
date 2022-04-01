    .arch armv8-a

    .global _start
    .type _start, %function
_start:
    mov x0, 0xf5
    .align 5
    mov x0, 0xf4
    .size    _start, .-_start
