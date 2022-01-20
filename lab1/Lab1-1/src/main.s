	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .byte 0
.text
	.global main
	.equ X, 0xFFFFFFFF
	.equ Y, 0x7FFFFFFF

main:
	ldr r0, =X	//load the value of X into r0
	ldr r1, =Y	//load the value of Y into r1
	ldr r2, =result		//load result into r2 (reslult is an address)
	ldr r2, [r2]	//load the value of r2 into r2
	bl hamm		//branch to hamm
	ldr r3, =result
	str r2, [r3]	//load the answer back to result

L: b L

hamm:
	//TODO
	eors r0, r0, r1		//get the result of r0 XOR r1, and store the result in r0
	mov r3, #0	//store the value 0 into r3

loop:
	adds r3, r3, #1		// add 1 to r3
	cmp r3, #33		//compare the value of r3 and 32
	itttt lo	//if r3 is smaller than 32
	andlo r4, r0, #1	//get the result of r0 AND 1, and store the result into r4
	addslo r2, r2, r4	//add r4 to r2
	movlo r0, r0, lsr #1	//shift r0 right 1 bit
	blo loop	//branch to loop

	bx lr
