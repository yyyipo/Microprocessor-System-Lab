	.syntax unified
	.cpu cortex-m4
	.thumb
.text
	.global max7219_send

	.equ GPIOB_BSRR, 0x48000418
	.equ GPIOB_BRR, 0x48000428
	//MAX7219
	.equ DIN, 0x10	//PB4
	.equ CS, 0x20	//PB5
	.equ CLK, 0x8 //PB3

max7219_send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r4, r5, r6, r7, r8, r9, r10}

	lsl r0, r0, #8
	add r0, r0, r1	//shift left 8 bits to connect the data

	ldr r4, =#CS
	ldr r5, =#DIN
	ldr r6, =#CLK
	ldr r7, =#GPIOB_BSRR
	ldr r8, =#GPIOB_BRR
	mov r9, #16	// r9 is i

max7219_send_loop:
	mov r10, #1
	sub r9, r9, #1
	lsl r10, r10, r9	// r10 is mask
	add r9, r9, #1
	str r6, [r8]
	tst r0,  r10
	beq bit_not_set
	str r5, [r7]
	b if_done

bit_not_set:
	str r5, [r8]

if_done:
	str r6, [r7]
	subs r9, r9, #1
	bgt max7219_send_loop
	str r4, [r8]
	str r4, [r7]

	pop {r4, r5, r6, r7, r8, r9, r10}
	bx lr
