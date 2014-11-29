*-----------------------------------------------------------
* Title      : IR Lab
* Written by : Olle Kvarnström / Hampus Andersson
* Date       : 2014-11-20
* Description: This program reads data from an IR-reader connected to the first
*            : bit at PIA A. The IR-reader will receive a high bit as a signal,
*            : and then 4 bits (with least significant bit first), which it
*            : needs to reverse and forward to the 9368 connected to the first
*            : byte at PIA B. There will also be a signal on the last bit of PIA B
*            : which the IR-sender can use to syncronize
*-----------------------------------------------------------
START:
	LEA $7000,A7		; Init stack @ $7000
	BSR PIAINIT
	
CHECK:	MOVE.B $10080,D1	; Wait for bit 0 at PIA A to be set
	AND.B #1,D1
	CMP.B #1,D1
	BNE CHECK
	
	BSR DELAYHALF		; Quick wait to center on the signal
	BSR DELAY		; Wait for the bit 0
	MOVE.B $10080,D2	; Bit 0
	BSR DELAY
	MOVE.B $10080,D3	; Bit 1
	BSR DELAY
	MOVE.B $10080,D4	; Bit 2
	BSR DELAY
	MOVE.B $10080,D5	; Bit 3
	BSR DELAY		; Make sure we're past the last bit

	AND.B #1,D2		; Filter bit 0

	AND.B #1,D3		; Filter bit 1 (times 2)
	ASL.B #1,D3
	ADD.B D3,D2

	AND.B #1,D4		; Filter bit 2 (times 4)
	ASL.B #2,D4
	ADD.B D4,D2

	AND.B #1,D5		; Filter bit 3 (times 8)
	ASL.B #3,D5
	ADD.B D5,D2

	MOVE.B D2,$10082	; Send the byte to PIA B
	BRA CHECK
	
	MOVE.B #228,D7		; Return to TUTOR (will never happen)
	TRAP #14

PIAINIT:
	CLR.B $10084		; Clear bit 2, to set $10080 to point at DDR A
	MOVE.B #$00,$10080	; Set DDR A to 00000000 (all ports are input)
	MOVE.B #$04,$10084	; Set bit 2, to set $10080 to point at PORT A
	
	CLR.B $10086		; Clear bit 2, to set $10082 to point at DDR B
	MOVE.B #$FF,$10082	; Set DDR B to 11111111 (all ports are output)
	MOVE.B #$04,$10086	; Set bit 2, to set $10082 to point at PORT B
	RTS

DELAY:
	MOVE.L #428,D1
	BRA DEL2
DELAYHALF:
	MOVE.L #214,D1
DEL2:	BSET #7,$10082		; Sent signal to $10082 (PIA B, last bit)
	SUB.L #1,D1
	BNE.S DEL2		; While --D1 > 0
	BCLR #7,$10082		; Turn off signal to $10082 (PIA B, last bit)
	RTS
