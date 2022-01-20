	.syntax unified
	.cpu cortex-m4
	.thumb


.text
	.global GPIO_init

	.equ RCC_AHB2ENR, 0x4002104C

	.equ GPIOB_MODER, 0x48000400	//mode (input, output), also the base of GPIOB
	.equ GPIOB_OSPEEDR, 0x48000408	//speed
	.equ GPIOB_PUPDR, 0x4800040C	//pullup pulldown
	.equ GPIOB_ODR, 0x48000414		//output
	.equ GPIOB_BSRR, 0x48000418		//BSRR
	.equ GPIOB_BRR, 0x48000428		//BRR



GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	//TODO: Initialize GPIO pins for max7219 DIN, CS and CLK

	push {r4, r5, r6}

	// Enable AHB2 clock (port B)
	mov r4, #0x2
	ldr r5, =RCC_AHB2ENR
	str r4, [r5]



	//set pins PB3-5 as output mode
	mov r4, #0x540
	ldr r5, =GPIOB_MODER
	ldr r6, [r5]
	and r6, r6, 0xFFFFF03F	//only change the mask of pin3-5
	orrs r6, r6, r4
	str r6, [r5]

	// Keep PUPDR as the default value.

	// Set output speed register
	mov r4, #0xFC0
	ldr r5, =GPIOB_OSPEEDR
	ldr r6, [r5]
	and r6, r6, 0xFFFFF03F
	orrs r6, r6, r4
	str r6, [r5]

	pop {r4, r5, r6}

	bx lr




