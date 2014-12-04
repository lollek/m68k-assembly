*-----------------------------------------------------------
* Title      : Digital Clock
* Written by : Olle Kvarnström / Hampus Andersson
* Date       : 2014-12-04
* Description: This program takes a 1Hz signal from PCA1 and a 1kHz signal from
*            : PCB1, and sends the time to a LED-display module connected to PIA
*            : A0-6, and muxing on PIA B0-1
*-----------------------------------------------------------

MAIN:	LEA $7000,A7		; Init stack @ $7000
	CLR.L D0		; Clear all registers
	CLR.L D1
	CLR.L D2
	CLR.L D3
	CLR.L D4
	CLR.L D5
	CLR.L D6
	CLR.L D7
	BSR PIAINIT
	MOVE.L #MUX,$68		; Interrupts on PCA1 will run MUX subroutine
	MOVE.L #BCD,$74		; Interrupts on PCB1 will run BCD subroutine
	AND.W #$F8FF,SR		; Allow all interrupts
LOOP:	BRA LOOP		; Inifinite loop. only handle interrupts
END:	MOVE.B #228,D7		; Return to TUTOR (will never happen)
	TRAP #14

PIAINIT:
	CLR.B $10084		; Set $10080 to point to DDR A
	MOVE.B #$FF,$10080	; Set all PIA A ports to output
	MOVE.B #$05,$10084	; Point $10080 to PORT A and allow interrupts
	CLR.B $10080		; Make sure no output is sent yet
	CLR.B $10086		; Set $10082 to point to DDR B
	MOVE.B #$FF,$10082	; Set all PIA B ports to output
	MOVE.B #$05,$10086	; Point $10082 to PORT B and allow interrupts
	CLR.B $10082		; Make sure no output is sent yet
	RTS

MUX:	CLR.B $10080		; Clear current output
	ADD.B #1,$10082		; Point to next digit on the LED-screen
	CMP.B #1,$10082
	BEQ MUX1
	CMP.B #2,$10082
	BEQ MUX2
	CMP.B #3,$10082
	BEQ MUX3
	CLR.B $10082
MUX0:	MOVE.B D0,$10080
	RTE
MUX1:	MOVE.B D1,$10080
	RTE
MUX2:	MOVE.B D2,$10080
	RTE
MUX3:	MOVE.B D3,$10080
	RTE

BCD:	TST.B $10080		; Clear interrupt
ADD1S:	ADD.B #1,D4		; Handle the right hand second
	CMP #10,D4
	BGE ADD2S
	BRA LOOKUP
ADD2S:	ADD.B #1,D5		; Handle the left hand second
	CLR.B D4
	CMP #6,D5
	BGE ADD1M
	BRA LOOKUP
ADD1M:	ADD.B #1,D6		; Handle the right hand minute
	CLR.B D5
	CMP #10,D6
	BGE ADD2M
	BRA LOOKUP
ADD2M:	ADD.B #1,D7		; Handle the left hand minute
	CLR.B D6
	CMP #6,D7
	BGE CLR2M
	BRA LOOKUP
CLR2M:	CLR.B D7		; Reset to 00:00

LOOKUP:	LEA TABLE,A1		; Convert BCD-digits to LED-digits
	MOVE.B (A1,D4.W),D0
	MOVE.B (A1,D5.W),D1
	MOVE.B (A1,D6.W),D2
	MOVE.B (A1,D7.W),D3
	RTE

TABLE:	DC.B $3F		; 0
	DC.B $06		; 1
	DC.B $5B		; 2
	DC.B $4F		; 3
	DC.B $66		; 4
	DC.B $6D		; 5
	DC.B $7D		; 6
	DC.B $27		; 7
	DC.B $FF		; 8
	DC.B $6F		; 9

