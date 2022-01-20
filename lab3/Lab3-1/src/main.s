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

	.equ GPIOB_MODER, 0x48000400	//mode (input, output)
	.equ GPIOB_OTYPER, 0x48000404	//type
	.equ GPIOB_OSPEEDR, 0x48000408	//speed
	.equ GPIOB_PUPDR, 0x4800040C	//pullup pulldown
	.equ GPIOB_ODR, 0x48000414	//output

main:
	bl GPIO_init		//branch with link to GPIO_init
	mov r3, #0			//r3 = 0 (use r3 to record which state the LEDs are at)

Loop:
	//TODO: Write the display pattern into leds variable
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
	ldr r4, =1000000	//r4 = 1000000
	bl Delay			//branch with link to Delay
	b Loop				//branch to Loop

GPIO_init:
	//TODO: Initial LED GPIO pins as output

	// Enable AHB2 clock (port A)
	mov r0, #0x1
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	//set pins PA4-7 as output mode
	mov r0, #0x5500
	ldr r1, =GPIOA_MODER
	ldr r2, [r1]
	and r2, r2, 0xFFFF00FF	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]

	// Keep PUPDR as the default value(pull-up).
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

	bx lr

DisplayLED:
	//TODO: Display LED by leds
	ldr r2, =GPIOA_ODR		//load the address of GPIOA_ODR into r2

	//load the value of leds into r1
	lsl r1, r1, #4			//r1 shift left 4 bits (PB4-7)
	strh r1, [r2]			//store r1 into the value of r2

	bx lr

Delay:
	//TODO: Write a delay 1 sec function
	cmp r4, #0
	itt gt
	subgt r4, r4, #1
	bgt Delay

	bx lr
