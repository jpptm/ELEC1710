.syntax unified
.cpu cortex-m3
.thumb
.global task5

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 7
.equ	GPIOA_ODR,	0x4001080C	// For Nucleo LED on pin 5
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11
.equ	GPIOB_ODR,	0x40010C0C	// For Nucleo button on pin 13

// Hardware configuration summary:
// 	Nucleo LED on PA5
// 	Nucleo button on PB13
// 	4x tactile switches on PA8 to PA11
// 	7-segment on PC0 to PC7

// REQUIRED THINGS TO DO:
// SIMULATE CLOCK INPUT (POSITIVE EDGE TRIGGERED)
// DEAL WITH DEBOUNCING BY INTRODUCING DELAYS
// USE THE USER SWITCH CONNECTED TO GPIOB_ODR


task5:
	ldr r9, =0
	ldr r10, =20000
	b main

main:
	// Assume clk is one of the tactile switches at GPIOA
	ldr r0, =GPIOA_IDR
	ldr r0, [r0]

	// LUT and output pins
	ldr r1, =ssegdata
	ldr r2, =GPIOC_ODR

	// Extract needed inputs from register A
	ubfx r3, r0, #8, #4
	// A input
	ubfx r4, r3, #0, #1
	// B input
	ubfx r5, r3, #1, #1
	// CLK input
	ubfx r6, r3, #2, #1

	// If only CLK is flagged as 1, we wait for about #500 and then check if it is still 1. If it is then we can check other inputs
	ldr r7, =0

	cmp r6, #1
	beq debounceRisingCLK

	b main

debounceRisingCLK:
	// Keep adding 1 to r7 until it reaches #500. If clk is still 1 by then then we know its a legit input
	add r7, r7, #1
	cmp r7, r10
	bne debounceRisingCLK

	ldr r7, =0 // Reset counter once the wait is finished

	// Scan CLK again
	ldr r0, =GPIOA_IDR
	ldr r0, [r0]
	// Extract needed inputs from register A
	ubfx r3, r0, #8, #4
	// CLK input
	ubfx r6, r3, #2, #1

	// If clk is still 1 after waiting then we scan for AB inputs and if not branch back to task5
	cmp r6, #1
	beq scanAB
	bne main

scanAB:
	// Assume clk is one of the tactile switches at GPIOA
	ldr r0, =GPIOA_IDR
	ldr r0, [r0]
	// Extract needed inputs from register A
	ubfx r3, r0, #8, #4
	// A input
	ubfx r4, r3, #0, #1
	// B input
	ubfx r5, r3, #1, #1

	// Check B first
	cmp r5, #1
	beq showMin

	// If B is off check A, if A is off show max
	cmp r4, #0
	beq showMax
	bne step


showMax:
	// Show output and check clock state
	ldrb r8, [r1, #7]
	str r8, [r2]
	b checkCLK


showMin:
	// Show output and chceck clock state
	ldrb r8, [r1, #5]
	str r8, [r2]
	b checkCLK

step:
	// Show output, increment table accessor by one. Check if the new value is greater than the max index
	// If it is, reset the value then check clock state
	ldrb r8, [r1, r9]
	str r8, [r2]

	add r9, r9, #1
	cmp r9, #8
	it eq
	subeq r9, r9, r9 // Turn back to 0

	b checkCLK


checkCLK:
	// Check clock state
	// Assume clk is one of the tactile switches at GPIOA
	ldr r0, =GPIOA_IDR
	ldr r0, [r0]
	// Extract needed inputs from register A
	ubfx r3, r0, #8, #4
	// CLK input
	ubfx r6, r3, #2, #1

	cmp r6, #1
	beq checkCLK // while the user is holding CLK down don't do anything until they let go
	bne debounceFallingCLK // Debounce the switch and check again

debounceFallingCLK:
	// Keep adding 1 to r7 until it reaches #500. If clk is still 1 by then then we know its a legit input
	add r7, r7, #1
	cmp r7, #500
	bne debounceFallingCLK

	// Scan CLK again
	ldr r0, =GPIOA_IDR
	ldr r0, [r0]
	// Extract needed inputs from register A
	ubfx r3, r0, #8, #4
	// CLK input
	ubfx r6, r3, #2, #1

	// If clk is still 1 after waiting then we scan for AB inputs and if not branch back to task5
	cmp r6, #1
	beq checkCLK
	bne main

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

