;=======================================================================
; tm1638cc.asm
; Examples of usage for tm1638 library
; written by Ralf Jardon (cosmicos at gmx dot net), May-July 2017
;
; Comments related to the datasheet refer to version 1.3 (en)
;
; License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
;
; Version: 1.0beta-1
;=======================================================================

.NOLIST
.INCLUDE "tm1638cc.h"
.INCLUDE "tm1638cc.mac"
.LIST
.LISTMAC

.CSEG
.ORG $0000

.INCLUDE "tm1638cc_interrupt_vectors.inc"; Interrupt Vectors

.ORG $100

;=======================================================================
;	Initialisation
;	THIS IS REQUIRED - DONT CHANGE
;=======================================================================

INIT:

	ldi 	AKKU, HIGH(RAMEND)			; Initialize stack pointer
	out 	SPH, AKKU
	ldi 	AKKU, LOW(RAMEND)
	out 	SPL, AKKU
	rcall	TM1638_INIT 				; Initialize Ports, SPI & TM1638

;=======================================================================
;	Mainloop
;	EXAMPLES OF LIBRARY USAGE - You can change whatever you want
;=======================================================================

MAINLOOP:

	rcall	TM1638_CLEAR
	ldi		AKKU3, 0					; Textblock "TM1638 DEMO"
	rcall	TM1638_PRINT_MOVETEXT

restart_loop:
	rcall	TM1638_CLEAR
	ldi		AKKU3, 6					; Textblock "PLEASE PRESS A BUTTON"
	rcall	TM1638_PRINT_MOVETEXT
	clr		BUTTONS

not_pressed:

	rcall	TM1638_POLL_KEYPAD			; check buttons

	tst		BUTTONS
	breq	not_pressed

	mov 	AKKU, BUTTONS
	cpi		AKKU, BUTTON8
	brne	b7;
; button8 pressed
	rcall	TM1638_CLEAR
	ldi		AKKU3, 1					; Textblock "RUNNING LIGHTS"
	rcall	TM1638_PRINT_MOVETEXT
	rcall	TM1638_CLEAR
	rcall	TM1638_LEDS_L
	rcall	TM1638_LEDS_R
	rjmp	restart_loop

b7:
	cpi		AKKU, BUTTON7
	brne	b6;
; button7 pressed
	rcall	TM1638_CLEAR
	ldi		AKKU3, 3					; Textblock "BINARY COUNTER"
	rcall	TM1638_PRINT_MOVETEXT
	rcall	TM1638_CLEAR
	rcall	TM1638_COUNT_BIN
	rjmp	restart_loop

b6:
	cpi		AKKU, BUTTON6
	brne	b5;
; button6 pressed
	rcall	TM1638_CLEAR
	ldi		AKKU3, 4					; Textblock "HEXADECIMAL COUNTER"
	rcall	TM1638_PRINT_MOVETEXT
	rcall	TM1638_CLEAR
	rcall	TM1638_COUNT_HEX
	rjmp	restart_loop

b5:
	cpi		AKKU, BUTTON5
	brne	b4;
; button5 pressed
	rcall	TM1638_CLEAR
	ldi		AKKU3, 5					; Textblock "DECIMAL COUNTER"
	rcall	TM1638_PRINT_MOVETEXT
	rcall	TM1638_CLEAR
	rcall	TM1638_COUNT_DEC
	rjmp	restart_loop

b4:
	cpi		AKKU, BUTTON4
	brne	b3;
; button4 pressed
	rcall	TM1638_CLEAR
	ldi		AKKU3, 2					; Textblock "TWIST SEGMENTS"
	rcall	TM1638_PRINT_MOVETEXT
	rcall	TM1638_CLEAR
	ldi		COUNT, 3					; twist cw
tw_loop:	
	rcall	TM1638_TWIST_CW
	dec 	COUNT
	brne	tw_loop

	ldi		COUNT, 3					; twist ccw
tw_loop1:	
	rcall	TM1638_TWIST_CCW
	dec 	COUNT
	brne	tw_loop1
	rcall	TM1638_CLEAR
	rjmp	restart_loop

b3:
	cpi		AKKU, BUTTON3
	brne	b2;
; button3 pressed
	rcall	TM1638_CLEAR
	ldi		AKKU3, 7					; Textblock "CODE COMES WITH GPL V3"
	rcall	TM1638_PRINT_MOVETEXT
	rcall	TM1638_CLEAR

	rjmp	restart_loop

b2:
	cpi		AKKU, BUTTON2
	brne	b1;
; button2 pressed
	ldi		AKKU3, 0					; Textblock "LEDS DIM"
	rcall	TM1638_PRINT_TEXT
	ldi		AKKU2, 4
dm0_loop:
	ldi		COUNT, 7					; DIM LEDs
dm_loop:
	mov		AKKU, COUNT
	rcall	TM1638_BRIGHTNESS
	rcall	Delay100ms
	rcall	Delay100ms
	dec 	COUNT
	brne	dm_loop
	
	dec		AKKU2
	brne	dm0_loop
	
	ldi		AKKU, DISP_PWM_MASK			; restore brightness settings
	rcall	TM1638_BRIGHTNESS
	rjmp	restart_loop


b1:
; button1 pressed, back to the beginning "TM1638 DEMO"

	rjmp	MAINLOOP

;=======================================================================
; Functions for Mainloop
;=======================================================================
;
; LED chain right
;

TM1638_LEDS_R:	
	push	COUNT
	ldi		COUNT, 8
	ldi		TM1638_GRID_BYTE, 0x01		; first LED address

