	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	infix_expr: .asciz "{ -99+ [ 10 + 20 - 10]] }"
	user_stack_bottom: .zero 128

.text
	.global main
	//move infix_expr here. Please refer to the question below.
	//infix_expr: .asciz "{ -99+ [ 10 + 20 - 10 }"
	//.align 4

main:
	bl stack_init					//branch and link to stack_init
	ldr r1, =infix_expr				//load the address of infix_expr into r1
	mov r0, #0						//move 0 into r0
	bl pare_check					//branch and link to pare_check

L: b L

stack_init:
	//TODO: Setup the stack pointer(sp) to user_stack.
	ldr r2, =user_stack_bottom		//load user_stack_bottom into r2
	add r2, r2, #128				//r2 = r2 + 128 (stack grows from high address to loew address so we have to add 128 byte back to r2)
	msr msp, r2 					//setup sp to user_stack_bottom + 128
	mrs r4, msp						//save the initial address of msp to m4 so that we can check if something is left in the stack later
	bx lr

pare_check:
	//TODO: check parentheses balance, and set the error code to R0.
	ldrb r2, [r1]					//load the value in r1 to r2
	add r1, r1, #1					//r1 = r1 + 1

	cmp r2, #0
	it eq			//if r2 == 0 (0 is '\0')
	beq handle_0	//branch to handle_0

	cmp r2, #91
	it eq			//if r2 == 91 (91 is '[')
	pusheq {r2}		//push r2 into stack

	cmp r2, #123
	it eq			//if r2 == 123 (123 is '{')
	pusheq {r2}		//push r2 into stack

	cmp r2, #93
	it eq			//if r2 == 93 (93 is ']')
	beq handle_93	//branch to handle_93

	cmp r2, #125
	it eq			//if r2 == 125 (125 is '}')
	beq handle_125	//branch to handle_125

	b pare_check	//branch to pare_check (loop)

handle_0:
	mrs r5, msp		//store msp to r5
	cmp r4, r5		//compare r4 and r5
	it ne			//if r4 and r5 are not the same, it means there's still something in the stack, and the parenthesises are not in pair
	movne r0, #-1	//r0 = -1
	bx lr			//return

handle_93:
	pop {r3}		//pop something from the stack and store it in r3
	cmp r3, #91		//compare r3 and 91
	itt ne			//if r3 != 91, it means the parenthesises are not in pair
	movne r0, #-1	//r0 = -1
	bxne lr			//return

	b pare_check	//branch to pare_check

handle_125:
	pop {r3}		//pop something from the stack and store it in r3
	cmp r3, #123	//compare r3 and 123
	itt ne			//if r3 != 123, it means the parenthesises are not in pair
	movne r0, #-1	//r0 = -1
	bxne lr			//return

	b pare_check	//branch to pare_check
