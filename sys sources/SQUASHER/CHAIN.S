*				;;MESSAGE.TXT to SQUASH.DAT compresser
*				;;
*				;; 24/06/86
*				;;
*				;;CMAIN.Z80
*				;;
*				;;-----
*				;;
*;;Maximum number of characters allowed in a single 'word':
MAXWORDLEN 	EQU	$20 	;MAXWORDLEN EQU $20
*				;;
*;;Maximum buffer for serial reading of SMT:
MAXMESSAGELEN 	EQU	$4000 	;MAXMESSAGELEN EQU $400
*;;
;>> ENDMEMORY 	EQU	$6 	;ENDMEMORY EQU $6
*				;;
*				;;-----
*				;;
*;;Message Descriptor Header:
JUMP 	EQU	7 	;JUMP EQU 7 ;Jump header or Message header.
PARSE 	EQU	6 	;PARSE EQU 6 ;Message contains keywords.
*				;;
*				;;Word reference:
LONG 	EQU	7 	;LONG EQU 7 ;Short or Long-form reference.
*				;;
*				;;Special short-codes:
LONGC 	EQU	$1A 	;LONGC EQU $1A ;Long escape code
HEADER 	EQU	$1C 	;HEADER EQU $1C ;Header short-code
ENDSEG 	EQU	$1B 	;ENDSEG EQU $1B ;Segment end marker
*				;;
*				;;Greater than $07, Less than LONGC:
UPPERCASEMARK 	EQU	$10 	;UPPERCASEMARK EQU $10 ;Operand to LONGC
*				;;
MAXHEADERLENGTH 	EQU	3 	;MAXHEADERLENGTH EQU 3 ;Max similarity count in header
*				;;
*				;;-----
*				;;
 even
ORIGIN 	EQU	*-PRG.STRT 	;ORIGIN
	MOVE.W 	#STACK,D6 	; LD SP,STACK
 lea squasherdriverblock,a6
;	MOVE.W 	#SETsquashercomputertype,D7 	; CALL SETsquashercomputertype
;	JSR 	SYS.JSR(A5) 	;
*				;;
	bsr prs
	dc.b pageoff,0
	even

	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"COMPACT " 	; DEFM "COMPACT "
	DC.B 	MAJOR,'.',MINOR 	; DEFB MAJOR,'.',MINOR
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"12th August 1986" 	; DEFM "12th August 1986"
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"Available memory =" 	; DEFM "Available memory ="
	DC.B 	0 	; DEFB 0
 even
*				;;
	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#STARTTABLEMEMORY,D3 	; LD DE,STARTTABLEMEMORY
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#ORIGIN,D1 	; LD HL,ORIGIN
	ROR.W 	#8,D2 	; LD B,0
	MOVE.B 	#0,D2 	;
	ROR.W 	#8,D2 	;
AA01 	EQU	*-PRG.STRT 	;AA01
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#CHKSUM,D3 	; LD DE,CHKSUM
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,AA02
	BNE.S 	LAB.1 	;
	JMP 	AA02(A5) 	;
LAB.1:
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	ADD.B 	0(a4,D1.W),D0 	; ADD A,(HL)
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	AA01(A5) 	; JR AA01
AA02 	EQU	*-PRG.STRT 	;AA02
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	0(a4,D1.W),D0 	; CP (HL)
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD (HL),B
	MOVE.B 	D2,0(a4,D1.W) 	;
	ROR.W 	#8,D2 	;
	MOVE 	F(A5),SR 	; JR Z,AA03
	BNE.S 	LAB.2 	;
	JMP 	AA03(A5) 	;
LAB.2:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"***** Corrupted *****" 	; DEFM "***** Corrupted *****"
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
AA03 	EQU	*-PRG.STRT 	;AA03
; For ST, I don't (at time of writing - 10/12/86)
; know how to grab arguments from the command line
; Therefore, instead, if there is a 'd' waiting in kbd buffer
; at this point, prompt the user for options
 lea osrdchdriverblock,a6
 move.b #osrdchdcode,d0
 jsr drivermation? ",0
 even

 bsr waitkey
 move.b (a6),d0
 jsr converttouppercase
 cmp.b #'Y',d0
 beq.s wantdebug
 move.b #'N',d0
