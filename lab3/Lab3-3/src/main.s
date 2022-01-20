	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte // (or leds: .word)
	password: .byte 0b1100
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
	.equ GPIOB_IDR, 0x48000410	//input

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804	//type
	.equ GPIOC_OSPEEDR, 0x48000808	//speed
	.equ GPIOC_PUPDR, 0x4800080C	//pullup pulldown
	.equ GPIOC_IDR, 0x48000810	//input

main:
	bl GPIO_init	//initial GPIO

	ldr r2, =GPIOA_ODR	//turn off the LED
	mov r1, #1			//since the LED is active-low, output 1 to turn off it
	lsl r1, r1, #5
	str r1, [r2]

	//load the password into r0
	ldr r0, =password
	ldrb r0, [r0]

	//(option) Test! Turn on all LEDs

Loop:
	/* TODO: Check the button status to determine whether to
	pause updating the LED pattern*/
	mov r5, #0

	ldr r2, =GPIOC_IDR
	ldr r4, [r2]
	and r4, r4, #0x2000

	cmp r4, #0
	itt eq
	ldreq r8, =1000
	bleq CheckPress

	cmp r5, #1	//check if the button is pressed
	it ne
	bne Loop

	bl Read_DIP

	cmp r0, r4	//r0 is the correct password, r1 is the password from DIP switch
	it eq
	beq Password_Correct

	b Password_Wrong

	b Loop

CheckPress:
	/* todo: do debounce and check button state */
	cmp r8, #0
	it eq
	beq Button_Pressed

	ldr r4, [r2]
	and r4, r4, #0x2000
	cmp r4, #0
	itt eq
	subeq r8, r8, #1
	beq CheckPress

	it ne
	bxne lr

Button_Pressed:
	mov r5, #1
	bx lr

Read_DIP:
	ldr r2, =GPIOC_IDR	//read the input value from the DIP switch
	ldr r4, [r2]
	lsr r4, r4, #3	//shift right 3 bits, since it is from PB3-5

	bx lr

Password_Correct:
	ldr r2, =GPIOA_ODR
	//load the value of leds into r1
	mov r1, #0
	lsl r1, r1, #5
	str r1, [r2]
	ldr r8, =100000
	bl Delay
	mov r1, #1
	lsl r1, r1, #5
	str r1, [r2]

	ldr r8, =100000
	bl Delay

	mov r1, #0
	lsl r1, r1, #5
	str r1, [r2]
	ldr r8, =100000
	bl Delay
	mov r1, #1
	lsl r1, r1, #5
	str r1, [r2]

	ldr r8, =100000
	bl Delay

	mov r1, #0
	lsl r1, r1, #5
	str r1, [r2]
	ldr r8, =100000
	bl Delay
	mov r1, #1
	lsl r1, r1, #5
	str r1, [r2]

	b Loop

Password_Wrong:
	ldr r2, =GPIOA_ODR

	mov r1, #0
	lsl r1, r1, #5
	str r1, [r2]
	ldr r8, =100000
	bl Delay
	mov r1, #1
	lsl r1, r1, #5
	str r1, [r2]

	b Loop


GPIO_init:
	/* TODO: Initialize LED, button GPIO pins */
	// Enable AHB2 clock
	/* Set LED gpio output */
	// Set gpio pins as output mode
	// Keep PUPDR as the default value(pull-up)
	// Set output speed register

	//enable port A and C
	mov r0, #0x5
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	//set pin pA5 as output mode(LED)
	mov r0, #0x400
	ldr r1, = GPIOA_MODER
	ldr r2, [r1]
	and r2, 0xFFFFF3FF
	orr r2, r2, r0
	str r2, [r1]

	//set pins PC3-6 as input mode(DIP)
	mov r0, #0
	ldr r1, =GPIOC_MODER
	ldr r2, [r1]
	and r2, r2, 0xFFFFC03F	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]

	//set pin PC13 as input mode(user botton)
	mov r0, #0
	ldr r1, =GPIOC_MODER
	ldr r2, [r1]
	and r2, r2, 0xF3FFFFFF
	orr r2, r2, r0
	str r2, [r1]

	// Keep PC13 as pull-up
	mov r0, 0x1640
	ldr r1, =GPIOC_PUPDR
	str r0, [r1]


	// Set output speed register
	mov r0, #0x2A80
	ldr r1, =GPIOC_OSPEEDR
	ldr r2, [r1]
	and r2, r2, 0xFFFFC03F	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]

	bx lr

Delay:
	/* TODO: Write a delay 1 sec function */
	// You can implement this part by busy waiting.
	// Timer and Interrupt will be introduced in later lectures.
	cmp r8, #0
	itt gt
	subgt r8, r8, #1
	bgt Delay

	bx lr
