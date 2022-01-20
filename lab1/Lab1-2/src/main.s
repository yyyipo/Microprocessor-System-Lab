	.syntax unified
	.cpu cortex-m4
	.thumb

.text
	.global main
	.equ N, 95

main:
	movs r0, #N			//move N into r0
	movs r1, #0			//move 0 into r1
	movs r2, #1			//move 1 into r2

	bl fib

L: b L

fib:
	//TODO
	// N > 100
	cmp r0, 100			//compare r0 and 100
	itt gt				//if r0 > 100
	movgt r4, #-1		//mov -1 to r4
	bxgt lr				//return

	// N < 0
	cmp r0, 0			//compare r0 and 0
	itt lt				//if r0 < 0
	movlt r4, #-1		//mov -1 to r4
	bxlt lr				//return

	// N = 0
	cmp r0, 0			//compare r0 and 0
	itt eq				//if r0 = 0
	moveq r4, #0		//move 0 to r4
	bxeq lr				//return

	// N = 1
	cmp r0, 1			//compare r0 and 1
	itt eq				//if r0 = 1
	moveq r4, #1		//move 1 to r4
	bxeq lr				//return

	movs r3, #0			//mov 0 to r3; r3 is used as the index of the loop
	movs r4, #1			//mov 1 to r4; r4 is used to record the answer


loop:
	// 2 <= N <= 100
	cmp r4, 0			//compare r4 and 0; check the answer of last loop, if r4 < 0 means r4 overflow
	itt lt				// if r4 < 0
	movslt r4, #-2		//move -2 to r4
	bxlt lr				//return

	adds r3, r3, #1		//add 1 to r3
	cmp r3, #N			//compare r3 and N
	itttt lo			//if r3 < N
	addslo r4, r1, r2	//add r1 and r2, and store the result to r4; r4 is fn, r1 is fn-2, r2 is fn-1
	movslo r1,r2		//move r2 to r1;
	movslo r2, r4		//move r4 to r2
	blo loop			//branch to loop


	bx lr				//return