wantdebug
 move.b d0,debug(a5)
 move.b d0,(a6)
 move.b #oswrchdcode,d0
 bsr driver ; echo selection
 bra gotoptions ; not really necessary, all rest of code
; is (hopefully!) commented out.
osrdchdriverblock
 ds.b 60
 even
*				;;
;	MOVE.B 	$82(A5),D0 	; LD A,($82)
;	CMP.B 	#'N',D0 	; CP 'N'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR Z,NOISE1
;	BNE.S 	LAB.3 	;
;	JMmation? ",0
 even

 bsr waitkey
 move.b (a6),d0
 jsr converttouppercase
 cmp.b #'Y',d0
 beq.s wantdebug
 move.b #'N',d0
wantdebug
 move.b d0,debug(a5)
 move.b d0,(a6)
 move.b #oswrchdcode,d0
 bsr driver ; echo selection
 bra gotoptions ; not really necessary, all rest of code
; is (hopefully!) commented out.
osrdchdriverblock
 ds.b 60
 even
*				;;
;	MOVE.B 	$82(A5),D0 	; LD A,($82)
;	CMP.B 	#'N',D0 	; CP 'N'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR Z,NOISE1
;	BNE.S 	LAB.3 	;
;	JMP 	NOISE1(A5) 	;
;LAB.3:
;	CMP.B 	#'Y',D0 	; CP 'Y'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR Z,NOISE1
;	BNE.S 	LAB.4 	;
;	JMP 	NOISE1(A5) 	;
;LAB.4:
;	MOVE.B 	#'N',D0 	; LD A,'N'
;NOISE1 	EQU	*-PRG.STRT 	;NOISE1
;	MOVE.B 	D0,NOISY(A5) 	; LD (NOISY),A
;	CMP.B 	#'Y',D0 	; CP 'Y'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR NZ,DEBUG1
;	BEQ.S 	LAB.5 	;
;	JMP 	DEBUG1(A5) 	;
;LAB.5:
;*				;;
;	MOVE.B 	$83(A5),D0 	; LD A,($83)
;	CMP.B 	#'N',D0 	; CP 'N'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR Z,DEBUG2
;	BNE.S 	LAB.6 	;
;	JMP 	DEBUG2(A5) 	;
;LAB.6:
;	CMP.B 	#'Y',D0 	; CP 'Y'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR Z,DEBUG2
;	BNE.S 	LAB.7 	;
;	JMP 	DEBUG2(A5) 	;
;LAB.7:
;DEBUG1 	EQU	*-PRG.STRT 	;DEBUG1
;	MOVE.B 	#'N',D0 	; LD A,'N'
;DEBUG2 	EQU	*-PRG.STRT 	;DEBUG2
;	MOVE.B 	D0,DEBUG(A5) 	; LD (DEBUG),A
;*				;;
;	MOVE.W 	#$84,D1 	; LD HL,$84
;	MOVE.W 	#HEXCONV,D7 	; CALL HEXCONV
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#$85,D1 	; LD HL,$85
;	MOVE.W 	#HEXCONV,D7 	; CALL HEXCONV
;	JSR 	SYS.JSR(A5) 	;
;*				;;
;	MOVE.B 	$84(A5),D0 	; LD A,($84)
;	CMP.B 	#'A',D0 	; CP 'A'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR C,NOCW
;	BCC.S 	LAB.8 	;
;	JMP 	NOCW(A5) 	;
;LAB.8:
;	CMP.B 	#'P'+1,D0 	; CP 'P'+1
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR NC,NOCW
;	BCS.S 	LAB.9 	;
;	JMP 	NOCW(A5) 	;
;LAB.9:
;	MOVE.B 	$85(A5),D0 	; LD A,($85)
;	CMP.B 	#'A',D0 	; CP 'A'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR C,NOCW
;	BCC.S 	LAB.10 	;
;	JMP 	NOCW(A5) 	;
;LAB.10:
;	CMP.B 	#'P'+1,D0 	; CP 'P'+1
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR NC,NOCW
;	BCS.S 	LAB.11 	;
;	JMP 	NOCW(A5) 	;
;LAB.11:
;*				;;
;	MOVE.B 	$84(A5),D0 	; LD A,($84)
;	SUB.B 	#'A',D0 	; SUB 'A'
;	MOVE 	SR,F(A5) 	;
;	ADD.B 	D0,D0 	; ADD A,A
;	MOVE 	SR,F(A5) 	;
;	ADD.B 	D0,D0 	; ADD A,A
;	MOVE 	SR,F(A5) 	;
;	ADD.B 	D0,D0 	; ADD A,A 
;	MOVE 	SR,F(A5) 	;
;	ADD.B 	D0,D0 	; ADD A,A
;	MOVE 	SR,F(A5) 	;
;	AND.B 	#$F0,D0 	; AND $F0
;	MOVE 	SR,F(A5) 	;
;	ROR.W 	#8,D2 	; LD B,A
;	MOVE.B 	D0,D2 	;
;	ROR.W 	#8,D2 	;
;	MOVE.B 	$85(A5),D0 	; LD A,($85)
;	SUB.B 	#'A',D0 	; SUB 'A'
;	MOVE 	SR,F(A5) 	;
;	AND.B 	#$0F,D0 	; AND $0F
;	MOVE 	SR,F(A5) 	;
;	ROR.W 	#8,D2 	; OR B
;	OR.B 	D2,D0 	;
;	MOVE 	SR,F(A5) 	;
;	ROR.W 	#8,D2 	;
;	JMP 	GOTCW(A5) 	; JR GOTCW
;*				;;
gotoptions
NOCW 	EQU	*-PRG.STRT 	;NOCW
*;;Up to 128 entries allowed in 'Common Word Dictionary':
	MOVE.B 	#128,D0 	; LD A,128
