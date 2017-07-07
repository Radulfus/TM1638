;=======================================================================
; tm1638cc.h
; Header file for tm1638 library
;
; written by Ralf Jardon (cosmicos@gmx.net), May-July 2017
;
; License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
;
; Version: 0.9beta
;=======================================================================

.INCLUDE "m32def-nopragma.inc"

;=======================================================================
;	Assembler definitions
;=======================================================================

#define BITBANGING						; ifdef BITBANGING data is send by
										; bitbanging code. If not defined 
										; data is send by hardware SPI

;=======================================================================
;	Constant definitions
;=======================================================================

.EQU	XTAL			=	16000000	; MCU clock in Hz
.EQU	FCK				=	XTAL/1000	; clock in kHz
.EQU	REG_MAX			=	0x0F		; Highest segment address
;
;	TM1638 Instructions	(Page 3 in datasheet)
;
.EQU	DATA_CMD		=	0x40;
.EQU	DISP_CTRL_CMD	=	0x80;
.EQU	ADDR_CMD		=	0xC0;
.EQU	ADDR			=	0x00;
;
;	TM1638 Data command set
;
.EQU	WRITE_DATA		=	0x00;
.EQU	READ_KEYS		=	0x02;
.EQU	FIXED_ADDR		=	0x04;
;
;	TM1638 Display controll command (Page 4 in datasheet)
;
.EQU	DISP_PWM_MASK	=	0x03		; first 3 bits are brightness (PWM)
.EQU	DISP_ON			=	0x08
.EQU	DISP_OFF		=	0x00
.EQU	ASCII_OFFSET	=	0x20
.EQU	CHAR_OFFSET		=	0x07
.EQU	TEXT_BLOCK		=	36

;=======================================================================
;	TM1638 Port configuration
;=======================================================================

#ifdef BITBANGING						; ports bitbanging

.EQU	PORT_TM1638		=	PORTA
.EQU	PIN_TM1638		=	PINA
.EQU	DDR_TM1638		=	DDRA

.EQU	STB_PIN			=	PA0			; TM1638 strobe input
.EQU	CLK_PIN			=	PA1			; TM1638 clock input
.EQU	DATA_PIN		=	PA2			; TM1638 data input/output

#else									; ports hardware-SPI

.EQU	PORT_TM1638		=	PORTB
.EQU	PIN_TM1638		=	PINB
.EQU	DDR_TM1638		=	DDRB

.EQU	STB_PIN			=	PB4			; SS   (13)
.EQU	CLK_PIN			=	PB7			; SCK  (16)
.EQU	DATA_PIN		=	PB5			; MOSI (14)

#endif

;=======================================================================
;	TM1638 used registers
;=======================================================================

.DEF	ZCODE			=	r0
.DEF	AKKU			=	r16			; akkumulator
.DEF	AKKU2			=	r17
.DEF	AKKU3			=	r18
.DEF	COUNT			=	r19			; counter in loops
.DEF	TM1638_SEGM_BYTE=	r20			; LED Segment	(1-8)
.DEF	TM1638_GRID_BYTE=	r21			; LED Grid		(a-g + dp)
.DEF	TM1638_DATA_BYTE=	r22			; Command, Grid & Segment Data
.DEF	DTMP			=	r23
