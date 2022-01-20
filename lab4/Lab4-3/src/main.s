	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	//TODO: put your student id here
	user_stack_bottom: .zero 128	//.zero <number_of_bytes>
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C	//enable port
	.equ GPIOB_MODER, 0x48000400	//pin mode( input, output...)
	.equ GPIOB_OTYPER, 0x48000404	//push pull/open drain
	.equ GPIOB_OSPEEDR, 0x48000408	//speed
	.equ GPIOB_PUPDR, 0x4800040C	//pull up/down
	.equ GPIOB_ODR, 0x48000414		//output address
	.equ GPIOB_BSRR, 0x48000418
	.equ GPIOB_BRR, 0x48000428

	.equ GPIOC_MODER, 0x48000800	//pin mode( input, output...)
	.equ GPIOC_OTYPER, 0x48000804	//push pull/open drain
	.equ GPIOC_OSPEEDR, 0x48000808	//speed
	.equ GPIOC_PUPDR, 0x4800080C	//pull up/down
	.equ GPIOC_IDR, 0x48000810		//input address

	//MAX7219
	.equ DECODE_MODE, 0x09			//decode mode
	.equ DISPLAY_TEST, 0x0F
	.equ SCAN_LIMIT, 0x0B
	.equ INTENSITY, 0x0A
	.equ SHUTDOWN, 0x0C
	.equ DIN, 0x10					//PB4
	.equ CS, 0x20					//PB5
	.equ CLK, 0x8 					//PB3
main:
	bl stack_init
	bl GPIO_init
	bl max7219_init

	mov r11, #0x2000	//r11 is the last state of button

reset:
	//set every bit as blank
	mov r0, #1
	mov r1, #0
	bl max7219send
	mov r0, #2
	mov r1, #0xF
	bl max7219send
	mov r0, #3
	mov r1, #0xF
	bl max7219send
	mov r0, #4
	mov r1, #0xF
	bl max7219send
	mov r0, #5
	mov r1, #0xF
	bl max7219send
	mov r0, #6
	mov r1, #0xF
	bl max7219send
	mov r0, #7
	mov r1, #0xF
	bl max7219send
	mov r0, #8
	mov r1, #0xF
	bl max7219send





loop0:
	/*ldr r7, =300000
	bl Delay*/

	mov r12, #0

	ldr r0, =GPIOC_IDR
	ldr r1, [r0]

	cmp r1, r11
	itt ne
	ldrne r7, =1000
	blne CheckPress

	cmp r12, #0
	it eq	// not press
	beq loop0

	/*//long press
	ldr r1, [r0]
	cmp r1, r11
	itt ne
	ldrne r7, =500000
	blne CheckPress*/

	cmp r12, #2
	it eq	// long press
	beq reset

	//N==1
	mov r0, #1
	mov r1, #1
	bl max7219send

	movs r3, #0
	movs r4, #1
fib:

	mov r12, #0

	ldr r0, =GPIOC_IDR
	ldr r1, [r0]

	cmp r1, r11
	itt ne
	ldrne r7, =1000
	blne CheckPress

	cmp r12, #0
	it eq	// not press
	beq fib

	/*//long press
	ldr r1, [r0]
	cmp r1, r11
	itt ne
	ldrne r7, =500000
	blne CheckPress*/

	cmp r12, #2
	it eq	// long press
	beq reset

	ldr r10, =99999999
	add r5, r3, r4	//r5 is the result, r3 r4 are the previous results
	cmp r5, r10
	it gt
	movgt r5, r10
	mov r3, r4
	mov r4, r5
	mov r8, #1	//r8 is the ith digit

display:

	mov r6, #10
	udiv r7, r5, r6	//r7 = r5 / r6
	mul r7, r7, r6	//r7 = r7 * 10
	sub r9, r5, r7	// r9 is the number to display in the ith digit
	udiv r5, r5, r6 //r5 = r5 / 10



	mov r0, r8
	mov r1, r9
	bl max7219send

	cmp r5, #0		//if r5 != 0, keep displaying
	itt ne
	addne r8, r8, #1	//r8 is the ith digit
	bne display

	b fib			//if r5 == 0 , display finish


Program_end:
	b Program_end


CheckPress:
	/* TODO: Do debounce and check button state */

	cmp r11, #0
	it eq
	beq Count_one	//if r4 == 0, the button should go from 0 to 1

	it ne
	bne Count_zero	//if r4 != 0, the button should go from 1 to 0