GOTCW 	EQU	*-PRG.STRT 	;GOTCW
	MOVE.B 	D0,COMMONMAXENTRIES(A5) 	; LD (COMMONMAXENTRIES),A
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Options: " 	; DEFM "Options: "
	DC.B 	0 	; DEFB 0
 even
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	COMMONMAXENTRIES(A5),D0 	; LD A,(COMMONMAXENTRIES)
	ROR.W 	#8,D1 	; LD H,0
	MOVE.B 	#0,D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D0,D1 	; LD L,A
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	13,13,0 	; DEFB 13,13,0
 even
*				;;
;
	bsr selectdirectory
;
	MOVE.B NOISY(A5),D0
	MOVE.W 	#PHASE01,D7 	; CALL PHASE01
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#PHASE02,D7 	; CALL PHASE02
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#PHASE03,D7 	; CALL PHASE03
	JSR 	SYS.JSR(A5) 	;
afterphase03 equ *-prg.strt
	MOVE.W 	#PHASE04,D7 	; CALL PHASE04
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#PHASE05,D7 	; CALL PHASE05
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#PHASE06,D7 	; CALL PHASE06
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#PHASE07,D7 	; CALL PHASE07
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#PHASE08,D7 	; CALL PHASE08
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#PHASE09,D7 	; CALL PHASE09
	JSR 	SYS.JSR(A5) 	;
WARMSTART 	EQU	*-PRG.STRXCONV
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#'0',D0 	; CP '0'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,HC02
	BCC.S 	LAB.12 	;
	JMP 	HC02(A5) 	;
LAB.12:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,HC01
	BCS.S 	LAB.13 	;
	JMP 	HC01(A5) 	;
LAB.13:
	SUB.B 	#'0'-'A',D0 	; SUB '0'-'A'
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	JMP 	SYS.RET(A5) 	; RET 
HC01 	EQU	*-PRG.STRT 	;HC01
	CMP.B 	#'A',D0 	; CP 'A'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; XCONV
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#'0',D0 	; CP '0'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,HC02
	BCC.S 	LAB.12 	;
	JMP 	HC02(A5) 	;
LAB.12:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,HC01
	BCS.S 	LAB.13 	;
	JMP 	HC01(A5) 	;
