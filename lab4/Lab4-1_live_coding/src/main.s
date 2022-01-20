	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	//TODO: put 0 to F 7-Seg LED pattern here
	arr: .byte 0x1c, 0x19, 0x15, 0xd, 0x1c, 0x19, 0x15, 0xd
	user_stack_bottom: .zero 128

.text
	.global main

	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOB_MODER, 0x48000400	//mode (input, output), also the base of GPIOB
	.equ GPIOB_OSPEEDR, 0x48000408	//speed
	.equ GPIOB_PUPDR, 0x4800040C	//pullup pulldown
	.equ GPIOB_ODR, 0x48000414		//output
	.equ GPIOB_BSRR, 0x48000418		//BSRR
	.equ GPIOB_BRR, 0x48000428		//BRR

	.equ DECODE_MODE, 0x09			//MAX7219 (put 0 into the don't care digit)
	.equ DISPLAY_TEST, 0x0F
	.equ SCAN_LIMIT, 0x0B
	.equ INTENSITY, 0x0A
	.equ SHUTDOWN, 0x0C

	.equ DIN, 0x10		//PB4 (10000)
	.equ CS, 0x20		//PB5 (100000)
	.equ CLK, 0x8		//PB3 (1000)


main:
	bl stack_init
	bl GPIO_init
	bl max7219_init

reset:
	mov r0, #1
	mov r1, #0x0
	bl MAX7219Send
	mov r0, #2
	mov r1, #0x0
	bl MAX7219Send
	mov r0, #3
	mov r1, #0x0
	bl MAX7219Send
	mov r0, #4
	mov r1, #0x0
	bl MAX7219Send
	mov r0, #5
	mov r1, #0x0
	bl MAX7219Send
	mov r0, #6
	mov r1, #0x0
	bl MAX7219Send
	mov r0, #7
	mov r1, #0x0
	bl MAX7219Send
	mov r0, #8
	mov r1, #0x0
	bl MAX7219Send

	ldr r9, =arr
	ldr r2, =#0
	ldr r0, =#1


loop:
	bl DisplayDigit

	//ldr r3, =#1000000
	//bl Delay

	add r2, r2, #1
	add r0, r0, #1
	cmp r2, #8
	bne loop
	mov r2, #0
	mov r0, #1
	b loop

stack_init:
	//TODO: Setup the stack pointer(sp) to user_stack.
	ldr r0, =user_stack_bottom		//load user_stack_bottom into r0
	add r0, r0, #128				//r0 = r0 + 128 (stack grows from high address to low address so we have to add 128 byte back to r2)
	msr msp, r0 					//setup sp to user_stack_bottom + 128

	bx lr

GPIO_init:
	//TODO: Initialize GPIO pins for max7219 DIN, CS and CLK
	// Enable AHB2 clock (port B)
	mov r0, #0x2
	ldr r1, =RCC_AHB2ENR
	str r0, [r1]

	//set pins PB3-6 as output mode
	mov r0, #0x540
	ldr r1, =GPIOB_MODER
	ldr r2, [r1]
	and r2, r2, 0xFFFFF03F	//only change the mask of pin3-6
	orrs r2, r2, r0
	str r2, [r1]

	// Keep PUPDR as the default value.

	// Set output speed register
	mov r0, #0xFC0
	ldr r1, =GPIOB_OSPEEDR
	ldr r2, [r1]
	and r2, r2, 0xFFFFF03F
	orrs r2, r2, r0
	str r2, [r1]

	bx lr

DisplayDigit:
	//TODO: Display 0 to F at first digit on 7-SEG LED.
	//mov r0, #1			//1 is register address of digit 0
	ldrb r1, [r9, r2]

	push {r0, r2, lr}
	bl MAX7219Send
	pop {r0, r2, lr}


	ldr r3, =1000000
	push {lr}
	bl Delay
	pop {lr}


	ldrb r1, =0
	push {r0, r2, lr}
	bl MAX7219Send
	pop {r0, r2, lr}




	bx lr

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =#CS	//spec r2
	ldr r2, =#DIN	//spec r3
	ldr r3, =#CLK	//spec r4
	ldr r4, =#GPIOB_BSRR	//spec r1 + r5
	ldr r5, =#GPIOB_BRR		//spec r1 + r6
	mov r6, #16				//spec r7

max7219send_loop:
	mov r7, #1
	sub r8, r6, #1
	lsl r7, r7, r8
	str r3, [r5]
	tst r0, r7
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

	bx lr

max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}

	ldr r0, =#DECODE_MODE		//store yhe value of decode mode into r0
	ldr r1, =#0x0				//store 0x0 into r1
	bl MAX7219Send

	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	bl MAX7219Send

	ldr r0, =#SCAN_LIMIT
	ldr r1, =#0x07
	bl MAX7219Send

	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	bl MAX7219Send

	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	bl MAX7219Send

	pop {lr}
	bx lr

Delay:
	//TODO: Write a delay 1sec function
	cmp r3, #0
	itt gt
	subgt r3, r3, #1
	bgt Delay

	bx lr
