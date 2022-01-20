	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte 0

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C

	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004	//type
	.equ GPIOA_OSPEEDR, 0x48000008	//speed
	.equ GPIOA_PUPDR, 0x4800000C	//pullup pulldown
	.equ GPIOA_ODR, 0x48000014	//output

	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404	//type
	.equ GPIOB_OSPEEDR, 0x48000408	//speed
	.equ GPIOB_PUPDR, 0x4800040C	//pullup pulldown
	.equ GPIOB_ODR, 0x48000414		//output

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804	//type
	.equ GPIOC_OSPEEDR, 0x48000808	//speed
	.equ GPIOC_PUPDR, 0x4800080C	//pullup pulldown
	.equ GPIOC_IDR, 0x48000810		//input

GPIO_init:
	/* TODO: Initialize LED, button GPIO pins */
	// Enable AHB2 clock
	/* Set LED gpio output */
	// Set gpio pins as output mode
	// Keep PUPDR as the default value(pull-up)
	// Set output speed register

	// Enable AHB2 clock (port A C)
	mov r0, #0x5
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

		//set pins PA4-7 as output mode
	mov r0, #0x5500
	ldr r1, =GPIOA_MODER
	ldr r2, [r1]
	and r2, r2, 0xFFFF00FF	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]

	// set pins PA4-7 as pull-up
	mov r0, #0x5500
	ldr r1, =GPIOA_PUPDR
	ldr r2, [r1]
	and r2, r2, 0xFFFF00FF
	orrs r2, r2, r0
	str r2, [r1]

	// Set output speed register
	mov r0, #0xFF00
	ldr r1, =GPIOA_OSPEEDR
	ldr r2, [r1]
	and r2, r2, 0xFFFF00FF
	orrs r2, r2, r0
	str r2, [r1]

	//set pin PC13 as input mode
	mov r0, #0
	ldr r1, =GPIOC_MODER
	ldr r2, [r1]
	and r2, r2, 0xF3FFFFFF
	orr r2, r2, r0
	str r2, [r1]

	// Set GPIOC_PUPDR as pull-up.
	mov r0, #0x4000000
	ldr r1, =GPIOC_PUPDR
	str r0, [r1]

	bx lr

main:
	bl GPIO_init		//branch with link to GPIO_init
	mov r3, #0			//r3 = 0 (use r3 to record which state the LEDs are at)
	mov r4, #0x2000			//r4 is used to record the last state of the button, initial it as 1
	mov r7, #1			//when r7 is 1, the LED keeps going; when it is 0, LED stops

Loop:
	/* TODO: Check the button status to determine whether to
	pause updating the LED pattern*/

	ldr r2, =GPIOC_IDR
	ldr r5, [r2]	//r5 is the current state of the button

	cmp r4, r5	//check the current button state and the old one
	it ne		//if r4 != r5
	blne CheckPress	//branch to CheckPress

	cmp r7, #0
	it eq
	beq Loop


	cmp r3, #0
	ittt eq				//r3 == 0
	movseq r1, #14
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #1
	ittt eq				//r3 == 1
	movseq r1, #12
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #2
	ittt eq				//r3 == 2
	movseq r1, #9
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #3
	ittt eq				//r3 == 3
	movseq r1, #3
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #4
	ittt eq				//r3 == 4
	movseq r1, #7
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #5
	ittt eq				//r3 == 5
	movseq r1, #3
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #6
	ittt eq				//r3 == 6
	movseq r1, #9
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #7
	ittt eq				//r3 == 7
	movseq r1, #12
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #7
	ite ne
	addne r3, r3, #1	//if r3 != 7, r3 += 1
	moveq r3, #0		//if r3 == 7, r3 = 0

	bl DisplayLED		//branch with link to DisplayLED
	ldr r8, =500000		//r8 = 500000
	bl Delay			//branch with link to Delay
	b Loop				//branch to Loop


CheckPress:
	/* TODO: Do debounce and check button state */
	ldr r6, =1000

	cmp r4, #0
	it eq
	beq Count_one	//if r4 == 0, the button should go from 0 to 1

	it ne
	bne Count_zero	//if r4 != 0, the button should go from 1 to 0

Count_one:
	//if r6 is 0, it means 50 0x2000 has been collected
	cmp r6, #0
	itt eq
	moveq r4, #1
	bxeq lr

	ldr r5, [r2]
	cmp r5, #0x2000
	itt eq
	subeq r6, r6, #1
	beq Count_one


	//when r5 is not 0x2000
	it ne
	bxne lr


Count_zero:
	cmp r6, #0
	itt eq
	moveq r4, #0
	beq Button_Pressed

	ldr r5, [r2]
	cmp r5, #0
	itt eq
	subeq r6, r6, #1
	beq Count_zero


	//when r5 is not 0
	it ne
	bxne lr

Button_Pressed:
	cmp r7, #1
	ite eq
	moveq r7, #0
	movne r7, #1


	bx lr





DisplayLED:
	//TODO: Display LED by leds
	ldr r2, =GPIOA_ODR		//load the address of GPIOA_ODR into r2

	//load the value of leds into r1
	lsl r1, r1, #4			//r1 shift left 3 bits (PB3-6)
	strh r1, [r2]			//store r1 into the value of r2

	bx lr

Delay:
	//TODO: Write a delay 1 sec function
	cmp r8, #0
	itt gt
	subgt r8, r8, #1
	bgt Delay

	bx lr