LAB.13:
	SUB.B 	#'0'-'A',D0 	; SUB '0'-'A'
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	JMP 	SYS.RET(A5) 	; RET 
HC01 	EQU	*-PRG.STRT 	;HC01
	CMP.B 	#'A',D0 	; CP 'A'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,HC02
	BCC.S 	LAB.14 	;
	JMP 	HC02(A5) 	;
LAB.14:
	CMP.B 	#'F'+1,D0 	; CP 'F'+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,HC02
	BCS.S 	LAB.15 	;
	JMP 	HC02(A5) 	;
LAB.15:
	SUB.B 	#'A'-'K',D0 	; SUB 'A'-'K'
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	JMP 	SYS.RET(A5) 	; RET 
HC02 	EQU	*-PRG.STRT 	;HC02
	MOVE.B 	#$FF,0(a4,D1.W) 	; LD (HL),$FF
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;Do a 'squasherprs' if DEBUG is 'Y'
*				;;Otherwise the message is skipped
*				;;
TRACE 	EQU	*-PRG.STRT 	;TRACE
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JP Z,squasherprs
	BNE.S 	LAB.16 	;
	JMP 	squasherprs(A5) 	;
LAB.16:
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
TRACE1 	EQU	*-PRG.STRT 	;TRACE1
	MOVE.B 	0(a5,D1.W),D0 	; LD A,(HL) - in program
	ADDQ.W 	#1,D1 	; INC HL
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,TRACE1
	BEQ.S 	LAB.17 	;
	JMP 	TRACE1(A5) 	;
LAB.17:
* check d1.w is even
 btst #0,d1
 beq.s traceeven
 addq.w #1,d1
traceeven
	JMP 	0(a5,D1.W) 	; JP (HL)
*				;;
*				;;-----
*				;;
*				;;Do a 'breakpoint' if (DEBUG)='Y'
*				;;
BREAK 	EQU	*-PRG.STRT 	;BREAK
	LEA 	HLSAVE(A5),A0 	; LD (HLSAVE),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	DESAVE(A5),A0 	; LD (DESAVE),DE
	MOVE.B 	D3,(A0) 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	D3,1(A0) 	;
	ROR.W 	#8,D3 	;
	LEA 	BCSAVE(A5),A0 	; LD (BCSAVE),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	LEA 	AFSAVE(A5),A0 	; LD (AFSAVE),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,BR01
	BEQ.S 	LAB.18 	;
	JMP 	BR01(A5) 	;
LAB.18:
	MOVE.W 	0(a4,D6.W),D1 	; POP HL ;Address after CALL BREAK instruction
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"PC=" 	; DEFM "PC="
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#DISPLAYHLHEX,D7 	; CALL DISPLAYHLHEX
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#DISPLAYSAVES,D7 	; CALL DISPLAYSAVES
	JSR 	SYS.JSR(A5) 	;
