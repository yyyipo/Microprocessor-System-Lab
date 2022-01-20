	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .word 0
	max_size: .word 0
	user_stack_bottom: .zero 1024

.text
	m: .word 0x5E
	n: .word 0x60
	.global main


main:
	bl stack_init		//branch and link to stack_init
	ldr r0, =m			//load the address of m into r0
	ldr r0, [r0]		//r0 = m
	ldr r1, =n			//load the address of n into r0
	ldr r1, [r1]		//r1 = n
	ldr r5, =max_size	//load the address of max_size into r5
	ldr r5, [r5]		//load the value of max_size into r5
	bl GCD				//branch and link to GCD
	ldr r3, =result		//load the address of result into r3
	str r2, [r3]		//store the r2 into result
	ldr r6, =max_size
	str r5, [r6]

L: 	b L

stack_init:
	//TODO: Setup the stack pointer(sp) to user_stack.
	ldr r3, =user_stack_bottom		//load the address of user_stack_bottom into r3
	add r3, r3, #1024				//r3 = r3 + 128, so that we can use the stack from high address
	msr msp, r3 					//setup msp to r3
	bx lr							//return

GCD:
	//TODO: Implement your GCD function
	cmp r0, #0
	it eq							//if a == 0
	beq handle_a_0					//branch to handle_a_0

	cmp r1, #0
	it eq							//if b == 0
	beq handle_b_0					//branch to handle_b_0

	and r3, r0, #1					//check if a is even (if a is even, r3 will be 0)
	and r4, r1, #1					//check if b is even (if b is even, r4 will be 0)
	orr r3, r3, r4					//check if both a and b are even (if they are, r3 will be 0)
	cmp r3, #0
	it eq							//if (a % 2 == 0) && (b % 2 == 0)
	beq handle_ab_even				//branch to handle_ab_even

	and r3, r0, #1					//check if a is even (if a is even, r3 will be 0)
	cmp r3, #0
	it eq							//if a % 2 == 0
	beq handle_a_even				//branch to handle_a_even

	and r3, r1, #1					//check if b is even (if b is even, r3 will be 0)
	cmp r3, #0
	it eq							//if b % 2 == 0
	beq handle_b_even				//branch to handle_b_even

	//else
	cmp r0, r1
	ittt lo							//if r0 < r1
	sublo r3, r1, r0				//r3 = r1 - r0
	movlo r1, r0					//r1 = r0
	movlo r0, r3					//r0 = r3

	it ge							//if r0 >= r1
	subge r0, r0, r1				//r0 = r0 - r1
	push {lr}						//push lr into the stack
	add r5, r5, #4
	bl GCD							//branch to GCD
	pop {lr}						//pop something from the stack and store it in lr

	bx lr							//return

handle_a_0:
	mov r2, r1						//r2 = r1 (r2 is where the result is stored)
	pop {lr}						//pop lr
	bx lr							//return

handle_b_0:
	mov r2, r0						//r2 = r0
	pop {lr}						//pop lr
	bx lr							//return

handle_ab_even:
	lsr r0, #1						//r0 = r0 / 2
	lsr r1, #1						//r1 = r1 / 2
	push {lr}						//push lr
	add r5, r5, #4					//r5 = r5 + 4
	bl GCD							//branch and link to GCD
	lsl r2, #1						//r2 = r2 * 2
	pop {lr}						//pop lr
	bx lr							//return

handle_a_even:
	lsr r0, #1						//r0 = r0 / 2
	push {lr}						//push lr
	add r5, r5, #4					// r5 = r5 + 4
	bl GCD							//branch and link to GCD
	pop {lr}						//pop lr
	bx lr							//return

handle_b_even:
	lsr r1, #1						//r1 = r1 / 2
	push {lr}						//push lr
	add r5, r5, #4					//r5 = r5 + 4
	bl GCD							//branch and link to GCD
	pop {lr}						//pop lr
	bx lr							//return
