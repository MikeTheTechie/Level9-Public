*;;MESSAGE.TXT to SQUASH.DAT compresser
*;;
*;; 12/08/86
*;;
*;;STAGE1.Z80
*;;
*;;-----
*;;
*;;Phase 1 - Load B:MESSAGE.TXT
*;;
*;;Load B:MESSAGE.TXT at address STARTTABLEMEMORY ($3000)
*;;Copy the file up to the top of memory.
*;;(STARTINPUTFILE) is the address of the start of this
*;;
*;;-----
*;;
PHASE01 	EQU	*-PRG.STRT 	;PHASE01
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5)
	jsr prs
	DC.B 	"Phase 1 - Clear memory",15
	DC.B 	ASCIICR,ASCIICR,0
 even
*				;;
*				;;Clear entire table area
*				;;
	MOVE.W 	#STARTTABLEMEMORY,D1 	; LD HL,STARTTABLEMEMORY
	MOVE.W 	#STARTTABLEMEMORY+1,D3 	; LD DE,STARTTABLEMEMORY+1
	MOVE.B 	#ASCIIEOF,0(a4,D1.W) 	; LD (HL),ASCIIEOF
 MOVE.W #60000,D2 ; SIZE OF MEMORY BLOCK
; *******	JSR 	SYS.LDIR(A5) 	; LDIR 
*				;;
	JMP 	RESET(A5) 	; JP RESET ;Clear RAM directory
