;=======================================================================
; tm1638cc_interrupt_vectors.inc
; 
; Reset and Interrupt Vectors (two address locations each!):
; ATmega328P can use absolute JMP instructions instead of RJMP!!!
; Otherwise a NOP is required after RJMP (or after RETI).
;
; written by Eberhard Haug, Aug. 2017
; customized by Ralf Jardon, Aug. 2017 (cosmicos at gmx dot net)
;
; Comments related to the datasheet refer to version 1.3 (en)
;
; License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
;
; Version: 0.1
;=======================================================================

		rjmp INIT			;  1 RESET		External Pin, Power-on Reset, Brown-out Reset and Watchdog System Reset
		nop

		reti				;  2 INT0addr	INT0 External Interrupt Request 0
		nop

		reti				;  3 INT1addr	INT1 External Interrupt Request 1
		nop

		reti				;  4 PCI0addr	PCINT0 Pin Change Interrupt Request 0, PORTB, Rotary Encoder outer shaft (higher priority)
		nop

		reti				;  5 PCI1addr	PCINT1 Pin Change Interrupt Request 1, PORTC, Rotary encoder inner shaft
		nop

		reti				;  6 PCI2addr	PCINT2 Pin Change Interrupt Request 2, PORTD (not used)
		nop

		reti				;  7 WDTaddr	WDT	Watchdog Time-out Interrupt
		nop

		reti				;  8 OC2Aaddr	TIMER2 COMPA Timer/Counter2 Compare Match A
		nop

		reti				;  9 OC2Baddr	TIMER2 COMPB Timer/Counter2 Compare Match B
		nop

		reti				; 10 OVF2addr	TIMER2 OVF Timer/Counter2 Overflow
		nop

		reti				; 11 ICP1addr	TIMER1 CAPT Timer/Counter1 Capture Event
		nop

		reti				; 12 OC1Aaddr	TIMER1 COMPA Timer/Counter1 Compare Match A
		nop

		reti				; 13 OC1Baddr	TIMER1 COMPB Timer/Coutner1 Compare Match B
		nop

		reti				; 14 OVF1addr	TIMER1 OVF Timer/Counter1 Overflow
		nop

		reti				; 15 OC0Aaddr	TIMER0 COMPA Timer/Counter0 Compare Match A
		nop

		reti				; 16 OC0Baddr	TIMER0 COMPB Timer/Counter0 Compare Match B
		nop

		reti				; 17 OVF0addr	TIMER0 OVF Timer/Counter0 Overflow
		nop

		reti				; 18 SPIaddr	SPI, STC SPI Serial Transfer Complete
		nop

		reti				; 19 URXCaddr	USART, RX USART Rx Complete
		nop

		reti				; 20 UDREaddr	USART, UDRE USART, Data Register Empty
		nop

		reti				; 21 UTXCaddr	USART, TX USART, Tx Complete
		nop

		reti				; 22 ADCCaddr	ADC	ADC Conversion Complete
		nop

		reti				; 23 ERDYaddr	EE READY EEPROM Ready
		nop

		reti				; 24 ACIaddr	ANALOG COMP Analog Comparator
		nop

		reti				; 25 TWIaddr	TWI (I2C) 2-wire Serial Interface
		nop

		reti				; 26 SPMRaddr	SPM READY Store Program Memory Ready
		nop
