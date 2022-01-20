	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	//TODO: put 0 to F 7-Seg LED pattern here
	arr: .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47
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

	ldr r9, =arr	//load the address of the array into r9
	ldr r2, =#0		//use r2 as the index of the array

loop:
	bl DisplayDigit

	ldr r3, =#1000000
	bl Delay

	add r2, r2, #1

	cmp r2, #16
	bne loop
	mov r2, #0
	b loop

DisplayDigit:
	//TODO: Display 0 to F at first digit on 7-SEG LED.
	mov r0, #1			//1 is register address of digit 0
	ldrb r1, [r9, r2]

	push {r2, lr}
	bl max7219send
	pop {r2, lr}

	bx lr


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

max7219send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	lsl r0, r0, #8			//address is in D11-D8, so shift left 8
	add r0, r0, r1			//add the data into r0
	ldr r1, =#CS			//load the value of CS into r1
	ldr r2, =#DIN			//load the value of DIN into r2
	ldr r3, =#CLK			//load the value of CLK into r3
	ldr r4, =#GPIOB_BSRR	//load the value of GPIO_BSRR into r4
	ldr r5, =#GPIOB_BRR		//load the value of GPIO_BRR into r5
	mov r6, #16				//r6 = 16 (enter max7219send_loop 16 times)

max7219send_loop:
	mov r7, #1				//r7 = 1
	sub r8, r6, #1			//r8 = r6 - 1
	lsl r7, r7, r8			//r7 shift left r8 (= r6 - 1) bits (use r7 as the mask of using which bit)
	str r3, [r5]			//set clk as 0
	tst r0, r7				//r0 AND r7 but only change the flag N,Z
	beq bit_not_set			//branch to bit not set if the Z is 0 (the bit in r0 is 0)
	str r2, [r4]			//set the bit as 1
	b if_done

bit_not_set:
	str r2, [r5]			////set the bit as 0

if_done:
	str r3, [r4]			//set clk as 1
	subs r6, r6, #1			//r6 = r6 - 1(r6 is index)
	bgt max7219send_loop	//if r6 != 0 branch to max7219send_loop
	str r1, [r5]			//set CS as 0
	str r1, [r4]			//set CS as 1

	bx lr

max7219_init:
	//TODO: Initialize max7219 registers
	push {lr}

	ldr r0, =#DECODE_MODE		//store the value of DECODE_MODE into r0
	ldr r1, =#0x0				//store 0x0(no decode for digit 7-0) into r1
	bl max7219send

	ldr r0, =#DISPLAY_TEST		//store the value of DECODE_MODE into r0
	ldr r1, =#0x0
	bl max7219send

	ldr r0, =#SCAN_LIMIT		//store the value of DECODE_MODE into r0
	ldr r1, =#0x0				//store 0x0(display digit 0 only) into r1
	bl max7219send

	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	bl max7219send

	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	bl max7219send

	pop {lr}
	bx lr

Delay:
	//TODO: Write a delay 1sec function
	cmp r3, #0
	itt gt
	subgt r3, r3, #1
	bgt Delay

	bx lr
