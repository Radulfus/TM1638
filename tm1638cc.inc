;=======================================================================
; TM1638cc.inc
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

;=======================================================================
; TM1638_INIT:
;=======================================================================

TM1638_INIT:

; initialize Ports

	ldi 	AKKU, (1<<STB_PIN) | (1<<CLK_PIN) | (1<<DATA_PIN)
	out		DDR_TM1638, AKKU

	ldi		AKKU, (1<<STB_PIN) | (1<<CLK_PIN)
	out		PORT_TM1638, AKKU
	rcall	delay1us

#if !defined(BITBANGING)				; initialize SPI-engine

	ldi		AKKU, (0<<SPIE)|(1<<SPE)|(1<<MSTR)|(1<<DORD)|(1<<CPOL)|(1<<CPHA)|(1<<SPR1)|(1<<SPR0)
	out		SPCR, AKKU
	ldi		AKKU, (1<<SPI2X)
	out		SPSR, AKKU

#endif

; initialize TM1638

	ldi		TM1638_DATA_BYTE, DATA_CMD + WRITE_DATA
	rcall	TM1638_SEND_COMMAND

	ldi		TM1638_DATA_BYTE, DISP_CTRL_CMD + DISP_ON + DISP_PWM_MASK
	rcall	TM1638_SEND_COMMAND

	rcall 	TM1638_CLEAR				; clear Display Memory

	ret

;=======================================================================
; TM1638_SEND: generates CLOCK signal and send DATA (bit-banging).
;=======================================================================

#ifdef BITBANGING					; BITBANGING

TM1638_SEND:
	push	COUNT
	push	AKKU
	push	AKKU2
	ldi		COUNT, 8				; loop bit 0-7
loop:
	ror		TM1638_DATA_BYTE		; put lowest bit into carry flag
	brcs	high_bit				; if carry set  -> DATA pin HIGH
	rcall	delay1us
	TM1638_CLK_LOW_DATA_LOW			; carry is not set -> DATA pin LOW
	rjmp	next_cycle				; go to the next clk cycle
high_bit:
	rcall	delay1us
	TM1638_CLK_LOW_DATA_HIGH
next_cycle:
	rcall	delay1us
	TM1638_CLK_HIGH					; CLOCK pin HIGH
	dec		COUNT					; next bit
	brne	loop
	pop		AKKU2
	pop		AKKU
	pop		COUNT
	ret

#else								; HARDWARE-SPI

TM1638_SEND:						; start SPI transfer
	out		SPDR, TM1638_DATA_BYTE	; write Data into SPI-engine
busy:
	sbis	SPSR, SPIF				; Wait for transmission complete
	rjmp	busy
	ret

#endif

;=======================================================================
; TM1638_SEND_COMMAND: Sends Command to TM1638
;=======================================================================

TM1638_SEND_COMMAND:
	TM1638_STB_LOW					; set STROBE-output LOW. Ready to 
									; send commands or data
	rcall	TM1638_SEND				; send 1 Byte command
	TM1638_STB_HIGH					; set STROBE-output HIGH. Command 
									; received
	rcall	delay1us
	ret

;=======================================================================
; TM1638_SEND_DATA: Sends DATA to TM1638
; (page 10 at datasheet)
;=======================================================================

TM1638_SEND_DATA:
	ldi		TM1638_DATA_BYTE, DATA_CMD + FIXED_ADDR
	rcall	TM1638_SEND_COMMAND			; send Command 1
	rcall	delay1us
	TM1638_STB_LOW
	ori		TM1638_GRID_BYTE, ADDR_CMD	; build segment address
	mov		TM1638_DATA_BYTE, TM1638_GRID_BYTE
	rcall	TM1638_SEND					; send Command 2 + address
	mov		TM1638_DATA_BYTE, TM1638_SEGM_BYTE
	rcall	TM1638_SEND					; send data
	TM1638_STB_HIGH
	ret

;=======================================================================
; TM1638_CLEAR: clears the Display memory  and the Grid-memory to prevent
; garbage after startup 
;=======================================================================

TM1638_CLEAR:
	push	COUNT
	clr		COUNT
clear_loop:
	mov		TM1638_GRID_BYTE, COUNT			; Grid
	ldi		TM1638_SEGM_BYTE, 0x00			; Segment
	rcall	TM1638_SEND_DATA
	subi	COUNT, -2						; next address
	cpi		COUNT, REG_MAX+1				; REG_MAX = 0x0F
	brne	clear_loop
	pop		COUNT
	ret

;=======================================================================
; TM1638_PRINT_DEC 16 bit
; AKKU2 (low Byte) / AKKU3 (high Byte)
;=======================================================================

TM1638_PRINT_DEC:
	push	AKKU
	push	AKKU2
	push	AKKU3

