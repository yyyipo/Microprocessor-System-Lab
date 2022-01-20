	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte 0

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404	//type
	.equ GPIOB_OSPEEDR, 0x48000408	//speed
	.equ GPIOB_PUPDR, 0x4800040C	//pullup pulldown
	.equ GPIOB_ODR, 0x48000414	//output

main:
	bl GPIO_init
	//movs r1, #1
	//ldr r0, =leds
	//strb r1, [r0]
	mov r3, #0

Loop:
	//TODO: Write the display pattern into leds variable
	cmp r3, #0	//r3 == 0
	ittt eq
	movseq r1, #1
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #1
	ittt eq
	movseq r1, #3
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #2
	ittt eq
	movseq r1, #6
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #3
	ittt eq
	movseq r1, #12
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #4
	ittt eq
	movseq r1, #8
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #5
	ittt eq
	movseq r1, #12
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #6
	ittt eq
	movseq r1, #6
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #7
	ittt eq
	movseq r1, #3
	ldreq r0, =leds
	strbeq r1, [r0]

	cmp r3, #7
	ite ne
	addne r3, r3, #1
	moveq r3, #0

	bl DisplayLED
	ldr r4, =1000000
	bl Delay
	b Loop

GPIO_init:
	//TODO: Initial LED GPIO pins as output
	// Enable AHB2 clock (port B)
	mov r0, #0x2
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	//set pins PB3-6 as output mode
	mov r0, #0x1540	//set pb3-6 as output mode
	ldr r1, =GPIOB_MODER
	ldr r2, [r1]
	and r2, r2, 0xFFFFC03F	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]

	// Keep PUPDR as the default value(pull-up).
	mov r0, #0x2A80
	ldr r1, =GPIOB_PUPDR
	ldr r2, [r1]
	and r2, r2, 0xFFFFC03F	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]


	// Set output speed register
	mov r0, #0x2A80
	ldr r1, =GPIOB_OSPEEDR
	ldr r2, [r1]
	and r2, r2, 0xFFFFC03F	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]

	bx lr

DisplayLED:
	//TODO: Display LED by leds
	ldr r2, =GPIOB_ODR

	//load the value of leds into r1
	lsl r1, r1, #3
	strh r1, [r2]

	bx lr

Delay:
	//TODO: Write a delay 1 sec function
	cmp r4, #0
	itt gt
	subgt r4, r4, #1
	bgt Delay

	bx lr
