	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC

.text
	.global main

main:
	ldr r0, =arr1		//load arr1 into r0
	bl do_sort			//branch to do_sort
	ldr r0, =arr2		//load arr2 into r0
	bl do_sort			//branch to do_sort

L: b L

do_sort:
	//TODO
	movs r1, #7			//move 7 to r1; r1 is used as the index of the outer loop; since the outer loop should be done 7 times, set r1 as 7
	b outer_loop		//branch to outer_loop

outer_loop:
	cmp r1, #0			//compare r1 and 0, r1 is used ad i
	it eq				//if r1 = 0, which means outer_loop has been done 7 times
	bxeq lr				//return

	//if r1 > 0, do what the outer_sort should do
	movs r2 ,#7			//move 7 to r2, r2 is used as j
	subs r1, r1, #1		//r1 minus 1
	b inner_loop		//branch to inner_loop

inner_loop:
	rsbs r6, r1, #6		//r6 = 6 - r1; it should work as j = 7 - i, but since r1 has been minus 1 before this, it'll become r6 = 7 - (r1 + 1) = 6 - r1
	cmp r2, r6			//compare r2 and r6
	it eq				//if r2 = r6
	beq outer_loop		//branch to outer loop

	//if r2 > r6, do what the inner loop should do
	sub r3, r2, #1 		//r3 = r2 - 1
	ldrb r4, [r0, r2]	//load r0 + r2byte into r4, r4 = array[j]
	ldrb r5, [r0, r3]	//load r0 + r3byte into r5, r5 = array[j - 1]

	//descending
	cmp r4, r5			//compare r4 and r5
	ittt gt				//if r4 > r5
	movsgt r6, r5		//move r5 to r6
	movsgt r5, r4		//move r4 to r5
	movsgt r4, r6		//move r6 to r4

	/*
	//ascending
	cmp r4, r5			//compare r4 and r5
	ittt lo				//if r4 < r5
	movslo r6, r5		//move r5 to r6
	movslo r5, r4		//move r4 to r5
	movslo r4, r6		//move r6 to r4
	*/

	strb r4, [r0, r2]	//store r4 back to r0 + r2byte
	strb r5, [r0, r3]	//store r5 back to r0 + r3byte

	subs r2, r2, #1		//r2 minus 1
	b inner_loop		//branch to inner_loop



