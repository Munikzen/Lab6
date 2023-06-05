.include "exti_map.inc"

.extern delay

.cpu cortex-m3      @ Generates Cortex-M3 instructions
.section .text
.align	1
.syntax unified
.thumb
.global EXTI0_Handler
EXTI0_Handler:
    adds    r5, r5, #1 @ adds 1 to speed 
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x1
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr

.global EXTI4_Handler
EXTI4_Handler:
    eor     r4, r4, #1  @ changes mode
    ldr     r0, =EXTI_BASE
    ldr     r1, [r0, EXTI_PR_OFFSET]
    orr     r1, r1, 0x10
    str     r1, [r0, EXTI_PR_OFFSET]
    bx      lr