; ** 10000 **
	ldi		AKKU, '0'
DEC_SEGM5:

	inc		AKKU
	subi	AKKU2, low(10000)
	sbci	AKKU3, high(10000)
	brcc	DEC_SEGM5
	subi	AKKU2, low(-10000)
	sbci	AKKU3, high(-10000)
	dec		AKKU
	clt								; clr t-flag: decimal place was 1-9
	cpi		AKKU, '0'
	breq	DEC_SEGM4
	mov		TM1638_SEGM_BYTE, AKKU
	ldi		TM1638_GRID_BYTE, 0x06           
	rcall	TM1638_PRINT_CHAR
	set								; set t-flag: decimal place was 0

; ** 1000 **
	ldi		AKKU, '0'
DEC_SEGM4:
	inc		AKKU
	subi	AKKU2, low(1000)
	sbci	AKKU3, high(1000)
	brcc	DEC_SEGM4
	subi	AKKU2, low(-1000)
	sbci	AKKU3, high(-1000)
	dec		AKKU
	brts	segm4					; skip zero test because previous 
									; decimal place was 1-9
	cpi		AKKU, '0'
	breq	DEC_SEGM3
segm4:
	mov		TM1638_SEGM_BYTE, AKKU
	ldi		TM1638_GRID_BYTE, 0x08
	rcall	TM1638_PRINT_CHAR
	set

; ** 100 **
	ldi		AKKU, '0'
DEC_SEGM3:
	inc		AKKU
	subi	AKKU2, low(100)
	sbci	AKKU3, high(100)
	brcc	DEC_SEGM3
	subi	AKKU2, -100
	dec		AKKU
	brts	segm3					; skip zero test because previous 
									; decimal place was 1-9
	cpi		AKKU, '0'
	breq	DEC_SEGM2
segm3:
	mov		TM1638_SEGM_BYTE, AKKU
	ldi		TM1638_GRID_BYTE, 0x0A
	rcall	TM1638_PRINT_CHAR
	set

; ** 10 **
	ldi		AKKU, '0'
DEC_SEGM2:
	inc		AKKU
	subi	AKKU2, 10
	brcc	DEC_SEGM2
	subi	AKKU2, -10
	dec		AKKU
	brts	segm2					; skip zero test because previous 
									; decimal place was 1-9
	cpi		AKKU, '0'
	breq	DEC_SEGM1
segm2:
	mov		TM1638_SEGM_BYTE, AKKU
	ldi		TM1638_GRID_BYTE, 0x0C
	rcall	TM1638_PRINT_CHAR
	set

; ** 1 **
DEC_SEGM1:
	ldi		AKKU, '0'
	add		AKKU, AKKU2
	mov		TM1638_SEGM_BYTE, AKKU
	ldi		TM1638_GRID_BYTE, 0x0E
	rcall	TM1638_PRINT_CHAR
	set

	pop		AKKU3
	pop		AKKU2
	pop		AKKU
	ret

;=======================================================================
; TM1638_PRINT_HEX 8 bit from AKKU
;=======================================================================

TM1638_PRINT_HEX:
	swap	AKKU
	ldi		TM1638_GRID_BYTE, 0x0C
	rcall	hex_digit
	swap	AKKU
	ldi		TM1638_GRID_BYTE, 0x0E

hex_digit:
	push	AKKU
	andi	AKKU, $0F
	cpi		AKKU, 10
	brlt	hex_digit_1
	subi	AKKU, -( 'A' - '9' - 1 ) 

hex_digit_1:
	subi	AKKU, -'0'
	mov		TM1638_SEGM_BYTE, AKKU
	rcall	TM1638_PRINT_CHAR
	pop		AKKU
	ret

;=======================================================================
; TM1638_PRINT_BIN 8 bit from AKKU
;=======================================================================

TM1638_PRINT_BIN:
	push	AKKU
	push	AKKU2
	push	AKKU3
	push	TM1638_GRID_BYTE

	mov		AKKU2, AKKU;
	ldi		TM1638_GRID_BYTE, 0x00		; Segment start-address    

	ldi		AKKU3, 8;
bin_number_loop:
	dec		AKKU3;
	rol		AKKU2;
	brcc	bin_number_bit_not_set; 
	brcs	bin_number_bit_set;
	rjmp	bin_number_loop;

bin_number_bit_not_set:	 
	ldi		AKKU, '0'
	rjmp	bin_out

bin_number_bit_set:
	ldi		AKKU, '1'
bin_out:
	mov		TM1638_SEGM_BYTE, AKKU	
	rcall	TM1638_PRINT_CHAR
	subi 	TM1638_GRID_BYTE, -2		; next segment address
	tst		AKKU3;
	breq	bin_number_ende;
	rjmp	bin_number_loop;