BR01 	EQU	*-PRG.STRT 	;BR01
	LEA 	AFSAVE(A5),A0 	; LD HL,(AFSAVE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	LEA 	BCSAVE(A5),A0 	; LD BC,(BCSAVE)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	LEA 	DESAVE(A5),A0 	; LD DE,(DESAVE)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	LEA 	HLSAVE(A5),A0 	; LD HL,(HLSAVE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;Display AFSAVE, HLSAVE, DESAVE and BCSAVE
*				;;
DISPLAYSAVES 	EQU	*-PRG.STRT 	;DISPLAYSAVES
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"AF=" 	; DEFM "AF="
	DC.B 	0 	; DEFB 0
 even
	LEA 	AFSAVE(A5),A0 	; LD HL,(AFSAVE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYHLHEX,D7 	; CALL DISPLAYHLHEX
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" HL=" 	; DEFM " HL="
	DC.B 	0 	; DEFB 0
 even
	LEA 	HLSAVE(A5),A0 	; LD HL,(HLSAVE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYHLHEX,D7 	; CALL DISPLAYHLHEX
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" DE=" 	; DEFM " DE="
	DC.B 	0 	; DEFB 0
 even
	LEA 	DESAVE(A5),A0 	; LD HL,(DESAVE)
	MOVEa 16-bit hex number
*				;;and as a positive decimal number.
*				;;
DISPLAYHLBOTH 	EQU	*-PRG.STRT 	;DISPLAYHLBOTH
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" &" 	; DEFM " &"
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#DISPLAYHLHEX,D7 	; CALL DISPLAYHLHEX
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squashera 16-bit hex number
*				;;and as a positive decimal number.
*				;;
DISPLAYHLBOTH 	EQU	*-PRG.STRT 	;DISPLAYHLBOTH
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" &" 	; DEFM " &"
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#DISPLAYHLHEX,D7 	; CALL DISPLAYHLHEX
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" = " 	; DEFM " = "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	DISPLAYDECIMAL(A5) 	; JP DISPLAYDECIMAL
*				;;
*				;;----
*				;;
*				;;Display a newline sequence
*				;;
NEWLINE 	EQU	*-PRG.STRT 	;NEWLINE
	MOVE.B 	#ASCIICR,D0 	; LD A,ASCIICR
	JMP 	squasheroswrch(A5) 	; JP squasheroswrch
*				;;
*				;;-----
*				;;
*				;;Calculate HL-DE and display in the form:
*				;;   &hhhh = ddd bytes.
*				;;
DISPLAYBYTESFREE 	EQU	*-PRG.STRT 	;DISPLAYBYTESFREE
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#DISPLAYHLBOTH,D7 	; CALL DISPLAYHLBOTH
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" bytes." 	; DEFM " bytes."
	DC.B 	0 	; DEFB 0
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;Copy block length BC start HL to DE
ICOPY 	EQU	*-PRG.STRT 	;ICOPY
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.19 	;
	JMP 	SYS.RET(A5) 	;
LAB.19:
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,IC01
	BCS.S 	LAB.20 	;
	JMP 	IC01(A5) 	;
LAB.20:
	SUBQ.W 	#1,D2 	; DEC BC
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	ADDQ.W 	#1,D2 	; INC BC
	JSR 	SYS.LDDR(A5) 	; LDDR 
	JMP 	SYS.RET(A5) 	; RET 
IC01 	EQU	*-PRG.STRT 	;IC01
	JSR 	SYS.LDIR(A5) 	; LDIR 
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
INPUTTERMINATE 	EQU	*-PRG.STRT 	;INPUTTERMINATE
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;Display a character
DISPLAYCODE 	EQU	*-PRG.STRT 	;DISPLAYCODE
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,OW01
	BEQ.S 	LAB.21 	;
	JMP 	OW01(A5) 	;
LAB.21:
	MOVE.W 	#DISPLAYCONTROL,D7 	; CALL DISPLAYCONTROL
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#ASCIILF,D0 	; LD A,ASCIILF
	JMP 	OW03(A5) 	; JR OW03
OW01 	EQU	*-PRG.STRT 	;OW01
	CMP.B 	#$80,D0 	; CP $80
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,OW02
	BCC.S 	LAB.22 	;
	JMP 	OW02(A5) 	;
LAB.22:
	SUB.B 	#$80,D0 	; SUB $80
	MOVE 	SR,F(A5) 	;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	#"*",D0 	; LD A,"*"
	MOVE.W 	#DISPLAYCONTROL,D7 	; CALL DISPLAYCONTROL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
OW02 	EQU	*-PRG.STRT 	;OW02
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,OW03
	BCS.S 	LAB.23 	;
	JMP 	OW03(A5) 	;
LAB.23:
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	#'^',D0 	; LD A,'^'
	MOVE.W 	#DISPLAYCONTROL,D7 	; CALL DISPLAYCONTROL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	ADD.B 	#'A'-1,D0 	; ADD A,'A'-1
	MOVE 	SR,F(A5) 	;
OW03 	EQU	*-PRG.STRT 	;OW03
	MOVE.W 	#DISPLAYCONTROL,D7 	; CALL DISPLAYCONTROL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
S 	EQU	*-PRG.STRT 	;S