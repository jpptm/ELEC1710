 .syntax unified
 .cpu cortex-m3
 .thumb
 .global task1

.equ	GPIOC_ODR,	0x4001100C	// For 7-seg on pins 0 to 7
.equ	GPIOA_ODR,	0x4001080C	// For Nucleo LED on pin 5
.equ	GPIOA_IDR,	0x40010808	// For custom buttons on pins 8-11
.equ	GPIOB_ODR,	0x40010C0C	// For Nucleo button on pin 13

// Hardware configuration summary:
// 	Nucleo LED on PA5
// 	Nucleo button on PB13
// 	4x tactile switches on PA8 to PA11
// 	7-segment on PC0 to PC7

task1:
// Hard code numbers in
ldr r0, =ssegdata // Put LUT in register 0
ldr r2, =GPIOC_ODR // Put output pins in register 2

// Let register 1 be hte input register - this task will be done through the debugger
// Basically going to load bytes from the LUT and store them 8 times (From C to the last digit of the student number)
// In this case, from C-9

//C
ldrb r1, [r0, #12]
str r1, [r2]

//3
ldrb r1, [r0, #3]
str r1, [r2]
//3
ldrb r1, [r0, #3]
str r1, [r2]
//3
ldrb r1, [r0, #3]
str r1, [r2]
//6
ldrb r1, [r0, #6]
str r1, [r2]

//0
ldrb r1, [r0, #0]
str r1, [r2]

//1
ldrb r1, [r0, #1]
str r1, [r2]

//9
ldrb r1, [r0, #9]
str r1, [r2]
//b task1

.align 4
ssegdata:   // The LUT
    .byte 0x3F  // 0:0
    .byte 0x06  // 1:1
    .byte 0x5B  // 2:2
    .byte 0x4F  // 3:3
    .byte 0x66  // 4
    .byte 0x6D  // 5
    .byte 0x7D  // 6
    .byte 0x07  // 7
    .byte 0x7F  // 8
    .byte 0x67  // 9
    .byte 0x77  // A:10
    .byte 0x7C  // B:11
    .byte 0x39  // C:12
    .byte 0x5E  // D:13
    .byte 0x79  // E:14
    .byte 0x71  // F:15
