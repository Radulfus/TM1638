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
; Version: 1.0beta-1
;=======================================================================

TM1638_POLL_KEYPAD:

	push	COUNT
	push	AKKU
	push	AKKU2
	push	AKKU3

	TM1638_STB_LOW												; set strobe low to start action

	ldi		TM1638_DATA_BYTE, DATA_CMD + READ_KEYS				; send DATA_READ COMMAND
	rcall	TM1638_SEND

	rcall	Delay1us											; Twait = 2us
	rcall	Delay1us

	ldi		AKKU, (1<<STB_PIN) | (1<<CLK_PIN) | (0<<DATA_PIN)	; configure DATA_PIN as INPUT
	out		DDR_TM1638, AKKU									; to receive DATA from Slave

	TM1638_DATA_HIGH											; activate internal pullup
 
	clr		AKKU

	FOR AKKU3 := #4												; 4 Bytes to read
		clr		AKKU2
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
		
		andi	AKKU2,0b00010001								; keep buttons 1 through 8 only
																; works with 8-Button "LED&KEY" Board

		mov		COUNT,AKKU3										; from outer FOR counter
		dec		COUNT											; shift by 3, 2, 1, 0
		WHILE COUNT > #0										; dynamically shift button bits
			lsl		AKKU2
			dec		COUNT
		ENDW
		or		BUTTONS,AKKU2									; mark buttons 1 through 8 only
	ENDF														; next byte
	swap	BUTTONS 											; finally all 8 Buttons (if pressed)
																; are marked in following order: 12345678

	TM1638_STB_HIGH												; set strobe high to terminate action

	ldi		AKKU, (1<<STB_PIN) | (1<<CLK_PIN) | (1<<DATA_PIN)	; reconfigure DATA_PIN as OUTPUT
	out		DDR_TM1638, AKKU
	
	pop		AKKU3
	pop		AKKU2
	pop		AKKU
	pop		COUNT
	ret
