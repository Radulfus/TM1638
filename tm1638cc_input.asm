; --------------------------------------------------------------------------
; s'AVR - Precompiler for Structured AVR Assembler by Eberhard Haug (C) 2017
; Version 2.23 (BETA), compiled 08-AUG-2017.
; This is the LITE version supporting short and medium range options.
; The selected default range is Short (.s).

; s'AVR File compiled: 09.08.2017 22:04:09
; Please report any bugs by email to xxx@xxxxxxx.de

; No liability accepted for any code generated by s'AVR!
; --------------------------------------------------------------------------

;=======================================================================
; TM1638cc_timer.asm
; Library to drive the special circuit for LED control TM1638 
; from Titan Micro Electronics (TM)
;
; written by Ralf Jardon (cosmicos at gmx dot net), May-July 2017
;
; Comments related to the datasheet refer to version 1.3 (en)
;
; License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
;
; Version: 0.1
;=======================================================================

TM1638_POLL_KEYPAD:

	push	COUNT
	push	AKKU
	push	AKKU2
	push	AKKU3
	push	ZL
	push	ZH

	TM1638_STB_LOW												; set strobe low to start action

	ldi		TM1638_DATA_BYTE, DATA_CMD + READ_KEYS				; send DATA_READ COMMAND
	rcall	TM1638_SEND

	rcall	Delay1us											; Twait = 2us
	rcall	Delay1us

	ldi		AKKU, (1<<STB_PIN) | (1<<CLK_PIN) | (0<<DATA_PIN)	; configure DATA_PIN as INPUT
	out		DDR_TM1638, AKKU									; to receive DATA from Slave

	TM1638_DATA_HIGH											; activate internal pullup

	clr		AKKU
	clr		AKKU2

	;01// FOR AKKU3 := #4												; 4 Bytes to read
	LDI	AKKU3,4
_A1:
	;02// FOR COUNT := #8											; 8 Bits each Byte
	LDI	COUNT,8
_A4:
	TM1638_CLK_LOW										; send CLK from Master to Slave
	rcall Delay1us										; Twait

	;03// IF %PIN_TM1638, DATA_PIN							; if slave sends high
	SBIS	PIN_TM1638,DATA_PIN
	RJMP	_A7
_A8:
	sbr		AKKU2, 0b10000000						; -> set bit
	;03// ENDI

_A7:
	;03// IF COUNT <> #1
	CPI	COUNT,1
	BREQ	_A11
	lsr		AKKU2									; shift bit
	;03// ENDI

_A11:
	TM1638_CLK_HIGH										; CLOCK pin HIGH
	rcall	Delay1us
	;02// ENDF													; next bit
	DEC	COUNT
	BRNE	_A4
	push AKKU2												; save Byte to stack

	;01// ENDF														; next byte
	DEC	AKKU3
	BRNE	_A1
	TM1638_STB_HIGH												; set strobe high to terminate action

	ldi		AKKU, (1<<STB_PIN) | (1<<CLK_PIN) | (1<<DATA_PIN)	; reconfigure DATA_PIN as OUTPUT
	out		DDR_TM1638, AKKU

	;01// FOR COUNT := #4
	LDI	COUNT,4
_A14:
	pop		AKKU											; restore Byte from stack to register
	;02// IF AKKU <> #0
	TST	AKKU
	BREQ	_A17
	ldi		AKKU3, 1									; Textblock "BUTTON"
	rcall	TM1638_PRINT_TEXT
	rcall	Delay50ms
	;02// ENDI
_A17:
	;01// ENDF
	DEC	COUNT
	BRNE	_A14

	rcall	Delay50ms
	ldi		AKKU3, 2									; Textblock "BUTTON"
	rcall	TM1638_PRINT_TEXT
	pop		ZH
	pop		ZL
	pop		AKKU3
	pop		AKKU2
	pop		AKKU
	pop		COUNT
	ret

; s'AVR lines read: 80
; Lines generated: 122
; Errors detected: 0
; Warnings/Hints noted: 0
