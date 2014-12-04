*-----------------------------------------------------------
* Title      : Morse Sender
* Written by : Olle Kvarnström / Hampus Andersson
* Date       : 2014-11-28
* Description: This program takes a string and outputs it to a speaker,
*            : which is located at the first bit at PIA B
*-----------------------------------------------------------
MAIN:	LEA $7000,A7		; Init stack @ $7000
	BSR PIAINIT
	CLR.B $10082		; No output
	LEA STR,A0		; Point to string
NEXTCH:	MOVE.B (A0)+,D0		; Load character of string
	CMP.B #0,D0		; String is null-terminated, so this is the end
	BEQ END
	BSR LOOKUP
	CMP.B #0,D0		; If LOOKUP returns 0 it wasnt in the table
	BEQ NEXTCH
	CMP.B #$FF,D0		; If LOOKUP returns $FF it's a space
	BEQ BLANK
	BSR SEND		; Send characters to speaker and repeat
	BRA NEXTCH
BLANK:	MOVE.L N,D1		; A space is 7N of silence
	MULU #7,D1
	CLR.B D2
	BSR BEEP
	BRA NEXTCH
END:	MOVE.B #228,D7		; Return to TUTOR
	TRAP #14

PIAINIT:
	CLR.B $10084		; Clear bit 2, to set $10080 to point at DDR A
	MOVE.B #$00,$10080	; Set DDR A to 00000000 (all ports are input)
	MOVE.B #$04,$10084	; Set bit 2, to set $10080 to point at PORT A
	CLR.B $10086		; Clear bit 2, to set $10082 to point at DDR B
	MOVE.B #$FF,$10082	; Set DDR B to 11111111 (all ports are output)
	MOVE.B #$04,$10086	; Set bit 2, to set $10082 to point at PORT B
	RTS

LOOKUP:
	LEA TABLE,A1
	AND.W #$00FF,D0
	MOVE.B	(A1,D0.W),D0	; Load D0 with TABLE[D0]
	RTS

DELAY:
	MOVE.L T,D3
WAIT:	SUBQ.L #1,D3
	BNE WAIT
	RTS

BEEP:
	CMP.B #1,D2		; D2 == 1 ? Beep : Stay silent
	SCC $10082
	BSR DELAY
	CLR.B $10082		; Change to silent
	BSR DELAY
	SUBQ.L #1,D1
	BNE BEEP
	RTS

T:	DC.L $000000AA
N:	DC.L $00000010

SEND:
	MOVE.L N,D1
	LSL.B #1,D0
	BEQ READY
	BCC DOT
DASH:	MULU #3,D1
DOT:	MOVE.B #1,D2
	BSR BEEP
	MOVE.L N,D1
	MOVE.B #0,D2
	BSR BEEP
	BRA SEND
READY:	ASL.L #1,D1
	MOVE.B #0,D2
	BSR BEEP
	RTS

TABLE:	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B $FF		; One of these
	DC.B $FF		; is space (forgot which)
	DC.B 00
	DC.B $4A		; "
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B 00
	DC.B $7A		; '
	DC.B $B4		; (
	DC.B $B6		; )
	DC.B 00
	DC.B 00
	DC.B $CE		; ,
	DC.B $86		; -
	DC.B $56		; .
	DC.B $94		; /
	DC.B $FC		; 0
	DC.B $7C		; 1
	DC.B $3C		; 2
	DC.B $1C		; 3
	DC.B $0C		; 4
	DC.B $04		; 5
	DC.B $84		; 6
	DC.B $C4		; 7
	DC.B $E4		; 8
	DC.B $F4		; 9
	DC.B $E2		; :
	DC.B $AA		; ;
	DC.B 00
	DC.B $8C		; =
	DC.B 00
	DC.B $32		; ?
	DC.B $60		; A
	DC.B $88		; B
	DC.B $A8		; C
	DC.B $90		; D
	DC.B $40		; E
	DC.B $28		; F
	DC.B $D0		; G
	DC.B $08		; H
	DC.B $20		; I
	DC.B $78		; J
	DC.B $B0		; K
	DC.B $48		; L
	DC.B $E0		; M
	DC.B $A0		; N
	DC.B $F0		; O
	DC.B $68		; P
	DC.B $D8		; Q
	DC.B $50		; R
	DC.B $10		; S
	DC.B $C0		; T
	DC.B $30		; U
	DC.B $18		; V
	DC.B $70		; W
	DC.B $98		; X
	DC.B $B8		; Y
	DC.B $C8		; Z
	DC.B $6C		; Å
	DC.B $58		; Ä
	DC.B $E8		; Ö

STR:	DC.B 'SOS SOS SOS',00

