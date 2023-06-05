/* 
 * This program turn on and off 10 leds embedded in a protoboard. The leds are 
 * connected to the following pins: PB5, PB6, PB7, PB8, PB9, PB10, PB11, PB12, PB13, PB14.
 * These LEDs work as a binary counter. The circuit has two buttons PA0 & PA4 
 * that control the operation of the counter. The button connected to PA4 controls the mode 
 * of the counter, in increment or decrement mode, and the button connected to PA0 
 * controls the speed: x1, x2, x4, x8.
 * 
 * Author: Brandon Chavez Salaverria.
 */
	
	.thumb              @ Assembles using thumb mode
	.cpu cortex-m3      @ Generates Cortex-M3 instructions
	.syntax unified

	.include "ivt.s"
	.include "gpio_map.inc"
	.include "rcc_map.inc"
	.include "systick_map.inc"
	.include "nvic_reg_map.inc"
	.include "afio_map.inc"
	.include "exti_map.inc"
	
	.extern delay
	.extern SysTick_Initialize

check_speed:
	# Prologue
	push 	{r7}
	sub 	sp, sp, #4
	add		r7, sp, #0
	# if(speed == 1)
	cmp		r5, #1
	bne		.CH1
	mov		r0, #1000 @ return 1000
	# Epilogue
	adds	r7, r7, #4
	mov		sp, r7
	pop		{r7}
	bx 		lr

.CH1:
	# else if(speed == 2)
	cmp		r5, #2
	bne		.CH2
	mov		r0, #500 @ return 500;
	# Epilogue
	adds	r7, r7, #4
	mov		sp, r7
	pop		{r7}
	bx 		lr

.CH2:
	# else if(speed == 3)
	cmp		r5, #3
	bne		.CH3
	mov		r0, #250 @ return 250;
	# Epilogue
	adds	r7, r7, #4
	mov		sp, r7
	pop		{r7}
	bx 		lr

.CH3:
	# else if(speed == 4)
	cmp		r5, #4
	bne		.CH4
	mov		r0, #125 @ return 125;
	# Epilogue
	adds	r7, r7, #4
	mov		sp, r7
	pop		{r7}
	bx 		lr

.CH4:
	# else
	mov		r5, #1 @ resets speed at 1;
	mov		r0, #1000 @ return 1000;
	# Epilogue
	adds	r7, r7, #4
	mov		sp, r7
	pop		{r7}
	bx 		lr


	.section .text
 	.align  1
 	.syntax unified
 	.thumb
 	.global __main
__main:
	push 	{r7, lr}
	sub 	sp, sp, #16
	add		r7, sp, #0

	bl 		SysTick_Initialize

	# enabling clock in port A, B and C
	ldr     r0, =RCC_BASE
	mov     r2, 0x1C
	str     r2, [r0, RCC_APB2ENR_OFFSET]

	# set pins PB5 - PB7 as digital output
    ldr     r0, =GPIOB_BASE
    ldr     r2, =0x33344444
    str     r2, [r0, GPIOx_CRL_OFFSET]

	# set pins PB8 - PB15 as digital output
    ldr     r0, =GPIOB_BASE
    ldr     r2, =0x33333333
    str     r2, [r0, GPIOx_CRH_OFFSET]

    # set pins PA0 and PA4 as digital input
    ldr     r0, =GPIOA_BASE
    ldr     r2, =0x44484448
    str     r2, [r0, GPIOx_CRL_OFFSET]

	# configures the mapping of external interrupts lines to GPIO pins
	ldr 	r0, =AFIO_BASE
	eor		r1, r1
	str 	r1, [r0, AFIO_EXTICR1_OFFSET]
	str		r1, [r0, AFIO_EXTICR2_OFFSET]

	# configures falling and rising edge triggers
	ldr 	r0, =EXTI_BASE
	mov		r1, #0x11
	str 	r1, [r0, EXTI_FTST_OFFSET]
	ldr 	r1, =0x0 @ 0x0 to set PA0 and PA4 
	str		r1, [r0, EXTI_RTST_OFFSET]

	str 	r1, [r0, EXTI_IMR_OFFSET]

	ldr 	r0, =NVIC_BASE
	ldr 	r1, =0x440 @ 0x440 to enable EXTI0 and EXTI4
	str		r1, [r0, NVIC_ISER0_OFFSET] 

    # Set led status initial value
	ldr     r3, =GPIOB_BASE
	mov		r4, 0x0
	str		r4, [r3, GPIOx_ODR_OFFSET]

	# Set counter with 0
	mov		r3, 0x0
	str		r3, [r7, #4]

	# Set delay with 1000
	mov		r3, #1000
	str 	r3, [r7, #8]

	# Set mode status as increment
	mov		r4, #1 @ set it in 0 to decrement mode 

	# Set speed at x1
	mov		r5, #1

loop:
	# delay = check_speed();
	bl		check_speed
	str 	r0, [r7, #8]

	# if(mode == 1)
	cmp 	r4, #1
	bne 	.L1
	# counter++;
	ldr 	r0, [r7, #4] 
	adds 	r0, r0, #1	
	str		r0, [r7, #4]
	b 		.L2

	# Else
.L1:
	# counter--;
	ldr 	r0, [r7, #4]
	subs	r0, r0, #1
	str		r0, [r7, #4]

.L2:
	@ Turn LEDs on
    ldr 	r3, =GPIOB_BASE
	ldr		r0, [r7, #4]
	mov 	r1, r0
	lsl 	r1, r1, #5
   	str 	r1, [r3, GPIOx_ODR_OFFSET]
	# wait(delay)
	ldr		r0, [r7, #8]
	bl		delay
	# go to loop
	b 		loop
