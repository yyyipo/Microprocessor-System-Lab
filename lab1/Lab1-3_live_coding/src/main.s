	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	arr1: .word 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .word 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC

.text
	.global main

do_sort:
	//TODO
	movs r1, #7
	b outer_loop

outer_loop:
	cmp r1, #0
	it eq
	bxeq lr

	movs r2 ,#7
	subs r1, r1, #1
	b inner_loop

inner_loop:
	rsbs r6, r1, #6

	cmp r2, r6
	it eq
	beq outer_loop

	sub r3, r2, #1
	mov r9, #4
	mul r7, r2, r9		//r7 = r2 * 4
	mul r8, r3, r9		//r8 = r3 * 4
	ldr r4, [r0, r7]
	ldr r5, [r0, r8]

	cmp r4, r5
	ittt gt
	movsgt r6, r5
	movsgt r5, r4
	movsgt r4, r6

	str r4, [r0, r7]
	str r5, [r0, r8]

	subs r2, r2, #1
	b inner_loop


main:
	ldr r0, =arr1
	bl do_sort
	ldr r0, =arr2
	bl do_sort

L: b L
