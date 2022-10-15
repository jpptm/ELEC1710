.syntax unified
.cpu cortex-m3
.thumb
.global task4

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 7
.equ	GPIOA_ODR,	0x4001080C	// For Nucleo LED on pin 5
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11
.equ	GPIOB_ODR,	0x40010C0C	// For Nucleo button on pin 13

// Hardware configuration summary:
// 	Nucleo LED on PA5
// 	Nucleo button on PB13
// 	4x tactile switches on PA8 to PA11
// 	7-segment on PC0 to PC7


// Rotate through student number automatically
// A    B    Z
// 0    0    MAX
// 0    1    MIN
// 1    0    STEP
// 1    1    MIN

task4:
	// Load required registers
	ldr r0, = GPIOA_IDR // Pseudoload input pins for user input
	ldr r1, [r0]

	// Put LUT data into register 2
	ldr r2, =ssegdata

	// Put output peripheral register to register 3
	ldr r3, =GPIOC_ODR

	// Extract the bits we want and put it to register 1. These would be output bits by PA8 and PA9
	ubfx r1, r1, #8, #4

	// Split the 2 bits into 2 separate values and make decisions based on these inputs
	ubfx r4, r1, #0, #1 // The 0th bit will be the first switch i.e., input A
	ubfx r5, r1, #1, #1 // The 1st bit will be the second switch i.e., input B


	// If B is on show the min number - this will be idx = 5 for the LUT
	cmp r5, #1
	it eq
	beq showMin

	// If A is on step through - don't have to worry about B at this point as if both inputs were on at the same time,
	// the program wouldve branched to showMin only anyway.
	cmp r4, #1
	it eq
	beq step

	// At this point, if neither of the inputs are on then we know that the user didn't press any buttons so we show them the max number
	// idx = 7

	b showMax

// --- --- --- From this point on we will use the same registers for showing output for efficiency and consistency --- --- ---

// Store output to GPIOC_ODR and branch to task4
showMin:
	ldrb r6, [r2, #5]
	str r6, [r3]

	b task4

showMax:
	ldrb r6, [r2, #7]
	str r6, [r3]

	b task4

// We just copy the code from the previous task for this
step:
	// The following will be indexing variables
	ldr r7, =0
	ldr r8, =8

	b showStep

showStep:
	ldr r9, =0 // This will be a delay variable
	ldrb r6, [r2, r7] // Show current number using the index for the LUT - use the same output register
	str r6, [r3]

	 // Increment r7 by 1
	add r7, r7, #1

	// Need to scan values of A and B again, copy the code from above
	ldr r0, = GPIOA_IDR // Pseudoload input pins for user input
	ldr r1, [r0]
	// Extract the bits we want and put it to register 1. These would be output bits by PA8 and PA9
	ubfx r1, r1, #8, #4
	// Split the 2 bits into 2 separate values and make decisions based on these inputs
	ubfx r4, r1, #0, #1 // The 0th bit will be the first switch i.e., input A
	ubfx r5, r1, #1, #1 // The 1st bit will be the second switch i.e., input B

	// If A is 0 branch to max, if B is 1 branch to min
	cmp r4, #0
	beq showMax

	cmp r5, #1
	beq showMin

	// Check if r7 is the same value as r8. If it is, branch back to task4
	cmp r7, r8
	blt delay
	beq delay
	bgt task4

// Make the computer count up to delay the process of showing the output
delay:
	ldr r10, =0x00080000
	add r9, r9, #1


	cmp r9, r10
	beq showStep
	bne delay

.align 4
ssegdata:
	.byte 0x39//C: 0
	.byte 0x4F//3: 1
	.byte 0x4F//3: 2
	.byte 0x4F//3: 3
	.byte 0x7D//6: 4
	.byte 0x3F//0: 5
	.byte 0x06//1: 6
	.byte 0x67//9: 7
