 .syntax unified
 .cpu cortex-m3
 .thumb
 .global task2

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 7
.equ	GPIOA_ODR,	0x4001080C	// For Nucleo LED on pin 5
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11
.equ	GPIOB_ODR,	0x40010C0C	// For Nucleo button on pin 13

// Hardware configuration summary:
// 	Nucleo LED on PA5
// 	Nucleo button on PB13
// 	4x tactile switches on PA8 to PA11
// 	7-segment on PC0 to PC7

task2:
// Load LUT to r0 and real load for the input pins
ldr r0, =ssegdata
ldr r1, =GPIOA_IDR
ldr r2, [r1]
// Load output peripheral
ldr r3, =GPIOC_ODR
// Extract the data in the input bits
ubfx r2, r2, #8, #4
// Grab data from the LUT based on user input
ldrb r2, [r0, r2]
// Show output while code has not been terminated
str r2, [r3]
// Branch back to task2 (while True)
b task2


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
