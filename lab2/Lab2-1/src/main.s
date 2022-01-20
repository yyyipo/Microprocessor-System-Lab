	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	result: .zero 8

.text
	.global main
	.equ X, 0x00FF00FF
	.equ Y, 0x00000101
	.equ MASK_ONE, 0x0000FFFF
	.equ MASK_TWO, 0xFFFF0000

main:
	ldr r0, =X			//load X into r0
	ldr r1, =Y			//load Y into r1
	ldr r2, =result		//load the address into r2
	bl kara_mul			//branch and link to kara_mul
	strd r1, r0, [r2]	//store the answer back to result, strd means store double words

L:	b L

kara_mul:
	//TODO: Separate the leftmost and rightmost halves intodifferent registers; then do the Karatsuba algorithm.
	//get XL, XR, YL, YR
	ldr r7, =MASK_ONE		//set r7 as mask(0x0000FFFF)
	and r3, r0, r7			//store XR in r3
	lsr r0, r0, #16			//shift r0 right 16 bits in order to get XL
	and r4, r0, r7 			//store XL in r4
	and r5, r1, r7			//store YR in r5
	lsr r1, r1, #16			//shift r1 right 16 bits in order to get YL
	and r6, r7, r1 			//store YL in r6

	//do karatsuba
	add r0, r4, r3			//r0 = r4 + r3 (r0 = XL + XR)
	add r1, r6, r5			//r1 = r6 + r5 (r1 = YL + YR)
	umull r0, r1, r0, r1	//r1 r0 = r0 * r1 (r1 r0 = (XL + XR) * (YL + YR))(r1 strore the higher 32bit, r0 stores the lower 32 bits)
	umull r7, r8, r4, r6	//r8 r7 = r4 * r6 (r8 r7 = XL * YL)
	umull r9, r10, r3, r5	//r10 r9 = r3 * r5 (r10 r9 = XR * YR)
	adds r7, r7, r9			//r7 = r7 + r9 (r7 = XL * YL + XR * YR)
	adc r8, r8, r10			//r8 = r8 + r10 + carry (r8 r7 = XL * YL + XR * YR)
	subs r0, r0, r7			//r0 = r0 - r7 (r0 = (XL + XR) * (YL + YR) - (XL * YL + XR * YR))
	sbc r1, r1, r8			//r1 = r1 - r8 + carry (r1 r0 = (XL + XR) * (YL + YR) - (XL * YL + XR * YR))


	ldr r7, = MASK_TWO		//set r7 as mask(0xFFFF0000)
	and r8, r0, r7			//store the higher 16 bit of r0 in r8
	lsl r0, r0, #16			//r0 shift left 16 bit
	lsl r1, r1, #16			//r1 shift left 16 bit
	lsr r8, r8, #16			//r8 shift right 16 bit
	add r1, r1, r8			//r1 = r1 + r8 (r1 r0 = pow(2, 16) * ((XL + XR) * (YL + YR) - (XL * YL + XR * YR))

	mul r7, r3, r5			//r7 = r3 * r5 (r7 = XR * YR)
	adds r0, r0, r7			//r0 = r0 + r7 (r0 = pow(2, 16) * ((XL + XR) * (YL + YR) - (XL * YL + XR * YR)) + XR * YR)
	adc r1, r1, #0			//r1 = r1 + carry (r1 r0 = pow(2, 16) * (XL + XR) * (YL + YR) - (XL * YL + XR * YR) + XR * YR)

	mul r7, r4, r6			//r7 = r4 * r6 (r7 = XL * YL)
	//adds r0, r0, #0		//r0 = r0 + 0 (r0 = pow(2, 32) * XL * YL + pow(2, 16) * (XL + XR) * (YL + YR) - (XL * YL + XR * YR) + XR * YR))
	add r1, r1, r7			//r1 = r1 + r7 (r1 r0 = pow(2, 32) * XL * YL + pow(2, 16) * (XL + XR) * (YL + YR) - (XL * YL + XR * YR) + XR * YR))

	bx lr