*				;;
*				;;-----
*				;;
*				;;Phase 2 - Sort messages
*	;;
*	;;Phase 2 read the file B:MESSAGE.TXT serially and creates
*	;;the 'Sorted Message Table' - A list of all messages in
*	;;numeric order.
*	;;
*	;;B:MESSAGE.TXT is read serially by SERIALREADBYTE
*	;;and written to B:SQUASH.TMP by SERIALWRITEBYTE
*	;;
*	;;Each 'Sorted Message' entry starts with a six-byte
*	;;header giving the length of the header (2 bytes), the
*	;;message number (2 bytes) and the B:MESSAGE.TXT line
*	;;number (2 bytes) for error messages.
*	;;
*	;;Comments, '[' and ']' are discarded.
*	;;
*	;;-----
*				;;
PHASE02 	EQU	*-PRG.STRT 	;PHASE02
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 2 - Sort into message number order" 	; ...
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Squashing. Please wait." 	; DEFM "Squashing. Please wait."
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*;;
*;;Initialise 'Sorted Message Table'
*;;
	MOVE.W 	#1,D1 	; LD HL,1 ;Line in source file
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#$0,D1 	; LD HL,$0 
;After auto-increment first message is number 1
	LEA 	MSGNUM(A5),A0 	; LD (MSGNUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	NUMCHARACTERS(A5),A0 	; LD (NUMCHARACTERS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	LENGTHSMT(A5),A0 	; LD (LENGTHSMT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	INPUTLENGTH(A5),A0 	; LD (INPUTLENGTH),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	MODIFYCOUNT(A5),A0 	; LD (MODIFYCOUNT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	#0,D0 	; LD A,0
	MOVE.B 	D0,SEENCOMMENT(A5) 	; LD (SEENCOMMENT),A
*				;;
*				;;Open B:MESSAGE.TXT for reading
*				;;
;	MOVE.W 	#INITSERIALINPUT,D7 	; CALL INITSERIALINPUT
;	JSR 	SYS.JSR(A5) 	;
 move.l startfilebuffer(a5),a3 * stays as current pointer
; to current file input throughout
 move.l a3,a2 ; stays as current write pointer throughout
 lea loadmessagedriverblock,a6
 move.l a3,(a6) ; load addresss
 move.b #loaddcode,d0
 bsr driver
 move.l $4(a6),d0 ; end address ?
 bne.s pb01openedok
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Can't read" 	; DEFM "Can't read"
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	#DISPLAYINPUTNAME,D7 	; CALL DISPLAYINPUTNAME
	JSR 	SYS.JSR(A5) 	;
	JMP 	EXITCPM(A5) 	; JP EX 	SYS.LDIR(A5) 	; LDIR 
;*				;;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"Writing " 	; DEFM "Writing "
;	DC.B 	0 	; DEFB 0
; even
;	MOVE.W 	#DISPLAYTEMPNAME,D7 	; CALL DISPLAYTEMPNAME
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"..." 	; DEFM "..."
;	DC.B 	$D,0 	; DEFB $D,0
; even
;*				;;
;	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;Output control block
;	MOVE.W 	#OPENSERIALWRITE,D7 	; CALL OPENSERIALWRITE
;	JSR  	SYS.LDIR(A5) 	; LDIR 
;*				;;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"Writing " 	; DEFM "Writing "
;	DC.B 	0 	; DEFB 0
; even
;	MOVE.W 	#DISPLAYTEMPNAME,D7 	; CALL DISPLAYTEMPNAME
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
;	JSR 	SYS.JSR(A5) 	;
;	DC.B 	"..." 	; DEFM "..."
;	DC.B 	$D,0 	; DEFB $D,0
; even
;*				;;
;	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;Output control block
;	MOVE.W 	#OPENSERIALWRITE,D7 	; CALL OPENSERIALWRITE
;	JSR 	SYS.JSR(A5) 	;
 move.l startfilebuffer(a5),a2 * write pointer

	MOVE.W 	#SORTFILE,D7 	; CALL SORTFILE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#ENDSERIALINPUT,D7 	; CALL ENDSERIALINPUT
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"... close" 	; DEFM "... close"
	DC.B 	$D,$D,0 	; DEFB $D,$D,0
 even
	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;Output control block
	MOVE.W 	#CLOSESERIALWRITE,D7 	; CALL CLOSESERIALWRITE
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP C,squasherwriteerror
	BCC.S 	LAB.203 	;
	JMP 	squasherwriteerror(A5) 	;
LAB.203:
*;;
*;;(Optional) Display length of SMT (B:SQUASH1.TMP)
*;;
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.204 	;
	JMP 	SYS.RET(A5) 	;
LAB.204:
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Length of SMT (B:SQUASH1.TMP) =" 	; DEFM "Length of SMT (B:SQUASH1.TMP) ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	LENGTHSMT(A5),A0 	; LD HL,(LENGTHSMT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
*				;;
*				;;(Optional) Display sorted messages
*				;;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,PB05
	BEQ.S 	LAB.205 	;
	JMP 	PB05(A5) 	;
LAB.205:
*				;;
	MOVE.W 	#$0,D1 	; LD HL,$0
	LEA 	NUMMESSAGES(A5),A0 	; LD (NUMMESSAGES),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1
*
	MOVE.W 	#INITSERIALSMT,D7 	; CALL INITSERIALSMT
	JSR 	SYS.JSR(A5)
PB03 	EQU	*-PRG.STRT 		;PB03
	MOVE.W 	#ENDSERIALSMT,D7 	; CALL ENDSERIALSMT
	JSR 	SYS.JSR(A5)
	MOVE 	F(A5),SR 		; JR Z,PB04 ;End of file
	BNE.S 	LAB.206
	JMP 	PB04(A5)
LAB.206:
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
	MOVE.W 	#DISPLAYSORTEDMESSAGE,D7 ; CALL DISPLAYSORTEDMESSAGE
	JSR 	SYS.JSR(A5)
	MOVE.W 	#NEXTSERIALSMT,D7 	; CALL NEXTSERIALSMT
	JSR 	SYS.JSR(A5)
	LEA 	NUMMESSAGES(A5),A0 	; LD BC,(NUMMESSAGES)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2
	ADDQ.W 	#1,D2 			; INC BC
	LEA 	NUMMESSAGES(A5),A0 	; LD (NUMMESSAGES),BC
	MOVE.B 	D2,(A0)
	ROR.W 	#8,D2
	MOVE.B 	D2,1(A0)
	ROR.W 	#8,D2
	JMP 	PB03(A5) 		; JR PB03
PB04 	EQU	*-PRG.STRT 		;PB04
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5)
	DC.B 	ASCIICR
	DC.B 	"Number of messages = "
	DC.B 	0 	; DEFB 0
 even
	LEA 	NUMMESSAGES(A5),A0 	; LD HL,(NUMMESSAGES)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*				;;
PB05 	EQU	*-PRG.STRT 	;PB05
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Number of modifications =" 	; DEFM "Number of modifications ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	MODIFYCOUNT(A5),A0 	; LD HL,(MODIFYCOUNT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYHLBOTH,D7 	; CALL DISPLAYHLBOTH
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"Number of text characters =" 	; DEFM "Number of text characters ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	NUMCHARACTERS(A5),A0 	; LD HL,(NUMCHARACTERS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYHLBOTH,D7 	; CALL DISPLAYHLBOTH
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	JMP 	NEWLINE(A5) 	; JP NEWLINE
*				;;
*				;;-----
*				;;
squasherwriteerror 	EQU	*-PRG.STRT 	;squasherwriteerror
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR
	DC.B 	"Error writing " 	; DEFM "E7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Unexpected EOF" 	; DEFM "Unexpected EOF"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
INVALIDNUMBER 	EQU	*-PRG.STRT 	;INVALIDNUMBER
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal message number" 	; DEFM "Illegal message number"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
P2BADWOR7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Unexpected EOF" 	; DEFM "Unexpected EOF"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
INVALIDNUMBER 	EQU	*-PRG.STRT 	;INVALIDNUMBER
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal message number" 	; DEFM "Illegal message number"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
P2BADWORDTYPE 	EQU	*-PRG.STRT 	;P2BADWORDTYPE
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Mis-use of special character '^'" 	; DEFM "Mis-use of special character '^'"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
P2BADSLASH 	EQU	*-PRG.STRT 	;P2BADSLASH
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Mis-use of special character '/'" 	; DEFM "Mis-use of special character '/'"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART 
*				;;
P2BADOPEN 	EQU	*-PRG.STRT 	;P2BADOPEN ;> 12/08/86
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs ;> 12/08/86
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Mis-use of special character '['" 	; DEFM "Mis-use of special character '['"
	DC.B 	0 	; DEFB 0 ;> 12/08/86
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WAMRSTART
*				;;
P2BADCLOSE 	EQU	*-PRG.STRT 	;P2BADCLOSE ;> 12/08/86
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs ;> 12/08/86
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Mis-use of special character ']'" 	; DEFM "Mis-use of special character ']'"
	DC.B 	0 	; DEFB 0 ;> 12/08/86
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
ILLEGALCHAR 	EQU	*-PRG.STRT 	;ILLEGALCHAR
	SUBQ.W 	#2,D6 	; PUSH AF ;Character code
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal character $" 	; DEFM "Illegal character $"
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	MOVE.W 	#DISPLAYAHEX,D7 	; CALL DISPLAYAHEX
	JSR 	SYS.JSR(A5) 	;
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
BADNEWLINE 	EQU	*-PRG.STRT 	;BADNEWLINE
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Illegal newline" 	; DEFM "Illegal newline"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE2ERROR(A5) 	; JP PHASE2ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
*				;;Sorted Message Table:
TEMPFILE 	EQU	*-PRG.STRT 	;TEMPFILE
	DC.B 	2 	; DEFB 2 ;Drive B:
	DC.B 	"SQUASH1 " 	; DEFM "SQUASH1 "
	DC.B 	"TMP" 	; DEFM "TMP"
 even
*;;
*;;-----
*;;
SORTFILE 	EQU	*-PRG.STRT 	;SORTFILE
*;;
*;;Read characters until found start of message '['
*;;
;	MOVE.W 	#INPUTREADBYTE,D7 	; CALL INPUTREADBYTE
;	JSR 	SYS.JSR(A5) 	;
 move.b (a3)+,d0
	CMP.B 	#ASCIIEOF,D0 	; CP ASCIIEOF
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z ;Normal end-of-file exit
	BNE.S 	LAB.207 	;
	JMP 	SYS.RET(A5) 	;
LAB.207:
	CMP.B 	#' ',D0 	; CP ' ' JR Z,SORTFILE
	BNE.S 	LAB.208 	;
	JMP 	SORTFILE(A5) 	;
LAB.208:
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR JR Z,SF01
	BNE.S 	LAB.209 	;
	JMP 	SF01(A5) 	;
LAB.209:
	CMP.B 	#ASCIILF,D0 	; CP ASCIILF ;Line Feed  JR Z,SORTFILE
	BNE.S 	LAB.210 	;
	JMP 	SORTFILE(A5) 	;
LAB.210:
	CMP.B 	#';',D0 	; CP ';' JR Z,SF02
	BNE.S 	LAB.211 	;
	JMP 	SF02(A5) 	;
LAB.211:
	CMP.B 	#'[',D0 	; CP '[' JR Z,SF03
	BNE.S 	LAB.212 	;
	JMP 	SF03(A5) 	;
LAB.212:
*				;;
*				;;Character not part of official comment or message
*				;;
	CMP.B 	#']',D0 	; CP ']' ;> 12/08/86
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,P2BADCLOSE ;> 12/08/86
	BNE.S 	LAB.213 	;
	JMP 	P2BADCLOSE(A5) 	;
LAB.213:
*				;;
	MOVE.B 	SEENCOMMENT(A5),D0 	; LD A,(SEENCOMMENT) ;> 04/08/86
	OR.B 	D0,D0 	; OR A               ;> 04/08/86
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SORTFILE     ;> 12/08/86 Comment character
	BEQ.S 	LAB.214 	;
	JMP 	SORTFILE(A5) 	;
LAB.214:
	MOVE.B 	#1,D0 	; LD A,1             ;> 04/08/86
	MOVE.B 	D0,SEENCOMMENT(A5) 	; LD (SEENCOMMENT),A ;> 04/08/86
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs           ;> 04/08/86
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR 	; DEFB ASCIICR       ;> 04/08/86
	DC.B 	"Warning: Text found outside square brackets. ",cr
	dc.b	"All future text outside brackets will be treated",cr
	dc.b	"as comments. This first happened" ; at line n
	DC.B 	0 	; DEFB 0             ;> 04/08/86
 even
	MOVE.W 	#DISPLAYWHERE,D7 	; CALL DISPLAYWHEREYS.RET(A5) 	;
LAB.215:
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SF02
	BEQ.S 	LAB.216 	;
	JMP 	SF02(A5) 	;
LAB.216:
*				;;
*				;;Carriage Return. Increments current line
*				;;number but has no other effect.
*				;;
SF01 	EQU	*-PRG.STRT 	;SF01
	LEA 	LINENUM(A5),A0 	; LD BC,(LINENUM)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	ADDQ.W 	#1,D2 	; INC BC
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B YS.RET(A5) 	;
LAB.215:
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SF02
	BEQ.S 	LAB.216 	;
	JMP 	SF02(A5) 	;
LAB.216:
*				;;
*				;;Carriage Return. Increments current line
*				;;number but has no other effect.
*				;;
SF01 	EQU	*-PRG.STRT 	;SF01
	LEA 	LINENUM(A5),A0 	; LD BC,(LINENUM)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	ADDQ.W 	#1,D2 	; INC BC
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	JMP 	SORTFILE(A5) 	; JP SORTFILE
*;;
*;;'[' Start of message
*;;
SF03 	EQU	*-PRG.STRT 	;SF03
	MOVE.W 	#SORTMESSAGE,D7 	; CALL SORTMESSAGE
	JSR 	SYS.JSR(A5) 	;
	JMP 	SORTFILE(A5) 	; JP SORTFILE
*				;;
*				;;-----
*				;;
SORTMESSAGE 	EQU	*-PRG.STRT 	;SORTMESSAGE
; have come to '[' i.e. the start of a new message
; Do the appropriate processing on it.

; Messages are read from (a3)+ and written to (a2)+
; this provides a way of remaining compatible with the serial files
; originally used on the z80 squasher.

	MOVE.W 	#STARTTABLEMEMORY,D1 	; LD HL,STARTTABLEMEMORY
	LEA 	STARTMSG(A5),A0 	; LD (STARTMSG),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.B 	D0,LASTCHAR(A5)	; LD (LASTCHAR),A ;'WRAPRESET' in AINT
*				;;
*				;;Read remainder of message
*				;;
SM01 	EQU	*-PRG.STRT 	;SM01
;	MOVE.W 	#INPUTREADBYTE,D7 	; CALL INPUTREADBYTE
;	JSR 	SYS.JSR(A5) 	;
 move.b (a3)+,d0
SM01A 	EQU	*-PRG.STRT 	;SM01A
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
*				;;
	CMP.B 	#']',D0 	; CP ']' ;End of message
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,SM14
	BNE.S 	LAB.217 	;
	JMP 	SM14(A5) 	;
LAB.217:
	CMP.B 	#ASCIILF,D0 	; CP ASCIILF
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM01
	BNE.S 	LAB.218 	;
	JMP 	SM01(A5) 	;
LAB.218:
*				;;
	MOVE.B 	D0,LASTSIGCHAR(A5) 	; LD (LASTSIGCHAR),A
*				;;
	CMP.B 	#'/',D0 	; CP '/' ;Disables effect of special characters ']' '%' etc.
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM02
	BNE.S 	LAB.219 	;
	JMP 	SM02(A5) 	;
LAB.219:
	CMP.B 	#'[',D0 	; CP '[' ;> 04/08/86
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,P2BADOPEN ;> 12/08/86
	BNE.S 	LAB.220 	;
	JMP 	P2BADOPEN(A5) 	;
LAB.220:
	CMP.B 	#'^',D0 	; CP '^' ;Start of keyword
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM04
	BNE.S 	LAB.221 	;
	JMP 	SM04(A5) 	;
LAB.221:
	CMP.B 	#'|',D0 	; CP '|' ;Keyword separator
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM06
	BNE.S 	LAB.222 	;
	JMP 	SM06(A5) 	;
LAB.222:
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,SM09 ;Increments LINENUM then as SPACE
	BNE.S 	LAB.223 	;
	JMP 	SM09(A5) 	;
LAB.223:
	CMP.B 	#'%',D0 	; CP '%'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,SM13
	BNE.S 	LAB.224 	;
	JMP 	SM13(A5) 	;
LAB.224:
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP C,ILLEGALCHAR
	BCC.S 	LAB.225 	;
	JMP 	ILLEGALCHAR(A5) 	;
LAB.225:
	JMP 	SM10(A5) 	; JP SM10
*;;
*;;Escape disables effect of ']' and disables conversion.
*;;Store 'escaped' characters with top bit set
*;;
SM02 	EQU	*-PRG.STRT 	;SM02
;	MOVE.W 	#INPUTREADBYTE,D7 	; CALL INPUTREADBYTE
;	JSR 	SYS.JSR(A5) 	;
 move.b (a3)+,d0
	MOVE.B 	D0,LASTCHAR(A5) 	; LD (LASTCHAR),A
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,P2BADSLASH
	BNE.S 	LAB.226 	;
	JMP 	P2BADSLASH(A5) 	;
LAB.226:
	CMP.B 	#ASCIILF,D0 	; CP ASCIILF
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,P2BADSLASH
	BNE.S 	LAB.227 	;
	JMP 	P2BADSLASH(A5) 	;
LAB.227:
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM03
	BNE.S 	LAB.228 	;
	JMP 	SM03(A5) 	;
LAB.228:
	BSET 	#7,d0 	; SET 7,A
SM03 	EQU	*-PRG.STRT 	;SM03
	MOVE.W 	#INCNUMCHARS,D7 	; CALL INCNUMCHARS
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	SM01(A5) 	; JR SM01
*;;
*;;'^' must be followed by word-type: a non-space character
*;;from TYPETABLE.
*;;
SM04 	EQU	*-PRG.STRT 	;SM04
	MOVE.B 	D0,LASTCHAR(A5) 	; LD (LASTCHAR),A
	ADDQ.W 	#1,D1 	; INC HL
;	MOVE.W 	#INPUTREADBYTE,D7 	; CALL INPUTREADBYTE
;	JSR 	SYS.JSR(A5) 	;
 move.b (a3)+,d0
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	ADDQ.W 	#1,D1 	; INC HL
*				;;
	MOVE.W 	#TYPETABLE+1,D3 	; LD DE,TYPETABLE+1
	ROR.W 	#8,D2 	; LD B,8-1
	MOVE.B 	#8-1,D2 	;
	ROR.W 	#8,D2 	;
SM05 	EQU	*-PRG.STRT 	;SM05
;	MOVE.W 	D3,-(SP) 	; EX DE,HL ;CP (DE)
;	MOVE.W 	D1,D3 	;
;	MOVE.W 	(SP)+,D1 	;
;	CMP.B 	0(a4,D1.W),D0OVE 	F(A5),SR 	; JR Z,SM05A
	BNE.S 	LAB.230 	;
	JMP 	SM05A(A5) 	;
LAB.230:
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM05B
	BNE.S 	LAB.231 	;
	JMP 	SM05B(A5) 	;
LAB.231:
	CMP.B 	#ASCIILF,D0 	; CP ASCIILF
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM05A
	BNE.S 	LAB.232 	;
	JMP 	SM05A(A5) 	;
LAB.232:
	JMP 	SM01A(A5) 	; JR SM01A
SM05B 	EQU	*-PRG.STRT 	;SM05B
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	LINENUM(A5),A0 	; LD HL,(LINENUM)
	MOVE.OVE 	F(A5),SR 	; JR Z,SM05A
	BNE.S 	LAB.230 	;
	JMP 	SM05A(A5) 	;
LAB.230:
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM05B
	BNE.S 	LAB.231 	;
	JMP 	SM05B(A5) 	;
LAB.231:
	CMP.B 	#ASCIILF,D0 	; CP ASCIILF
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM05A
	BNE.S 	LAB.232 	;
	JMP 	SM05A(A5) 	;
LAB.232:
	JMP 	SM01A(A5) 	; JR SM01A
SM05B 	EQU	*-PRG.STRT 	;SM05B
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	LINENUM(A5),A0 	; LD HL,(LINENUM)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SM05A(A5) 	; JR SM05A
*;;
*;;"|" marks end of printable message, start of keywords
*;;Remove any spaces stored before '|'
*;;
SM06 	EQU	*-PRG.STRT 	;SM06
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.B 	D0,LASTCHAR(A5) 	; LD (LASTCHAR),A
SM07 	EQU	*-PRG.STRT 	;SM07
	MOVE.W 	#P1GETLASTCHAR,D7 	; CALL P1GETLASTCHAR
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SM08
	BEQ.S 	LAB.233 	;
	JMP 	SM08(A5) 	;
LAB.233:
	SUBQ.W 	#1,D1 	; DEC HL
	JMP 	SM07(A5) 	; JR SM07
SM08 	EQU	*-PRG.STRT 	;SM08
	MOVE.B 	#'|',D0 	; LD A,'|'
	JMP 	SM10(A5) 	; JR SM10
*;;
*;;CR. Incremente line number then as SPACE
*;;
SM09 	EQU	*-PRG.STRT 	;SM09
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	LINENUM(A5),A0 	; LD HL,(LINENUM)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.W 	#P1GETLASTCHAR,D7 	; CALL P1GETLASTCHAR
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'%',D0 	; CP '%'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,SM01 ;Don't store CR.
	BNE.S 	LAB.234 	;
	JMP 	SM01(A5) 	;
LAB.234:
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
*				;;
*				;;Remove upper case chars if follow '.' '?' or '!'
*				;;
SM10 	EQU	*-PRG.STRT 	;SM10
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SM11
	BEQ.S 	LAB.235 	;
	JMP 	SM11(A5) 	;
LAB.235:
	MOVE.B 	#' ',D0 	; LD A,' '
*				;;
SM11 	EQU	*-PRG.STRT 	;SM11
	MOVE.W 	#CASEMODIFY,D7 	; CALL CASEMODIFY
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR C,SM12
	BCC.S 	LAB.236 	;
	JMP 	SM12(A5) 	;
LAB.236:
	CMP.B 	0(a4,D1.W),D0 	; CP (HL)
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM13
	BNE.S 	LAB.237 	;
	JMP 	SM13(A5) 	;
LAB.237:
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	MODIFYCOUNT(A5),A0 	; LD HL,(MODIFYCOUNT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	MODIFYCOUNT(A5),A0 	; LD (MODIFYCOUNT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SM13(A5) 	; JR SM13
*				;;
*				;;Needs lower-case force
*				;;So set top bit
*				;;
SM12 	EQU	*-PRG.STRT 	;SM12
	BSET 	#7,d0 	; SET 7,A
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
*				;;
*				;;Next byte of input
*				;;
SM13 	EQU	*-PRG.STRT 	;SM13
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.W 	#INCNUMCHARS,D7 	; CALL INCNUMCHARS
	JSR 	SYS.JSR(A5) 	;
	JMP 	SM01(A5) 	; JP SM01 
*				;;
*				;;']' for end of message
*				;;
SM14 	EQU	*-PRG.STRT 	;SM14
	LEA 	ENDMSG(A5),A0 	; LD (ENDMSG),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	LASTSIGCHAR(A5),D0 	; LD A,(LASTSIGCHAR)
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,BADNEWLINE
	BNE.S 	LAB.238 	;
	JMP 	BADNEWLINE(A5) 	;
LAB.238:
*				;;
*				;;Check if starts with number
*				;;
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
SM15 	EQU	*-PRG.STRT 	;SM15
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	ENDMSG(A5),A0 	; LD DE,(ENDMSG)
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
	MOVE 	F(A5),SR 	; JR Z,SM18 ;No number
	BNE.S 	LAB.239 	;
	JMP 	SM18(A5) 	;
LAB.239:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SM16
	BEQ.S 	LAB.240 	;
	JMP 	SM16(A5) AB.243:
SM17 	EQU	*-PRG.STRT 	;SM17
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	LEA 	ENDMSG(A5),A0 	; LD DE,(ENDMSG)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,SM18 ;No number
	BNEAB.243:
SM17 	EQU	*-PRG.STRT 	;SM17
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	LEA 	ENDMSG(A5),A0 	; LD DE,(ENDMSG)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,SM18 ;No number
	BNE.S 	LAB.244 	;
	JMP 	SM18(A5) 	;
LAB.244:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL) ;Check if number followed by ":"
	ADDQ.W 	#1,D1 	; INC HL
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM17
	BNE.S 	LAB.245 	;
	JMP 	SM17(A5) 	;
LAB.245:
	CMP.B 	#':',D0 	; CP ':'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM19
	BNE.S 	LAB.246 	;
	JMP 	SM19(A5) 	;
LAB.246:
*				;;
*				;;No message number
*				;;
SM18 	EQU	*-PRG.STRT 	;SM18
	LEA 	MSGNUM(A5),A0 	; LD HL,(MSGNUM)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	MSGNUM(A5),A0 	; LD (MSGNUM),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	OR.B 	D1,D0 	; OR L
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,INVALIDNUMBER
	BNE.S 	LAB.247 	;
	JMP 	INVALIDNUMBER(A5) 	;
LAB.247:
	JMP 	SM21(A5) 	; JR SM21
*				;;
*				;;Message number valid
*				;;
SM19 	EQU	*-PRG.STRT 	;SM19
	SUBQ.W 	#2,D6 	; PUSH HL ;New message start address
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE ;Message number
	MOVE.W 	D3,0(a4,D6.W) 	;
	LEA 	STARTMSG(A5),A0 	; LD DE,(STARTMSG)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
*				;;HL=Length of number
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	LEA 	NUMCHARACTERS(A5),A0 	; LD HL,(NUMCHARACTERS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	LEA 	NUMCHARACTERS(A5),A0 	; LD (NUMCHARACTERS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	LEA 	STARTMSG(A5),A0 	; LD (STARTMSG),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	MSGNUM(A5),A0 	; LD HL,(MSGNUM)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	OR.B 	D1,D0 	; OR L
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D3 	; OR D
	OR.B 	D3,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D3 	;
	OR.B 	D3,D0 	; OR E
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,SM20
	BNE.S 	LAB.248 	;
	JMP 	SM20(A5) 	;
LAB.248:
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,INVALIDNUMBER
	BCS.S 	LAB.249 	;
	JMP 	INVALIDNUMBER(A5) 	;
LAB.249:
SM20 	EQU	*-PRG.STRT 	;SM20
	LEA 	MSGNUM(A5),A0 	; LD (MSGNUM),DE
	MOVE.B 	D3,(A0) 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	D3,1(A0) 	;
	ROR.W 	#8,D3 	;
*				;;
SM21 	EQU	*-PRG.STRT 	;SM21
*;;
*;;Calculate length of header required
*;;
	LEA 	ENDMSG(A5),A0 	; LD HL,(ENDMSG)
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
; RET Z - Blank message not stored
	BNE.S 	LAB.250 	;
	JMP 	SYS.RET(A5) 	;

LAB.250:
;	MOVE.W 	#6,D2 	; LD BC,6 ;Sorted message header length
	ADD.W 	#6,D1 	; ADD HL,BC
*;;
*;;Write header. Two bytes are length of entry
*;;
	MOVE.B 	D1,D0 	; LD A,L
 move.w d1,-(sp)
	MOVE.W 	#OUTPUTWRITEBYTE,D7 	; CALL OUTPUTWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
 move.w (sp)+,d1
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#OUTPUTWRITEBYTE,D7 	; CALL OUTPUTWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
*;;
*;;Two bytes are message number
*;;
	LEA 	MSGNUM(A5),A0 	; LD HL,(MSGNUM)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	#OUTPUTWRITEBYTE,D7 	; CALL OUTPUTWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
	LEA 	MSGNUM(A5),A0 	; LD HL,(MSGNUM)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#D A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#OUTPUTWRITEBYTE,D7 	; CALL OUTPUTWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
SM22 	EQU	*-PRG.STRT 	;SM22
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	ENDMSG(A5),A0 	; LD DE,(ENDMSG)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	D A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#OUTPUTWRITEBYTE,D7 	; CALL OUTPUTWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
*				;;
	LEA 	STARTMSG(A5),A0 	; LD HL,(STARTMSG)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
SM22 	EQU	*-PRG.STRT 	;SM22
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	ENDMSG(A5),A0 	; LD DE,(ENDMSG)
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
	MOVE 	F(A5),SR 	; RET Z ;All message stored
	BNE.S 	LAB.251 	;
	JMP 	SYS.RET(A5) 	;
LAB.251:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#OUTPUTWRITEBYTE,D7 	; CALL OUTPUTWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	SM22(A5) 	; JR SM22
*				;;-----
*				;;
INCNUMCHARS 	EQU	*-PRG.STRT 	;INCNUMCHARS
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	NUMCHARACTERS(A5),A0 	; LD HL,(NUMCHARACTERS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1		 	; INC HL
	LEA 	NUMCHARACTERS(A5),A0 	; LD (NUMCHARACTERS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
P1GETLASTCHAR 	EQU	*-PRG.STRT 	;P1GETLASTCHAR
	LEA 	STARTMSG(A5),A0 	; LD DE,(STARTMSG)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.B 	#0,D2 	; LD C,0 ;Returned char if end-of-message
GL01 	EQU	*-PRG.STRT 	;GL01
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,GL02 ;Reached end
	BNE.S 	LAB.252 	;
	JMP 	GL02(A5) 	;
LAB.252:
	MOVE 	F(A5),SR 	; JR C,GL02
	BCC.S 	LAB.253 	;
	JMP 	GL02(A5) 	;
LAB.253:
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	MOVE.B 	D0,D2 	; LD C,A ;Save last char
	ADDQ.W 	#1,D3 	; INC DE
	JMP 	GL01(A5) 	; JR GL01
*				;;Last char of message is register C
GL02 	EQU	*-PRG.STRT 	;GL02
	MOVE.B 	D2,D0 	; LD A,C
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
INPUTREADBYTE 	EQU	*-PRG.STRT 	;INPUTREADBYTE
; return asciieof if end of file
 	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#NEXTSERIALINPUT,D7 	; CALL NEXTSERIALINPUT
	JSR 	SYS.JSR(A5) 	;
	LEA 	INPUTLENGTH(A5),A0 	; LD HL,(INPUTLENGTH)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	INPUTLENGTH(A5),A0 	; LD (INPUTLENGTH),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
OUTPUTWRITEBYTE 	EQU	*-PRG.STRT 	;OUTPUTWRITEBYTE
	move.b d0,(a2)+ ; write data to "file"
	LEA 	LENGTHSMT(A5),A0 	; LD HL,(LENGTHSMT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	LENGTHSMT(A5),A0 	; LD (LENGTHSMT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	jmp sys.ret(a5)
;----

	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;Output control block
	MOVE.W 	#SERIALWRITEBYTE,D7 	; CALL SERIALWRITEBYTE
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP C,HITEOF
	BCC.S 	LAB.254 	;
	JMP 	HITEOF(A5) 	;
LAB.254:
	LEA 	LENGTHSMT(A5),A0 	; LD HL,(LENGTHSMT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	LENGTHSMT(A5),A0 	; LD (LENGTHSMT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
INITSERIALINPUT 	EQU	*-PRG.STRT 	;INITSERIALINPUT
	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#$6000,D3 	; LD DE,$6000 ;Must be small enough to use TBUG
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
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	BUFFERSIZE(A5),A0 	; LD (BUFFERSIZE),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA .."
	DC.B 	$D,0 	; DEFB $D,0
 even
	MOVE.W 	#CLEARFCB,D7 	; CALL CLEARFCB
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#INPUT,D1 	; LD HL,INPUT
	MOVE.W 	#SYSTEMFCBDRIVE,D3 	; LD DE,SYSTEMFCBDRIVE
	MOVE.W 	#12,D2 	; LD BC,12
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input control block
	MOVE.W 	#OPENSERIALREAD,D7 	; CALL OPENSERIALREAD
	JSR 	SYS.JSR(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
NEXTSERIALINPUT 	EQU	*-PRG.STRT 	;NEXTSERIALINPUT
	LEA 	UNREADSIZE(A5),A0 	; L.."
	DC.B 	$D,0 	; DEFB $D,0
 even
	MOVE.W 	#CLEARFCB,D7 	; CALL CLEARFCB
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#INPUT,D1 	; LD HL,INPUT
	MOVE.W 	#SYSTEMFCBDRIVE,D3 	; LD DE,SYSTEMFCBDRIVE
	MOVE.W 	#12,D2 	; LD BC,12
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input control block
	MOVE.W 	#OPENSERIALREAD,D7 	; CALL OPENSERIALREAD
	JSR 	SYS.JSR(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
NEXTSERIALINPUT 	EQU	*-PRG.STRT 	;NEXTSERIALINPUT
	LEA 	UNREADSIZE(A5),A0 	; LD HL,(UNREADSIZE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	OR.B 	D1,D0 	; OR L
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SI04 ;Buffer contains enough chars
	BEQ.S 	LAB.255 	;
	JMP 	SI04(A5) 	;
LAB.255:
*				;;
	MOVE.B 	INPUTEOF(A5),D0 	; LD A,(INPUTEOF)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SI05 ;Return EOF
	BEQ.S 	LAB.256 	;
	JMP 	SI05(A5) 	;
LAB.256:
*				;;
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
SI01 	EQU	*-PRG.STRT 	;SI01
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	ENDMEMORY(A5),A0 	; LD DE,(ENDMEMORY)
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
	MOVE 	F(A5),SR 	; JR NC,SI03 ;Buffer full
	BCS.S 	LAB.257 	;
	JMP 	SI03(A5) 	;
LAB.257:
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input control block
	MOVE.W 	#SERIALREADBYTE,D7 	; CALL SERIALREADBYTE
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR C,SI02
	BCC.S 	LAB.258 	;
	JMP 	SI02(A5) 	;
LAB.258:
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	SI01(A5) 	; JR SI01
SI02 	EQU	*-PRG.STRT 	;SI02
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.B 	#1,D0 	; LD A,1
	MOVE.B 	D0,INPUTEOF(A5) 	; LD (INPUTEOF),A
SI03 	EQU	*-PRG.STRT 	;SI03
	LEA 	STARTBUFFER(A5),A0 	; LD DE,(STARTBUFFER)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	LEA 	BUFFERSIZE(A5),A0 	; LD (BUFFERSIZE),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	UNREADSIZE(A5),A0 	; LD (UNREADSIZE),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
SI04 	EQU	*-PRG.STRT 	;SI04
	LEA 	BUFFERSIZE(A5),A0 	; LD HL,(BUFFERSIZE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTBUFFER(A5),A0 	; LD DE,(STARTBUFFER)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	LEA 	UNREADSIZE(A5),A0 	; LD DE,(UNREADSIZE)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	LEA 	UNREADSIZE(A5),A0 	; LD HL,(UNREADSIZE)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	SUBQ.W 	#1,D1 	; DEC HL
	LEA 	UNREADSIZE(A5),A0 	; LD (UNREADSIZE),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
SI05 	EQU	*-PRG.STRT 	;SI05
	MOVE.B 	#ASCIIEOF,D0 	; LD A,ASCIIEOF
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
ENDSERIALINPUT 	EQU	*-PRG.STRT 	;ENDSERIALINPUT
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; CALL Z,NEWLINE
	BNE.S 	LAB.259 	;
	MOVE.W 	#NEWLINE,D7 	;
	JSR 	SYS.JSR(A5) 	;
LAB.259:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"... eof" 	; DEFM "... eof"
	DC.B 	$D,0 	; DEFB $D,0
 even
	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input control block
	JMP 	CLOSESERIALREAD(A5) 	; JP CLOSESERIALREAD
*				;;
*				;;-----
*				;;
ABORTSERIALINPUT 	EQU	*-PRG.STRT 	;ABORTSERIALINPUT
	JMP 	CLOSESERIALREAD(A5) 	; JP CLOSESERIALREAD
*				;;
*				;;-----
*				;;
CASEMODIFY 	EQU	*-PRG.STRT 	;CASEMODIFY
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
*				;;Transparent characters:
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC04
	BNE.S 	LAB.260 	;
	JMP 	PC04(A5) 	;
LAB.260:
	CMP.B 	#'_',D0 	; CP '_'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC04
	BASTCHAR(A5),D0 	; LD A,(LASTCHAR)
	CMP.B 	#'!',D0 	; CP '!'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC01
	BNE.S 	LAB.265 	;
	JMP 	PC01(A5) 	;
LAB.265:
	CMP.B 	#'?',D0 	; CP '?'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC01
	BNE.S 	LAB.266 	;
	JMP 	PC01(A5) 	;
LAB.266:
	CMP.B 	#'.',D0 	; CP '.'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,PC03
	BEQ.S 	LAB.267 	;
	JMP 	PC03(A5) 	;
LAB.267:
PC01 	EQU	*-PRG.STRT 	;PC01
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,LASTASTCHAR(A5),D0 	; LD A,(LASTCHAR)
	CMP.B 	#'!',D0 	; CP '!'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC01
	BNE.S 	LAB.265 	;
	JMP 	PC01(A5) 	;
LAB.265:
	CMP.B 	#'?',D0 	; CP '?'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC01
	BNE.S 	LAB.266 	;
	JMP 	PC01(A5) 	;
LAB.266:
	CMP.B 	#'.',D0 	; CP '.'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,PC03
	BEQ.S 	LAB.267 	;
	JMP 	PC03(A5) 	;
LAB.267:
PC01 	EQU	*-PRG.STRT 	;PC01
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,LASTCHAR(A5) 	; LD (LASTCHAR),A
	CMP.B 	#"a",D0 	; CP "a"
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,PC02
	BCC.S 	LAB.268 	;
	JMP 	PC02(A5) 	;
LAB.268:
	CMP.B 	#"z"+1,D0 	; CP "z"+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET C ;Already lower case
	BCC.S 	LAB.269 	;
	JMP 	SYS.RET(A5) 	;
LAB.269:
PC02 	EQU	*-PRG.STRT 	;PC02
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
PC03 	EQU	*-PRG.STRT 	;PC03
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D0,LASTCHAR(A5) 	; LD (LASTCHAR),A
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
PC04 	EQU	*-PRG.STRT 	;PC04
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	OR.B 	D0,D0 	; OR A ;Reset carry
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
DISPLAYSORTEDMESSAGE 	EQU	*-PRG.STRT 	;DISPLAYSORTEDMESSAGE
	MOVE.W 	#DISPLAYHEADER,D7 	; CALL DISPLAYHEADER
	JSR 	SYS.JSR(A5) 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" Text " 	; DEFM " Text "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL) ;Length of entry
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL ;Adjust for start of text
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#1,D2 	; DEC BC
DS01 	EQU	*-PRG.STRT 	;DS01
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,DS02
	BNE.S 	LAB.270 	;
	JMP 	DS02(A5) 	;
LAB.270:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#DISPLAYCODE,D7 	; CALL DISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	DS01(A5) 	; JR DS01
DS02 	EQU	*-PRG.STRT 	;DS02 JP NEWLINE
	JMP 	NEWLINE(A5) 	;
*				;;
*				;;-----
*				;;
*				;;Display line and message number of a Sorted Message Header.
DISPLAYHEADER 	EQU	*-PRG.STRT 	;DISPLAYHEADER
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Line " 	; DEFM "Line "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL) ;Line number
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D7 	; LD H,(HL)
	ROR.W 	#8,D1 	;
	MOVE.B 	D7,D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D2,D1 	; LD L,C
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" Number " 	; DEFM " Number "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL) ;Message number
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D7 	; LD H,(HL)
	ROR.W 	#8,D1 	;
	MOVE.B 	D7,D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D2,D1 	; LD L,C
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*				;;> 04/08/86 DISPLAYLINENUM
DISPLAYWHERE 	EQU	*-PRG.STRT 	;DISPLAYWHERE ;> 04/08/86
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" in line " 	; DEFM " in line "
	DC.B 	0 	; DEFB 0
 even
	LEA 	LINENUM(A5),A0 	; LD HL,(LINENUM)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
 clr.l d0
 move.w d1,d0
 jsr printdecimald0
;	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
;	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squas8/86
*				;;
DISPLAYLINENUM 	EQU	*-PRG.STRT 	;DISPLAYLINENUM ;> 04/08/86
	MOVE.W 	#DISPLAYWHERE,D7 	; CALL DISPLAYWHERE ;> 04/08/86
	JSR 	SYS.JSR(A5) 	;
	JMP 	WARMSTART(A5) 	; JP WARMSTART
*;;
*;;-----
*;;
*;;Try to read character at address HL as a decimal number.
*;;Returns DE as address of the character following the end
*;;of the number and HL as the numbers binary value.
*;;
EVALNUMBER 	EQU	*-PRG.STRT 	;EVALNUMBER LD A,(HL)
	MOVE.B 	0(a4,D1.W),D0 	;
	MOVE.W 	#$0,D3 	; LD DE,$0
RN01 	EQU8/86
*				;;
DISPLAYLINENUM 	EQU	*-PRG.STRT 	;DISPLAYLINENUM ;> 04/08/86
	MOVE.W 	#DISPLAYWHERE,D7 	; CALL DISPLAYWHERE ;> 04/08/86
	JSR 	SYS.JSR(A5) 	;
	JMP 	WARMSTART(A5) 	; JP WARMSTART
*;;
*;;-----
*;;
*;;Try to read character at address HL as a decimal number.
*;;Returns DE as address of the character following the end
*;;of the number and HL as the numbers binary value.
*;;
EVALNUMBER 	EQU	*-PRG.STRT 	;EVALNUMBER LD A,(HL)
	MOVE.B 	0(a4,D1.W),D0 	;
	MOVE.W 	#$0,D3 	; LD DE,$0
RN01 	EQU	*-PRG.STRT 	;RN01 EX DE,HL
	MOVE.W 	D3,-(SP) 	;
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
; PUSH HL; LD BC,6554; XOR A - Reset carry SBC HL,BC
 move.w #6554,d0
 cmp.w d1,d0	;order reversed to avoid inverting carry
; POP HL
; RET C ;Number too big ( greater than 65539 )
	BCC.S 	LAB.271 	;
	JMP 	SYS.RET(A5) 	;
LAB.271:
	ADD.W 	D1,D1 	; ADD HL,HL
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D1,D2 	; LD C,L
	ROR.W 	#8,D2 	; LD B,H
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,D2 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D2 	;
	ADD.W 	D1,D1 	; ADD HL,HL
	MOVE 	SR,F(A5) 	;
	ADD.W 	D1,D1 	; ADD HL,HL
	MOVE 	SR,F(A5) 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	SUB.B 	#'0',D0 	; SUB '0'
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,D2 	; LD C,A
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET C ;Number too big ( 65536 thru 65539 )
	BCC.S 	LAB.272 	;
	JMP 	SYS.RET(A5) 	;
LAB.272:
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	ADDQ.W 	#1,D1 	; INC HL;Next char
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#'0',D0 	; CP '0'
	MOVE 	SR,F(A5) 	;
	EOR.B 	#17,F+1(A5) 	; CCF 
	MOVE 	F(A5),SR 	; RET NC ;Number OK
	BCS.S 	LAB.273 	;
	JMP 	SYS.RET(A5) 	;
LAB.273:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NC ;Number OK
	BCS.S 	LAB.274 	;
	JMP 	SYS.RET(A5) 	;
LAB.274:
	JMP 	RN01(A5) 	; JR RN01
*				;;
*				;;-----
*				;;
*				;;Compare HL with (ENDMEMORY).
*				;;Returns NC if HL >= (ENDMEMORY)
*				;;
CHECKENDMEMORY 	EQU	*-PRG.STRT 	;CHECKENDMEMORY
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	LEA 	ENDMEMORY(A5),A0 	; LD DE,(ENDMEMORY)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
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
PHASE2ERROR 	EQU	*-PRG.STRT 	;PHASE2ERROR
	MOVE.W 	#FCB1,D1 	; LD HL,FCB1 ;Input control block
	MOVE.W 	#CLOSESERIALREAD,D7 	; CALL CLOSESERIALREAD
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#FCB2,D1 	; LD HL,FCB2 ;Output file
	MOVE.W 	#CLOSESERIALWRITE,D7 	; CALL CLOSESERIALWRITE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#DELETESYSTEM,D7 	; CALL DELETESYSTEM
	JSR 	SYS.JSR(A5) 	;
	JMP 	DISPLAYLINENUM(A5) 	; JP DISPLAYLINENUM ;Ends in WARMSTART
*;;
*;;-----
*;;
*;;Phase 3 - Construct 'Frequency Table'
*;;
*;;Phase 3 scans the 'Sorted Message Table' and builds the
*;;Frequency Table' - A list of all 'words' in
*;;alphabetical order stored with the number of times they
*;;are used.
*;;
*;;The 'Frequency Table' occupies addresses (STARTFT)
*;;thru (ENDFT)-1.
*;;
*;;Each Frequency entry starts with
*;;the entries length (one byte) and the number of
*;;occurrances (two bytes.)
*;;
*;;-----
*;;
PHASE03 	EQU	*-PRG.STRT 	;PHASE03
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 3 - Construct 'Frequency Table'" 	; DEFM "Phase 3 - Construct 'Frequency Table'"
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*;;
*;;Clear Frequency Table'
*;;
	MOVE.W 	#STARTTABLEMEMORY,D1 	; LD HL,STARTTABLEMEMORY
	LEA 	STARTFT(A5),A0 	; LD (STARTFT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	ENDFT(A5),A0 	; LD (ENDFT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0)
	ROR.W 	#8,D1

	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1
	ROR.W 	#8,D1
	MOVE.B 	(A0),D1
	LEA 	STARTFT(A5),A0 	; LD DE,(STARTFT)
	MOVE.B 	1(A0),D3
	ROR.W 	#8,D3
	MOVE.B 	(A0),D3

	sub.w d3,d1 ; SBC HL,DE
	SUBQ.W 	#1,D1 	; DEC HL
	move.w d1,d2
	LEA 	STARTFT(A5),A0 	; LD HL,(STARTFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	move.w d1,d3 		; LD D,H; LD E,L
	ADDQ.W #1,D3 		; INC DE
	MOVE.B 	#$0,0(a4,D1.W) 	; LD (HL),$0
	JSR 	SYS.LDIR(SR 	SYS.JSR(A5) 	;
*;;
*;;Search each sentance picking out 'words'
*;;
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	NUMWORDS(A5),A0 	; LD (NUMWORDS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
PC11 	EQU	*-PRG.STRT 	;PC11
	MOVE.W 	#ENDSERIALSMT,D7 	; CALL ENDSERIALSMT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC13 ;End of file
	BNE.S 	LAB.275 	;
	JMP 	PC13(A5) 	;
LAB.275:
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B SR 	SYS.JSR(A5) 	;
*;;
*;;Search each sentance picking out 'words'
*;;
	MOVE.W 	#0,D1 	; LD HL,0
	LEA 	NUMWORDS(A5),A0 	; LD (NUMWORDS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
PC11 	EQU	*-PRG.STRT 	;PC11
	MOVE.W 	#ENDSERIALSMT,D7 	; CALL ENDSERIALSMT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PC13 ;End of file
	BNE.S 	LAB.275 	;
	JMP 	PC13(A5) 	;
LAB.275:
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D1.W),D2
; LD C,(HL) ;Length of Sorted Message Table entry
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
*				;;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
;** put back when debugging finished!	BEQ.S 	LAB.276 	;
	JMP 	PC12(A5) 	;
LAB.276:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Message number = " 	; DEFM "Message number = "
	DC.B 	0 	; DEFB 0
 even
 move.w d2,d1 ; ld h,b; ld l,c
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
PC12 	EQU	*-PRG.STRT 	;PC12
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH BC ;Store line number for error messages
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 		; INC HL
	ROR.W 	#8,D2 		; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 		; INC HL
	LEA 	LINENUM(A5),A0 	; LD (LINENUM),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
*				;;
; DEC BC; DEC BC; DEC BC; DEC BC; DEC BC; DEC BC
	SUBQ.W 	#6,D2
	MOVE.W 	#COUNTSENTANCE,D7 	; CALL COUNTSENTANCE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.W 	#NEXTSERIALSMT,D7 	; CALL NEXTSERIALSMT
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 		; INC HL
	ROR.W 	#8,D2 		; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 		;
	SUBQ.W 	#1,D1 		; DEC HL
	ADD.W 	D2,D1 		; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	JMP 	PC11(A5) 	; JR PC11
*;;
*;;Check frequency table not too big (2^12-128)
*;;And note word number of first 'typed' word.
*;;
PC13 	EQU	*-PRG.STRT 	;PC13
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	LEA 	NUMWORDS(A5),A0 ; LD BC,(NUMWORDS)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
;	EOR.B 	D0,D0 		; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP C,TOOMANY
	BCC.S 	LAB.277 	;
	JMP 	TOOMANY(A5) 	;
LAB.277:
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.278 	;
	JMP 	phase3exit(A5) 	;
LAB.278:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Number of 'words' =" 	; DEFM "Number of 'words' ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	NUMWORDS(A5),A0 	; LD HL,(NUMWORDS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#DISPLAYHLBOTH,D7 	; CALL DISPLAYHLBOTH
	JSR 	SYS.JSR(A5) 	;

	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIICR 	; DEFB ASCIICR,ASCIICR
	DC.B 	"Length of 'Frequency Table' =" 	; DEFM "Length of 'Frequency Table' ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	ENDFT(A5),A0 	; LD HL,(ENDFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTFT(A5),A0 	; LD DE,(STARTFT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIICR 	; DEFB ASCIICR,ASCIICR
	DC.B 	"Low memory used =" 	; DEFM "Low memory used ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	ENDFT(A5),A0 	; LD HL,(ENDFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.W 	#STARTTABLEMEMORY,D3 	; LD DE,STARTTABLEMEMORY
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	LL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" Free =" 	; DEFM " Free ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	ENDFT(A5),A0 	; LD DE,(ENDFT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
phase3exit equ *-prg.strt
	jmp afterphase03(a5)
;***** some staLL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" Free =" 	; DEFM " Free ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	STARTBUFFER(A5),A0 	; LD HL,(STARTBUFFER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	ENDFT(A5),A0 	; LD DE,(ENDFT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
phase3exit equ *-prg.strt
	jmp afterphase03(a5)
;***** some stack problem?
	JMP 	SYS.RET(A5)
*;;
*;;-----
*;;
*;;Search each sentance skiping punctuation, picking out
*;;words. HL is address of start of text of sentance. BC
*;;is its length.
*;;
COUNTSENTANCE 	EQU	*-PRG.STRT 	;COUNTSENTANCE
	tst.w d2 ; LD A,B; or c; RET Z
	BNE.S 	LAB.279 	;
 JMP 	SYS.RET(A5) 	;
LAB.279:
*;;
*;;If a non-simple word it will be preceeded by '^'
*;;and a word-type.
*;;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#'^',D0 	; CP '^' ; JR NZ,CS05
	BEQ.S 	LAB.280 	;
	JMP 	CS05(A5) 	;
LAB.280:
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	tst.w d2 	; LD A,b; OR C
; JP Z,P3BADWORDTYPE ;'^' and end of sentance
	BNE.S 	LAB.281 	;
	JMP 	P3BADWORDTYPE(A5) 	;
LAB.281:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	SUBQ.W 	#2,D6		; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	#TYPETABLE+1,D3 ; LD DE,TYPETABLE+1
	ROR.W 	#8,D2 		; LD B,1
	MOVE.B 	#1,D2 	;
	ROR.W 	#8,D2 	;
CS01 	EQU	*-PRG.STRT 	;CS01
	ROR.W 	#8,D2 		; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	#8,D0 		; CP 8
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JP Z,P3BADWORDTYPE ;Unknown word-type
	BNE.S 	LAB.282 	;
	JMP 	P3BADWORDTYPE(A5) 	;
LAB.282:
	MOVE.B 	0(a5,D3.W),D0 	; LD A,(DE)
	CMP.B 	0(a4,D1.W),D0 	; CP (HL)
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR Z,CS02
	BNE.S 	LAB.283 	;
	JMP 	CS02(A5) 	;
LAB.283:
	ADDQ.W 	#1,D3 	; INC DE
	ADD.W 	#$100,D2 	; INC B
	JMP 	CS01(A5) 	; JR CS01
CS02 	EQU	*-PRG.STRT 	;CS02
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
*;;
*;;Word-type declaration must be followed by a word
*;;
CS03 	EQU	*-PRG.STRT 	;CS03
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
;	ROR.W 	#8,D2 	; LD A,B
;	MOVE.B 	D2,D0 	;
;	ROR.W 	#8,D2 	;
;	OR.B 	D2,D0 	; OR C
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JP Z,P3BADWORDTYPE ;Missing word
	BNE.S 	LAB.284 	;
	JMP 	P3BADWORDTYPE(A5) 	;
LAB.284:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#' ',D0 	; CP ' '
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR Z,CS03
	BNE.S 	LAB.285 	;
	JMP 	CS03(A5) 	;
LAB.285:
	MOVE.W 	#VALIDWORDSTART,D7 	; CALL VALIDWORDSTART
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,P3BADWORDTYPE ;Not followed by word
	BCS.S 	LAB.286 	;
	JMP 	P3BADWORDTYPE(A5) 	;
LAB.286:
	JMP 	CS06(A5) 	; JR CS06
*				;;
*				;;Check for a simple word
*				;;
CS05 	EQU	*-PRG.STRT 	;CS05
	MOVE.W 	#VALIDWORDSTART,D7 	; CALL VALIDWORDSTART
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,CS07 ;Invalid start of word
	BCS.S 	LAB.287 	;
	JMP 	CS07(A5) 	;
LAB.287:
*				;;
CS06 	EQU	*-PRG.STRT 	;CS06
	MOVE.W 	#LOADBUFFER,D7 	; CALL LOADBUFFER
	JSR 	SYS.JSR(A5) 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	#ADDFREQUENCY,D7 	; CALL ADDFREQUENCY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	COUNTSENTANCE(A5) 	; JR COUNTSENTANCE
*				;;
*				;;Not part of a word so count as puctuation:
*				;;
CS07 	EQU	*-PRG.STRT 	;CS07
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	ADD.B 	D0,D0 	; ADD A,A
	MOVE 	SR,F(A5) 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
;	ROR.W 	#8,D3 			; LD D,$0
;	MOVE.B 	#$0,D3 	;
;	ROR.W 	#8,D3 	;
	move.w  #0,d3	; clear DE
	MOVE.B 	D0,D3 			; LD E,A
	MOVE.W 	#CHARACTERCOUNTS,D1 	; LD HL,CHARACTERCOUNTS
	ADD.W 	D3,D1 			; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D3 		; LD E,(HL)
	ADDQ.W 	#1,D1 			; INC HL
	ROR.W 	#8,D3 			; LD D,(HL)
	MOVE.B 	0(a4,D1.W),D3 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D3 			; INC DE
	ROR.W 	#8,D3 			; LD (HL),D
	MOVE.B 	D3,0(a4,D1.W) 	;
	ROR.W 	#8,D3 	;
	SUBQ.W 	#1,D1 			; DEC HL
	MOVE.B 	D3,0(a4,D1.W) 		; LD (HL),E
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	COUNTSENTANCE(A5) 	; JR COUNTSENTANCE
*				;;
P3BADSLASH 	EQU	*-PRG.STRT 	;P3BADSLASH
	MOVDWORDSTART
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 		; RES 7,A
	CMP.B 	#'0',D0 	; CP '0'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR C,VS03
	BCC.S 	LAB.288 	;
	JMP 	VS03(A5) 	;
LAB.288:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
	MOVE 	SR,F(A5) 	; must leave this one in
;	MOVE 	F(A5),SR 	; RET C ;Valid
	BCC.S 	LAB.289 	;
	JMP 	SYS.RET(A5) 	;
LAB.289:
VS03 	EQU	*-PRG.STRT 	;VS03
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'a',D0 	; CP 'a'
	MOVE 	SR,F(A5) 	; must leave this onDWORDSTART
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 		; RES 7,A
	CMP.B 	#'0',D0 	; CP '0'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR C,VS03
	BCC.S 	LAB.288 	;
	JMP 	VS03(A5) 	;
LAB.288:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
	MOVE 	SR,F(A5) 	; must leave this one in
;	MOVE 	F(A5),SR 	; RET C ;Valid
	BCC.S 	LAB.289 	;
	JMP 	SYS.RET(A5) 	;
LAB.289:
VS03 	EQU	*-PRG.STRT 	;VS03
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'a',D0 	; CP 'a'
	MOVE 	SR,F(A5) 	; must leave this one in
	EOR.B 	#17,F+1(A5) 	; CCF 
	MOVE 	F(A5),SR 	; RET NC ;Invalid
	BCS.S 	LAB.290 	;
	JMP 	SYS.RET(A5) 	;
LAB.290:
	CMP.B 	#'z'+1,D0 	; CP 'z'+1
	MOVE 	SR,F(A5) 	; must leave in
	JMP 	SYS.RET(A5) 	; RET ;'C' if valid
*				;;
P3BADWORDTYPE 	EQU	*-PRG.STRT 	;P3BADWORDTYPE
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Bad use of special character '^'"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE3ERROR(A5) 	; JP PHASE3ERROR ;Calls DISPLAYLINENUM then WARMSTART
*;;
*;;-----
*;;
*;;Copy word from Sorted Message Table into BUFFER.
*;;HL is address in S.M.T. BC is length of sentance
*;;remaining.
*;;
LOADBUFFER 	EQU	*-PRG.STRT 	;LOADBUFFER
	MOVE.W 	#BUFFER,D3 	; LD DE,BUFFER
LB02 	EQU	*-PRG.STRT 	;LB02
; LD A,B; OR C; JP Z,LB10
	tst.w d2
	BNE.S 	LAB.291
	JMP 	LB10(A5)
LAB.291:
*				;;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BTST 	#7,d0		; BIT 7,A ; JR NZ,LB02A
	BEQ.S 	LAB.292 	;
	JMP 	LB02A(A5) 	;
LAB.292:
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	0(a4,D1.W),D0 	; CP (HL) ; JR Z,LB02A
	BNE.S 	LAB.293 	;
	JMP 	LB02A(A5) 	;
LAB.293:
	BSET 	#7,0(a4,D1.W) 	; SET 7,(HL)
LB02A 	EQU	*-PRG.STRT 	;LB02A
*				;;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,D0		; RES 7,A
	CMP.B 	#"'",D0 	; CP "'" ; JR Z,LB08
	BNE.S 	LAB.294 	;
	JMP 	LB08(A5) 	;
LAB.294:
	CMP.B 	#'-',D0 	; CP '-' ; JR Z,LB08
	BNE.S 	LAB.295 	;
	JMP 	LB08(A5) 	;
LAB.295:
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'a',D0 	; CP 'a' ; JR C,LB03
	BCC.S 	LAB.296 	;
	JMP 	LB03(A5) 	;
LAB.296:
	CMP.B 	#'z'+1,D0 	; CP 'z'+1
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE 	F(A5),SR 	; JR C,LB07
	BCC.S 	LAB.297 	;
	JMP 	LB07(A5) 	;
LAB.297:
LB03 	EQU	*-PRG.STRT 	;LB03
	CMP.B 	#'0',D0 	; CP '0'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR C,LB04
	BCC.S 	LAB.298 	;
	JMP 	LB04(A5) 	;
LAB.298:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE 	F(A5),SR 	; JR C,LB07
	BCC.S 	LAB.299 	;
	JMP 	LB07(A5) 	;
LAB.299:
LB04 	EQU	*-PRG.STRT 	;LB04
	JMP 	LB10(A5) 	; JR LB10
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 	; RES 7,A
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'a',D0 	; CP 'a'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,LB05
	BCC.S 	LAB.300 	;
	JMP 	LB05(A5) 	;
LAB.300:
	CMP.B 	#'z'+1,D0 	; CP 'z'+1
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR C,LB06
	BCC.S 	LAB.301 	;
	JMP 	LB06(A5) 	;
LAB.301:
LB05 	EQU	*-PRG.STRT 	;LB05
	CMP.B 	#'0',D0 	; CP '0'
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR C,LB06
	BCC.S 	LAB.302 	;
	JMP 	LB06(A5) 	;
LAB.302:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR NC,LB10
	BCS.S 	LAB.303 	;
	JMP 	LB10(A5) 	;
LAB.303:
*				;;
*				;;Escaped character
*				;;
LB06 	EQU	*-PRG.STRT 	;LB06
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.B 	D0,0(a4,D3.W) 	; LD (DE),A
	MOVE.W 	#UPPOINTER,D7 	; CALL UPPOINTER
	JSR 	SYS.JSR(A5) 	;
	JMP 	LB02(A5) 	; JR LB02
*				;;
*				;;Single alphabetic character
*				;;
LB07 	EQU	*-PRG.STRT 	;LB07
	MOVE.B 	D0,0(a4,D3.W) 	; LD (DE),A
	MOVE.W 	#UPPOINTER,D7 	; CALL UPPOINTER
	JSR 	SYS.JSR(A5) 	;
	JMP 	LB02(A5) 	; JR LB02
*;;
*;;Single quote, will be an apostrophe if followed by an
*;;alpha. It's already preceeded by an alpha otherwise
*;;can't be a word.
*;;
LB08 	EQU	*-PRG.STRT 	;LB08
	MOVE.W 	#UPPOINTER,D7 	; CALL UPPOINTER
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,LB09
	BNE.S 	LAB.304 	;
	JMP 	LB09(A5) 	;
LAB.304:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#LOWER,D7 	; CALL LOWER
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'a',D0 	; CP 'a'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,LB09
	BCC.S 	LAB.305 	;
	JMP 	LB09(A5) 	;
LAB.305:
	CMP.B 	#'z'+1,D0 	; CP 'z'+1
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR NC,LB09
	BCS.S 	LAB.306 	;
	JMP 	LB09(A5) 	;
LAB.306:
	MOVE.W 	#DOWNPOINTER,D7 	; CALL DOWNPOINTER
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	0(a4SR,F(A5) 	;
	MOVE.B 	D0,0(a4,D3.W) 	; LD (DE),A
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;Advance read and write pointers, decrement count (to
*				;;end of sentance.) Check that write pointer does not
*				;;escape buffer. 
*				;;
UPPOINTER 	EQU	*-PRG.STRT 	;UPPOINTER
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D3 	; INC DE
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#BUFFER+MAXWORDLEN,D1 	; LD HL,BUFFER+MAXWORDLEN
; XOR A ; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOSR,F(A5) 	;
	MOVE.B 	D0,0(a4,D3.W) 	; LD (DE),A
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;Advance read and write pointers, decrement count (to
*				;;end of sentance.) Check that write pointer does not
*				;;escape buffer. 
*				;;
UPPOINTER 	EQU	*-PRG.STRT 	;UPPOINTER
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D3 	; INC DE
	SUBQ.W 	#1,D2 	; DEC BC
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#BUFFER+MAXWORDLEN,D1 	; LD HL,BUFFER+MAXWORDLEN
; XOR A ; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JP C,TOOLONG
	BCC.S 	LAB.307 	;
	JMP 	TOOLONG(A5) 	;
LAB.307:
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;Retreate read and write pointers.
*				;;
DOWNPOINTER 	EQU	*-PRG.STRT 	;DOWNPOINTER
	SUBQ.W 	#1,D1 	; DEC HL
	SUBQ.W 	#1,D3 	; DEC DE
	ADDQ.W 	#1,D2 	; INC BC
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;If word in buffer is already in dictionary its frequency 
*;;count is incremented. Otherwise the word is inserted in
*;;alphabetical order.
*;;
ADDFREQUENCY 	EQU	*-PRG.STRT 	;ADDFREQUENCY
	LEA 	STARTFT(A5),A0 	; LD HL,(STARTFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
AF01 	EQU	*-PRG.STRT 	;AF01
	MOVE.W 	#CHECKENDFT,D7 	; CALL CHECKENDFT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,AF06 ;Add word to end
	BCS.S 	LAB.308 	;
	JMP 	AF06(A5) 	;
LAB.308:
	MOVE.W 	#COMPARE,D7 	; CALL COMPARE
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,AF02 ;Word exists
	BNE.S 	LAB.309 	;
	JMP 	AF02(A5) 	;
LAB.309:
*				;;
	MOVE 	F(A5),SR 	; JR C,AF03 ;Insert word here.
	BCC.S 	LAB.310 	;
	JMP 	AF03(A5) 	;
LAB.310:
	ROR.W 	#8,D2 	; LD B,$0 ;Move on one entry.
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	JMP 	AF01(A5) 	; JR AF01
*				;;
*				;;Word already exists
*				;;
AF02 	EQU	*-PRG.STRT 	;AF02
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D2 	; INC BC
	ROR.W 	#8,D2 	; LD (HL),B
	MOVE.B 	D2,0(a4,D1.W) 	;
	ROR.W 	#8,D2 	;
	SUBQ.W 	#1,D1 	; DEC HL
	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
	SUBQ.W 	#1,D1 	; DEC HL
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.311 	;
	JMP 	SYS.RET(A5) 	;
LAB.311:
	JMP 	DISPLAYFREQUENCY(A5) 	; JP DISPLAYFREQUENCY
*				;;
*				;;Move up dictionary
*				;;
AF03 	EQU	*-PRG.STRT 	;AF03
	SUBQ.W 	#2,D6 	; PUSH HL;Insert point
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.B 	D1,D2 	; LD C,L
	ROR.W 	#8,D2 	; LD B,H
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,D2 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D2 	;
	LEA 	ENDFT(A5),A0 	; LD HL,(ENDFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D1,D2 	; LD C,L
	ROR.W 	#8,D2 	; LD B,H;BC=Copy length
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,D2 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#BUFFER,D3 	; LD DE,BUFFER
AF04 	EQU	*-PRG.STRT 	;AF04
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,AF05
	BNE.S 	LAB.312 	;
	JMP 	AF05(A5) 	;
LAB.312:
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D3 	; INC DE
	JMP 	AF04(A5) 	; JR AF04
AF05 	EQU	*-PRG.STRT 	;AF05
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL 
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#ICOPY,D7 	; CALL ICOPY
	JSR 	SYS.JSR(A5) 	;
	LEA 	NUMWORDS(A5),A0 	; LD HL,(NUMWORDS)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	NUMWORDS(A5),A0 	; LD (NUMWORDS),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*;;
*;;Put word in dictionary
*;;
AF06 	EQU	*-PRG.STRT 	;AF06
; first find the length of the message in the buffer
; by scanning for the zero at the end. Length goes in BC(d2.w)
	MOVE.W 	#$0,D2	 	; LD BC,$0
	MOVE.W 	#BUFFER,D3 	; LD DE,BUFFER
AF07 	EQU	*-PRG.STRT 	;AF07
	MOVE.B 	0(a4,D3.W), BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	LEA 	ENDFT(A5),A0 	; LD HL,(ENDFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADD.W 	D2,D1 		; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	LEA 	ENDFT(A5),A0 	; LD (ENDFT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	STARTBUFFER(A5),A0 	; LD BC,(STARTBUFFER)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F( BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	LEA 	ENDFT(A5),A0 	; LD HL,(ENDFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADD.W 	D2,D1 		; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	LEA 	ENDFT(A5),A0 	; LD (ENDFT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	STARTBUFFER(A5),A0 	; LD BC,(STARTBUFFER)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP NC,FTFULL
	BCS.S 	LAB.314 	;
	JMP 	FTFULL(A5) 	;
LAB.314:
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
; HL = (STARTFT)
	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	#1,0(a4,D1.W) 	; LD (HL),1 ;Initially occurances=1
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	#$0,0(a4,D1.W) 	; LD (HL),$0
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#BUFFER,D1 	; LD HL,BUFFER
	SUBQ.W 	#3,D2 	; DEC BC; DEC BC; DEC BC
	MOVE.W 	#ICOPY,D7 	; CALL ICOPY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.315 	;
	JMP 	SYS.RET(A5) 	;
LAB.315:
	JMP 	DISPLAYFREQUENCY(A5) 	; JP DISPLAYFREQUENCY
*;;
*;;-----
*;;
COMPARE 	EQU	*-PRG.STRT 	;COMPARE
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#INSENSITIVECOMPARE,D7 	; CALL INSENSITIVECOMPARE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR ; RET NZ ;Not case-insensitive the same
	BEQ.S 	LAB.316 	;
	JMP 	SYS.RET(A5) 	;
LAB.316:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#SENSITIVECOMPARE,D7 	; CALL SENSITIVECOMPARE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Compare word in buffer with dictionary entry at HL
*;;Returns 'Z' if identical
*;;'NZ' and 'C' if buffer alphabetically before dictionary
*;;
INSENSITIVECOMPARE 	EQU	*-PRG.STRT 	;INSENSITIVECOMPARE
	ROR.W 	#8,D2 	; LD B,(HL) ;B=Length dictionary entry
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#3,D1 	; INC HL, INC HL, INC HL
	SUB.W 	#$300,D2 	; DEC B; DEC B; DEC B
	MOVE.W 	#BUFFER,D3 	; LD DE,BUFFER
ICOMP1 	EQU	*-PRG.STRT 	;ICOMP1
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,ICOMP2
	BNE.S 	LAB.317 	;
	JMP 	ICOMP2(A5) 	;
LAB.317:
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,ICOMP3
	BNE.S 	LAB.318 	;
	JMP 	ICOMP3(A5) 	;
LAB.318:
*;;
*;;Do comparison on case-insensitivity first
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 	; RES 7,A
	MOVE.W 	#UPPER,D7 	; CALL UPPER
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	BCLR 	#7,d0 	; RES 7,A
	MOVE.W 	#UPPER,D7 	; CALL UPPER
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; CP B
	CMP.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.319 	;
	JMP 	SYS.RET(A5) 	;
LAB.319:
*				;;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D3 	; INC DE
	SUB.W 	#$100,D2 	; DEC B
	JMP 	ICOMP1(A5) 	; JR ICOMP1
*;;
*;;End of dictionary entry. Check if also end of
*;;buffer.
*;;
ICOMP2 	EQU	*-PRG.STRT 	;ICOMP2
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z;Both end together
	BNE.S 	LAB.320 	;
	JMP 	SYS.RET(A5) 	;
LAB.320:
	MOVE.B 	#1,D0 	; LD A,1;Return 'NZ' and 'NC'
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;Buffer ends but dictionary entry does not
*;;
ICOMP3 	EQU	*-PRG.STRT 	;ICOMP3
	MOVE.B 	#1,D0 	; LD A,1;Return 'NZ' and 'C'
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	OR.B 	#17,F+1(A5) 	; SCF 
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Compare word in buffer with dictionary entry at HL
*;;Returns 'Z' if identical,
*;;'NZ' and 'C' if buffer alphabetically before dictionary.
*;;
SENSITIVECOMPARE 	EQU	*-PRG.STRT 	;SENSITIVECOMPARE
	ROR.W 	#8,D2 	; LD B,(HL) ;Length of dictionary entry
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,P 	SCOMP3(A5) 	;
LAB.322:
*				;;
	SUBQ.W 	#2,D6 	; PUSH BC ;LD A,(HL):CP (DE)
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	BCLR 	#7,d0 	; RES 7,A
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#UPPER,D7 	; CALL UPPER
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; CP B
	CMP.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE 	F(A5),SR 	; JR NZ,SCOMP1D
	BEQ.S 	LAB.323 	;
	JMP 	SCOMP1D(A5) 	;
LAB.323:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 	; RES P 	SCOMP3(A5) 	;
LAB.322:
*				;;
	SUBQ.W 	#2,D6 	; PUSH BC ;LD A,(HL):CP (DE)
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	BCLR 	#7,d0 	; RES 7,A
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#UPPER,D7 	; CALL UPPER
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; CP B
	CMP.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE 	F(A5),SR 	; JR NZ,SCOMP1D
	BEQ.S 	LAB.323 	;
	JMP 	SCOMP1D(A5) 	;
LAB.323:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 	; RES 7,A
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#UPPER,D7 	; CALL UPPER
	JSR 	SYS.JSR(A5) 	;
	ROR.W 	#8,D2 	; CP B
	CMP.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	MOVE 	F(A5),SR 	; JR Z,SCOMP1A
	BNE.S 	LAB.324 	;
	JMP 	SCOMP1A(A5) 	;
LAB.324:
SCOMP1D 	EQU	*-PRG.STRT 	;SCOMP1D
*				;;One char is lower case
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	ROR.W 	#8,D2 	; CP B
	CMP.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
	JMP 	SCOMP1B(A5) 	; JR SCOMP1B
*				;;Not lower case so escape flag does not matter
SCOMP1A 	EQU	*-PRG.STRT 	;SCOMP1A
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	BCLR 	#7,d0 	; RES 7,A
	ROR.W 	#8,D2 	; LD B,A
	MOVE.B 	D0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	BCLR 	#7,d0 	; RES 7,A
	ROR.W 	#8,D2 	; CP B
	CMP.B 	D2,D0 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	;
SCOMP1B 	EQU	*-PRG.STRT 	;SCOMP1B
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.325 	;
	JMP 	SYS.RET(A5) 	;
LAB.325:
*				;;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D3 	; INC DE
	SUB.W 	#$100,D2 	; DEC B
	JMP 	SCOMP1(A5) 	; JR SCOMP1
*				;;
*				;;End of entry. Check if also end of buffer.
SCOMP2 	EQU	*-PRG.STRT 	;SCOMP2
	MOVE.B 	0(a4,D3.W),D0 	; LD A,(DE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z;Both end together
	BNE.S 	LAB.326 	;
	JMP 	SYS.RET(A5) 	;
LAB.326:
	MOVE.B 	#1,D0 	; LD A,1 ;Return 'NZ' and 'NC'
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;Buffer ends but dictionary entry does not
*				;;
SCOMP3 	EQU	*-PRG.STRT 	;SCOMP3
	MOVE.B 	#1,D0 	; LD A,1 ;Return 'NZ' and 'C'
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	OR.B 	#17,F+1(A5) 	; SCF 
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Compare HL with (ENDFT). Returns 'NC' if HL >= (ENDFT)
*;;
CHECKENDFT 	EQU	*-PRG.STRT 	;CHECKENDFT
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	LEA 	ENDFT(A5),A0 	; LD DE,(ENDFT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
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
*				;;Word longer that buffer
*				;;
TOOLONG 	EQU	*-PRG.STRT 	;TOOLONG
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Word too long" 	; DEFM "Word too long"
	DC.B 	0 	; DEFB 0
 even
	JMP 	DISPLAYLINENUM(A5) 	; JP DISPLAYLINENUM ;Ends in WARMSTART
*				;;
*				;;-----
*				;;
*				;;Frequency Table full.
*				;;
FTFULL 	EQU	*-PRG.STRT 	;FTFULL
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"'Frequency Table' full" 	; DEFM "'Frequency Table' full"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE3ERROR(A5) 	; JP PHASE3ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
*				;;-----
*				;;
*				;;Too many words
*				;;
TOOMANY 	EQU	*-PRG.STRT 	;TOOMANY
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"More than $0F80 words" 	; DEFM "More than $0F80 words"
	DC.B 	0 	; DEFB 0
 even
	JMP 	PHASE3ERROR(A5) 	; JP PHASE3ERROR ;Calls DISPLAYLINENUM then WARMSTART
*				;;
*				;;-----
*				;;
PHASE3ERROR 	EQU	*-PRG.STRT 	;PHASE3ERROR
	JMP 	DISPLAYLINENUM(A5) 	; JP DISPLAYLINENUM ;Ends in WARMSTART
*;;
*;;-----
*;;
*;;Phase 4 - (Optional) Display 'Frequency Table'
*;;
*;;Phase 4 Displays the Sorted 'Frequency Table'
*;;list of all 'words'.
*;;
*;;-----
*;;
PHASE04 	EQU	*-PRG.STRT 	;PHASE04
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 4 - (Optional) Display 'Frequency Table'" ; ...
	DC.B 	ASCIICR,0 	; DEFB ASCIICR,0
 even
*				;;
	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	JMP 	PD01(A5) 	; JR PD01
PD02 	EQU	*-PRG.STRT 	;PD02
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#CHARACTERCOUNTS,D1 	; LD HL,CHARACTERCOUNTS
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
PD03 	EQU	*-PRG.STRT 	;PD03
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	#128,D0 	; CP 128
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.329 	;
	JMP 	SYS.RET(A5) 	;
LAB.329:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W	JMP 	PD01(A5) 	; JR PD01
PD02 	EQU	*-PRG.STRT 	;PD02
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#CHARACTERCOUNTS,D1 	; LD HL,CHARACTERCOUNTS
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
PD03 	EQU	*-PRG.STRT 	;PD03
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	#128,D0 	; CP 128
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.329 	;
	JMP 	SYS.RET(A5) 	;
LAB.329:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	0(a4,D1.W),D3 	; LD E,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D3 	; LD D,(HL)
	MOVE.B 	0(a4,D1.W),D3 	;
	ROR.W 	#8,D3 	;
	ROR.W 	#8,D3 	; LD A,D
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	OR.B 	D3,D0 	; OR E
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PD04
	BNE.S 	LAB.330 	;
	JMP 	PD04(A5) 	;
LAB.330:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Character $" 	; DEFM "Character $"
	DC.B 	0 	; DEFB 0
 even
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	MOVE.W 	#DISPLAYAHEX,D7 	; CALL DISPLAYAHEX
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" occurances = " 	; DEFM " occurances = "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#DISPLAYDECIMAL,D7 	; CALL DISPLAYDECIMAL
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
PD04 	EQU	*-PRG.STRT 	;PD04
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADD.W 	#$100,D2 	; INC B
	JMP 	PD03(A5) 	; JR PD03
*				;;
*				;;-----
*				;;
*				;;Display a single entry from the 'Frequency Table'.
*				;;HL is the address of the entry.
*				;;
DISPLAYFREQUENCY 	EQU	*-PRG.STRT 	;DISPLAYFREQUENCY
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Occurances = " 	; DEFM "Occurances = "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL) ;Length
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL) ;Occurances
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ROR.W 	#8,D1 	; LD H,B
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,D1 	;
	ROR.W 	#8,D2 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D2,D1 	; LD L,C
	MOVE.W 	#DISPLAYHLBOTH,D7 	; CALL DISPLAYHLBOTH
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" Word = " 	; DEFM " Word = "
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	SUBQ.B 	#1,D2 	; DEC C
	SUBQ.B 	#1,D2 	; DEC C
	SUBQ.B 	#1,D2 	; DEC C
*				;;
*				;;Display word 
*				;;
LF01 	EQU	*-PRG.STRT 	;LF01
	MOVE.B 	D2,D0 	; LD A,C
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP Z,NEWLINE
	BNE.S 	LAB.331 	;
	JMP 	NEWLINE(A5) 	;
LAB.331:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#DISPLAYCODE,D7 	; CALL DISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	SUBQ.B 	#1,D2 	; DEC C
	JMP 	LF01(A5) 	; JR LF01
*;;
*;;-----
*;;
*;;Phase 5 - Construct 'Common Word Dictionary'
*;;
*;;Phase 5 scans the 'Frequency Table' and picks
*;;most often used words. this are built into the 'Common
*;;Word Dictionary' at address (STARTCWT) thru (ENDCWT)-1.
*;;
*;;-----
*;;
PHASE05 	EQU	*-PRG.STRT 	;PHASE05
;	MOVE.W 	#TRACE,D7 	; CALL TRACE
;	JSR 	SYS.JSR(A5) 	;
	jsr prs
	DC.B 	"Phase 5 - Construct 'Common Word Dictionary'" 	;
	DC.B 	ASCIICR,0 	; DEFB ASCIICR,0
 even
*				;;
*				;;Clear 'Common Word Dictionary'
*				;;
	LEA 	ENDFT(A5),A0 	; LD HL,(ENDFT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTCWT(A5),A0 	; LD (STARTCWT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	LEA 	ENDCWT(A5),A0 	; LD (ENDCWT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
*				;;Select each word in 'Frequency Table' and asses it for
*				;;insertion into the 'Common Word Dictionary'.
*				;;
	MOVE.W 	#$0,D1 	; LD HL,$0
	LEA 	WORDNUMBER(	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	LEA 	FREQUENCYTIMES(A5),A0 	; LD (FREQUENCYTIMES),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL ;Check if a 'typed' entry
	MOVE.W 	#ASSESSCOMMONWORD,D7 	; CALL ASSESSCOMMONWORD
	JSR 	SYS.JSR(A5) 	;
	LEA 	WORDNUMBER(A5),A0 	; LD HL,(WORDNUMBER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	WORDNUMBE	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	LEA 	FREQUENCYTIMES(A5),A0 	; LD (FREQUENCYTIMES),BC
	MOVE.B 	D2,(A0) 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,1(A0) 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL ;Check if a 'typed' entry
	MOVE.W 	#ASSESSCOMMONWORD,D7 	; CALL ASSESSCOMMONWORD
	JSR 	SYS.JSR(A5) 	;
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
*				;;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	JMP 	PE01(A5) 	; JR PE01
*				;;
*				;;Go through each 'character' used and asses each to be
*				;;a common reference.
*				;;
PE02 	EQU	*-PRG.STRT 	;PE02
	MOVE.W 	#CHARACTERCOUNTS,D1 	; LD HL,CHARACTERCOUNTS
	ROR.W 	#8,D2 	; LD B,0
	MOVE.B 	#0,D2 	;
	ROR.W 	#8,D2 	;
PE03 	EQU	*-PRG.STRT 	;PE03
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	ROR.W 	#8,D2 	; LD C,B
	MOVE.B 	D2,D7 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D7,D2 	;
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#$0F80,D1 	; LD HL,$0F80
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.B 	0(a4,D1.W),D3 	; LD E,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D3 	; LD D,(HL)
	MOVE.B 	0(a4,D1.W),D3 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	FREQUENCYTIMES(A5),A0 	; LD (FREQUENCYTIMES),DE
	MOVE.B 	D3,(A0) 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	D3,1(A0) 	;
	ROR.W 	#8,D3 	;
	ROR.W 	#8,D3 	; LD A,D
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	OR.B 	D3,D0 	; OR E
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PE04
	BNE.S 	LAB.333 	;
	JMP 	PE04(A5) 	;
LAB.333:
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	#'|',D0 	; CP '|' ;End of parse marker
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,PE04
	BNE.S 	LAB.334 	;
	JMP 	PE04(A5) 	;
LAB.334:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	#ASSESSCOMMONWORD,D7 	; CALL ASSESSCOMMONWORD
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
PE04 	EQU	*-PRG.STRT 	;PE04
	ADD.W 	#$100,D2 	; INC B
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	CMP.B 	#128,D0 	; CP 128
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,PE03
	BEQ.S 	LAB.335 	;
	JMP 	PE03(A5) 	;
LAB.335:
*				;;
	MOVE.W 	#$200,D1 	; LD HL,$200
	LEA 	FREQUENCYTIMES(A5),A0 	; LD (FREQUENCYTIMES),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
*				;;
	MOVE.W 	#$1FAE,D1 	; LD HL,$1FAE ;dot space
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#ASSESSCOMMONREF,D7 	; CALL ASSESSCOMMONREF
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#$1FAC,D1 	; LD HL,$1FAC ;comma space
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#ASSESSCOMMONREF,D7 	; CALL ASSESSCOMMONREF
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#$1FBA,D1 	; LD HL,$1FBA ;colon space
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#ASSESSCOMMONREF,D7 	; CALL ASSESSCOMMONREF
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.W 	#$2FA2,D1 	; LD HL,$2FA2 ;space quote
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#ASSESSCOMMONREF,D7 	; CALL ASSESSCOMMONREF
	JSR 	SYS.JSR(A5) 	;
*				;;
*				;;Convert 'Frequency Table' addresses to word references
*				;;
	LEA 	STARTCWT(A5),A0 	; LD HL,(STARTCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D3 	; LD D,H
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,D3 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	D1,D3 	; LD E,L
PE05 	EQU	*-PRG.STRT 	;PE05
	MOVE.W 	#CHECKENDCWT,D7 	; CALL CHECKENDCWT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,PE06
	BCS.S 	LAB.336 	;
	JMP	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,PE09
	BEQ.S 	LAB.337 	;
	JMP 	PE09(A5) 	;
LAB.337:
*				;;
*				;;Display 'Common Word Dictionary'
*				;;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	LEA 	STARTCWT(A5),A0 	; LD HL,(STARTCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
PE07 	EQU	*-PRG.STRT 	;PE07
	MOVE.W 	#CHECKENDCWT,D7 	; CALL CHECKENDCWT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,P	MOVE.B 	DEBUG(A5),D0 	; LD A,(DEBUG)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,PE09
	BEQ.S 	LAB.337 	;
	JMP 	PE09(A5) 	;
LAB.337:
*				;;
*				;;Display 'Common Word Dictionary'
*				;;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	LEA 	STARTCWT(A5),A0 	; LD HL,(STARTCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
PE07 	EQU	*-PRG.STRT 	;PE07
	MOVE.W 	#CHECKENDCWT,D7 	; CALL CHECKENDCWT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,PE08
	BCS.S 	LAB.338 	;
	JMP 	PE08(A5) 	;
LAB.338:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ROR.W 	#8,D3 	; LD D,(HL)
	MOVE.B 	0(a4,D1.W),D3 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D3 	; LD E,(HL)
	MOVE.W 	#DISPLAYWORD,D7 	; CALL DISPLAYWORD
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	PE07(A5) 	; JR PE07
PE08 	EQU	*-PRG.STRT 	;PE08
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIICR,0 	; DEFB ASCIICR,ASCIICR,0
 even
*				;;
*				;;Display length of 'Common Word Dictionary'
*				;;
PE09 	EQU	*-PRG.STRT 	;PE09
	MOVE.B 	NOISY(A5),D0 	; LD A,(NOISY)
	CMP.B 	#'Y',D0 	; CP 'Y'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.339 	;
	JMP 	SYS.RET(A5) 	;
LAB.339:
*				;;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"Length of 'Common Word Dictionary' =" 	; DEFM "Length of 'Common Word Dictionary' ="
	DC.B 	0 	; DEFB 0
 even
	LEA 	ENDCWT(A5),A0 	; LD HL,(ENDCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	LEA 	STARTCWT(A5),A0 	; LD DE,(STARTCWT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
	MOVE.W 	#DISPLAYBYTESFREE,D7 	; CALL DISPLAYBYTESFREE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#NEWLINE,D7 	; CALL NEWLINE
	JSR 	SYS.JSR(A5) 	;
	JMP 	NEWLINE(A5) 	; JP NEWLINE
*				;;
*				;;-----
*				;;
*				;;Display word reference 'DE'
*				;;
DISPLAYWORD 	EQU	*-PRG.STRT 	;DISPLAYWORD
	ROR.W 	#8,D3 	; LD A,D ;1tttiiii, ttt is word type
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	LSR.B 	#1,D0 	; SRL A
	MOVE 	SR,F(A5) 	;
	LSR.B 	#1,D0 	; SRL A
	MOVE 	SR,F(A5) 	;
	LSR.B 	#1,D0 	; SRL A
	MOVE 	SR,F(A5) 	;
	LSR.B 	#1,D0 	; SRL A
	MOVE 	SR,F(A5) 	;
	AND.B 	#$07,D0 	; AND $07
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,LW01
	BNE.S 	LAB.340 	;
	JMP 	LW01(A5) 	;
LAB.340:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#TYPETABLE,D1 	; LD HL,TYPETABLE
	ROR.W 	#8,D2 	; LD B,0
	MOVE.B 	#0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D0,D2 	; LD C,A
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	MOVE.B 	#'^',D0 	; LD A,'^'
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
LW01 	EQU	*-PRG.STRT 	;LW01
*				;;
	ROR.W 	#8,D3 	; LD A,D
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	AND.B 	#$0F,D0 	; AND $0F
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D1 	; LD H,A
	MOVE.B 	D0,D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D3,D1 	; LD L,E
	MOVE.W 	#$0F80,D2 	; LD BC,$0F80
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,LW04
	BCC.S 	LAB.341 	;
	JMP 	LW04(A5) 	;
LAB.341:
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" {" 	; DEFM " {"
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.B 	D1,D0 	; LD A,L
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,LW02
	BEQ.S 	LAB.342 	;
	JMP 	LW02(A5) 	;
LAB.342:
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"CR" 	; DEFM "CR"
	DC.B 	0 	; DEFB 0
 even
	JMP 	LW03(A5) 	; JR LW03
LW02 	EQU	*-PRG.STRT 	;LW02
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
LW03 	EQU	*-PRG.STRT 	;LW03
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"} " 	; DEFM "} "
	DC.B 	0 	; DEFB 0
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
LW04 	EQU	*-PRG.STRT 	;LW04
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	" [" 	; DEFM " ["
	DC.B 	0 	; DEFB 0
 even
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	ROR.W 	#8,D3 	; LD A,D
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	AND.B 	#$0F,D0 	; AND $0F
	MOVE 	F(A5),SR 	; JR Z,LW06
	BNE.S 	LAB.344 	;
	JMP 	LW06(A5) 	;
LAB.344:
*				;;
*				;;Move to next word
*				;;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	LW05(A5) 	; JR LW05
*				;;
*				;;Display the word
*				;;
LW06 	EQU	*-PRG.STRT 	;LW06
	ROR.W
	MOVE 	F(A5),SR 	; JR Z,LW06
	BNE.S 	LAB.344 	;
	JMP 	LW06(A5) 	;
LAB.344:
*				;;
*				;;Move to next word
*				;;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	ROR.W 	#8,D2 	; LD B,$0
	MOVE.B 	#$0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	LW05(A5) 	; JR LW05
*				;;
*				;;Display the word
*				;;
LW06 	EQU	*-PRG.STRT 	;LW06
	ROR.W 	#8,D2 	; LD B,(HL) ;Length
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	SUB.W 	#$100,D2 	; DEC B
	SUB.W 	#$100,D2 	; DEC B
	SUB.W 	#$100,D2 	; DEC B 
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
LW07 	EQU	*-PRG.STRT 	;LW07
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,LW08
	BNE.S 	LAB.345 	;
	JMP 	LW08(A5) 	;
LAB.345:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#DISPLAYCODE,D7 	; CALL DISPLAYCODE
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	SUB.W 	#$100,D2 	; DEC B
	JMP 	LW07(A5) 	; JR LW07
LW08 	EQU	*-PRG.STRT 	;LW08 
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"] ",0
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
TYPETABLE 	EQU	*-PRG.STRT 	;TYPETABLE
	DC.B 	' '	; DEFB ' ' ;No meaning
	DC.B 	'v' 	; DEFB 'v' ;Verb
	DC.B 	'j' 	; DEFB 'j' ;Conjunction
	DC.B 	'p' 	; DEFB 'p' ;Preposition
	DC.B 	'n' 	; DEFB 'n' ;Noun
	DC.B 	'a' 	; DEFB 'a' ;Adjective
	DC.B 	'c' 	; DEFB 'c' ;Proper Noun
	DC.B 	'u' 	; DEFB 'u' ;Captalised but no meaning
 even
*				;;
*				;;
*				;;-----
*				;;
*				;;If word is more 'Common' than those in Dictionary then it
*				;;replaces one of them. HL is address of Frequency entry.
*				;;
ASSESSCOMMONWORD 	EQU	*-PRG.STRT 	;ASSESSCOMMONWORD
	LEA 	WORDNUMBER(A5),A0 	; LD HL,(WORDNUMBER)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	AND.B 	#$0F,D0 	; AND $0F
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D1 	; LD H,A
	MOVE.B 	D0,D1 	;
	ROR.W 	#8,D1 	;
	LEA 	WORDNUMBER(A5),A0 	; LD (WORDNUMBER),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
ASSESSCOMMONREF 	EQU	*-PRG.STRT 	;ASSESSCOMMONREF
	LEA 	STARTCWT(A5),A0 	; LD HL,(STARTCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
AC01 	EQU	*-PRG.STRT 	;AC01
	MOVE.W 	#CHECKENDCWT,D7 	; CALL CHECKENDCWT
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,AC02
	BCS.S 	LAB.346 	;
	JMP 	AC02(A5) 	;
LAB.346:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ROR.W 	#8,D3 	; LD D,(HL)
	MOVE.B 	0(a4,D1.W),D3 	;
	ROR.W 	#8,D3 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D3 	; LD E,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL) ;Get occurrance count
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	FREQUENCYTIMES(A5),A0 	; LD HL,(FREQUENCYTIMES)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	MOVE 	F(A5),SR 	; JR C,AC03
	BCC.S 	LAB.347 	;
	JMP 	AC03(A5) 	;
LAB.347:
*				;;
*				;;Insert new Common Word
*				;;
AC02 	EQU	*-PRG.STRT 	;AC02
	SUBQ.W 	#2,D6 	; PUSH HL ;Address to insert
	MOVE.W 	D1,0(a4,D6.W) 	;
	LEA 	ENDMEMORY(A5),A0 	; LD HL,(ENDMEMORY)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	SUBQ.W 	#1,D1 	; DEC HL
	SUBQ.W 	#1,D1 	; DEC HL
	SUBQ.W 	#1,D1 	; DEC HL
	SUBQ.W 	#1,D1 	; DEC HL
	LEA 	ENDCWT(A5),A0 	; LD DE,(ENDCWT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JP C,CWTFULL
	BCC.S 	LAB.348 	;
	JMP 	CWTFULL(A5) 	;
LAB.348:
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
*				;;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	LEA 	ENDCWT(A5),A0 	; LD HL,(ENDCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,H
	ROR.W 	#8,D1 	;
	MOVE.B6 	;
	LEA 	WORDNUMBER(A5),A0 	; LD BC,(WORDNUMBER)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	ROR.W 	#8,D2 	; LD (HL),B
	MOVE.B 	D2,0(a4,D1.W) 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	FREQUENCYTIMES(A5),A0 	; LD BC,(FREQUENCYTIMES)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD (HL),B
	MOVE.B 	D2,0(a4,D1.W) 	;
	R6 	;
	LEA 	WORDNUMBER(A5),A0 	; LD BC,(WORDNUMBER)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	ROR.W 	#8,D2 	; LD (HL),B
	MOVE.B 	D2,0(a4,D1.W) 	;
	ROR.W 	#8,D2 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	FREQUENCYTIMES(A5),A0 	; LD BC,(FREQUENCYTIMES)
	MOVE.B 	1(A0),D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	(A0),D2 	;
	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD (HL),B
	MOVE.B 	D2,0(a4,D1.W) 	;
	ROR.W 	#8,D2 	;
*				;;
*				;;Adjust top of table pointer
*				;;
	LEA 	STARTCWT(A5),A0 	; LD HL,(STARTCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	MOVE.B 	COMMONMAXENTRIES(A5),D0 	; LD A,(COMMONMAXENTRIES)
	ROR.W 	#8,D2 	; LD B,0
	MOVE.B 	#0,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D0,D2 	; LD C,A
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,H
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,D2 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D1,D2 	; LD C,L
	LEA 	ENDCWT(A5),A0 	; LD HL,(ENDCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NC
	BCS.S 	LAB.349 	;
	JMP 	SYS.RET(A5) 	;
LAB.349:
	LEA 	ENDCWT(A5),A0 	; LD HL,(ENDCWT)
	MOVE.B 	1(A0),D1 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	(A0),D1 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	LEA 	ENDCWT(A5),A0 	; LD (ENDCWT),HL
	MOVE.B 	D1,(A0) 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,1(A0) 	;
	ROR.W 	#8,D1 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;Keep on moving down 'Common Word Dictionary'
*				;;
AC03 	EQU	*-PRG.STRT 	;AC03
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	AC01(A5) 	; JP AC01
*				;;
*				;;-----
*				;;
ILLEGALREFERENCE 	EQU	*-PRG.STRT 	;ILLEGALREFERENCE
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"SQUASH error. Invalid word number" 	; DEFM "SQUASH error. Invalid word number"
	DC.B 	0 	; DEFB 0
 even
	JMP 	EXITCPM(A5) 	; JP EXITCPM
*				;;
*				;;-----
*				;;
*				;;'Common Word Dictionary' full
*				;;
CWTFULL 	EQU	*-PRG.STRT 	;CWTFULL
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"'Common Word Dictionary' too big" 	; DEFM "'Common Word Dictionary' too big"
	DC.B 	0 	; DEFB 0
 even
	JMP 	WARMSTART(A5) 	; JP WARMSTART
*				;;
*				;;-----
*				;;
*				;;Compare HL with (ENDCWT). Returns 'NC' if HL >= (ENDCWT)
*				;;
CHECKENDCWT 	EQU	*-PRG.STRT 	;CHECKENDCWT
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	LEA 	ENDCWT(A5),A0 	; LD DE,(ENDCWT)
	MOVE.B 	1(A0),D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	(A0),D3 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
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
DISPLAYINPUTNAME 	EQU	*-PRG.STRT 	;DISPLAYINPUTNAME
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"B:MESSAGE.TXT " 	; DEFM "B:MESSAGE.TXT "
	DC.B 	0 	; DEFB 0
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
DISPLAYTEMPNAME 	EQU	*-PRG.STRT 	;DISPLAYTEMPNAME
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"B:SQUASH1.TMP " 	; DEFM "B:SQUASH1.TMP "
	DC.B 	0 	; DEFB 0
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
DISPLAYOUTPUTNAME 	EQU	*-PRG.STRT 	;DISPLAYOUTPUTNAME
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	"B:SQUASH.DAT " 	; DEFM "B:SQUASH.DAT "
	DC.B 	0 	; DEFB 0
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
G 	EQU	*-PRG.STRT 	;G