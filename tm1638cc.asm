;=======================================================================
; tm1638cc.asm
; Examples of usage for tm1638 library
; written by Ralf Jardon (cosmicos@gmx.net), May-July 2017
;
; Comments related to the datasheet refer to version 1.3 (en)
;
; License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
;
; Version: 0.1
;=======================================================================

.NOLIST
.INCLUDE "tm1638cc.h"
.INCLUDE "tm1638cc.mac"
.LIST
.LISTMAC

.CSEG
.ORG $0000
	rjmp 	INIT						; Reset Vektor

.ORG INT_VECTORS_SIZE					; Placeholder Interrupt Vectors

;=======================================================================
;							Mainloop
; 
;=======================================================================

INIT:

	ldi 	AKKU, HIGH(RAMEND)			; Initialize stack pointer
	out 	SPH, AKKU
	ldi 	AKKU, LOW(RAMEND)
	out 	SPL, AKKU
	rcall	TM1638_INIT 				; Initialize Ports, SPI & TM1638

MAINLOOP:

;=======================================================================

ldi		COUNT, 3						; move LEDs
tw0_loop:	
	rcall	TM1638_LEDS_R
	rcall	TM1638_LEDS_L
	dec 	COUNT
	brne	tw0_loop

;=======================================================================

	ldi		COUNT, 3					; twist cw
tw_loop:	
	rcall	TM1638_TWIST_CW
	dec 	COUNT
	brne	tw_loop
	rcall	TM1638_CLEAR
	
;=======================================================================

	ldi		COUNT, 3					; twist ccw
tw2_loop:	
	rcall	TM1638_TWIST_CCW
	dec 	COUNT
	brne	tw2_loop
	rcall	TM1638_CLEAR
	
;=======================================================================

	clr		AKKU3						; Textblock "TM1638 DEMO"
	rcall	TM1638_PRINT_MOVETEXT

	rcall	TM1638_LEDS_L
	rcall	TM1638_LEDS_R

;=======================================================================

	ldi		AKKU3, 2					; Textblock "HEXACECIMAL COUNTER"
	rcall	TM1638_PRINT_MOVETEXT

	rcall	TM1638_COUNT_HEX
	rcall	Delay1s

	rcall	TM1638_LEDS_L
	rcall	TM1638_LEDS_R
	
;=======================================================================

	ldi		AKKU3, 4					; Textblock "LEDS DIM"
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
	
;=======================================================================

	ldi		AKKU3, 1					; Textblock "BINARY COUNTER"
	rcall	TM1638_PRINT_MOVETEXT

	rcall	TM1638_COUNT_BIN
	rcall	Delay1s

	rcall	TM1638_LEDS_L
	rcall	TM1638_LEDS_R

;=======================================================================

	ldi		AKKU3, 3					; Textblock "DECIMAL COUNTER"
	rcall	TM1638_PRINT_MOVETEXT

	rcall	TM1638_COUNT_DEC
	rcall	Delay1s
	rcall	TM1638_LEDS_L
	rcall	TM1638_LEDS_R

	rjmp		MAINLOOP

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
	push	AKKU
	clr		AKKU
hexloop:
	rcall	TM1638_PRINT_HEX			; print value in AKKU
	rcall	Delay100ms
	inc		AKKU
	cpi		AKKU, 0x00
	brne	hexloop
	pop		AKKU
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
.INCLUDE "tm1638cc_delay.inc"
.INCLUDE "tm1638cc_font.inc"

MOVETEXT:
.db "            TM1638 DEMO            ",0	; TEXT_BLOCK 0
.db "          BINARY COUNTER           ",0	; TEXT_BLOCK 1
.db "       HEXADECIMAL COUNTER         ",0	; TEXT_BLOCK 2
.db "         DECIMAL COUNTER           ",0	; TEXT_BLOCK 3
.db "LEDS DIM",0,0							; TEXT_BLOCK 4

.EXIT
