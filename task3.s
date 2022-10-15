 .syntax unified
 .cpu cortex-m3
 .thumb
 .global task3

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 7
.equ	GPIOA_ODR,	0x4001080C	// For Nucleo LED on pin 5
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11
.equ	GPIOB_ODR,	0x40010C0C	// For Nucleo button on pin 13

// Hardware configuration summary:
// 	Nucleo LED on PA5
// 	Nucleo button on PB13
// 	4x tactile switches on PA8 to PA11
// 	7-segment on PC0 to PC7

// BRANCH STATEMENTS MUST BE LAST

// Rotate through student number automatically
task3:
// Load lookup table in register 0 and keep register 1 as our output peripheral
ldr r0, =ssegdata
ldr r1, =GPIOC_ODR

ldr r2, =0 // This counter will continuously count up. It will be the offset used for accessing values in the data table
ldr r3, =8 // Max number to compare r2 to - once r2 reaches this value we loop back to the beginning i.e., set r2 back to 0

b show


show:
// Prepare counter variable for delay
ldr r5, =0
// Grab info from LUT and show output
ldrb r4, [r0, r2]
str r4, [r1]
// Update data in r2 by going to the next desired output
add r2, r2, #1
// Compare r2 and r3
cmp r2, r3
// while r2 is less than or equal to r3, keep delaying and showing output else
// go back to task3 and refresh all values
blt delay
beq delay
bgt task3

// Count from 0 to this number to delay the execution
delay:
ldr r6, =0x000F0000 // Set r6 as a big number
add r5, r5, #1 // Keep adding 1 to r5

// If r5 is equal to r6 show the current required number
// If not, branch back to delay
cmp r5, r6
beq show
bne delay


.align 4
ssegdata:
	.byte 0x39//C
	.byte 0x4F//3
	.byte 0x4F//3
	.byte 0x4F//3
	.byte 0x7D//6
	.byte 0x3F//0
	.byte 0x06//1
	.byte 0x67//9
