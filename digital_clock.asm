*-----------------------------------------------------------
* Title      : Digital Clock
* Written by : Olle Kvarnström / Hampus Andersson
* Date       : 2014-12-04
* Description: This program takes a 1Hz signal from PCA1 and a 1kHz signal from
*            : PCB1, and sends the time to a LED-display module connected to PIA
*            : A0-6, and muxing on PIA B0-1
*-----------------------------------------------------------
MAIN:	LEA $7000,A7
	MOVE.L #$FFAA8801,D2
	CLR.L D0
	CLR.L D1
	CLR.L D2
	CLR.L D3
	CLR.L D4
	CLR.L D5
	CLR.L D6
	CLR.L D7
	BSR PIAINIT
	MOVE.L #MUX,$68
	MOVE.L #BCD,$74
	AND.W #$F8FF,SR


	
LOOP:	BRA LOOP
	
END:	MOVE.B #228,D7
	TRAP #14
	
PIAINIT:
	CLR.B $10084
	MOVE.B #$FF,$10080
	MOVE.B #$05,$10084
	CLR.B $10080
	CLR.B $10086
	MOVE.B #$FF,$10082
	MOVE.B #$05,$10086
	CLR.B $10082
	RTS


MUX:	CLR.B $10080
	ADD.B #$1,$10082
	CMP.B #$1,$10082
	BNE NEXT1
	MOVE.B D1,$10080
	RTE
	
NEXT1:	CMP.B #$2,$10082
	BNE NEXT2
	MOVE.B D2,$10080
	RTE

NEXT2:	CMP.B #$3,$10082
	BNE NEXT3
	MOVE.B D3,$10080
	RTE
	
NEXT3:	CLR.B $10082
	MOVE.B D0,$10080
	RTE


BCD:	TST.B $10080
ADD1S:	ADD.B #1,D4
	CMP #10,D4
	BGE ADD2S
	BRA LOOKUP
ADD2S:	ADD.B #1,D5
	CLR.B D4
	CMP #6,D5
	BGE ADD1M
	BRA LOOKUP
ADD1M:	ADD.B #1,D6
	CLR.B D5
	CMP #10,D6
	BGE ADD2M
	BRA LOOKUP
ADD2M:	ADD.B #1,D7
	CLR.B D6
	CMP #6,D7
	BGE CLR2M
	BRA LOOKUP
CLR2M:	CLR.B D7
LOOKUP:	LEA TABLE,A1
	AND.W #$00FF,D4
	MOVE.B (A1,D4.W),D0
	AND.W #$00FF,D5
	MOVE.B (A1,D5.W),D1
	AND.W #$00FF,D6
	MOVE.B (A1,D6.W),D2
	AND.W #$00FF,D7
	MOVE.B (A1,D7.W),D3
	RTE

TABLE:	DC.B $3F
	DC.B $6
	DC.B $5B
	DC.B $4F
	DC.B $66
	DC.B $6D
	DC.B $7D
	DC.B $27
	DC.B $FF
	DC.B $6F
	