CheckLongPress:
	ldr r7, =500000
	b Count_zero

Count_one:
	//if r6 is 0, it means 50 0x2000 has been collected
	cmp r7, #0
	itt eq
	moveq r11, #0x2000
	bxeq lr

	ldr r1, [r0]
	cmp r1, #0x2000
	itt eq
	subeq r7, r7, #1
	beq Count_one


	//when r1 is not 0x2000
	it ne
	bxne lr


Count_zero:
	cmp r7, #0
	itt eq
	moveq r11, #0
	beq Button_Pressed

	ldr r1, [r0]
	cmp r1, #0
	itt eq
	subeq r7, r7, #1
	beq Count_zero


	//when r1 is not 0
	it ne
	bxne lr

LongPress_Count_zero:
	cmp r7, #0
	it eq
	beq Button_Pressed

	ldr r1, [r0]
	cmp r1, #0
	itt eq
	subeq r7, r7, #1
	beq LongPress_Count_zero


	//when r1 is not 0
	it ne
	bxne lr


Button_Pressed:
	cmp r12, #0
	ite eq
	moveq r12, #1
	movne r12, #2

	cmp r12, #1
	it eq
	beq CheckLongPress

	it ne
	bxne lr

Delay:
	/* TODO: Write a delay 1 sec function */
	// You can implement this part by busy waiting.
	// Timer and Interrupt will be introduced in later lectures.
	cmp r7, #0
	itt gt
	subgt r7, r7, #1
	bgt Delay

	bx lr


stack_init:
	//todo: Setup the stack pointer(sp) to user_stack.
	ldr r2, =user_stack_bottom
	add r2, r2, #128
	msr msp, r2		// move the value in r2 to msp ( main stack pointer)
	bx lr

max7219send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push { r3, r4, r5, r6, r8}

	lsl r0, r0, #8
	add r0, r0, r1	//shift left 8 bits to connect the data

	ldr r1, =#CS
	ldr r2, =#DIN
	ldr r3, =#CLK
	ldr r4, =#GPIOB_BSRR
	ldr r5, =#GPIOB_BRR
	mov r6, #16	// r6 is i

max7219send_loop:
	mov r7, #1
	sub r8, r6, #1
	lsl r7, r7, r8	// r7 is mask
	str r3, [r5]
	tst r0,  r7
	beq bit_not_set
	str r2, [r4]
	b if_done

bit_not_set:
	str r2, [r5]

if_done:
	str r3, [r4]
	subs r6, r6, #1
	bgt max7219send_loop
	str r1, [r5]
	str r1, [r4]

	pop { r3, r4, r5, r6, r8}
	bx lr
max7219_init:
	//TODO: Initial max7219 registers.
	push {lr}
	ldr r0, =#DECODE_MODE
	ldr r1, =#0xff
	bl max7219send

	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0	// normal operation
	bl max7219send

	ldr r0, =#SCAN_LIMIT
	ldr r1, =#0x07	// display digit 0-7
	bl max7219send

	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	bl max7219send

	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1	// normal operation
	bl max7219send

	pop {lr}
	bx lr

GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK

	// enable AHB2 clock port b and port c
	mov r0, #6
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]
	// set pins PB3-5 as output mode
	mov r0, #0x540
	ldr r1, =GPIOB_MODER
	ldr r2, [r1]
	and r2, #0xFFFFF03F
	orr r2, r2, r0
	str r2, [r1]

	// keep PUPDR as the default value(pull-up).
	// set output speed register
	mov r0, #0xFC0
	ldr r1, =GPIOB_OSPEEDR
	ldr r2, [r1]
	and r2, #0xFFFFF03F
	orr r2, r2, r0
	str r2, [r1]

	// set PC13 as input mode
	mov r0, #0
	ldr r1, =GPIOC_MODER
	ldr r2, [r1]
	and r2, #0xF3FFFFFF
	orr r2, r2, r0
	str r2, [r1]

	// set PC13 speed
	mov r0, #0xC000000
	ldr r1, =GPIOC_OSPEEDR
	str r0, [r1]

	// set PC13 as Pull-up
	mov r0, #0x4000000
	ldr r1, =GPIOC_PUPDR
	str r0, [r1]


	bx lr