led_loop:
	ldi		TM1638_SEGM_BYTE, 1			; LED ON
	rcall	TM1638_SEND_DATA			; 
	rcall	Delay100ms
	clr		TM1638_SEGM_BYTE			; LED OFF
	rcall	TM1638_SEND_DATA			;
	subi	TM1638_GRID_BYTE, -2		; next LED address
	dec		COUNT
	brne	led_loop
	pop		COUNT
	ret

;
; LED chain left
;

TM1638_LEDS_L:	
	push	COUNT
	ldi		COUNT, 8
	ldi		TM1638_GRID_BYTE, 0x0F		; first LED address

led_loop_l:
	ldi		TM1638_SEGM_BYTE, 1			; LED ON
	rcall	TM1638_SEND_DATA			; 
	rcall	Delay100ms

	clr		TM1638_SEGM_BYTE			; LED OFF
	rcall	TM1638_SEND_DATA			;
	subi	TM1638_GRID_BYTE, 2			; next LED address
	dec		COUNT
	brne	led_loop_l
	pop		COUNT
	ret

;
; binary counter
;

TM1638_COUNT_BIN:
	push	AKKU
	clr		AKKU
binloop:
	rcall	TM1638_PRINT_BIN			; print value in AKKU
	rcall	Delay100ms
	inc		AKKU
	cpi		AKKU, 0x00
	brne	binloop
	pop		AKKU
	ret

;
; hexadecimal coutner
;

TM1638_COUNT_HEX:
	push	AKKU2
	push	AKKU3
	ldi		XL,HIGH(0)
	ldi		XH,LOW(0)
z1loop:
	mov		AKKU2, XL
	mov		AKKU3, XH
	rcall	TM1638_PRINT_HEX			; print values in AKKU2 and AKKU3
										; as 16 bit number (LO and HI-Byte)
	rcall 	Delay10ms
	cpi 	XH, 11
	breq	stop1_counting
	adiw 	XH:XL,1	
	brne 	z1loop
stop1_counting:
	pop		AKKU3
	pop		AKKU2
	ret

;
; decimal counter
;

TM1638_COUNT_DEC:
	push	AKKU2
	push	AKKU3
	ldi		XL,HIGH(0)
	ldi		XH,LOW(0)
zloop:
	mov		AKKU2, XL
	mov		AKKU3, XH
	rcall	TM1638_PRINT_DEC			; print values in AKKU2 and AKKU3
										; as 16 bit number (LO and HI-Byte)
	rcall 	Delay10ms
	cpi 	XH, 8
	breq	stop_counting
	adiw 	XH:XL,1	
	brne 	zloop
stop_counting:
	pop		AKKU3
	pop		AKKU2
	ret

;
; twist arround CW
;

TM1638_TWIST_CW:
	push 	AKKU
	push 	COUNT
	ldi 	AKKU, 1
	clr		COUNT
	clr 	TM1638_GRID_BYTE
	
twistloop:
	mov 	TM1638_SEGM_BYTE, AKKU		
	rcall 	TM1638_SEND_DATA			; activates only one LED. Position
										; is given by GRID_BYTE (DIGIT) and
										; SEGM_BYTE (LED-SEGMENT)
	subi 	TM1638_GRID_BYTE, -2
	inc		COUNT
	cpi		COUNT, 8
	brne	twistloop
	rcall	delay10ms
	rcall	delay10ms
	
	clr		TM1638_GRID_BYTE
	
	rol		AKKU
	cpi 	AKKU, 0b01000000
	brne	twistloop
	pop		COUNT
	pop		AKKU
	ret

;
; twist arround CCW
;

TM1638_TWIST_CCW:
	push 	AKKU
	push 	COUNT
	ldi 	AKKU, 0b00100000
	clr		COUNT
	clr 	TM1638_GRID_BYTE

twistloop2:
	mov 	TM1638_SEGM_BYTE, AKKU
	rcall 	TM1638_SEND_DATA			; activates only one LED. Position
										; is given by GRID_BYTE (DIGIT) and
										; SEGM_BYTE (LED-SEGMENT)
	subi 	TM1638_GRID_BYTE, -2
	inc		COUNT
	cpi		COUNT, 8
	brne	twistloop2
	rcall	delay10ms
	rcall	delay10ms

	clr		TM1638_GRID_BYTE
	
	ror		AKKU
	brcc	twistloop2
	pop		COUNT
	pop		AKKU
	ret

.INCLUDE "tm1638cc.inc"
.INCLUDE "tm1638cc_input.asm"
.INCLUDE "tm1638cc_delay.inc"
.INCLUDE "tm1638cc_font.inc"

MOVETEXT:
.db "            TM1638 DEMO            ",0	; TEXT_BLOCK 0
.db "           RUNNING LIGHT           ",0	; TEXT_BLOCK 1
.db "          TWIST SEGMENTS           ",0	; TEXT_BLOCK 2
.db "          BINARY COUNTER           ",0	; TEXT_BLOCK 3
.db "       HEXADECIMAL COUNTER         ",0	; TEXT_BLOCK 4
.db "         DECIMAL COUNTER           ",0	; TEXT_BLOCK 5
.db "              PLEASE PRESS A BUTTON",0	; TEXT_BLOCK 6
.db "       CODE COMES WITH GPL V3      ",0	; TEXT_BLOCK 7

PRINTTEXT:
.db "LEDS DIM",0,0							; TEXT_BLOCK 0
.db "A BUTTON",0,0							; TEXT_BLOCK 1
.db "        ",0,0							; TEXT_BLOCK 2

.EXIT