bin_number_ende:
	pop		TM1638_GRID_BYTE
	pop		AKKU3
	pop		AKKU2
	pop		AKKU
	ret

;=======================================================================
; M1638_PRINT_CHAR: prints only one character from font table. 
; Char is given by TM1638_SEGM_BYTE, Position is given by TM1638_GRID_BYTE
;=======================================================================

TM1638_PRINT_CHAR:
	push	ZH
	push	ZL
	push	ZCODE
	push	AKKU
	push	TM1638_SEGM_BYTE
	
	ldi		ZL, LOW(2*FONTS)			; start address fonts
	ldi		ZH, HIGH(2*FONTS)			; 

	subi	TM1638_SEGM_BYTE, ASCII_OFFSET; - 0x30	
	cpi		TM1638_SEGM_BYTE, 0x1A		; check, if number or character
	brlo	number						; if char, sub 7
	subi	TM1638_SEGM_BYTE, CHAR_OFFSET

number:
	add		ZL, TM1638_SEGM_BYTE		; select char address
	lpm									; load r0=ZCODE with char
	sub		ZL, TM1638_SEGM_BYTE		; reset char address

	mov		TM1638_SEGM_BYTE, ZCODE
	rcall	TM1638_SEND_DATA			; send data

	pop		TM1638_SEGM_BYTE
	pop		AKKU
	pop		ZCODE
	pop		ZL
	pop		ZH
	ret

;=======================================================================
; TM1638_PRINT_TEXT
; AKKU3 = Textblock Number
;=======================================================================

TM1638_PRINT_TEXT:
	push	AKKU3
	push	AKKU

	ldi		ZL, LOW(PRINTTEXT*2)	; load text start address
	ldi		ZH, HIGH(PRINTTEXT*2)

	ldi		TM1638_GRID_BYTE, 0x00	; first segment

select_textblock_print:
	cpi		AKKU3, 0
	breq	print_text_loop
	adiw	ZL, 10,					; each TEXT_BLOCK has 10 chars
									; calculate address of current block
	dec		AKKU3
	rjmp	select_textblock_print

print_text_loop:
	lpm		AKKU, Z+				; load first char of current block +
									; post-increment pointer
	cpi		AKKU, 0					; test if zero (block end)
	breq	text_end

	mov		TM1638_SEGM_BYTE, AKKU
	rcall	TM1638_PRINT_CHAR		; print char
	subi 	TM1638_GRID_BYTE, -2	; go to next segment address

	rjmp	print_text_loop

text_end:
	pop		AKKU
	pop		AKKU3
	ret

;=======================================================================
; TM1638_PRINT_MOVETEXT
; AKKU3 = Textblock Number
;=======================================================================

TM1638_PRINT_MOVETEXT:
	push	COUNT
	push	AKKU3
	push	AKKU2
	push	AKKU

	ldi		ZL, LOW(MOVETEXT*2)		; load text start address
	ldi		ZH, HIGH(MOVETEXT*2)

select_textblock_move:
	cpi		AKKU3, 0
	breq	start_movement
	adiw	ZL, TEXT_BLOCK			; each TEXT_BLOCK has 36 chars
									; calculate address of current block
	dec		AKKU3
	rjmp	select_textblock_move

start_movement:
	clr		TM1638_GRID_BYTE    
	clr		COUNT
	clr		AKKU2

move_display_loop:
	inc		COUNT					; display loop
	lpm		AKKU, Z+				; load first char of current block +
									; post-increment pointer
	mov		TM1638_SEGM_BYTE, AKKU
	rcall	TM1638_PRINT_CHAR		; print current char
	subi	TM1638_GRID_BYTE, -2	; go to next segment address
	cpi		COUNT, 8				; test, if display full
	brne	move_display_loop		; if not, print next char

	rcall	Delay100ms				; text loop
	rcall	Delay100ms
	rcall	TM1638_POLL_KEYPAD
	clr		COUNT
	sbiw	ZL, 7					; sub 7 (8-1) to shift display 
	inc		AKKU2
	cpi		AKKU2, TEXT_BLOCK-8
	breq	move_text_end
	rjmp	move_display_loop

move_text_end:

	pop		AKKU
	pop		AKKU2
	pop		AKKU3
	pop		COUNT
	ret

;=======================================================================
; TM1638_BRIGHTNESS
; AKKU = Value between 0-7
;=======================================================================

TM1638_BRIGHTNESS:

	ldi		TM1638_DATA_BYTE, DISP_CTRL_CMD + DISP_ON
	add		TM1638_DATA_BYTE, AKKU
	rcall	TM1638_SEND_COMMAND
	ret
