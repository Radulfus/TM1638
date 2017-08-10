;=======================================================================
; tm1638cc_delay.inc
; delay routines for tm1638 library
; 
; written by Ralf Jardon (cosmicos at gmx dot net), May-July 2017
;
; License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
;
; Version: 0.9beta
;=======================================================================

.equ	c1us	= (1*fck)/4000 - 1
.equ	c10ms	= (10*fck)/4 - 1
.equ	c50ms	= (500*fck)/4 - 1

;=======================================================================

Delay1s:
		ldi   	DTMP, 100
dloop:
		rcall	Delay10ms
		dec		DTMP
		brne	dloop
		ret

;=======================================================================

Delay100ms:
		ldi   	DTMP, 10
d100loop:
		rcall	Delay10ms
		dec		DTMP
		brne	d100loop
		ret

;=======================================================================

Delay1us:
		ldi R25,HIGH(c1us)
		ldi R24,LOW(c1us)
		rjmp Delayloop

;=======================================================================

Delay50ms: 
		ldi R25,HIGH(c50ms)
		ldi R24,LOW(c50ms)
		rjmp Delayloop

;=======================================================================

Delay10ms:

		ldi R25,HIGH(c10ms)
		ldi R24,LOW(c10ms)
		rjmp Delayloop

;=======================================================================
;
; delayloop, awaits values in R25:R24
;

Delayloop:
	sbiw R24,1
	brne Delayloop
	ret
