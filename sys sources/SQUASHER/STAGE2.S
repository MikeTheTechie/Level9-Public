*;;MESSAGE.TXT to SQUASH.DAT compresser
*;;
*;;28/09/86
*;;
*;;STAGE2.Z80
*;;
*;;-----
*;;
LENGTHPOINTERS 	EQU	$14 	;LENGTHPOINTERS EQU $14
*;;
spaceforsquashdat equ 70000 ; must be at least big enough
; to hold largest text file
*;;-----
*;;
*;;Phase 6 - Construct 'Message Descriptors'
*;;
*;;Phase 6 Scans the 'Sorted Message Table' in conjunction
*;;with the 'Frequency Table' (for word numbers)
*;;'Common Word Dictionary' (for short-form references)
*;;and builds the 'Message Descriptor;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 6 - Construct 'Message Descriptors'" 	;
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*;;
*;;MAXMDT will be highest byte used (below buffer)
*;;
	LEA 	ENDCWT(A5),A0 	; LD HL,(ENDCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	MAXMDT(A5),A0 	; LD (MAXMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
*				;;Set up message number expected
*	;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 6 - Construct 'Message Descriptors'" 	;
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*;;
*;;MAXMDT will be highest byte used (below buffer)
*;;
	LEA 	ENDCWT(A5),A0 	; LD HL,(ENDCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	MAXMDT(A5),A0 	; LD (MAXMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
*				;;Set up message number expected
*				;;
	MOVE.W 	#$0,D1 	; LD HL,$0 
	LEA 	MSGNUM(A5),A0 	; LD (MSGNUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	NUMSHORTREFS(A5),A0 	; LD (NUMSHORTREFS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	NUMLONGREFS(A5),A0 	; LD (NUMLONGREFS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	NUMMSGHEADS(A5),A0 	; LD (NUMMSGHEADS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	NUMJUMPHEADS(A5),A0 	; LD (NUMJUMPHEADS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*;;
*;;Open B:SQUASH1.TMP for reading
*;;
	MOVE.W 	#INITSERIALSMT,D7 	; CALL INITSERIALSMT
	JSR 	SYS.JSR(A5) 	;
*;;
*;;Open B:SQUASH2.TMP for writing
*;;
;	MOVE.W 	#INITSERIALICF,D7 	; CALL INITSERIALICF
;	JSR 	SYS.JSR(A5) 	;
 move.l startfilebuffer(a5),a2
 add.l #spaceforsquashdat,a2
; allow space to build first bit of squash.dat file

PF01 	EQU	*-PRG.STRT 	;PF01
	MOVE.W 	#ENDSERIALSMT,D7 	; CALL ENDSERIALSMT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PF02 ;End of SMT
	BNE.S 	LAB.501 	;
	JMP 	PF02(A5) 	;
LAB.501:
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*				;;
	MOVE.W 	#CONVERTMESSAGE,D7 	; CALL CONVERTMESSAGE
	JSR 	SYS.JSR(A5) 	;
*;;
*;;Find next 'Sorted Message Table' entry.
*;;
	MOVE.W 	#NEXTSERIALSMT,D7 	; CALL NEXTSERIALSMT
	JSR 	SYS.JSR(A5) 	;
*				;;
*				;;Increment expected message number
*				;;
	LEA 	MSGNUM(A5),A0 	; LD BC,(MSGNUM)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	ADDQ.W 	#1,D2 	; INC BC
	LEA 	MSGNUM(A5),A0 	; LD (MSGNUM),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	JMP 	PF01(A5) 	; JR PF01
*;;
*;;Display Message Descriptors
*;;
PF02 	EQU	*-PRG.STRT 	;PF02
	MOVE.W 	#DELETESYSTEM,D7 	; CALL DELETESYSTEM ;Delete B:SQUASH1.TMP
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NZ,PF03
	BEQ.S 	LAB.502 	;
	JMP 	PF03(A5) 	;
LAB.502:
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Number of short-references = ",0
 even
	LEA 	NUMSHORTREFS(A5),A0 	; LD HL,(NUMSHORTREFS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"Number of long-references = ",0
 even
	LEA 	NUMLONGREFS(A5),A0 	; LD HL,(NUMLONGREFS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"Number of Message Headers = ",0
 even
	LEA 	NUMMSGHEADS(A5),A0 	; LD HL,(NUMMSGHEADS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	asciicr,"Number of Jump Headers = ",0
 even
	LEA 	NUMJUMPHEADS(A5),A0 	; LD HL,(NUMJUMPHEADS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*				;;
PF03 	EQU	*-PRG.STRT 	;PF03
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF) ;*
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	LENGTHMD(A5),A0 	; LD (LENGTHMD),HL ;*
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#LENGTHPOINTERS,D2 	; LD BC,LENGTHPOINTERS ;*
	ADD.W 	D2,D1 	; ADD HL,BC ;*
	MOVE 	SR,F(A5) 	;
	LEA 	INDEXMD(A5),A0 	; LD (INDEXMD),HL ;*
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#E.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR
	DC.B 	"Length compressed Message Desriptors =",0
 even
	LEA 	LENGTHMD(A5),A0 	; LD HL,(LENGTHMD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	E.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR
	DC.B 	"Length compressed Message Desriptors =",0
 even
	LEA 	LENGTHMD(A5),A0 	; LD HL,(LENGTHMD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIICR 	; DEFB ASCIICR,ASCIICR
	DC.B 	"Low memory used =" 	; DEFM "Low memory used ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	MAXMDT(A5),A0 	; LD HL,(MAXMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#STARTTABLEMEMORY,D3 	; LD DE,STARTTABLEMEMORY
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"High memory used =",0
 even
	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTBUFFER(A5),A0 	; LD DE,(STARTBUFFER)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Free =",0
 even
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	MAXMDT(A5),A0 	; LD DE,(MAXMDT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	JMP 	NEWLINE(A5) 	; JP NEWLINE
*				;;
P6BADWORDTYPE 	EQU	*-PRG.STRT 	;P6BADWORDTYPE
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal use of special character '^'",0
 even
	JMP 	P6ERROR(A5) 	; JP P6ERROR ;Calls DISPLAYLINENUM and WARMSTART
*				;;
P6BADSLASH 	EQU	*-PRG.STRT 	;P6BADSLASH
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal use of special character '/'",0
 even
	JMP 	P6ERROR(A5) 	; JP P6ERROR ;Calls DISPLAYLINENUM and WARMSTART
*				;;
MODEERROR 	EQU	*-PRG.STRT 	;MODEERROR
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"SQUASH error: Invalid P6MODE value: ",0
 even
	MOVE.B 	P6MODE(A5),D0 	; LD A,(P6MODE)
	MOVE.W 	#DISPLAYAHEX,D7 	; CALL DISPLAYAHEX
	JSR 	SYS.JSR(A5) 	;
	JMP 	P6ERROR(A5) 	; JP P6ERROR ;Calls DISPLAYLINENUM and WARMSTART
*				;;
P6ERROR 	EQU	*-PRG.STRT 	;P6ERROR
;	MOVE.W 	#ABORTSERIALSMT,D7 	; CALL ABORTSERIALSMT
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#ABORTSERIALICF,D7 	; CALL ABORTSERIALICF
;	JSR 	SYS.JSR(A5) 	;
	JMP 	DISPLAYLINENUM(A5) 	; JP DISPLAYLINENUM ;ends in WARMSTART
*;;
*;;-----
*;;
*;;Build a message descriptor from one 'Sorted Message 
*;;Table' entry. HL is address of SMT entry. 
*;;
CONVERTMESSAGE 	EQU	*-PRG.STRT 	;CONVERTMESSAGE
*;;Reset for new message:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	ENDCWT(A5),A0 	; LD HL,(ENDCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	CURRENTMDT(A5),A0 	; LD (CURRENTMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL ;Get source line number (for errors)
	MOVE.W 	D1,0(a4,D6.W) 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D3 	; LD E,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D3 	; LD D,(HL)
	MOVE.B 	0(a4,D1.W),D3 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
*;;
*;;Check this is the next message number in sequence
*;;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	LEA 	MSGNUM(A5),A0 	; LD BC,(MSGNUM)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM02
	BNE.S 	LAB.504 	;
	JMP 	HM02(A5) 	;
LAB.504:
*;;
*;;Calculate distance of 'jump'
*;;
	SUBQ.W 	#1,D1 	; DEC HL ;Jump range is 1-$80.
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#$80,D2 	; LD BC,$80
;	EOR.	(A0),D2 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	MSGNUM(A5),A0 	; LD (MSGNUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.B 	D1,D0 	; LD A,L
	BSET 	#JUMP,d0 	; SET JUMP,A ;Make a jump header
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	LEA 	NUMJUMPHEADS(A5),A0 	; LD HL,(NUMJUMPHEADS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MO	(A0),D2 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	MSGNUM(A5),A0 	; LD (MSGNUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.B 	D1,D0 	; LD A,L
	BSET 	#JUMP,d0 	; SET JUMP,A ;Make a jump header
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	LEA 	NUMJUMPHEADS(A5),A0 	; LD HL,(NUMJUMPHEADS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMJUMPHEADS(A5),A0 	; LD (NUMJUMPHEADS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	CONVERTMESSAGE(A5) 	; JR CONVERTMESSAGE
*				;;
*				;;Not a jump, Create zero-length 'Message Header'
*				;;
HM02 	EQU	*-PRG.STRT 	;HM02
	EOR.B 	D0,D0 	; XOR A ;Invalid 'mode'
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,WORDTYPE(A5) 	; LD (WORDTYPE),A ;Clear type of next word
	MOVE.B 	#MODEINIT,D0 	; LD A,MODEINIT
	MOVE.B 	D0,P6MODE(A5) 	; LD (P6MODE),A
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	NUMKEYWORDS(A5),A0 	; LD (NUMKEYWORDS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	#$00,0(a4,D1.W) 	; LD (HL),$00 ;Zero-length header
	LEA 	STARTMSG(A5),A0 	; LD (STARTMSG),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	CURRENTMDT(A5),A0 	; LD (CURRENTMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#CHECKBELOWBUFFER,D7 	; CALL CHECKBELOWBUFFER
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,MDTFULL
	BCS.S 	LAB.506 	;
	JMP 	MDTFULL(A5) 	;
LAB.506:
	LEA 	NUMMSGHEADS(A5),A0 	; LD HL,(NUMMSGHEADS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMMSGHEADS(A5),A0 	; LD (NUMMSGHEADS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC 
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
	LEA 	MESSAGELENGTH(A5),A0 	; LD (MESSAGELENGTH),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#2,D6 	; PUSH BC ;Message number
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM03
	BEQ.S 	LAB.507 	;
	JMP 	HM03(A5) 	;
LAB.507:
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Message number = " 	; DEFM "Message number = "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
HM03 	EQU	*-PRG.STRT 	;HM03
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
*				;;Examine for words
*				;;
HM04 	EQU	*-PRG.STRT 	;HM04
	LEA 	MESSAGELENGTH(A5),A0 	; LD BC,(MESSAGELENGTH)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,HM33
	BNE.S 	LAB.508 	;
	JMP 	HM33(A5) 	;
LAB.508:
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,WORDTYPE(A5) 	; LD (WORDTYPE),A
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#DEBUGDISPLAYCODE,D7 	; CALL DEBUGDISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#' ',D0 	; CP ' ' ;Space, cPRG.STRT 	;HM05
	CMP.B 	#MODELEAD,D0 	; CP MODELEAD
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM10
	BNE.S 	LAB.511 	;
	JMP 	HM10(A5) 	;
LAB.511:
	CMP.B 	#MODENULL,D0 	; CP MODENULL
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM06
	BEQ.S 	LAB.512 	;
	JMP 	HM06(A5) 	;
LAB.512:
	MOVE.B 	#MODESPACE,D0 	; LD A,MODESPACE
	JMP 	HM09(A5) 	; JR HM09
HM06 	EQU	*-PRG.STRT 	;HM06
	CMP.B 	#MODESPACE,D0 	; CP MODESPACE
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM10
	BNE.S 	LAB.513 	;
	JMP 	HM10(A5) PRG.STRT 	;HM05
	CMP.B 	#MODELEAD,D0 	; CP MODELEAD
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM10
	BNE.S 	LAB.511 	;
	JMP 	HM10(A5) 	;
LAB.511:
	CMP.B 	#MODENULL,D0 	; CP MODENULL
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM06
	BEQ.S 	LAB.512 	;
	JMP 	HM06(A5) 	;
LAB.512:
	MOVE.B 	#MODESPACE,D0 	; LD A,MODESPACE
	JMP 	HM09(A5) 	; JR HM09
HM06 	EQU	*-PRG.STRT 	;HM06
	CMP.B 	#MODESPACE,D0 	; CP MODESPACE
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM10
	BNE.S 	LAB.513 	;
	JMP 	HM10(A5) 	;
LAB.513:
	CMP.B 	#MODECHAR,D0 	; CP MODECHAR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM07
	BEQ.S 	LAB.514 	;
	JMP 	HM07(A5) 	;
LAB.514:
	MOVE.B 	#MODECS,D0 	; LD A,MODECS
	JMP 	HM09(A5) 	; JR HM09
HM07 	EQU	*-PRG.STRT 	;HM07
	CMP.B 	#MODESC,D0 	; CP MODESC
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM08
	BEQ.S 	LAB.515 	;
	JMP 	HM08(A5) 	;
LAB.515:
*				;;Output character
	MOVE.B 	P6CHAR(A5),D0 	; LD A,(P6CHAR)
	MOVE.B 	D0,D3 	; LD E,A
	ROR.W 	#8,D3 	; LD D,$30 ;Leading+trailing spaces
	MOVE.B 	#$30,D3 	;
	ROR.W 	#8,D3 	;
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#STORECHARACTER,D7 	; CALL STORECHARACTER
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#MODENULL,D0 	; LD A,MODENULL
	JMP 	HM09(A5) 	; JR HM09
HM08 	EQU	*-PRG.STRT 	;HM08
	CMP.B 	#MODECS,D0 	; CP MODECS
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NZ,MODEERROR
	BEQ.S 	LAB.516 	;
	JMP 	MODEERROR(A5) 	;
LAB.516:
	JMP 	HM10(A5) 	; JR HM10
HM09 	EQU	*-PRG.STRT 	;HM09
	MOVE.B 	D0,P6MODE(A5) 	; LD (P6MODE),A
HM10 	EQU	*-PRG.STRT 	;HM10
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
*				;;Move on to next character
*				;;
HM11 	EQU	*-PRG.STRT 	;HM11
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	LEA 	MESSAGELENGTH(A5),A0 	; LD (MESSAGELENGTH),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	JMP 	HM04(A5) 	; JR HM04
*				;;
*				;;Check for 'special' characters
*				;;
HM12 	EQU	*-PRG.STRT 	;HM12
	LEA 	WORDADDRESS(A5),A0 	; LD (WORDADDRESS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	CMP.B 	#'%',D0 	; CP '%' ;Forces a cr.
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,HM21
	BNE.S 	LAB.517 	;
	JMP 	HM21(A5) 	;
LAB.517:
	CMP.B 	#'_',D0 	; CP '_' ;Forces a space
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,HM21
	BNE.S 	LAB.518 	;
	JMP 	HM21(A5) 	;
LAB.518:
	CMP.B 	#'|',D0 	; CP '|' ;Terminates printing part of message
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,HM21
	BNE.S 	LAB.519 	;
	JMP 	HM21(A5) 	;
LAB.519:
	CMP.B 	#'^',D0 	; CP '^' ;Word-type
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM13
	BEQ.S 	LAB.520 	;
	JMP 	HM13(A5) 	;
LAB.520:
*				;;
*				;;Process word-type declaration
*				;;
	MOVE.W 	#WT01,D7 	; CALL WT01
	JSR 	SYS.JSR(A5) 	;
HM13 	EQU	*-PRG.STRT 	;HM13
	MOVE.W 	#FF01,D7 	; CALL FF01
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP C,HM20 ;Not a word
	BCC.S 	LAB.521 	;
	JMP 	HM20(A5) 	;
LAB.521:
*				;;
*				;;Frequency table address of word found, check if it's
*				;;a 'Common Word', convert and store its word number.
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL ;Frequency Table entry address
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.B 	P6MODE(A5),D0 	; LD A,(P6MODE)
	CMP.B 	#MODENULL,D0 	; CP MODENULL
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM19 ;Store word
	BNE.S 	LAB.522 	;
	JMP 	HM19(A5) 	;
LAB.522:
	CMP.B 	#MODEINIT,D0 	; CP MODEINIT
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM19 ;Store word
	BNE.S 	LAB.523 	;
	JMP 	HM19(A5) 	;
LAB.523:
	CMP.B 	#MODELEAD,D0 	; CP MODELEAD
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM15
	BNE.S 	LAB.524 	;
	JMP 	HM15(A5) 	;
LAB.524:
	CMP.B 	#MODESPACE,D0 	; CP MODESPACE
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM19 ;Store word
	BNE.S 	LAB.525 	;
	JMP 	HM19(A5) 	;
LAB.525:
	CMP.B 	#MODESC,D0 	; CP MODESC
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM16
	BNE.S 	LAB.526 	;
	JMP 	HM16(A5) 	;
LAB.526:
	CMP.B 	#MODECS,D0 	; CP MODECS
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM17
	BNE.S 	LAB.527 	;
	JMP 	HM17(A5) 	;
LAB.527:
	CMP.B 	#MODECHAR,D0 	; CP MODECHAR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NZ,MODEERROR
	BEQ.S 	LAB.528 	;
	JMP 	MODEERROR(A5) 	;
LAB.528:
	ROR.W 	#8,D3 	; LD D,$0
	MOVE.B 	#$0,D3 	;
	ROR.W 	#8,D3 	;
	JMP 	HM18(A5) 	; JR HM18
*				;;Only places where space is before a word are at start
*				;;of sentance or where space is forced as a character ('_' or '/ ')
HM15 	EQU	*-PRG.STRT 	;HM15
	MOVE.W 	#$0F80+' ',D1;
*				;;
*				;;Output stored character with word-type D
*				;;(D=0 character only, D=$10 traling space, D=$20 leading space)
HM18 	EQU	*-PRG.STRT 	;HM18
*				;;> CALL OLDFIX ;> For Adrian Mole/Archers
*				;;
	MOVE.B 	P6CHAR(A5),D0 	; LD A,(P6CHAR)
	MOVE.B 	D0,D3 	; LD E,A
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#STORECHARACTER,D7 	; CALL STORECHARACTER
	JSR 	SYS.JSR(A5) 	;
*				;;
*				;;Output word and reset to 'idle' state
HM19 	EQU	*-PR;
*				;;
*				;;Output stored character with word-type D
*				;;(D=0 character only, D=$10 traling space, D=$20 leading space)
HM18 	EQU	*-PRG.STRT 	;HM18
*				;;> CALL OLDFIX ;> For Adrian Mole/Archers
*				;;
	MOVE.B 	P6CHAR(A5),D0 	; LD A,(P6CHAR)
	MOVE.B 	D0,D3 	; LD E,A
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#STORECHARACTER,D7 	; CALL STORECHARACTER
	JSR 	SYS.JSR(A5) 	;
*				;;
*				;;Output word and reset to 'idle' state
HM19 	EQU	*-PRG.STRT 	;HM19
	MOVE.B 	#MODENULL,D0 	; LD A,MODENULL
	MOVE.B 	D0,P6MODE(A5) 	; LD (P6MODE),A
	MOVE.W 	0(a4,D6.W),D1 	; POP HL ;Adress of a FT entry
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.W 	#SW01,D7 	; CALL SW01
	JSR 	SYS.JSR(A5) 	;
	JMP 	HM04(A5) 	; JP HM04
*				;;
*				;;Not in Frequency Table (i.e. Not a 'word')
*				;;
HM20 	EQU	*-PRG.STRT 	;HM20
*				;;
*				;;Check for special character codes
	LEA 	WORDADDRESS(A5),A0 	; LD HL,(WORDADDRESS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BTST 	#7,d0 	; BIT 7,A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM21
	BNE.S 	LAB.529 	;
	JMP 	HM21(A5) 	;
LAB.529:
	BCLR 	#7,d0 	; RES 7,A
	JMP 	HM24(A5) 	; JR HM24
*				;;
HM21 	EQU	*-PRG.STRT 	;HM21
	CMP.B 	#'%',D0 	; CP '%' ;Forces a CR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM22
	BEQ.S 	LAB.530 	;
	JMP 	HM22(A5) 	;
LAB.530:
	MOVE.B 	#ASCIICR,D0 	; LD A,ASCIICR
HM22 	EQU	*-PRG.STRT 	;HM22
	CMP.B 	#'_',D0 	; CP '_' ;Forces a SPACE
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM23
	BEQ.S 	LAB.531 	;
	JMP 	HM23(A5) 	;
LAB.531:
	MOVE.B 	#' ',D0 	; LD A,' '
HM23 	EQU	*-PRG.STRT 	;HM23
	CMP.B 	#'|',D0 	; CP '|' ;End of printable message
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,HM24
	BEQ.S 	LAB.532 	;
	JMP 	HM24(A5) 	;
LAB.532:
	MOVE.W 	#MODEEOF,D7 	; CALL MODEEOF
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#KY00,D7 	; CALL KY00
	JSR 	SYS.JSR(A5) 	;
	JMP 	HM33(A5) 	; JP HM33
*				;;
HM24 	EQU	*-PRG.STRT 	;HM24
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	P6MODE(A5),D0 	; LD A,(P6MODE)
	CMP.B 	#MODEINIT,D0 	; CP MODEINIT
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM25
	BNE.S 	LAB.533 	;
	JMP 	HM25(A5) 	;
LAB.533:
	CMP.B 	#MODELEAD,D0 	; CP MODELEAD
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM26
	BNE.S 	LAB.534 	;
	JMP 	HM26(A5) 	;
LAB.534:
	CMP.B 	#MODESPACE,D0 	; CP MODESPACE
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM26
	BNE.S 	LAB.535 	;
	JMP 	HM26(A5) 	;
LAB.535:
	CMP.B 	#MODECHAR,D0 	; CP MODECHAR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM28
	BNE.S 	LAB.536 	;
	JMP 	HM28(A5) 	;
LAB.536:
	CMP.B 	#MODESC,D0 	; CP MODESC
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM29
	BNE.S 	LAB.537 	;
	JMP 	HM29(A5) 	;
LAB.537:
	CMP.B 	#MODECS,D0 	; CP MODECS
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM30
	BNE.S 	LAB.538 	;
	JMP 	HM30(A5) 	;
LAB.538:
	CMP.B 	#MODENULL,D0 	; CP MODENULL
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NZ,MODEERROR
	BEQ.S 	LAB.539 	;
	JMP 	MODEERROR(A5) 	;
LAB.539:
*				;;Character in initial and 'idle' states just stores
HM25 	EQU	*-PRG.STRT 	;HM25
	MOVE.B 	#MODECHAR,D0 	; LD A,MODECHAR
	JMP 	HM27(A5) 	; JR HM27
*				;;Following a space
HM26 	EQU	*-PRG.STRT 	;HM26
	MOVE.B 	#MODESC,D0 	; LD A,MODESC
HM27 	EQU	*-PRG.STRT 	;HM27
	MOVE.B 	D0,P6MODE(A5) 	; LD (P6MODE),A
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,P6CHAR(A5) 	; LD (P6CHAR),A
	JMP 	HM32(A5) 	; JR HM32
*				;;Two characters together
HM28 	EQU	*-PRG.STRT 	;HM28
	ROR.W 	#8,D3 	; LD D,$0
	MOVE.B 	#$0,D3 	;
	ROR.W 	#8,D3 	;
	JMP 	HM31(A5) 	; JR HM31
*				;;Space character character
HM29 	EQU	*-PRG.STRT 	;HM29
	ROR.W 	#8,D3 	; LD D,$20 ;Leading space
	MOVE.B 	#$20,D3 	;
	ROR.W 	#8,D3 	;
	JMP 	HM31(A5) 	; JR HM31
*				;;Character space character
HM30 	EQU	*-PRG.STRT 	;HM30
	ROR.W 	#8,D3 	; LD D,$10 ;Trailing space
	MOVE.B 	#$10,D3 	;
	ROR.W 	#8,D3 	;
HM31 	EQU	*-PRG.STRT 	;HM31
*				;;Save stored character, D=word-type
*				;;> CALL OLDFIX ;>
	MOVE.B 	P6CHAR(A5),D0 	; LD A,(P6CHAR)
	MOVE.B 	D0,D3 	; LD E,A
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#STORECHARACTER,D7 	; CALL STORECHARACTER
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.B 	#MODECHAR,D0 	; LD A,MODECHAR
	MOVE.B 	D0,P6MODE(A5) 	; LD (P6MODE),A
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,P6CHAR(A5) 	; LD (P6CHAR),A
*				;;
HM32 	EQU	*-PRG.STRT 	;HM32
	LEA 	WORDADDRESS(A5),A0 	; LD HL,(WORDADDRESS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1:
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL) ;Examine message header
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NZ,HM39
	BEQ.S 	LAB.541 	;
	JMP 	HM39(A5) 	;
LAB.541:
*				;;
*				;;If message contains any non-garbage words then
*				;;set 'parse' bit in first header byte.
*				;;
	LEA 	NUMKEYWORDS(A5),A0 	; LD HL,(NUMKEYWORDS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),:
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL) ;Examine message header
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NZ,HM39
	BEQ.S 	LAB.541 	;
	JMP 	HM39(A5) 	;
LAB.541:
*				;;
*				;;If message contains any non-garbage words then
*				;;set 'parse' bit in first header byte.
*				;;
	LEA 	NUMKEYWORDS(A5),A0 	; LD HL,(NUMKEYWORDS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	OR.B 	D1,D0 	; OR L
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,HM34
	BNE.S 	LAB.542 	;
	JMP 	HM34(A5) 	;
LAB.542:
*				;;
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BSET 	#PARSE,d0 	; SET PARSE,A
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
*				;;
*				;;Calculate length of finished message
*				;;
HM34 	EQU	*-PRG.STRT 	;HM34
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTMSG(A5),A0 	; LD DE,(STARTMSG)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	LEA 	FREQUENCYTIMES(A5),A0 	; LD (FREQUENCYTIMES),HL ;Length
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
HM35 	EQU	*-PRG.STRT 	;HM35
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#$003F+1,D2 	; LD BC,$003F+1
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR C,HM36
	BCC.S 	LAB.543 	;
	JMP 	HM36(A5) 	;
LAB.543:
*;;
*;;Length is greater than allowed for a single
*;;header byte, add additional header.
*;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL) ;Duplicate 'PARSE' flag
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	STARTMSG(A5),A0 	; LD (STARTMSG),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	SUBQ.W 	#1,D1 	; DEC HL
	LEA 	CURRENTMDT(A5),A0 	; LD DE,(CURRENTMDT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	LEA 	FREQUENCYTIMES(A5),A0 	; LD BC,(FREQUENCYTIMES) ;Length
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	JSR 	SYS.LDDR(A5) 	; LDDR 
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	CURRENTMDT(A5),A0 	; LD (CURRENTMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#CHECKBELOWBUFFER,D7 	; CALL CHECKBELOWBUFFER
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,MDTFULL
	BCS.S 	LAB.544 	;
	JMP 	MDTFULL(A5) 	;
LAB.544:
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.W 	#$003F,D2 	; LD BC,$003F
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	JMP 	HM35(A5) 	; JR HM35
*				;;
*				;;Replace length byte
*				;;
HM36 	EQU	*-PRG.STRT 	;HM36
	MOVE.B 	D1,D0 	; LD A,L
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	OR.B 	0(a4,D1.W),D0 	; OR (HL)
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
*				;;
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	MAXMDT(A5),A0 	; LD DE,(MAXMDT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,HM37
	BCC.S 	LAB.545 	;
	JMP 	HM37(A5) 	;
LAB.545:
*				;;
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	MAXMDT(A5),A0 	; LD (MAXMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*;;
*;;Write message to B:SQUASH2.TMP
*;;
HM37 	EQU	*-PRG.STRT 	;HM37
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
HM38 	EQU	*-PRG.STRT 	;HM38
	LEA 	CURRENTMDT(A5)LL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	HM38(A5) 	; JR HM38
*				;;
HM39 	EQU	*-PRG.STRT 	;HM39
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal message header" 	; DEFM "Illegal message header"
	DC.B 	0 	; DEFB 0
 even
	JMP 	P6ERROR(A5) 	; JP P6ERROR ;Calls DISPLAYLINENUM and WARMSTART
*				;;
*				;;-----
*				;;
OLDFIX 	EQU	*-PRG.STRT 	;OLDFIX ;>
	ROR.W 	#8,D3 	; LD A,D ;>
	LL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	HM38(A5) 	; JR HM38
*				;;
HM39 	EQU	*-PRG.STRT 	;HM39
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal message header" 	; DEFM "Illegal message header"
	DC.B 	0 	; DEFB 0
 even
	JMP 	P6ERROR(A5) 	; JP P6ERROR ;Calls DISPLAYLINENUM and WARMSTART
*				;;
*				;;-----
*				;;
OLDFIX 	EQU	*-PRG.STRT 	;OLDFIX ;>
	ROR.W 	#8,D3 	; LD A,D ;>
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	CMP.B 	#$20,D0 	; CP $20 ;>
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,OF01
	BEQ.S 	LAB.547 	;
	JMP 	OF01(A5) 	;
LAB.547:
	SUBQ.W 	#2,D6 	; PUSH DE ;>
	MOVE.W 	D3,0(a4,D6.W) 	;
	MOVE.W 	#$0F80+" ",D1 	; LD HL,$0F80+" " ;>
	MOVE.W 	#STORECHARACTER,D7 	; CALL STORECHARACTER ;>
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE ;>
	ADDQ.W 	#2,D6 	;
OF01 	EQU	*-PRG.STRT 	;OF01 ;>
*				;;
	SUBQ.W 	#2,D6 	; PUSH DE ;>
	MOVE.W 	D3,0(a4,D6.W) 	;
	MOVE.B 	P6CHAR(A5),D0 	; LD A,(P6CHAR)
	MOVE.B 	D0,D3 	; LD E,A
	ROR.W 	#8,D3 	; LD D,0 ;>
	MOVE.B 	#0,D3 	;
	ROR.W 	#8,D3 	;
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#STORECHARACTER,D7 	; CALL STORECHARACTER
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE ;>
	ADDQ.W 	#2,D6 	;
*				;;
	ROR.W 	#8,D3 	; LD A,D ;>
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	CMP.B 	#$10,D0 	; CP $10 ;>
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ ;>
	BEQ.S 	LAB.548 	;
	JMP 	SYS.RET(A5) 	;
LAB.548:
	MOVE.W 	#$0F80+" ",D1 	; LD HL,$0F80+" " ;>
	JMP 	STORECHARACTER(A5) 	; JP STORECHARACTER ;>
*				;;
*				;;-----
*				;;
MODEEOF 	EQU	*-PRG.STRT 	;MODEEOF
	MOVE.W 	#ME01,D7 	; CALL ME01
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#MODENULL,D0 	; LD A,MODENULL
	MOVE.B 	D0,P6MODE(A5) 	; LD (P6MODE),A
	JMP 	SYS.RET(A5) 	; RET 
*				;;
ME01 	EQU	*-PRG.STRT 	;ME01
	MOVE.B 	P6MODE(A5),D0 	; LD A,(P6MODE)
	CMP.B 	#MODENULL,D0 	; CP MODENULL
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.549 	;
	JMP 	SYS.RET(A5) 	;
LAB.549:
	CMP.B 	#MODEINIT,D0 	; CP MODEINIT
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.550 	;
	JMP 	SYS.RET(A5) 	;
LAB.550:
	CMP.B 	#MODESPACE,D0 	; CP MODESPACE
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,ME01A
	BNE.S 	LAB.551 	;
	JMP 	ME01A(A5) 	;
LAB.551:
	CMP.B 	#MODELEAD,D0 	; CP MODELEAD
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,ME02
	BEQ.S 	LAB.552 	;
	JMP 	ME02(A5) 	;
LAB.552:
ME01A 	EQU	*-PRG.STRT 	;ME01A
	MOVE.W 	#$0F80+' ',D1 	; LD HL,$0F80+' '
	JMP 	STORECHARACTER(A5) 	; JP STORECHARACTER
ME02 	EQU	*-PRG.STRT 	;ME02
	CMP.B 	#MODECHAR,D0 	; CP MODECHAR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,ME03
	BEQ.S 	LAB.553 	;
	JMP 	ME03(A5) 	;
LAB.553:
	MOVE.B 	P6CHAR(A5),D0 	; LD A,(P6CHAR)
	MOVE.B 	D0,D3 	; LD E,A
	ROR.W 	#8,D3 	; LD D,0
	MOVE.B 	#0,D3 	;
	ROR.W 	#8,D3 	;
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	JMP 	STORECHARACTER(A5) 	; JP STORECHARACTER
ME03 	EQU	*-PRG.STRT 	;ME03
	CMP.B 	#MODESC,D0 	; CP MODESC
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,ME04
	BEQ.S 	LAB.554 	;
	JMP 	ME04(A5) 	;
LAB.554:
	ROR.W 	#8,D3 	; LD D,$20 ;Leading space
	MOVE.B 	#$20,D3 	;
	ROR.W 	#8,D3 	;
	JMP 	ME05(A5) 	; JR ME05
ME04 	EQU	*-PRG.STRT 	;ME04
	CMP.B 	#MODECS,D0 	; CP MODECS
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NZ,MODEERROR
	BEQ.S 	LAB.555 	;
	JMP 	MODEERROR(A5) 	;
LAB.555:
	ROR.W 	#8,D3 	; LD D,$10 ;Trailing space
	MOVE.B 	#$10,D3 	;
	ROR.W 	#8,D3 	;
ME05 	EQU	*-PRG.STRT 	;ME05
*				;;> JP OLDFIX ;>
	MOVE.B 	P6CHAR(A5),D0 	; LD A,(P6CHAR)
	MOVE.B 	D0,D3 	; LD E,A
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	JMP 	STORECHARACTER(A5) 	; JP STORECHARACTER
*				;;
*				;;-----
*				;;
*				;;Examine for key words
*				;;
KY00 	EQU	*-PRG.STRT 	;KY00
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	MOVE.W 	#STOREREFERENCE,D7 	; CALL STOREREFERENCE
	JSR 	SYS.JSR(A5) 	;
	LEA 	WORDADDRESS(A5),A0 	; LD HL,(WORDADDRESS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	MESSAGELENGTH(A5),A0 	; LD BC,(MESSAGELENGTH)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
KY02 	EQU	*-PRG.STRT 	;KY02
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.556 	;
	JMP 	SYS.RET(A5) 	;
LAB.556:
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	LEA 	MESSAGELENGTH(A5),A0 	; LD (MESSAGELENGTH),BC
	MOVE.B 	D2,(A0) 	;
	ROR.	#DEBUGDISPLAYCODE,D7 	; CALL DEBUGDISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#'^',D0 	; CP '^'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,KY03
	BNE.S 	LAB.558 	;
	JMP 	KY03(A5) 	;
LAB.558:
*				;;
*				;;Not a keyword so ignore
*				;;
	JMP 	KY02(A5) 	; JR KY02
*				;;
*				;;Check for 'special' characters
*				;;
KY03 	EQU	*-PRG.STRT 	;KY03
	LEA 	WORDADDRESS(A5),A0 	; LD (WORDADDRESS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W	#DEBUGDISPLAYCODE,D7 	; CALL DEBUGDISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#'^',D0 	; CP '^'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,KY03
	BNE.S 	LAB.558 	;
	JMP 	KY03(A5) 	;
LAB.558:
*				;;
*				;;Not a keyword so ignore
*				;;
	JMP 	KY02(A5) 	; JR KY02
*				;;
*				;;Check for 'special' characters
*				;;
KY03 	EQU	*-PRG.STRT 	;KY03
	LEA 	WORDADDRESS(A5),A0 	; LD (WORDADDRESS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
*				;;Process word-type declaration
*				;;
	MOVE.W 	#WT01,D7 	; CALL WT01
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#FF01,D7 	; CALL FF01
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR C,KY20 ;Not a word
	BCC.S 	LAB.559 	;
	JMP 	KY20(A5) 	;
LAB.559:
	MOVE.W 	#SW01,D7 	; CALL SW01 ;Store it
	JSR 	SYS.JSR(A5) 	;
	JMP 	KY01(A5) 	; JR KY01
*				;;
*				;;Not in Frequency Table (i.e. Not a 'word')
*				;;
KY20 	EQU	*-PRG.STRT 	;KY20
	LEA 	WORDADDRESS(A5),A0 	; LD HL,(WORDADDRESS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	MESSAGELENGTH(A5),A0 	; LD BC,(MESSAGELENGTH)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	JMP 	KY02(A5) 	; JP KY02
*;;
*;;-----
*;;
*;;Process word-type declaration
*;;
WT01 	EQU	*-PRG.STRT 	;WT01
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,P6BADWORDTYPE
	BNE.S 	LAB.560 	;
	JMP 	P6BADWORDTYPE(A5) 	;
LAB.560:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#DEBUGDISPLAYCODE,D7 	; CALL DEBUGDISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	#TYPETABLE+1,D3 	; LD DE,TYPETABLE+1
	ROR.W 	#8,D2 	; LD B,1
	MOVE.B 	#1,D2 	;
	ROR.W 	#8,D2 	;
WT02 	EQU	*-PRG.STRT 	;WT02
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	#8,D0 	; CP 8
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,P6BADWORDTYPE
	BNE.S 	LAB.561 	;
	JMP 	P6BADWORDTYPE(A5) 	;
LAB.561:
	MOVE.B 	0(a5,D3.W),D0 	; LD A,(DE)
	CMP.B 	0(a4,D1.W),D0 	; CP (HL)
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,WT03
	BNE.S 	LAB.562 	;
	JMP 	WT03(A5) 	;
LAB.562:
	ADDQ.W 	#1,D3 	; INC DE
	ADD.W 	#$100,D2 	; INC B
	JMP 	WT02(A5) 	; JR WT02
WT03 	EQU	*-PRG.STRT 	;WT03
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,WORDTYPE(A5) 	; LD (WORDTYPE),A
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,WT04
	BNE.S 	LAB.563 	;
	JMP 	WT04(A5) 	;
LAB.563:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	NUMKEYWORDS(A5),A0 	; LD HL,(NUMKEYWORDS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMKEYWORDS(A5),A0 	; LD (NUMKEYWORDS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
WT04 	EQU	*-PRG.STRT 	;WT04
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,P6BADWORDTYPE
	BNE.S 	LAB.564 	;
	JMP 	P6BADWORDTYPE(A5) 	;
LAB.564:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,WT04
	BNE.S 	LAB.565 	;
	JMP 	WT04(A5) 	;
LAB.565:
	LEA 	WORDADDRESS(A5),A0 	; LD (WORDADDRESS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	MESSAGELENGTH(A5),A0 	; LD (MESSAGELENGTH),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	JMP 	DEBUGDISPLAYCODE(A5) 	; JP DEBUGDISPLAYCODE
*				;;
*				;;-----
*				;;
FF01 	EQU	*-PRG.STRT 	;FF01
*				;;Search directory for a matching word
*				;;
	MOVE.W 	#LOADBUFFER,D7 	; CALL LOADBUFFER
	JSR 	SYS.JSR(A5) 	;
	LEA 	STARTFT(A5),A0 	; LD HL,(STARTFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
FF02 	EQU	*-PRG.STRT 	;FF02
	MOVE.W 	#CHECKENDFT,D7 	; CALL CHECKENDFT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,FF04
	BCS.S 	LAB.566 	;
	JMP 	FF04(A5) 	;
LAB.566:
	MOVE.W 	#COMPARE,D7 	; CALL COMPARE
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,FF03
	BNE.S 	LAB.567 	;
	JMP 	FF03(A5) 	;
LAB.567:
	MOVE 	F(A5),SR 	; JP C,FF04 ;Past it
	BCC.S 	LAB.568 	;
	JMP 	FF04(A5) 	;
LAB.568:
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	dress of word found, check if it's
*				;;a 'Common Word', convert and store its word number.
*				;;
SW01 	EQU	*-PRG.STRT 	;SW01
	MOVE.W 	#GETWORDNUMBER,D7 	; CALL GETWORDNUMBER
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#STOREREFERENCE,D7 	; CALL STOREREFERENCE
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	WORDADDRESS(A5),A0 	; LD HL,(WORDADDRESS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#BUFFER,D3 	; LD DE,BUFFER
	LEA 	MESSAGELENGTH(A5),A0 	; LD BC,(MESSAGELENGTH)
	MOVE.B 	1(A0),D2 	;
	dress of word found, check if it's
*				;;a 'Common Word', convert and store its word number.
*				;;
SW01 	EQU	*-PRG.STRT 	;SW01
	MOVE.W 	#GETWORDNUMBER,D7 	; CALL GETWORDNUMBER
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#STOREREFERENCE,D7 	; CALL STOREREFERENCE
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	WORDADDRESS(A5),A0 	; LD HL,(WORDADDRESS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#BUFFER,D3 	; LD DE,BUFFER
	LEA 	MESSAGELENGTH(A5),A0 	; LD BC,(MESSAGELENGTH)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SW03
	BNE.S 	LAB.569 	;
	JMP 	SW03(A5) 	;
LAB.569:
SW02 	EQU	*-PRG.STRT 	;SW02
	ADDQ.W 	#1,D3 	; INC DE
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SW03
	BNE.S 	LAB.570 	;
	JMP 	SW03(A5) 	;
LAB.570:
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	MOVE.W 	#DEBUGDISPLAYCODE,D7 	; CALL DEBUGDISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	JMP 	SW02(A5) 	; JR SW02
SW03 	EQU	*-PRG.STRT 	;SW03
	LEA 	MESSAGELENGTH(A5),A0 	; LD (MESSAGELENGTH),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	EOR.B 	D0,D0 	; XOR A ;Return 'word-ok'
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
DEBUGDISPLAYCODE 	EQU	*-PRG.STRT 	;DEBUGDISPLAYCODE
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,DISPDEBUG01
	BNE.S 	LAB.571 	;
	JMP 	DISPDEBUG01(A5) 	;
LAB.571:
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
DISPDEBUG01 	EQU	*-PRG.STRT 	;DISPDEBUG01
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	JMP 	DISPLAYCODE(A5) 	; JP DISPLAYCODE
*				;;
*				;;-----
*				;;
*				;;HL is Long word reference. Returns 'Z' and
*				;;A = short-ref. Otherwise returns 'NZ'.
*				;;
CHECKSHORTREF 	EQU	*-PRG.STRT 	;CHECKSHORTREF
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	LEA 	STARTCWT(A5),A0 	; LD HL,(STARTCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D2 	; LD B,0
	MOVE.B 	#0,D2 	;
	ROR.W 	#8,D2 	;
CR01 	EQU	*-PRG.STRT 	;CR01
	MOVE.W 	#CHECKENDCWT,D7 	; CALL CHECKENDCWT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,CR04
	BCS.S 	LAB.572 	;
	JMP 	CR04(A5) 	;
LAB.572:
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ROR.W 	#8,D1 	; LD H,B
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,D1 	;
	ROR.W 	#8,D2 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D2,D1 	; LD L,C
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,CR02
	BNE.S 	LAB.573 	;
	JMP 	CR02(A5) 	;
LAB.573:
	ADD.W 	#$100,D2 	; INC B
	JMP 	CR01(A5) 	; JR CR01
CR02 	EQU	*-PRG.STRT 	;CR02
	EOR.B 	D0,D0 	; XOR A ;Return 'Z'
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	JMP 	SYS.RET(A5) 	; RET 
CR04 	EQU	*-PRG.STRT 	;CR04
	MOVE.B 	#1,D0 	; LD A,1 ;Return 'NZ'
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;HL is the address of a frequency entry.
*				;;Returns HL as its word number.
*				;;
GETWORDNUMBER 	EQU	*-PRG.STRT 	;GETWORDNUMBER
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#0,D2 	; LD BC,0
	LEA 	STARTFT(A5),A0 	; LD HL,(STARTFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
GW01 	EQU	*-PRG.STRT 	;GW01
	MOVE.W 	#CHECKENDFT,D7 	; CALL CHECKENDFT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,SHORTOVERSHOOT
	BCS.S 	LAB.574 	;
	JMP 	SHORTOVERSHOOT(A5) 	;
LAB.574:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,GW02
	BNE.S 	LAB.575 	;
	JMP 	GW02(A5) 	;
LAB.575:
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	ROR.	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
STOREREFERENCE 	EQU	*-PRG.STRT 	;STOREREFERENCE
	ROR.W 	#8,D1 	; LD A,H ;Make it a long-form reference
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	AND.B 	#$0F,D0 	; AND $0F
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D1 	; LD H,A
	MOVE.B 	D0,D1 	;
	ROR.W 	#8,D1 	;
*				;;
	MOVE.B 	WORDTYPE(A5),D0 	; LD A,(WORDTYPE)
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
STOREREFERENCE 	EQU	*-PRG.STRT 	;STOREREFERENCE
	ROR.W 	#8,D1 	; LD A,H ;Make it a long-form reference
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	AND.B 	#$0F,D0 	; AND $0F
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D1 	; LD H,A
	MOVE.B 	D0,D1 	;
	ROR.W 	#8,D1 	;
*				;;
	MOVE.B 	WORDTYPE(A5),D0 	; LD A,(WORDTYPE)
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	AND.B 	#$70,D0 	; AND $70
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D1 	; OR H
	OR.B 	D1,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D1 	; LD H,A
	MOVE.B 	D0,D1 	;
	ROR.W 	#8,D1 	;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,WORDTYPE(A5) 	; LD (WORDTYPE),A
*				;;
STORECHARACTER 	EQU	*-PRG.STRT 	;STORECHARACTER
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#CHECKSHORTREF,D7 	; CALL CHECKSHORTREF
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JP Z,STORESHORTREF
	BNE.S 	LAB.576 	;
	JMP 	STORESHORTREF(A5) 	;
LAB.576:
	JMP 	STORELONGREF(A5) 	; JP STORELONGREF
*				;;
*				;;-----
*				;;
*				;;HL is a long-form word-reference. It is appended to the
*				;;end of the current message descriptor.
*				;;
STORELONGREF 	EQU	*-PRG.STRT 	;STORELONGREF
	ROR.W 	#8,D1 	; SET LONG,H ;Make it a long-form reference
	BSET 	#LONG,d1 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.W 	#CHECKBELOWBUFFER,D7 	; CALL CHECKBELOWBUFFER
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,MDTFULL
	BCS.S 	LAB.577 	;
	JMP 	MDTFULL(A5) 	;
LAB.577:
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D3 	; LD (HL),D
	MOVE.B 	D3,0(a4,D1.W) 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	D3,0(a4,D1.W) 	; LD (HL),E
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	CURRENTMDT(A5),A0 	; LD (CURRENTMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	NUMLONGREFS(A5),A0 	; LD HL,(NUMLONGREFS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMLONGREFS(A5),A0 	; LD (NUMLONGREFS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;A is a short-form word-reference. It is appended to
*				;;the end ot the current message descriptor.
*				;;
STORESHORTREF 	EQU	*-PRG.STRT 	;STORESHORTREF
	BCLR 	#LONG,d0 	; RES LONG,A ;Make it a short-form reference
	MOVE.B 	D0,D3 	; LD E,A
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.W 	#CHECKBELOWBUFFER,D7 	; CALL CHECKBELOWBUFFER
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,MDTFULL
	BCS.S 	LAB.578 	;
	JMP 	MDTFULL(A5) 	;
LAB.578:
	LEA 	CURRENTMDT(A5),A0 	; LD HL,(CURRENTMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	D3,0(a4,D1.W) 	; LD (HL),E
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	CURRENTMDT(A5),A0 	; LD (CURRENTMDT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	NUMSHORTREFS(A5),A0 	; LD HL,(NUMSHORTREFS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMSHORTREFS(A5),A0 	; LD (NUMSHORTREFS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;'Message Descriptor Table' full
*				;;
MDTFULL 	EQU	*-PRG.STRT 	;MDTFULL
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"'Message Descriptor Table' full" 	; DEFM "'Message Descriptor Table' full"
	DC.B 	0 	; DEFB 0
 even
	JMP 	P6ERROR(A5) 	; JP P6ERROR ;Calls DISPLAYLINENUM and WARMSTART
*				;;
*				;;-----
*				;;
*				;;Long-to-Short word reference look-up ran of end of
*				;;Frequency Table
*				;;
SHORTOVERSHOOT 	EQU	*-PRG.STRT 	;SHORTOVERSHOOT
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"SQUASH Error. " 	; DEFM "SQUASH Error. "
	DC.B 	"Short-reference address conversion failed." 	;
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	#ABORTSERIALSMT,D7 	; CALL ABORTSERIALSMT
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#ABORTSERIALICF,D7 	; CALL ABORTSA5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
INITSERIALSMT 	EQU	*-PRG.STRT 	;INITSERIALSMT
	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#MAXMESSAGELEN+256,D3 	; LD DE,MAXMESSAGELEN+256
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
INITSERIALSMT 	EQU	*-PRG.STRT 	;INITSERIALSMT
	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#MAXMESSAGELEN+256,D3 	; LD DE,MAXMESSAGELEN+256
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	LEA 	STARTBUFFER(A5),A0 	; LD (STARTBUFFER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	LENGTHSMT(A5),A0 	; LD HL,(LENGTHSMT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	UNREADSIZE(A5),A0 	; LD (UNREADSIZE),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	BUFFERSIZE(A5),A0 	; LD (BUFFERSIZE),HL
	MOVE.B 	#0,(A0) 	;
	MOVE.B 	#0,1(A0) 	;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"Reading " 	; DEFM "Reading "
;	DC.B 	0 	; DEFB 0
; even
;	MOVE.W 	#DISPLAYTEMPNAME,D7 	; CALL DISPLAYTEMPNAME
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"..." 	; DEFM "..."
;	DC.B 	ASCIICR,0 	; DEFB ASCIICR,0
; even
;	MOVE.W 	#CLEARFCB,D7 	; CALL CLEARFCB
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#TEMPFILE,D1 	; LD HL,TEMPFILE
;	MOVE.W 	#SYSTEMFCBDRIVE,D3 	; LD DE,SYSTEMFCBDRIVE
;	MOVE.W 	#12,D2 	; LD BC,12
;	JSR 	SYS.LDIR(A5) 	; LDIR 
;*				;;
;	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input File Control Block
;	MOVE.W 	#OPENSERIALREAD,D7 	; CALL OPENSERIALREAD
;	JSR 	SYS.JSR(A5) 	;
;	MOVE 	F(A5),SR 	; JR NC,NS01 ;File OK
;	BCS.S 	LAB.579 	;
 move.l startfilebuffer(A5),a3 ; start of squash.tmp file
; (in memory on 68000 systems)
	JMP 	NS01(A5) 	;
;LAB.579:
;*				;;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"SQUASH error. Can't open " 	; DEFM "SQUASH error. Can't open "
;	DC.B 	0 	; DEFB 0
; even
;	MOVE.W 	#DISPLAYTEMPNAME,D7 	; CALL DISPLAYTEMPNAME
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
;	JSR 	SYS.JSR(A5) 	;
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
*;;
*;;-----
*;;
NEXTSERIALSMT 	EQU	*-PRG.STRT 	;NEXTSERIALSMT
* uses serialreadbyte to pull chars into a buffer
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2
	ROR.W 	#8,D2
	LEA 	UNREADSIZE(A5),A0 	; LD HL,(UNREADSIZE)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5)
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1
;	MOVE 	SR,F(A5)
	LEA 	UNREADSIZE(A5),A0 	; LD (UNREADSIZE),HL
	MOVE.B 	D1,(A0)
	ROR.W 	#8,D1
	MOVE.B 	D1,1(A0)
	ROR.W 	#8,D1
	LEA 	BUFFERSIZE(A5),A0 	; LD HL,(BUFFERSIZE)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1 		; SBC HL,BC
	SUB.W 	D2,D1
	MOVE 	SR,F(A5)
	LEA 	BUFFERSIZE(A5),A0 	; LD (BUFFERSIZE),HL
	MOVE.B 	D1,(A0)
	ROR.W 	#8,D1
	MOVE.B 	D1,1(A0)
	ROR.W 	#8,D1
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
	ADD.W 	D2,D1 			; ADD HL,BC
	MOVE 	SR,F(A5)
	LEA 	STARTBUFFER(A5),A0 	; LD DE,(STARTBUFFER)
	MOVE.B 	1(A0),D3
	ROR.W 	#8,D3
	MOVE.B 	(A0),D3
	LEA 	BUFFERSIZE(A5),A0 	; LD BC,(BUFFERSIZE)
	MOVE.B 	1(A0),D2
	ROR.W 	#8,D2
	MOVE.B 	(A0),D2
	JSR 	SYS.LDIR(A5)	 	; LDIR 
NS01 	EQU	*-PRG.STRT 		;NS01
	LEA 	BUFFERSIZE(A5),A0 	; LD HL,(BUFFERSIZE)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
	MOVE.W 	#MAXMESSAGELEN,D3 	; LD DE,MAXMESSAGELEN
;					; XOR A
;				 	; SBC HL,DE
	SUB.W 	D3,D1
;					; RET NC
;Buffer contains enough bytes for longest message
	BCS.S 	LAB.580
	JMP 	SYS.RET(A5)
LAB.580:
	LEA 	UNREADSIZE(A5),A0 	; LD HL,(UNREADSIZE)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
	tst.w d1 ; LD A,H; OR L; RET Z ;Nothing left to read
	BNE.S 	LAB.581 		;
	JMP 	SYS.RET(A5) 		;
LAB.581:
; now pull in characters from file [(a3)+ on 68000]
*				;;
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	BUFFERSIZE(A5),A0 	; LD DE,(BUFFERSIZE)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	ADD.W 	D3,D1 			; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	ADDQ.W 	#1,D3 			; INC DE
	LEA 	BUFFERSIZE(A5),A0 	; LD (BUFFERSIZE),DE
	MOVE.B 	D3,(A0)
	ROR.W 	#8,D3
	M	LEA 	BUFFERSIZE(A5),A0 	; LD HL,(BUFFERSIZE)
;;	MOVE.B 	1(A0),D1 	;
;;	ROR.W 	#8,D1 	;
;	MOVE.B 	(A0),D1 	;
;	LEA 	UNREADSIZE(A5),A0 	; LD DE,(UNREADSIZE)
;	MOVE.B 	1(A0),D3 	;
;	ROR.W 	#8,D3 	;
;	MOVE.B 	(A0),D3 	;	
;;		 		; XOR A
;;				; SBC HL,DE
;	SUB.W 	D3,D1
;;				; JR NC,NS01 ;Valid end of file
;	BCS.S 	LAB.583 	;
;	JMP 	NS01(A5) 	;
;LAB.583:
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"SQUASH error. Unexpected EOF in " 	; DEFM "SQUASH error. Unexpect	LEA 	BUFFERSIZE(A5),A0 	; LD HL,(BUFFERSIZE)
;;	MOVE.B 	1(A0),D1 	;
;;	ROR.W 	#8,D1 	;
;	MOVE.B 	(A0),D1 	;
;	LEA 	UNREADSIZE(A5),A0 	; LD DE,(UNREADSIZE)
;	MOVE.B 	1(A0),D3 	;
;	ROR.W 	#8,D3 	;
;	MOVE.B 	(A0),D3 	;	
;;		 		; XOR A
;;				; SBC HL,DE
;	SUB.W 	D3,D1
;;				; JR NC,NS01 ;Valid end of file
;	BCS.S 	LAB.583 	;
;	JMP 	NS01(A5) 	;
;LAB.583:
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"SQUASH error. Unexpected EOF in " 	; DEFM "SQUASH error. Unexpected EOF in "
;	DC.B 	0 	; DEFB 0
; even
;	MOVE.W 	#DISPLAYTEMPNAME,D7 	; CALL DISPLAYTEMPNAME
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#ABORTSERIALSMT,D7 	; CALL ABORTSERIALSMT
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#ABORTSERIALICF,D7 	; CALL ABORTSERIALICF
;	JSR 	SYS.JSR(A5) 	;
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
*				;;-----
*				;;
ENDSERIALSMT 	EQU	*-PRG.STRT 	;ENDSERIALSMT
	LEA 	UNREADSIZE(A5),A0 	; LD HL,(UNREADSIZE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	OR.B 	D1,D0 	; OR L
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.584 	;
	JMP 	SYS.RET(A5) 	;
LAB.584:
	SUBQ.W 	#2,D6 	; PUSH AF ;Save 'NZ' condition
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; CALL Z,NEWLINE
	BNE.S 	LAB.585 	;
	MOVE.W 	#NEWLINE,D7 	;
	JSR 	SYS.JSR(A5) 	;
LAB.585:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"... eof" 	; DEFM "... eof"
	DC.B 	ASCIICR,0 	; DEFB ASCIICR,0
 even
;	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input File Control Block
;	MOVE.W 	#CLOSESERIALREAD,D7 	; CALL CLOSESERIALREAD
;	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF ;Return 'NZ'
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
ABORTSERIALSMT 	EQU	*-PRG.STRT 	;ABORTSERIALSMT
 jmp sys.ret(a5) ; nothing to do on 68000

	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input File Control Block
	MOVE.W 	#CLOSESERIALREAD,D7 	; CALL CLOSESERIALREAD
	JSR 	SYS.JSR(A5) 	;
	JMP 	DELETESYSTEM(A5) 	; JP DELETESYSTEM ;Delete B:SQUASH1.TMP
*				;;
*				;;-----
*				;;
NAMEICF 	EQU	*-PRG.STRT 	;NAMEICF
	DC.B 	2 	; DEFB 2 ;Drive B:
	DC.B 	"SQUASH2 " 	; DEFM "SQUASH2 "
	DC.B 	"TMP" 	; DEFM "TMP"
 even
*				;;
*				;;-----
*				;;
INITSERIALICF 	EQU	*-PRG.STRT 	;INITSERIALICF
	MOVE.W 	#CLEARFCB,D7 	; CALL CLEARFCB
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Writing B:SQUASH2.TMP ..." 	; DEFM "Writing B:SQUASH2.TMP ..."
	DC.B 	$D,0 	; DEFB $D,0
 even
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	LENGTHICF(A5),A0 	; LD (LENGTHICF),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#NAMEICF,D1 	; LD HL,NAMEICF
	MOVE.W 	#SYSTEMFCBDRIVE,D3 	; LD DE,SYSTEMFCBDRIVE
	MOVE.W 	#12,D2 	; LD BC,12
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;Output File Control Block
	MOVE.W 	#OPENSERIALWRITE,D7 	; CALL OPENSERIALWRITE
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; RET NC ;Ok
	BCS.S 	LAB.586 	;
	JMP 	SYS.RET(A5) 	;
LAB.586:
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"Can't create: B:SQUASH2.TMP" 	; DEFM "Can't create: B:SQUASH2.TMP"
	DC.B 	0 	; DEFB 0
 even
	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
*				;;-----
*				;;
WRITESERIALICF 	EQU	*-PRG.STRT 	;WRITESERIALICF
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	LENGTHICF(A5),A0 	; LD (LENGTHICF),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;Output File Control Block
	MOVE.W 	#SERIALWRITEBYTE,D7 	; CALL SERIALWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
;	MOVE 	F(A5),SR 	; RET NC ;Ok
;	BCS.S 	LAB.587 	;
	JMP 	SYS.RET(A5) 	;
;LAB.587:
;*				;;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	ASCIICR 	; DEFB ASCIICR
;	DC.B 	"Error writing B:SQUASH2.TMP" 	; DEFM "Error writing B:SQUASH2.TMP"
;	DC.B 	0 	; DEFB 0
; even
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
;SESERIALWRITE
	JSR 	SYS.JSR(A5) 	;
	JMP 	DELETESYSTEM(A5) 	; JP DELETESYSTEM ;Delete B:SQUASH1.TMP
*;;
*;;-----
*;;
*;;Phase 7 - Construct 'Word Dictionary'
*;;
*;;Phase 7 Converts words from the 'Frequency Table' into
*;;a bit-stream of 5,10 and 15 bit short-codes.
*;;These are used to build the 'Word Dictionary'
*;;at addresses (CURRENTMDT) thru (ENDMEMORY).
*;;(ENDWD) holds the current top of the Dictionary.
*;;
*;;-----
*;;
PHASE07 	EQU	*-PRG.STRT 	;PHASE07
;	MOVE.W 	#TRACE,D7 	; CALL TSESERIALWRITE
	JSR 	SYS.JSR(A5) 	;
	JMP 	DELETESYSTEM(A5) 	; JP DELETESYSTEM ;Delete B:SQUASH1.TMP
*;;
*;;-----
*;;
*;;Phase 7 - Construct 'Word Dictionary'
*;;
*;;Phase 7 Converts words from the 'Frequency Table' into
*;;a bit-stream of 5,10 and 15 bit short-codes.
*;;These are used to build the 'Word Dictionary'
*;;at addresses (CURRENTMDT) thru (ENDMEMORY).
*;;(ENDWD) holds the current top of the Dictionary.
*;;
*;;-----
*;;
PHASE07 	EQU	*-PRG.STRT 	;PHASE07
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 7 - Construct 'Word Dictionary'" 	; DEFM "Phase 7 - Construct 'Word Dictionary'"
	DC.B 	ASCIICR,0 	; DEFB ASCIICR,0
 even
*				;;
*				;;* LD HL,(LENGTHICF)
*				;;* LD (LENGTHMD),HL
*				;;* LD BC,LENGTHPOINTERS
*				;;* ADD HL,BC
*				;;* LD (INDEXMD),HL
*;;
*;;Clear current segment:
*;;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,SEGNUM(A5) 	; LD (SEGNUM),A
	MOVE.W 	#SEGMENTADDRESSES,D1 	; LD HL,SEGMENTADDRESSES
	LEA 	LASTPOINTER(A5),A0 	; LD (LASTPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*;;
*;;Clear 'Previous Word Start' buffer.
*;;
	MOVE.W 	#CLEARTHREE,D7 	; CALL CLEARTHREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#UNPACK1,D1 	; LD HL,UNPACK1
	LEA 	READWRITEPOINTER(A5),A0	; LD (READWRITEPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	#ENDSEG,D0 	; LD A,ENDSEG
	MOVE.B 	D0,LASTBYTE(A5) 	; LD (LASTBYTE),A
*				;;
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
	LEA 	STARTFT(A5),A0 	; LD HL,(STARTFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
PG01 	EQU	*-PRG.STRT 	;PG01
	MOVE.W 	#CHECKENDFT,D7 	; CALL CHECKENDFT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,PG10
	BCS.S 	LAB.588 	;
	JMP 	PG10(A5) 	;
LAB.588:
*
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#GETWORDTEXT,D7 	; CALL GETWORDTEXT
	JSR 	SYS.JSR(A5) 	; load length of word into B
	MOVE.B 	0(a4,D1.W),D0
	BCLR 	#7,d0 	; RES 7,A
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	SUB.B 	#'a',D0 	; SUB 'a'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP C,PG09
	BCC.S 	LAB.589 	;
	JMP 	PG09(A5) 	;
LAB.589:
	CMP.B 	#26,D0 	; CP 26
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,PG03
	BCC.S 	LAB.590 	;
	JMP 	PG03(A5) 	;
LAB.590:
	MOVE.B 	#103,D0 	; LD A,103
	JMP 	PG05(A5) 	; JR PG05
PG03 	EQU	*-PRG.STRT 	;PG03
; a=first char of word to put into dictionary.
; We know it IS alphabetic
; B is length of word
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	MOVE.B 	D0,D2 	; LD C,A ; C=first char*4 i.e. high part
; of segment number
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	#2,D0 	; CP 2
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D2,D0 	; LD A,C ; high part of segment number
	MOVE 	F(A5),SR 	; JR C,PG05 ;Less than 2 chars
	BCC.S 	LAB.591 	;
	JMP 	PG05(A5) 	;
LAB.591:
; more than 2 chars in word, so find low part of segment number
; high part is already in C
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL 
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 	; RES 7,A
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'a',D0 	; CP 'a'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,PG04
	BCS.S 	LAB.592 	;
	JMP 	PG04(A5) 	;
LAB.592:
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	JMP 	PG05(A5) 	; JR PG05

; continue to find low part of segment number
PG04 	EQU	*-PRG.STRT 	;PG04
; high part is in C (calculated from first char-'a'*4)
; alphabetic second char of word is in A
	SUB.B 	#'a',D0 	; SUB 'a'
	LSR.B 	#3,D0 	; SRL A*3
	AND.B 	#$3,D0 	; AND $3
	ROR.W 	#8,D2 	; ADD A,B
	ADD.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
PG05 	EQU	*-PRG.STRT 	;PG05
*				;;
	ADDQ.B 	#1,D0 	; INC A
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	SEGNUM(A5),D0 	; LD A,(SEGNUM)
	ROR.W 	#8,D2 	; CP B
	CMP.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE 	F(A5),SR 	; JR Z,PG09 ;(this segment)
	BNE.S 	LAB.593 	;
	JMP 	PG09(A5) 	;
LAB.593:
	MOVE 	F(A5),SR 	; JR NC,PG09 ;(previous segment)
	BCS.S 	LAB.594 	;
	JMP 	PG09(A5) 	;
LAB.594:
*				;;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
*				;;
	LEA 	LASTPOINTER(A5),A0 ; LD HL,(LASTPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W,SR 	; JR Z,PG08 ;Table full
	BNE.S 	LAB.595 	;
	JMP 	PG08(A5) 	;
LAB.595:
*
	MOVE.B 	LASTBYTE(A5),D0 ; LD A,(LASTBYTE)
	CMP.B 	#ENDSEG,D0 	; CP ENDSEG
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PG07
	BNE.S 	LAB.596 	;
	JMP 	PG07(A5) 	;
LAB.596:
	MOVE.B 	#ENDSEG,D0 	; LD A,ENDSEG
	MOVE.W 	#STOREWORDDICTIONARY,D7 ; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
PG07 	EQU	*-PRG.STRT 	;PG07
	MOVE.W 	#BYTEALIGN,D7 	; CALL BYTEALIGN
	JSR 	SYS.JSR(A5) 	;
	LEA 	LASTPOINTER(A5),A0 	; LD HL,(LASTPOI,SR 	; JR Z,PG08 ;Table full
	BNE.S 	LAB.595 	;
	JMP 	PG08(A5) 	;
LAB.595:
*
	MOVE.B 	LASTBYTE(A5),D0 ; LD A,(LASTBYTE)
	CMP.B 	#ENDSEG,D0 	; CP ENDSEG
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PG07
	BNE.S 	LAB.596 	;
	JMP 	PG07(A5) 	;
LAB.596:
	MOVE.B 	#ENDSEG,D0 	; LD A,ENDSEG
	MOVE.W 	#STOREWORDDICTIONARY,D7 ; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
PG07 	EQU	*-PRG.STRT 	;PG07
	MOVE.W 	#BYTEALIGN,D7 	; CALL BYTEALIGN
	JSR 	SYS.JSR(A5) 	;
	LEA 	LASTPOINTER(A5),A0 	; LD HL,(LASTPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*				;;
	LEA 	LENGTHICF(A5),A0 	; LD DE,(LENGTHICF)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#LENGTHPOINTERS,D1 	; LD HL,LENGTHPOINTERS
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.B 	D3,0(a4,D1.W) 	; LD (HL),E
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D3 	; LD (HL),D
	MOVE.B 	D3,0(a4,D1.W) 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	WORDNUMBER(A5),A0 	; LD DE,(WORDNUMBER)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	SUBQ.W 	#1,D3 	; DEC DE
	ADDQ.W 	#1,D3 	; INC DE
	MOVE.B 	D3,0(a4,D1.W) 	; LD (HL),E
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D3 	; LD (HL),D
	MOVE.B 	D3,0(a4,D1.W) 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	LASTPOINTER(A5),A0 	; LD (LASTPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
PG08 	EQU	*-PRG.STRT 	;PG08
	MOVE.B 	SEGNUM(A5),D0 	; LD A,(SEGNUM)
	ADDQ.B 	#1,D0 	; INC A
	MOVE.B 	D0,SEGNUM(A5) 	; LD (SEGNUM),A
*				;;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	PG01(A5) 	; JP PG01
PG09 	EQU	*-PRG.STRT 	;PG09
*				;;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#CONVERTWORD,D7 	; CALL CONVERTWORD
	JSR 	SYS.JSR(A5) 	;
*;;
*;;Move on to next word
*;;
	LEA 	WORDNUMBER(A5),A0 	; LD HL,(WORDNUMBER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ROR.W 	#8,D2 	; LD B,0
	MOVE.B 	#0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	JMP 	PG01(A5) 	; JP PG01
*;;
*;;Extend table so it ends on a byte-boundary
*;;
PG10 	EQU	*-PRG.STRT 	;PG10
	MOVE.B 	LASTBYTE(A5),D0 	; LD A,(LASTBYTE)
	CMP.B 	#ENDSEG,D0 	; CP ENDSEG
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PG11 
	BNE.S 	LAB.597 	;
	JMP 	PG11(A5) 	;
LAB.597:
	MOVE.B 	#ENDSEG,D0 	; LD A,ENDSEG ;Terminate final word
	MOVE.W 	#STOREWORDDICTIONARY,D7 	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
PG11 	EQU	*-PRG.STRT 	;PG11
	MOVE.W 	#BYTEALIGN,D7 	; CALL BYTEALIGN
	JSR 	SYS.JSR(A5) 	;
*;;
*;;Calculate offset into SQUASH file end
*;;and length of Word Dictionary.
*;;
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS,D2 	; LD BC,LENGTHPOINTERS
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	LEA 	INDEXWD(A5),A0 	; LD (INDEXWD),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	INDEXMD(A5),A0 	; LD DE,(INDEXMD)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	LEA 	LENGTHWD(A5),A0 	; LD (LENGTHWD),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*;;
*;;(Optional) Display length of table
*;;
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.598 	;
	JMP 	SYS.RET(A5) 	;
LAB.598:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Length of 'Word Dictionary' =" 	; DEFM "Length of 'Word Dictionary' ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	LENGTHWD(A5),A0 	; LD HL,(LENGTHWD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	JMP 	NEWLINE(A5) 	; JP NEWLINE
*				;;
*				;;-----
*				;;
CLEARTHREE 	EQU	*-PRG.STRT 	;CLEARTHREE
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(orce $1C header type next.
*;;
BYTEALIGN 	EQU	*-PRG.STRT 	;BYTEALIGN
	MOVE.W 	#CLEARTHREE,D7 	; CALL CLEARTHREE
	JSR 	SYS.JSR(A5) 	;
BA01 	EQU	*-PRG.STRT 	;BA01
	LEA 	READWRITEPOINTER(A5),A0 ; LD HL,(READWRITEPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#UNPACK1,D3 	; LD DE,UNPACK1
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.599 	;
	JMP 	SYS.RET(A5) 	;
LAB.orce $1C header type next.
*;;
BYTEALIGN 	EQU	*-PRG.STRT 	;BYTEALIGN
	MOVE.W 	#CLEARTHREE,D7 	; CALL CLEARTHREE
	JSR 	SYS.JSR(A5) 	;
BA01 	EQU	*-PRG.STRT 	;BA01
	LEA 	READWRITEPOINTER(A5),A0 ; LD HL,(READWRITEPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#UNPACK1,D3 	; LD DE,UNPACK1
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.599 	;
	JMP 	SYS.RET(A5) 	;
LAB.599:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#DOCONVERSION,D7 	; CALL DOCONVERSION
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D1,D0 	; LD A,L
	CMP.B 	#1,D0 	; CP 1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,BA07
	BNE.S 	LAB.600 	;
	JMP 	BA07(A5) 	;
LAB.600:
	CMP.B 	#2,D0 	; CP 2
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,BA07
	BNE.S 	LAB.601 	;
	JMP 	BA07(A5) 	;
LAB.601:
	CMP.B 	#3,D0 	; CP 3
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,BA02
	BNE.S 	LAB.602 	;
	JMP 	BA02(A5) 	;
LAB.602:
	CMP.B 	#4,D0 	; CP 4
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,BA03
	BNE.S 	LAB.603 	;
	JMP 	BA03(A5) 	;
LAB.603:
	CMP.B 	#5,D0 	; CP 5
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,BA04
	BNE.S 	LAB.604 	;
	JMP 	BA04(A5) 	;
LAB.604:
	CMP.B 	#6,D0 	; CP 6
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,BA05
	BNE.S 	LAB.605 	;
	JMP 	BA05(A5) 	;
LAB.605:
	CMP.B 	#7,D0 	; CP 7
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,BA06
	BNE.S 	LAB.606 	;
	JMP 	BA06(A5) 	;
LAB.606:
	MOVE.W 	#BREAK,D7 	; CALL BREAK
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"byte-align error" 	; DEFM "byte-align error"
	DC.B 	0 	; DEFB 0
 even
	JMP 	EXITCPM(A5) 	; JP EXITCPM
BA02 	EQU	*-PRG.STRT 	;BA02
	MOVE.B 	#2,D0 	; LD A,2
	JMP 	BA07(A5) 	; JR BA07
BA03 	EQU	*-PRG.STRT 	;BA03
	MOVE.B 	#3,D0 	; LD A,3
	JMP 	BA07(A5) 	; JR BA07
BA04 	EQU	*-PRG.STRT 	;BA04
	MOVE.B 	#4,D0 	; LD A,4
	JMP 	BA07(A5) 	; JR BA07
BA05 	EQU	*-PRG.STRT 	;BA05
	MOVE.B 	#4,D0 	; LD A,4
	JMP 	BA07(A5) 	; JR BA07
BA06 	EQU	*-PRG.STRT 	;BA06
	MOVE.B 	#5,D0 	; LD A,5
	JMP 	BA07(A5) 	; JR BA07
BA07 	EQU	*-PRG.STRT 	;BA07
*;;
*;;A holds the number of bytes of 'PACK'ed data
*;;to be written to dictionary
*;;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	#PACK1,D1 	; LD HL,PACK1
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
BA08 	EQU	*-PRG.STRT 	;BA08
ba08a
	MOVE.B 	0(a5,D1.W),D0 	; LD A,(HL) ;>>in program, so a5
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
; DJNZ BA08
 sub.w #$100,d2 ; ((decb))
 clr.b d2 ; clr c
 tst.w d2
 bne ba08a

;	JSR 	SYS.DJNZ(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.W 	#UNPACK1,D1 	; LD HL,UNPACK1
	LEA 	READWRITEPOINTER(A5),A0 	; LD (READWRITEPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Change one 'Frequency Table' entry to a
*;;'Word Dictionary' entry. HL is the address of
*;;the 'Frequency Table' entry.
*;;
CONVERTWORD 	EQU	*-PRG.STRT 	;CONVERTWORD
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#GETWORDTEXT,D7 	; CALL GETWORDTEXT
	JSR 	SYS.JSR(A5) 	;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.B	#0,WORDCASE(A5) 	; LD (WORDCASE),A
	MOVE.B	#0,D2 	; LD C,A ;=0 Number of characters the same
	MOVE.W 	#THREECHARACTERS,D3 	; LD DE,THREECHARACTERS
CW01 	EQU	*-PRG.STRT 	;CW01
	MOVE.B 	D2,D0 	; LD A,C ;Don't exceed header length
	CMP.B 	#MAXHEADERLENGTH,D0 	; CP MAXHEADERLENGTH
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW02
	BNE.S 	LAB.607 	;
	JMP 	CW02(A5) 	;
LAB.607:
	ROR.W 	#8,D2 	; LD A,B ;End of word
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW02
	BNE.S 	LAB.608 	;
	JMP 	CW02(A5) 	;
LAB.608:
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	CMP.B 	0(a4,D1.W),D0 	; CP (HL)
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,CW02 ;End of similarity
	BEQ.S 	LAB.609 	;
	JMP 	CW02(A5) 	;
LAB.609:
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D3 	; INC DE
	SUB.W 	#$100,D2 	; DEC B
	ADDQ.B 	#1,D2 	; INC C
	JMP 	CW01(A5) 	; JR CW01
*;;
*;;Save Word header (111xx, xx is number of characters
*;;same as previous word.)
*;;
CW02 	EQU	*-PRG.STRT 	;CW02
	MOVE.B 	D2,D0 	; LD A,C
	AND.B 	#$3,D0 	; AND $3 ;Number of similar chars
	MOVE 	SR,F(A5) 	;
	OR.B 	#HEADER,D0 	; OR HEADER ;Word header
	MOVE 	SR,FETWORDTEXT
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#THREECHARACTERS,D3 	; LD DE,THREECHARACTERS
	MOVE.B 	#MAXHEADERLENGTH,D2 	; LD C,MAXHEADERLENGTH ;Copy three characters
CW03 	EQU	*-PRG.STRT 	;CW03
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW04
	BNE.S 	LAB.610 	;
	JMP 	CW04(A5) 	;
LAB.610:
	MOVE.B 	D2,D0 	; LD A,C
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW04
	BNE.S 	LAB.611 	;
	JMP 	CW04(A5) 	ETWORDTEXT
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#THREECHARACTERS,D3 	; LD DE,THREECHARACTERS
	MOVE.B 	#MAXHEADERLENGTH,D2 	; LD C,MAXHEADERLENGTH ;Copy three characters
CW03 	EQU	*-PRG.STRT 	;CW03
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW04
	BNE.S 	LAB.610 	;
	JMP 	CW04(A5) 	;
LAB.610:
	MOVE.B 	D2,D0 	; LD A,C
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW04
	BNE.S 	LAB.611 	;
	JMP 	CW04(A5) 	;
LAB.611:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.B 	D0,0(a4,D3.W) 	; LD (DE),A
	ADDQ.W 	#1,D3 	; INC DE
	ADDQ.W 	#1,D1 	; INC HL
	SUB.W 	#$100,D2 	; DEC B
	SUBQ.B 	#1,D2 	; DEC C
	JMP 	CW03(A5) 	; JR CW03
CW04 	EQU	*-PRG.STRT 	;CW04 
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
*				;;Save word itself
*				;;
	MOVE.W 	#GETWORDTEXT,D7 	; CALL GETWORDTEXT
	JSR 	SYS.JSR(A5) 	;
CW05 	EQU	*-PRG.STRT 	;CW05
	MOVE.B 	D2,D0 	; LD A,C
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW06
	BNE.S 	LAB.612 	;
	JMP 	CW06(A5) 	;
LAB.612:
	ADDQ.W 	#1,D1 	; INC HL
	SUB.W 	#$100,D2 	; DEC B
	SUBQ.B 	#1,D2 	; DEC C
	JMP 	CW05(A5) 	; JR CW05
CW06 	EQU	*-PRG.STRT 	;CW06
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.613 	;
	JMP 	SYS.RET(A5) 	;
LAB.613:
*				;;
*				;;If remainder of word contains upper case chars but no lower case
*				;;then put in an upper-case-word marker.
*				;;
	MOVE.B 	WORDCASE(A5),D0 	; LD A,(WORDCASE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,CW06A
	BEQ.S 	LAB.614 	;
	JMP 	CW06A(A5) 	;
LAB.614:
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	ROR.W 	#8,D2 	; LD C,B
	MOVE.B 	D2,D7 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D7,D2 	;
	ROR.W 	#8,D2 	; LD B,0
	MOVE.B 	#0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#UPPERCASEWORD,D7 	; CALL UPPERCASEWORD
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,WORDCASE(A5) 	; LD (WORDCASE),A
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW06A
	BNE.S 	LAB.615 	;
	JMP 	CW06A(A5) 	;
LAB.615:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	#LONGC,D0 	; LD A,LONGC
	MOVE.W 	#STOREWORDDICTIONARY,D7 	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#UPPERCASEMARK,D0 	; LD A,UPPERCASEMARK
	MOVE.W 	#STOREWORDDICTIONARY,D7 	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
CW06A 	EQU	*-PRG.STRT 	;CW06A
*				;;
*				;;If character is preceeded by '/' it cannot be
*				;;character so it must be a short-escape or long-escape code.
*				;;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BTST 	#7,d0 	; BIT 7,A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,CW08 ;Normal char
	BNE.S 	LAB.616 	;
	JMP 	CW08(A5) 	;
LAB.616:
*				;;
*				;;Not an auto-case alpha so do an escape sequence
*				;;
CW07 	EQU	*-PRG.STRT 	;CW07 
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 	; RES 7,A
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
*				;;
*				;;Long escape sequence
*				;;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	#LONGC,D0 ; LD A,LONGC ;Long character escape code
	MOVE.W 	#STOREWORDDICTIONARY,D7	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W)
	ROR.B 	#5,D0 	; RRCA*5 
	AND.B 	#$07,D0 ; AND $07
	MOVE.W 	#STOREWORDDICTIONARY,D7 	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	AND.B 	#$1F,D0 	; AND $1F
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#STOREWORDDICTIONARY,D7 	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	CW09(A5) 	; JR CW09
*				;;
*				;;Not escaped, so if lower-case alpha it can be
*				;;represented as a 5-bit short-code, Otherwise use 
*				;;either a 10-bit short-escape or
*				;;15-bit long-escape code.
*				;;
CW08 	EQU	*-PRG.STRT 	;CW08
	MOVE.B 	WORDCASE(A5),D0 	; LD A,(WORDCASE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE 	F(A5),SR 	; CALL NZ,LOWER ;Called if upper-case-only marker used
	BEQ.S 	LAB.617 	;
	MOV 	#STOREWORDDICTIONARY,D7 	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
*				;;Move on to next character of word in Frequency Table.
*				;;
CW09 	EQU	*-PRG.STRT 	;CW09
	ADDQ.W 	#1,D1 	; INC HL
	SUB.W 	#$100,D2 	; DEC B
	JMP 	CW06(A5) 	; JR CW06
*				;;
*				;;-----
*				;;
*				;;HL is address within Frequency table of a word or part
*				;;or a word, BC is number of chars in re 	#STOREWORDDICTIONARY,D7 	; CALL STOREWORDDICTIONARY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
*				;;Move on to next character of word in Frequency Table.
*				;;
CW09 	EQU	*-PRG.STRT 	;CW09
	ADDQ.W 	#1,D1 	; INC HL
	SUB.W 	#$100,D2 	; DEC B
	JMP 	CW06(A5) 	; JR CW06
*				;;
*				;;-----
*				;;
*				;;HL is address within Frequency table of a word or part
*				;;or a word, BC is number of chars in remainder
*				;;Returns A non-zero if word is suitable for an
*				;;upper-case-only marker.
UPPERCASEWORD 	EQU	*-PRG.STRT 	;UPPERCASEWORD
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	#0,D3 	; LD E,0 ;Count of upper-case chars
UC01 	EQU	*-PRG.STRT 	;UC01
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,UC04
	BNE.S 	LAB.620 	;
	JMP 	UC04(A5) 	;
LAB.620:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#'a',D0 	; CP 'a'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,UC02
	BCC.S 	LAB.621 	;
	JMP 	UC02(A5) 	;
LAB.621:
	CMP.B 	#'z'+1,D0 	; CP 'z'+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,UC05 ;Contains lower-case
	BCC.S 	LAB.622 	;
	JMP 	UC05(A5) 	;
LAB.622:
UC02 	EQU	*-PRG.STRT 	;UC02
	CMP.B 	#'A',D0 	; CP 'A'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,UC03
	BCC.S 	LAB.623 	;
	JMP 	UC03(A5) 	;
LAB.623:
	CMP.B 	#'Z'+1,D0 	; CP 'Z'+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,UC03
	BCS.S 	LAB.624 	;
	JMP 	UC03(A5) 	;
LAB.624:
	ADDQ.B 	#1,D3 	; INC E ;Count of upper-case chars
UC03 	EQU	*-PRG.STRT 	;UC03
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	UC01(A5) 	; JR UC01
*				;;Found end of word with no lower-case, Check than
*				;;word contains enough upper-case
UC04 	EQU	*-PRG.STRT 	;UC04
	MOVE.B 	D3,D0 	; LD A,E
	CMP.B 	#2,D0 	; CP 2
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,UC05
	BCC.S 	LAB.625 	;
	JMP 	UC05(A5) 	;
LAB.625:
*				;;
*				;;Can be upper-case marked
	MOVE.B 	#1,D0 	; LD A,1
	JMP 	UC06(A5) 	; JR UC06
*				;;
*				;;Can't be upper-case-only marked
UC05 	EQU	*-PRG.STRT 	;UC05
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
*				;;
UC06 	EQU	*-PRG.STRT 	;UC06
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
GETWORDTEXT 	EQU	*-PRG.STRT 	;GETWORDTEXT
	ROR.W 	#8,D2 	; LD B,(HL) ;Entries length
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#3,D1 	; INC HL*3
	SUB.W 	#$300,D2 	; DEC B*3
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
STOREWORDDICTIONARY 	EQU	*-PRG.STRT
	MOVE.B 	D0,LASTBYTE(A5) 	; LD (LASTBYTE),A
	LEA 	READWRITEPOINTER(A5),A0 ; LD HL,(READWRITEPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	D0,0(a5,D1.W) 	; LD (HL),A - in program, so a5
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	READWRITEPOINTER(A5),A0 ; LD (READWRITEPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#UNPACK1+8,D3 	; LD DE,UNPACK1+8
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
; RET NZ
	BEQ.S 	LAB.626 	;
	JMP 	SYS.RET(A5) 	;
LAB.626:
	MOVE.W 	#UNPACK1,D1 	; LD HL,UNPACK1
	LEA 	READWRITEPOINTER(A5),A0 ; LD (READWRITEPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*;;
*;;Convert 8 short-codes to 5 bytes
*;;
	MOVE.W 	#DOCONVERSION,D7 	; CALL DOCONVERSION
	JSR 	SYS.JSR(A5) 	;
*;;
*;;Store all 5 bytes of 'PACK'ed buffer
*;;
	MOVE.W 	#PACK1,D1 	; LD HL,PACK1
	ROR.W 	#8,D2 		; LD B,5
	MOVE.B 	#5,D2 	;
	ROR.W 	#8,D2 	;
SD01 	EQU	*-PRG.STRT 	;SD01
	MOVE.B 	0(a5,D1.W),D0 	; LD A,(HL) - in program, so a5
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.W 	#SD01,D7 	; DJNZ SD01
	JSR 	SYS.DJNZ(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;
*;;Convert block of 8 short-codes to 5 bytes.
*;;
DOCONVERSION 	EQU	*-PRG.STRT 	;DOCONVERSION
	MOVE.B 	UNPACK1(A5),D0 	; LD A,(UNPACK1) ;000aaaaa
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	AND.B 	#$F8,D0 	; AND $F8
	ROR.W 	#8,D2 	; LD B,A ;aaaaa000
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	UNPACK2(A5),D0 	; LD A,(UNPACK2) ;000bbbbb
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	AND.B 	#$07,D0 	; AND $07 ;00000bbb
	ROR.W 	#8,D2 	; OR B
	OR$3E,D0 	; AND $3E ;00ccccc0 
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	UNPACK4(A5),D0 	; LD A,(UNPACK4) ;000ddddd
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	AND.B 	#$1,D0 	; AND $1 ;0000000d
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
*				;;Store bbcccccd
	MOVE.B 	D0,PACK2(A5) 	; LD (PACK2),A
	MOVE.B 	UNPACK4(A5),D0 	; LD A,(UNPA$3E,D0 	; AND $3E ;00ccccc0 
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	UNPACK4(A5),D0 	; LD A,(UNPACK4) ;000ddddd
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	AND.B 	#$1,D0 	; AND $1 ;0000000d
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
*				;;Store bbcccccd
	MOVE.B 	D0,PACK2(A5) 	; LD (PACK2),A
	MOVE.B 	UNPACK4(A5),D0 	; LD A,(UNPACK4) ;000ddddd
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	AND.B 	#$F0,D0 	; AND $F0
	ROR.W 	#8,D2 	; LD B,A ;dddd0000
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	UNPACK5(A5),D0 	; LD A,(UNPACK5) ;000eeeee
	ROR.B 	#1,D0 	; RRCA 
	AND.B 	#$0F,D0 	; AND $0F ;0000eeee
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
*				;;Store ddddeeee
	MOVE.B 	D0,PACK3(A5) 	; LD (PACK3),A
	MOVE.B 	UNPACK5(A5),D0 	; LD A,(UNPACK5) ;000eeeee
	ROR.B 	#1,D0 	; RRCA 
	AND.B 	#$80,D0 	; AND $80 ;e0000000
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	UNPACK6(A5),D0 	; LD A,(UNPACK6) ;000fffff
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	AND.B 	#$7C,D0 	; AND $7C ;0fffff00
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	UNPACK7(A5),D0 	; LD A,(UNPACK7) ;000ggggg
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	ROR.B 	#1,D0 	; RRCA 
	AND.B 	#$03,D0 	; AND $03 ;000000gg
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
*				;;Store efffffgg
	MOVE.B 	D0,PACK4(A5) 	; LD (PACK4),A
	MOVE.B 	UNPACK7(A5),D0 	; LD A,(UNPACK7) ;000ggggg
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	ADD.B 	D0,D0 	; ADD A,A
	AND.B 	#$E0,D0 	; AND $E0
	ROR.W 	#8,D2 	; LD B,A ;ggg00000
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	UNPACK8(A5),D0 	; LD A,(UNPACK8) ;000hhhhh
	AND.B 	#$1F,D0 	; AND $1F ;000hhhhh
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
*				;;Store ggghhhhh
	MOVE.B 	D0,PACK5(A5) 	; LD (PACK5),A
*				;;
*				;;(PACK1) thru (PACK5) contain 5 bytes
*				;;packed short-codes.
*				;;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;
*;;-----
*;;
*;;Unpack and Return bytes from Word Dictionary
*;;
GETDICTIONARYCODE 	EQU	*-PRG.STRT
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	LEA 	READWRITEPOINTER(A5),A0 ; LD HL,(READWRITEPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#UNPACK1+8,D3 	; LD DE,UNPACK1+8
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; CALL Z,RD01
	BNE.S 	LAB.627 	;
	MOVE.W 	#RD01,D7 	;
	JSR 	SYS.JSR(A5) 	;
LAB.627:
	LEA 	READWRITEPOINTER(A5),A0 ; LD HL,(READWRITEPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	0(a5,D1.W),D0 	; LD A,(HL) - in program, so a5
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	READWRITEPOINTER(A5),A0 ; LD (READWRITEPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
RD01 	EQU	*-PRG.STRT 	;RD01
	MOVE.W 	#UNPACK1,D1 	; LD HL,UNPACK1
	LEA 	READWRITEPOINTER(A5),A0 ; LD (READWRITEPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	BLOCKPOINTER(A5),A0 	; LD HL,(BLOCKPOINTER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#5,D2 	; LD BC,5
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	LEA 	BLOCKPOINTER(A5),A0 	; LD (BLOCKPOINTER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#PACK1,D3 	; LD DE,PACK1
	MOVE.W 	#5,D2 	; LD BC,5
	JSR 	SYS.LDIR(A5) 	; LDIR 
*				;;
	MOVE.B 	PACK1(A5),D0 	; LD A,(PACK1) ;aaaaabbb
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	AND.B 	#$1F,D0 	; AND $1F
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,UNPACK1(A5) 	; LD (UNPACK1),A ;000aaaaa
*				;;
	MOVE.B 	PACK1(A5),D0 	; LD A,(PACK1) ;aaaaabbb
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	AND.B 	#$1C,D0 	; AND $1C
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	PACK2(A5),D0 	; LD A,(PACK2) ;bbcccccd
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MCK3),A ;000ccccc
*				;;
	MOVE.B 	PACK2(A5),D0 	; LD A,(PACK2) ;bbcccccd
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	AND.B 	#$10,D0 	; AND $10
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	PACK3(A5),D0 	; LD A,(PACK3) ;ddddeeee
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.CK3),A ;000ccccc
*				;;
	MOVE.B 	PACK2(A5),D0 	; LD A,(PACK2) ;bbcccccd
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	AND.B 	#$10,D0 	; AND $10
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	PACK3(A5),D0 	; LD A,(PACK3) ;ddddeeee
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	AND.B 	#$0F,D0 	; AND $0F
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D0,UNPACK4(A5) 	; LD (UNPACK4),A ;000ddddd
*				;;
	MOVE.B 	PACK3(A5),D0 	; LD A,(PACK3) ;ddddeeee
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	AND.B 	#$1E,D0 	; AND $1E
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	PACK4(A5),D0 	; LD A,(PACK4) ;efffffgg
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	AND.B 	#$1,D0 	; AND $1
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D0,UNPACK5(A5) 	; LD (UNPACK5),A ;000eeeee
*				;;
	MOVE.B 	PACK4(A5),D0 	; LD A,(PACK4) ;efffffgg
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	AND.B 	#$1F,D0 	; AND $1F
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,UNPACK6(A5) 	; LD (UNPACK6),A ;0000fffff
*				;;
	MOVE.B 	PACK4(A5),D0 	; LD A,(PACK4) ;efffffgg
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	AND.B 	#$18,D0 	; AND $18
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	PACK5(A5),D0 	; LD A,(PACK5) ;ggghhhhh
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	ROR.B 	#1,D0 	; RRCA 
	MOVE 	SR,F(A5) 	;
	AND.B 	#$07,D0 	; AND $07
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; OR B
	OR.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D0,UNPACK7(A5) 	; LD (UNPACK7),A ;000ggggg
*				;;
	MOVE.B 	PACK5(A5),D0 	; LD A,(PACK5) ;ggghhhhh
	AND.B 	#$1F,D0 	; AND $1F
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,UNPACK8(A5) 	; LD (UNPACK8),A ;000hhhhh
*				;;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;'Word Dictionary' larger than
*				;;'Sorted Message Table'.
*				;;
WDFULL 	EQU	*-PRG.STRT 	;WDFULL
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"'Word Dictionary' full." 	; DEFM "'Word Dictionary' full."
	DC.B 	0 	; DEFB 0
 even
	JMP 	EXITCPM(A5) 	; JP EXITCPM
*;;
*;;-----
*;;
*;;Phase 8 - Construct 'Word Dictionary Index'
*;;
*;;Reads the SEGMENTADDRESSES table built by the
*;;'Construct Word Dictionary' phase and builds the 'Word
*;;Dictionary Index' between addresses (STARTWDI) and (ENDMEMORY)
*;;
*;;The current top of this table is (ENDWDI).
*;;
*;;-----
*;;
PHASE08 	EQU	*-PRG.STRT 	;PHASE08
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 8 - Construct 'Word Dictionary Index'" 	;
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0 
 even
*				;;
*				;;Clear table
*				;;
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	NUMSEGS(A5),A0 	; LD (NUMSEGS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*;;
*;;Copy each entry from SEGMENTADDRESSES subtracting start
*;;address of 'Word Dictionary' to give offset.
*;;
	MOVE.W 	#SEGMENTADDRESSES,D1 	; LD HL,SEGMENTADDRESSES
PH01 	EQU	*-PRG.STRT 	;PH01
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	LASTPOINTER(A5),A0 	; LD DE,(LASTPOINTER)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,PH02
	BNE.S 	LAB.628 	;
	JMP 	PH02(A5) 	;
LAB.628:
*;;
*;;Get address of byte-aligned boundary
*;;
	MOVE.B 	0(a4,D1.W),D3 	; LD E,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D3 	; LD D,(HL)
	MOVE.B 	0(a4,D1.W),D3 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INLD A,C
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	NUMSEGS(A5),A0 	; LD HL,(NUMSEGS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMSEGS(A5),A0 	; LD (NUMSEGS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
*				;;Move on to next entryLD A,C
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	NUMSEGS(A5),A0 	; LD HL,(NUMSEGS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMSEGS(A5),A0 	; LD (NUMSEGS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
*				;;Move on to next entry
*				;;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	PH01(A5) 	; JR PH01
*				;;
*				;;(Optional) Display length of table
*				;;
PH02 	EQU	*-PRG.STRT 	;PH02
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS,D2 	; LD BC,LENGTHPOINTERS
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	LEA 	INDEXWDI(A5),A0 	; LD (INDEXWDI),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.629 	;
	JMP 	SYS.RET(A5) 	;
LAB.629:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Length of 'Word Dictionary Index' =" 	; DEFM "Length of 'Word Dictionary Index' ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	INDEXWDI(A5),A0 	; LD HL,(INDEXWDI)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	INDEXWD(A5),A0 	; LD DE,(INDEXWD)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*				;;
*				;;Option to display Segment Table Index removed:
*				;;too difficult when writing SQUASH file 'on-the-fly'
*				;;Original listing not usefull anyway.
*				;;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;Phase 9 - Build Squash File
*				;;
*				;;Move 'Common Word Index' to be above 'Dictionary Index'
*				;;then build the 'Squash' file and save it.
*				;;
*				;;-----
*				;;
PHASE09 	EQU	*-PRG.STRT 	;PHASE09
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 9 - Build Squash File"
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0 
 even
*;;
*;;Save CWT to ICF
*;;
	LEA 	STARTCWT(A5),A0 	; LD HL,(STARTCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
PI01 	EQU	*-PRG.STRT 	;PI01
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	ENDCWT(A5),A0 	; LD DE,(ENDCWT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,PI02
	BNE.S 	LAB.630 	;
	JMP 	PI02(A5) 	;
LAB.630:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#WRITESERIALICF,D7 	; CALL WRITESERIALICF
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	PI01(A5) 	; JR PI01
*				;;
PI02 	EQU	*-PRG.STRT 	;PI02
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*;;
*;;Close B:SQUASH2.TMP (ICF)
*;;
;	MOVE.W 	#ENDSERIALICF,D7 	; CALL ENDSERIALICF
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.B 	#$D,D0 	; LD A,$D
;	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
;	JSR 	SYS.JSR(A5) 	;
;*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Reading B:SQUASH2.TMP ..." 	; DEFM "Reading B:SQUASH2.TMP ..."
	DC.B 	$D,0 	; DEFB $D,0
 even
;	MOVE.W 	#CLEARFCB,D7 	; CALL CLEARFCB
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#NAMEICF,D1 	; LD HL,NAMEICF
;	MOVE.W 	#SYSTEMFCBDRIVE,D3 	; LD DE,SYSTEMFCBDRIVE
;	MOVE.W 	#12,D2 	; LD BC,12
;	JSR 	SYS.LDIR(A5) 	; LDIR 
;	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input File Control Block
;	MOVE.W 	#OPENSERIALREAD,D7 	; CALL OPENSERIALREAD
;	JSR 	SYS.JSR(A5) 	;
;	MOVE 	F(A5),SR 	; JR NC,PI03
;	BCS.S 	LAB.631 	;
;	JMP 	PI03(A5) 	;
;LAB.631:
;*				;;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"Can't read B:SQUASH2.TMP" 	; DEFM "Can't read B:SQUASH2.TMP"
;	DC.B 	$D,0 	; DEFB $D,0
; even
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
;*				;;
PI03 	EQU	*-PRG.STRT 	;PI03
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,FINALCHECKSUM(A5) 	; LD (FINALCHECKSUM),A
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Writing B:SQUASH.DAT ..." 	; DEFM "Writin632 	;
;	JMP 	PI04(A5) 	;
;LAB.632:
;*				;;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"Can't create B:SQUASH.DAT" 	; DEFM "Can't create B:SQUASH.DAT"
;	DC.B 	$D,0 	; DEFB $D,0
; even
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
PI04 	EQU	*-PRG.STRT 	;PI04
*;;
*;;Write Header/Pointers:
*;;
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS+1,D3 	; LD DE,LENGTHPOINTERS+1 ;Include heade632 	;
;	JMP 	PI04(A5) 	;
;LAB.632:
;*				;;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"Can't create B:SQUASH.DAT" 	; DEFM "Can't create B:SQUASH.DAT"
;	DC.B 	$D,0 	; DEFB $D,0
; even
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
PI04 	EQU	*-PRG.STRT 	;PI04
*;;
*;;Write Header/Pointers:
*;;
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS+1,D3 	; LD DE,LENGTHPOINTERS+1 ;Include header+checksum
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
*;;HL = Length of file
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#LENGTHPOINTERS,D1 	; LD HL,LENGTHPOINTERS
*;;HL = Offset to Message Descriptors
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	LENGTHMD(A5),A0 	; LD HL,(LENGTHMD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*;;HL = Length of Message Descriptors
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	INDEXMD(A5),A0 	; LD HL,(INDEXMD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*;;HL = Offset to Word Dictionary
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	LENGTHWD(A5),A0 	; LD HL,(LENGTHWD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*;;HL = Length of Word Dictionary
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	INDEXWD(A5),A0 	; LD HL,(INDEXWD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*				;;HL = Offset to Dictionary Index
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	NUMSEGS(A5),A0 	; LD BC,(NUMSEGS)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
*				;;BC = Number of Segments
	MOVE.B 	D2,D0 	; LD A,C
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	INDEXWDI(A5),A0 	; LD HL,(INDEXWDI)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
*				;;HL = Offset to Common Word Index
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.B 	#MINOR,D0 	; LD A,MINOR
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH ;Version number
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#MAJOR,D0 	; LD A,MAJOR
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*				;;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*;;
*;;Copy ICF file (squash2.tmp) to Squash file
*;;

; OPEN SQUASH2.TMP for read
 move.l startfilebuffer(a5),a3
 add.l #spaceforsquashdat,a3
; space allowed when writing for squash.dat file

	LEA 	LENGTHICF(A5),A0 ; LD BC,(LENGTHICF)
;Number of bytes to copy
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
PI05 	EQU	*-PRG.STRT 	;PI05	
	tst.w d2 ; ld a,b; or c; JR Z,PI07
	BNE.S 	LAB.633 	;
	JMP 	PI07(A5) 	;
LAB.633:
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
;	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input File Control Block

	MOVE.W 	#SERIALREADBYTE,D7 	; CALL SERIALREADBYTE
	JSR 	SYS.JSR(A5) 	;
;	MOVE 	F(A5),SR 	; JR NC,PI06 ;Ok
;	BCS.S 	LAB.634 	;
;	JMP 	PI06(A5) 	;
;LAB.634:
;*				;;
;	MOVE.W 	#squasherprs,D7 ; CALL CLOSESERIALWRITE
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#DELETESYSTEM,D7 	; CALL DELETESYSTEM ;Delete B:SQUASH.DAT
;	JSR 	SYS.JSR(A5) 	;
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
PI06 	EQU	*-PRG.STRT 	;PI06
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	PI05(A5) 	; JR PI05
PI07 	EQU	*-PRG.STRT 	;PI07
*				;;
*				;;Write checksum
*				;;
	MOVE.B 	FINALCHECKSUM(A5),D0 	; LD A,(FINALCHECKSUM)
; CALL CLOSESERIALWRITE
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#DELETESYSTEM,D7 	; CALL DELETESYSTEM ;Delete B:SQUASH.DAT
;	JSR 	SYS.JSR(A5) 	;
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
PI06 	EQU	*-PRG.STRT 	;PI06
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	PI05(A5) 	; JR PI05
PI07 	EQU	*-PRG.STRT 	;PI07
*				;;
*				;;Write checksum
*				;;
	MOVE.B 	FINALCHECKSUM(A5),D0 	; LD A,(FINALCHECKSUM)
	NEG.B 	D0 	; NEG 
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
*;;
*;;(Optional) Pad file to be a multiple of 256 bytes long
*;;
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS+1,D3 	; LD DE,LENGTHPOINTERS+1
	ADD.W 	D3,D1 	; ADD HL,DE ;Bytes written so far
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D1,D0 	; LD A,L
PI08 	EQU	*-PRG.STRT 	;PI08
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PI09
	BNE.S 	LAB.635 	;
	JMP 	PI09(A5) 	;
LAB.635:
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#WRITESQUASH,D7 	; CALL WRITESQUASH
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	ADDQ.B 	#1,D0 	; INC A
	JMP 	PI08(A5) 	; JR PI08
*;;
*;;Close all files
*;;
PI09 	EQU	*-PRG.STRT 	;PI09
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"... close" 	; DEFM "... close"
	DC.B 	$D,0 	; DEFB $D,0
 even
	MOVE.W 	#FCB2,D1 	; LD HL,FCB2
	MOVE.W 	#CLOSESERIALWRITE,D7 	; CALL CLOSESERIALWRITE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"... eof" 	; DEFM "... eof"
	DC.B 	$D,$D,0 	; DEFB $D,$D,0
 even
; (68000 only)
; now write out squash.dat to disk...
 lea savesquashdatdriverblock,a6
 move.l a2,$4(a6) ; current write pointer points to end
 move.l startfilebuffer(a5),(a6)
 move.b #savedcode,d0
 jsr driver

	MOVE.W 	#FCB1,D1 	; LD HL,FCB1
;	MOVE.W 	#CLOSESERIALREAD,D7 	; CALL CLOSESERIALREAD
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#DELETESYSTEM,D7 	; CALL DELETESYSTEM ;Delete B:SQUASH2.TMP
;	JSR 	SYS.JSR(A5) 	;
*				;;
*				;;Print Statistics
*				;;
	MOVE.W 	#DISPLAYINPUTNAME,D7 	; CALL DISPLAYINPUTNAME
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"file length =" 	; DEFM "file length ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	INPUTLENGTH(A5),A0 	; LD HL,(INPUTLENGTH)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"Number of characters = " 	; DEFM "Number of characters = "
	DC.B 	0 	; DEFB 0
 even
	LEA 	NUMCHARACTERS(A5),A0 	; LD HL,(NUMCHARACTERS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	". Number of words = " 	; DEFM ". Number of words = "
	DC.B 	0 	; DEFB 0
 even
	LEA 	NUMWORDS(A5),A0 	; LD HL,(NUMWORDS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	'.',ASCIICR 	; DEFB '.',ASCIICR
	DC.B 	"Low memory used  =" 	; DEFM "Low memory used  ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	MAXMDT(A5),A0 	; LD HL,(MAXMDT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTFT(A5),A0 	; LD DE,(STARTFT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	$D 	; DEFB $D
	DC.B 	"High memory used =" 	; DEFM "High memory used ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTBUFFER(A5),A0 	; LD DE,(STARTBUFFER)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" Free =" 	; DEFM " Free ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),Dn
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS+1,D3 	; LD DE,LENGTHPOINTERS+1
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Compressed size of message descriptors = " 	;
	n
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS+1,D3 	; LD DE,LENGTHPOINTERS+1
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Compressed size of message descriptors = " 	;
	DC.B 	0 	; DEFB 0
 even
	LEA 	LENGTHMD(A5),A0 	; LD HL,(LENGTHMD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Compressed size of word dictionary     = " 	; 
	DC.B 	0 	; DEFB 0
 even
	LEA 	LENGTHWD(A5),A0 	; LD HL,(LENGTHWD)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Compression = " 	; DEFM "Compression = "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	#CALCCOMPRESSION,D7 	; CALL CALCCOMPRESSION
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	'%',ASCIICR,0 	; DEFB '%',ASCIICR,0
 even
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
WRITESQUASH 	EQU	*-PRG.STRT 	;WRITESQUASH
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	D0,D1 	; LD L,A
	MOVE.B 	FINALCHECKSUM(A5),D0 	; LD A,(FINALCHECKSUM)
	ADD.B 	D1,D0 	; ADD A,L
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,FINALCHECKSUM(A5) 	; LD (FINALCHECKSUM),A
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
*				;;
;	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;File output Control Block
	MOVE.W 	#SERIALWRITEBYTE,D7 	; CALL SERIALWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
;	MOVE 	F(A5),SR 	; JP C,WRITESQUASH01
;	BCC.S 	LAB.636 	;
;	JMP 	WRITESQUASH01(A5) 	;
LAB.636:
*				;;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
;WRITESQUASH01 	EQU	*-PRG.STRT 	;WRITESQUASH01
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	$D 	; DEFB $D
;	DC.B 	"Error writing B:SQUASH.DAT" 	; DEFM "Error writing B:SQUASH.DAT"
;	DC.B 	$D,0 	; DEFB $D,0
; even
;	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
*				;;-----
*				;;
OUTPUT 	EQU	*-PRG.STRT 	;OUTPUT
	DC.B 	2 	; DEFB 2 ;Drive B:
	DC.B 	"SQUASH  " 	; DEFM "SQUASH  "
	DC.B 	"DAT" 	; DEFM "DAT"
 even
*				;;
*				;;-----
*				;;
CALCCOMPRESSION 	EQU	*-PRG.STRT 	;CALCCOMPRESSION
	LEA 	LENGTHICF(A5),A0 	; LD HL,(LENGTHICF)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#LENGTHPOINTERS+1,D3 	; LD DE,LENGTHPOINTERS+1
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
*				;;
	LEA 	NUMCHARACTERS(A5),A0 	; LD BC,(NUMCHARACTERS) ;B=Hi byte of input file length
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	MOVE.W 	#DIVIDE,D7 	; CALL DIVIDE ;HL=HL/B
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; LD B,100 ;HL=DE*100
	MOVE.B 	#100,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#0,D1 	; LD HL,0
CALC1 	EQU	*-PRG.STRT 	;CALC1
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#CALC1,D7 	; DJNZ CALC1
	JSR 	SYS.DJNZ(A5) 	;
	ROR.W 	#8,D1 	; LD L,H ;HL=HL/256
	MOVE.B 	D1,D7 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D7,D1 	;
	ROR.W 	#8,D1 	; LD H,0
	MOVE.B 	#0,D1 	;
	ROR.W 	#8,D1 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
DIVIDE 	EQU	*-PRG.STRT 	;DIVIDE
*				;;HL=HL/B
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,ZERO
	BNE.S 	LAB.637 	;
	JMP 	ZERO(A5) 	;
LAB.637:
	MOVE.W 	#0,D3 	; LD DE,0 ;Result
DIV1 	EQU	*-PRG.STRT 	;DIV1
	MOVE.B 	D1,D0 	; LD A,L
	ROR.W 	#8,D2 	; SUB B
	SUB.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D0,D1 	; LD L,A
	MOVE 	F(A5),SR 	; JR NC,DIV2
	BCS.S 	LAB.638 	;
	JMP 	DIV2(A5) 	;
LAB.638:
	SUB.W 	#$100,D1 	; DEC H
	********
*
SYS.JSR EQU     *-PRG.STRT      Subroutine Jump:
        MOVE.L  (SP)+,A0        Get return link
        SUBA.L  a5,A0           Make relative to A5
        SUBQ.W  #2,D6           Decrease Z80 SP
        MOVE.W  A0,0(a4,D6.W)   Push link
        JMP     0(a5,D7.W)      Jump via rel. address in D7
*
SYS.RET EQU     *-PRG.STRT      Subroutine Return:
        MOVE.W  0(a4,D6.W),D7   Put link in D7
        ADDQ.W  #2,D6           Adjust Z80 SP
        JMP     0(a5,D7.W)      Return
*
S********
*
SYS.JSR EQU     *-PRG.STRT      Subroutine Jump:
        MOVE.L  (SP)+,A0        Get return link
        SUBA.L  a5,A0           Make relative to A5
        SUBQ.W  #2,D6           Decrease Z80 SP
        MOVE.W  A0,0(a4,D6.W)   Push link
        JMP     0(a5,D7.W)      Jump via rel. address in D7
*
SYS.RET EQU     *-PRG.STRT      Subroutine Return:
        MOVE.W  0(a4,D6.W),D7   Put link in D7
        ADDQ.W  #2,D6           Adjust Z80 SP
        JMP     0(a5,D7.W)      Return
*
SYS.DJNZ EQU    *-PRG.STRT      Z80 DJNZ:
        ROR.W   #8,D2           Access B
        SUBQ.B  #1,D2           Decrease B
        BEQ.S   S.DJNZ1         Branch if B zero ...
        ADDQ.L  #4,SP           Otherwise ... remove link
        ROR.W   #8,D2           Restore BC
        JMP     0(a5,D7.W)      Jump to label in D7
S.DJNZ1 ROR.W   #8,D2           B zero ... restore BC
        RTS                     Return via link on stack
*
SYS.LDIR EQU    *-PRG.STRT      Z80 LDIR:
S.LDIR
	MOVE.B  0(a4,D1.W),0(a4,D3.W)  Common routine - move byte
	ADDQ.W  #1,D1           Adjust HL
        ADDQ.W  #1,D3           Adjust DE
        SUBQ.W  #1,D2           Decrement BC
        BNE.S   S.LDIR        Loop if BC not zero
        AND.B   #29,F+1(A5)     Reset overflow bit
        RTS                     Return
*
SYS.LDDR EQU    *-PRG.STRT      Z80 LDDR:
S.LDDR
	MOVE.B  0(a4,D1.W),0(a4,D3.W)
        SUBQ.W  #1,D1           Adjust HL
        SUBQ.W  #1,D3           Adjust DE
        SUBQ.W  #1,D2           Decrement BC
        BNE.S   S.LDDR        Loop if BC not zero
        AND.B   #29,F+1(A5)     Reset overflow bit
        RTS                     Return
*
SYS.LDI EQU     *-PRG.STRT      Z80 LDI:
        MOVE.B  0(a4,D1.W),0(a4,D3.W)  Move byte
        ADDQ.W  #1,D1           Increment HL
        ADDQ.W  #1,D3           Increment DE
        BRA.S   S.LDID          Go to Common routine
*
SYS.LDD EQU     *-PRG.STRT      Z80 LDD:
        MOVE.B  0(a4,D1.W),0(a4,D3.W)  Move byte
        SUBQ.W  #1,D1           Decrement HL
        SUBQ.W  #1,D3           Decrement DE
S.LDID  SUBQ.W  #1,D2           Common routine - Decrement BC
        BEQ.S   S.LDID1         Test for BC zero
        OR.B    #2,F+1(A5)      Set overflow if BC non-zero
        RTS                     Return
S.LDID1 AND.B   #29,F+1(A5)     Reset overflow if BC zero
        RTS                     Return
*
SYS.CPIR EQU    *-PRG.STRT      Z80 CPIR:
        MOVEQ   #1,D7           Set D7 to increment
        BRA.S   S.CPIDR         Go to common routine
*
SYS.CPDR EQU    *-PRG.STRT      Z80 CPDR:
        MOVEQ   #-1,D7          Set D7 to increment
S.CPIDR AND.B   #17,F+1(A5)     Common routine - reset sign,zero,overflow
S.CPIDR1 CMP.B  0(a4,D1.W),D0   Loop - compare (HL) with A
        BEQ.S   S.CPIDR2        Exit if equal
        ADD.W   D7,D1           Adjust HL
        SUBQ.W  #1,D2           Decrement BC
        BNE.S   S.CPIDR1        Loop if BC non-zero
        BRA.S   S.CPIDR3        Otherwise go to common return
S.CPIDR2 OR.B   #4,F+1(A5)      Match found - Set zero flag
        SUBQ.W  #1,D2           Decrement BC once more
        BNE.S   S.CPIDR3        Take common return if more
        OR.B    #2,F+1(A5)      Set sign flag if last byte
S.CPIDR3 ADD.W  D7,D1           Common return - move HL on
        RTS                     Return
*
SYS.CPI EQU     *-PRG.STRT      Z80 CPI:
        MOVE.B  0(a4,D1.W),D7   Move byte to D7
        ADDQ.W  #1,D1           Increment HL
        BRA.S   S.CPID          Go to common routine
*
SYS.CPD EQU     *-PRG.STRT      Z80 CPD:
        MOVE.B  0(a4,D1.W),D7   Move byte to D7
        SUBQ.W  #1,D1           Decrement HL
S.CPID  AND.B   #17,F+1(A5)     Common routine - reset sign,zero,overflow
        SUBQ.W  #1,D2           Decrement BC
        BNE.S   S.CPID1         Test for BC zero
        OR.B    #2,F+1(A5)      BC zero - set overflow
S.CPID1 CMP.B   D7,D0           Compare bytes
        BNE.S   S.CPID2         Test for equal
        OR.B    #4,F+1(A5)      Bytes match - set sign
S.CPID2 RTS                     Return
*
SYS.EXX EQU     *-PRG.STRT      Z80 EXX:
        MOVEM.W D1-D3,-(SP)     Save HL BC DE on stack
        MOVEM.W ALT.REGS+2(A5),D1-D3  Restore alt. reg. set
        MOVE.L  (SP)+,ALT.REGS+2(A5)  Shift saved values
        MOVE.W  (SP)+,ALT.REGS+6(A5)
        RTS                     Return
*
SYS.EXAF EQU    *-PRG.STRT      Z80 EX AF,AF':
        MOVE.B  D0,F(A5)        Move A
        MOVE.W  F(A5),-(SP)     Stack AF
  T
SYS.RRD EQU     *-PRG.STRT
*
SYS.RST EQU     *-PRG.STRT      Embryo Z80 RST routine:
* ........ operand value is in D7 .....................
* ........ fill in with code as required ..............
        RTS
*
savesquashdatdriverblock
 dc.l 0 * start file
 dc.l 0 * end file
 dc.b "squash.dat",0
 even


ееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееееT
SYS.RRD EQU     *-PRG.STRT
*
SYS.RST EQU     *-PRG.STRT      Embryo Z80 RST routine:
* ........ operand value is in D7 .....................
* ........ fill in with code as required ..............
        RTS
*
savesquashdatdriverblock
 dc.l 0 * start file
 dc.l 0 * end file
 dc.b "squash.dat",0
 even


