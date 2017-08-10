;=======================================================================
; TM1638cc_input.asm
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

	FOR AKKU3 := #4												; 4 Bytes to read
		FOR COUNT := #8											; 8 Bits each Byte
			TM1638_CLK_LOW										; send CLK from Master to Slave
			rcall Delay1us										; Twait

			IF %PIN_TM1638, DATA_PIN							; if slave sends high
				sbr		AKKU2, 0b10000000						; -> set bit
			ENDI
			IF COUNT <> #1
				lsr		AKKU2									; shift bit
			ENDI
			TM1638_CLK_HIGH										; CLOCK pin HIGH
			rcall	Delay1us
		ENDF													; next bit
		push AKKU2												; save Byte to stack
		
	ENDF														; next byte
	TM1638_STB_HIGH												; set strobe high to terminate action

	ldi		AKKU, (1<<STB_PIN) | (1<<CLK_PIN) | (1<<DATA_PIN)	; reconfigure DATA_PIN as OUTPUT
	out		DDR_TM1638, AKKU

	FOR COUNT := #4
		pop		AKKU											; restore Byte from stack to register
		IF AKKU <> #0
			ldi		AKKU3, 1									; Textblock "BUTTON"
			rcall	TM1638_PRINT_TEXT
			rcall	Delay50ms
		ENDI
	ENDF

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
