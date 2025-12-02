*******************************************************************
*            Z80 TO M68000 TRANSLATION  -  N. BROWN               *
*******************************************************************
*************  Data Areas and Initialisation Code *****************
*
        JMP     PRG.CODE        Jump around data areas
PRG.STRT:
F       EQU     *-PRG.STRT      Flags Register
        DS.W    1
I       EQU     *-PRG.STRT      Interrupt Register (not used)
        DS.W    1
R       EQU     *-PRG.STRT      Refresh Register (not used)
        DS.W    1
ALT.REGS EQU    *-PRG.STRT      Alternative register set
        DS.W    4
STAK.SIZ EQU    400             Default stack size
Z80.STAK DS.B   STAK.SIZ+2      Default Z80 Stack
*
PRG.CODE
;	LEA    PRG.STRT,A5     Set A5 to code base address
        LEA     Z80.STAK+STAK.SIZ,A0  Set up stack pointer ...
        SUBA.L  a5,A0           ... as a relative (word) value ...
        MOVE.W  A0,D6           ... in D6
 jmp origin(a5) * start real code
*
******************* Start Of Translated Code **********************
*
*				;;System disk version number
*				;;
*				;; 24/06/86
*				;;
*				;;VERSION.Z80
*				;;
*				;;Version 2.3:
MAJOR 	EQU	'2' 	;MAJOR EQU '2'
MINOR 	EQU	'3' 	;MINOR EQU '3'
*				;;
*				;; Torch/Acorn Z80 Standard Routines
*				;;
*				;; 06/01/86
*				;;
*				;; STANDARD.Z80
*				;;
*				;; Copyright (C) 1985 Level 9 Computing
*				;;
*				;;-----
*				;;
*				;;Entry to all standard CP/M functions:
;CPMENTRY 	EQU	$0005 	;CPMENTRY EQU $0005
*				;;
*				;;CPMENTRY 'E' register values:
CPNEXIT 	EQU	0 	;CPNEXIT EQU 0 ;Quit
CPNDCI 	EQU	$06 	;CPNDCI EQU $06 ;Direct Console I/O
CPNRST 	EQU	13 ;Reset 	;CPNRST EQU 13;Reset disk system
CPNOF 	EQU	15 ;Open 	;CPNOF  EQU 15;Open File
CPNCF 	EQU	16 ;Close 	;CPNCF  EQU 16;Close File
CPNDF 	EQU	19 ;Delete 	;CPNDF  EQU 19;Delete File
CPNRS 	EQU	20 ;Read 	;CPNRS  EQU 20;Read Sequential
CPNWS 	EQU	21 ;Write 	;CPNWS  EQU 21;Write Sequential
CPNMF 	EQU	22 ;Make 	;CPNMF  EQU 22;Make File
*				;;
*				;;Torch CPN bios calls:
USRLMM 	EQU	$FFC0 ;Call 	;USRLMM EQU $FFC0;Call user function
*				;;
*				;;Torch 1MHz bus drivers:
RX 	EQU	$FFC6 ;Get 	;RX EQU $FFC6;Get user function result
* .... Altered for now .....
TX 	EQU	0 ;Transmit 	;TX EQU $FFC9;Transmit
*				;;
*				;;Torch User Functions:
UFGES 	EQU	5 ;Get 	;UFGES EQU 5;Get Escape Status
UFUDC 	EQU	9 	;UFUDC EQU 9 ;Unslave disc cache
UFOSW 	EQU	12 	;UFOSW EQU 12 ;Osword
UFWSR 	EQU	14 	;UFWSR EQU 14 ;Write scratchpad ram
UFOSB 	EQU	15 	;UFOSB EQU 15 ;OsByte
*				;;
*				;;CP/M DMA buffer:
DMAADDR 	EQU	$0080 	;DMAADDR EQU $0080
DMALEN 	EQU	$80 	;DMALEN EQU $80
*				;;
FCBLENGTH 	EQU	$24 	;FCBLENGTH EQU $24 ;Length of File Control Block
SERIALFCBLENGTH 	EQU	FCBLENGTH+2+2000 ;****256
*				;;
*				;;Ascii/BBC control codes:
ASCIINULL 	EQU	$00 	;ASCIINULL EQU $00
ASCIIBELL 	EQU	$07 	;ASCIIBELL EQU $07
ASCIIBS 	EQU	$08 	;ASCIIBS EQU $08
ASCIILF 	EQU	$0A 	;ASCIILF EQU $0A
ASCIICR 	EQU	$0D 	;ASCIICR EQU $0D
ASCIIEOF 	EQU	$1A 	;ASCIIEOF EQU $1A
ASCIIESC 	EQU	$1B 	;ASCIIESC EQU $1B
ASCIIDEL 	EQU	$7F 	;ASCIIDEL EQU $7F
*				;;
*				;;squasherinputline buffer length
LINELENGTH 	EQU	80 	;LINELENGTH EQU 80 ;*
*				;;
*				;;-----
*				;;
*				;;'Vectors' for all driver Input/Output:
*				;;
ECHOINPUTCHARACTER 	EQU	*-PRG.STRT 	;ECHOINPUTCHARACTER JP squasheroswrch
	JMP 	squasheroswrch(A5) 	;
*				;;
GETINPUTCHARACTER 	EQU	*-PRG.STRT 	;GETINPUTCHARACTER JP squasherosrdch
	JMP 	squasherosrdcll to set up squashercomputertype. Required before STAR, FX calls
*				;;Disk writes.
*				;;
*				;;-----
 even
printchar
 bra driverprintchar
*				;;
*				;;Display NEWLINE sequence
*				;;(Preferred to send LF as well as this works with printer)
*				;;
squashercrlf 	EQU	*-PRG.STRT 	;squashercrlf
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIINULL 	; DEFB ASCIICR,ASCIINULL
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*;;Read bytesll to set up squashercomputertype. Required before STAR, FX calls
*				;;Disk writes.
*				;;
*				;;-----
 even
printchar
 bra driverprintchar
*				;;
*				;;Display NEWLINE sequence
*				;;(Preferred to send LF as well as this works with printer)
*				;;
squashercrlf 	EQU	*-PRG.STRT 	;squashercrlf
	MOVE.W 	#squasherprs,D7 	; CALL squasherprs
	JSR 	SYS.JSR(A5) 	;
	DC.B 	ASCIICR,ASCIINULL 	; DEFB ASCIICR,ASCIINULL
 even
	JMP 	SYS.RET(A5) 	; RET 
*				;;
*				;;-----
*				;;
*;;Read bytes from (HL) and increment HL until a
*;; non-space if found. Returns 'NC' and 'Z' if
*;; (HL)=NULL, 'C' and 'NZ' otherwise. Always A=(HL).
*				;;
READEOLN 	EQU	*-PRG.STRT 	;READEOLN LD A,(HL)
	MOVE.B 	0(a4,D1.W),D0 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.803 	;
	JMP 	SYS.RET(A5) 	;
LAB.803:
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	OR.B 	#17,F+1(A5) 	; SCF 
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.804 	;
	JMP 	SYS.RET(A5) 	;
LAB.804:
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	READEOLN(A5) 	; JR READEOLN
*				;;
*;;-----
*;;
*;;Quit user program via CP/M warm start
*;;
EXITCPM 	EQU	*-PRG.STRT 	;EXITCPM
 bsr prs
 dc.b "Exit to tos",cr,0
 even
	MOVE.B 	#CPNEXIT,D2 	; LD C,CPNEXIT
	JMP 	CPMENTRY(A5) 	; JP CPMENTRY
*				;;
*				;;-----
*				;;
*;;Scan memory for a valid 16 bit hex number, Optionally
*;;preceeded by spaces and terminated by either a space
*;;or null.
*;;
READADDRESS 	EQU	*-PRG.STRT 	;READADDRESS
	MOVE.W 	#READEOLN,D7 	; CALL READEOLN ;Used to skip spaces
	JSR 	SYS.JSR(A5) 	;
	EOR.B 	#17,F+1(A5) 	; CCF 
	MOVE 	F(A5),SR 	; RET C ;NULL found
	BCC.S 	LAB.805 	;
	JMP 	SYS.RET(A5) 	;
LAB.805:
	MOVE.W 	#$0000,D2 	; LD BC,$0000
READADDR01 	EQU	*-PRG.STRT 	;READADDR01 LD A,(HL)
	MOVE.B 	0(a4,D1.W),D0 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,READADDR04
	BNE.S 	LAB.806 	;
	JMP 	READADDR04(A5) 	;
LAB.806:
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,READADDR04
	BNE.S 	LAB.807 	;
	JMP 	READADDR04(A5) 	;
LAB.807:
	CMP.B 	#'0',D0 	; CP '0'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET C
	BCC.S 	LAB.808 	;
	JMP 	SYS.RET(A5) 	;
LAB.808:
	CMP.B 	#'9'+1,D0 	; CP '9'+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,READADDR02
	BCS.S 	LAB.809 	;
	JMP 	READADDR02(A5) 	;
LAB.809:
	SUB.B 	#'0',D0 	; SUB '0'
	MOVE 	SR,F(A5) 	;
	JMP 	READADDR03(A5) 	; JR READADDR03
READADDR02 	EQU	*-PRG.STRT 	;READADDR02 CALL UPPER
	MOVE.W 	#UPPER,D7 	;
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'A',D0 	; CP 'A'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET C
	BCC.S 	LAB.810 	;
	JMP 	SYS.RET(A5) 	;
LAB.810:
	CMP.B 	#'F'+1,D0 	; CP 'F'+1
	MOVE 	SR,F(A5) 	;
	EOR.B 	#17,F+1(A5) 	; CCF 
	MOVE 	F(A5),SR 	; RET C
	BCC.S 	LAB.811 	;
	JMP 	SYS.RET(A5) 	;
LAB.811:
	SUB.B 	#'A'-10,D0 	; SUB 'A'-10
	MOVE 	SR,F(A5) 	;
READADDR03 	EQU	*-PRG.STRT 	;READADDR03 PUSH HL
	SUBQ.W 	#2,D6 	;
	MOVE.W 	D1,0(a4,D6.W) 	;
	ROR.W 	#8,D1 	; LD H,B
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,D1 	;
	ROR.W 	#8,D2 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D2,D1 	; LD L,C
	ADD.W 	D1,D1 	; ADD HL,HL 
	MOVE 	SR,F(A5) 	;
	ADD.W 	D1,D1 	; ADD HL,HL 
	MOVE 	SR,F(A5) 	;
	ADD.W 	D1,D1 	; ADD HL,HL 
	MOVE 	SR,F(A5) 	;
	ADD.W 	D1,D1 	; ADD HL,HL 
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,$00
	MOVE.B 	#$00,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D0,D2 	; LD C,A
	ADD.W 	D2,D1 	; ADD HL,BC 
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D2 	; LD B,H
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,D2 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D2 	;
	MOVE.B 	D1,D2 	; LD C,L
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ADDQ.W 	#1,D1 	; INC HL
	JMP 	READADDR01(A5) 	; JR READADDR01
READADDR04 	EQU	*-PRG.STRT 	;READADDR04 XOR A
	EOR.B 	D0,D0 	;
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Display character
*;;
squasheroswrch 	EQU	*-PRG.STRT 	;squasheroswrch
	CMP.B 	#ASCIIEOF,D0 	; CP ASCIIEOF
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.812 	;
	JMP 	SYS.RET(A5) 	;
LAB.812:
*				;;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	#DISPLAYCONTROL,D7 	; CALL DISPLAYCONTROL
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#ASCIICR,D0 	; CP ASCIICR
	MOVE 	SR,F(A5) 	;
	MOVE.B 	#ASCIILF,D0 	; LD A,ASCIILF
	MOVE 	F(A5),SR 	; CALL Z,DISPLAYCONTROL
	BNE.S 	LAB.813 	;
	MOVE.W 	#DISPLAYCONTROL,D7 	;
	JSR 	SYS.JSR(A5) 	;
LAB.813:
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Display raw byte data
*;;
DISPLAYCONTROL 	EQU	*-PRG.STRT 	;DISPLAYCONTROL
	move.b d0,(a6)
	move.b #oswrchdcode,d0
	bsr driver

	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Execute valid '*' command.
*;;Hangs in place of 'Bad command'
*;;
STAR 	EQU	*-PRG.STRT 	;STAR
	JMP 	SYS.RET(A5) 	;
*;;-----
*;;
*;;Copy contents of SYSTEMFCB to block of memory
*;;
SAVESYSTEMFCB 	EQU	*-PRG.STRT 	;SAVESYSTEMFCB
	JMP 	SYS.RET(A5) 	; RET *****
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Execute valid '*' command.
*;;Hangs in place of 'Bad command'
*;;
STAR 	EQU	*-PRG.STRT 	;STAR
	JMP 	SYS.RET(A5) 	;
*;;-----
*;;
*;;Copy contents of SYSTEMFCB to block of memory
*;;
SAVESYSTEMFCB 	EQU	*-PRG.STRT 	;SAVESYSTEMFCB
	JMP 	SYS.RET(A5) 	; RET *****
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#SYSTEMFCB,D1 	; LD HL,SYSTEMFCB
	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Copy FCBLENGTH bytes from memory to SYSTEMFCB.
*;;
LOADSYSTEMFCB 	EQU	*-PRG.STRT 	;LOADSYSTEMFCB
	JMP 	SYS.RET(A5) 	; RET ***********
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;-----
*;;-----
*;;
*;;Open system file for reading multiples of pages
*;;
OPENSYSTEMREAD 	EQU	*-PRG.STRT 	;OPENSYSTEMREAD
	JMP 	SYS.RET(A5) 	; RET *******
	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
	MOVE.B 	#CPNOF,D2 	; LD C,CPNOF ;Open file
	MOVE.W 	#CPMENTRY,D7 	; CALL CPMENTRY
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#4,D0 	; CP 4
	MOVE 	SR,F(A5) 	;
	EOR.B 	#17,F+1(A5) 	; CCF 
	JMP 	SYS.RET(A5) 	; RET ;Return 'C' if A=$FF (Not found)
*;;
*;;-----
*;;-----
READSECTOR 	EQU	*-PRG.STRT 	;READSECTOR
	JMP 	SYS.RET(A5) 	; RET *********
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	MOVE.B 	#CPNRS,D2 	; LD C,CPNRS ;Read sequential
	MOVE.W 	#CPMENTRY,D7 	; CALL CPMENTRY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,READSECTOR01
	BEQ.S 	LAB.830 	;
	JMP 	READSECTOR01(A5) 	;
LAB.830:
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#DMAADDR,D1 	; LD HL,DMAADDR
	MOVE.W 	#DMALEN,D2 	; LD BC,DMALEN
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
READSECTOR01 	EQU	*-PRG.STRT 	;READSECTOR01 POP AF
	MOVE.W 	0(a4,D6.W),D0 	;
	ADDQ.W 	#2,D6 	;
	OR.B 	#17,F+1(A5) 	; SCF 
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Close read or write file
*;;
CLOSESYSTEMREAD 	EQU	*-PRG.STRT 	;CLOSESYSTEMREAD
CLOSESYSTEMWRITE 	EQU	*-PRG.STRT 	;CLOSESYSTEMWRITE
	JMP 	SYS.RET(A5) 	; RET ********
	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
	MOVE.B 	#CPNCF,D2 	; LD C,CPNCF ;Close file
	MOVE.W 	#CPMENTRY,D7 	; CALL CPMENTRY
	JSR 	SYS.JSR(A5) 	;
*				;;
*				;;No return code
	JMP 	STOPFCB(A5) 	; JP STOPFCB
*;;
*;;-----
*;;
*;;Wipe all bytes in FCB at (HL) except thoses requires for
*;;DISPLAYNAME.
*;;
STOPFCB 	EQU	*-PRG.STRT 	;STOPFCB
	JMP 	SYS.RET(A5) 	; RET *******
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.W 	#12,D2 	; LD BC,12 ;Skip Drive/Name/Type
	ADD.W 	D2,D1 	; ADD HL,BC
	MOVE 	SR,F(A5) 	;
*				;;
	MOVE.B 	#0,0(a4,D1.W) 	; LD (HL),0
	ROR.W 	#8,D3 	; LD D,H
	ROR.W 	#8,D1 	;
	MOVE.B 	D1,D3 	;
	ROR.W 	#8,D1 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	D1,D3 	; LD E,L
	ADDQ.W 	#1,D3 	; INC DE
	MOVE.W 	#FCBLENGTH-12,D2 	; LD BC,FCBLENGTH-12
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Open system file for writing multiples of pages
*;;
OPENSYSTEMWRITE 	EQU	*-PRG.STRT 	;OOR A
	JMP 	SYS.RET(A5) 	; RET ********
	OR.B 	D0,D0 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.831 	;
	JMP 	SYS.RET(A5) 	;
LAB.831:
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	#WRITESECTOR,D7 	; CALL WRITESECTOR
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR C,WRITESYSTEM01
	BCC.S 	LAB.832 	;
	JMP 	WRITESYSTEM01(A5) 	;
LAB.832:
	MOVE.W 	#WRITESECTOR,D7 	; CALL WRITESECTOR
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR C,WRITESYSTEM01
	BCC.S 	LAB.833 	;
	JMP 	WRITOR A
	JMP 	SYS.RET(A5) 	; RET ********
	OR.B 	D0,D0 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.831 	;
	JMP 	SYS.RET(A5) 	;
LAB.831:
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	#WRITESECTOR,D7 	; CALL WRITESECTOR
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR C,WRITESYSTEM01
	BCC.S 	LAB.832 	;
	JMP 	WRITESYSTEM01(A5) 	;
LAB.832:
	MOVE.W 	#WRITESECTOR,D7 	; CALL WRITESECTOR
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR C,WRITESYSTEM01
	BCC.S 	LAB.833 	;
	JMP 	WRITESYSTEM01(A5) 	;
LAB.833:
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	SUBQ.B 	#1,D0 	; DEC A
	JMP 	WRITESYSTEMPAGES(A5) 	; JR WRITESYSTEMPAGES
*				;;
WRITESYSTEM01 	EQU	*-PRG.STRT 	;WRITESYSTEM01 POP AF
	MOVE.W 	0(a4,D6.W),D0 	;
	ADDQ.W 	#2,D6 	;
	MOVE.W 	#CLOSESYSTEMWRITE,D7 	; CALL CLOSESYSTEMWRITE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#DELETESYSTEM,D7 	; CALL DELETESYSTEM
	JSR 	SYS.JSR(A5) 	;
	OR.B 	#17,F+1(A5) 	; SCF 
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
WRITESECTOR 	EQU	*-PRG.STRT 	;WRITESECTOR
	JMP 	SYS.RET(A5) 	; RET ********
	MOVE.W 	#DMAADDR,D3 	; LD DE,DMAADDR
	MOVE.W 	#DMALEN,D2 	; LD BC,DMALEN
	JSR 	SYS.LDIR(A5) 	; LDIR 
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
	MOVE.B 	#CPNWS,D2 	; LD C,CPNWS ;Write sequential
	MOVE.W 	#CPMENTRY,D7 	; CALL CPMENTRY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.834 	;
	JMP 	SYS.RET(A5) 	;
LAB.834:
	OR.B 	#17,F+1(A5) 	; SCF 
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Delete file
*;;
DELETESYSTEM 	EQU	*-PRG.STRT 	;DELETESYSTEM
	JMP 	SYS.RET(A5) 	; RET ********
	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
	MOVE.B 	#CPNDF,D2 	; LD C,CPNDF ;Delete file
	MOVE.W 	#CPMENTRY,D7 	; CALL CPMENTRY
	JSR 	SYS.JSR(A5) 	;
*				;;
	MOVE.B 	squashercomputertype(A5),D0 	; LD A,(squashercomputertype)
	CMP.B 	#1,D0 	; CP 1 ;Torch
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NZ
	BEQ.S 	LAB.835 	;
	JMP 	SYS.RET(A5) 	;
LAB.835:
*;;
*;;On Torch system clear BBC cache buffer:
*;;
	MOVE.W 	#USRLMM,D7 	; CALL USRLMM
	JSR 	SYS.JSR(A5) 	;
	DC.B 	UFUDC 	; DEFB UFUDC
 even
*				;;
	MOVE.B 	#CPNRST,D2 	; LD C,CPNRST
	JMP 	CPMENTRY(A5) 	; JP CPMENTRY
*;;
*;;-----
*;;
*;;Call 'RESET' only when no files open
*;;'CLEARFCB' initialises FCB before OPEN.
*;;
RESET 	EQU	*-PRG.STRT 	;RESET
	JMP 	SYS.RET(A5) 	; RET ********
	MOVE.B 	#CPNRST,D2 	; LD C,CPNRST ;Reset disk system
	JMP 	CPMENTRY(A5) 	; JP CPMENTRY
*				;;
RESETANDCLEARFCB 	EQU	*-PRG.STRT 	;RESETANDCLEARFCB
	MOVE.W 	#RESET,D7 	; CALL RESET
	JSR 	SYS.JSR(A5) 	;
CLEARFCB 	EQU	*-PRG.STRT 	;CLEARFCB
	MOVE.W 	#SYSTEMFCB,D1 	; LD HL,SYSTEMFCB
	MOVE.W 	#SYSTEMFCB+1,D3 	; LD DE,SYSTEMFCB+1
	MOVE.W 	#FCBLENGTH-1,D2 	; LD BC,FCBLENGTH-1
	MOVE.B 	#' ',D0 	; LD A,' '
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	JSR 	SYS.LDIR(A5) 	; LDIR 
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,SYSTEMFCBDRIVE(A5) 	; LD (SYSTEMFCBDRIVE),A
	MOVE.B 	D0,SYSTEMFCBEX(A5) 	; LD (SYSTEMFCBEX),A
	MOVE.B 	D0,SYSTEMFCBCR(A5) 	; LD (SYSTEMFCBCR),A
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Display file name contained in SYSTEMFCB.
*;;
DISPLAYNAME 	EQU	*-PRG.STRT 	;DISPLAYNAME
	MOVE.B 	SYSTEMFCBDRIVE(A5),D0 	; LD A,(SYSTEMFCBDRIVE)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,DISPLAYNAME1
	BNE.S 	LAB.836 	;
	JMP 	DISPLAYNAME1(A5) 	;
LAB.836:
	ADD.B 	#'A'-1,D0 	; ADD A,'A'-1
	MOVE 	SR,F(A5) 	;
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#':',D0 	; LD A,':'
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
DISPLAYNAME1 	EQU	*-PRG.STRT 	;DISPLAYNAME1 LD HL,SYSTEMFCBNAME
	MOVE.W 	#SYSTEMFCBNAME,D1 	;
	ROR.W 	#8,D2 	; LD B,$08
	MOVE.B 	#$08,D2 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#DISPLAYNAME2,D7 	; CALL DISPLAYNAME2
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	#'.',D0 	; LD A,'.'
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	#SYSTEMFCBTYPE,D1 	; LD HL,SYSTEMFCBTYPE
	ROR.W 	#8,D2 	; LD B,$03
	MOVE.B 	#$03,D2 	;
	ROR.W 	#8,D2 	;
DISPLAYNAME2 	EQU	*-PRG.STRT 	;DISPLAYNAME2 LD A,B
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.837 	;
	JMP 	SYS.RET(A5) 	;
LAB.837:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,DISPLAYNAME3
	BNE.S 	LAB.838 	;
	JMP 	DISPLAYNAME3(A5) 	;
LAB.838:
 HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#RESETANDCLEARFCB,D7 	; CALL RESETANDCLEARFCB
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.W 	#READEOLN,D7 	; CALL READEOLN ;Skip spaces
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,READNAME09 ;Found NULL.
	BCS.S 	LAB.843 	;
	JMP 	READNAME09(A5) 	;
LAB.843:
*				;;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	SUBQ.W 	#1,D1 	; DEC HL
	CMP.B 	#':',D0 	; CP ':'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#RESETANDCLEARFCB,D7 	; CALL RESETANDCLEARFCB
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE.W 	#READEOLN,D7 	; CALL READEOLN ;Skip spaces
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,READNAME09 ;Found NULL.
	BCS.S 	LAB.843 	;
	JMP 	READNAME09(A5) 	;
LAB.843:
*				;;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	SUBQ.W 	#1,D1 	; DEC HL
	CMP.B 	#':',D0 	; CP ':'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,READNAME02
	BEQ.S 	LAB.844 	;
	JMP 	READNAME02(A5) 	;
LAB.844:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	SUB.B 	#'A'-1,D0 	; SUB 'A'-1
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,SYSTEMFCBDRIVE(A5) 	; LD (SYSTEMFCBDRIVE),A
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D1 	; INC HL
READNAME02 	EQU	*-PRG.STRT 	;READNAME02 LD DE,SYSTEMFCBNAME
	MOVE.W 	#SYSTEMFCBNAME,D3 	;
	MOVE.W 	#$0008,D2 	; LD BC,$0008
	MOVE.W 	#READSYSTEMID,D7 	; CALL READSYSTEMID
	JSR 	SYS.JSR(A5) 	;
	CMP.B 	#'.',D0 	; CP '.'
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,READNAME03
	BNE.S 	LAB.845 	;
	JMP 	READNAME03(A5) 	;
LAB.845:
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.846 	;
	JMP 	SYS.RET(A5) 	;
LAB.846:
	OR.B 	#17,F+1(A5) 	; SCF 
	JMP 	SYS.RET(A5) 	; RET 
READNAME03 	EQU	*-PRG.STRT 	;READNAME03 INC HL
	ADDQ.W 	#1,D1 	;
	MOVE.W 	#SYSTEMFCBTYPE,D3 	; LD DE,SYSTEMFCBTYPE
	MOVE.W 	#$0003,D2 	; LD BC,$0003
	MOVE.W 	#READSYSTEMID,D7 	; CALL READSYSTEMID
	JSR 	SYS.JSR(A5) 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.847 	;
	JMP 	SYS.RET(A5) 	;
LAB.847:
READNAME09 	EQU	*-PRG.STRT 	;READNAME09
	OR.B 	#17,F+1(A5) 	; SCF 
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;; Copy up to BC characters from (HL) to (DE) but stop
*;; if find a totaly illegal character for a file name.
*;;
READSYSTEMID 	EQU	*-PRG.STRT 	;READSYSTEMID LD A,B
	ROR.W 	#8,D2 	;
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,READSYSTEM02 ;Copied all, Return A
	BNE.S 	LAB.848 	;
	JMP 	READSYSTEM02(A5) 	;
LAB.848:
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	MOVE.W 	#UPPER,D7 	; CALL UPPER
	JSR 	SYS.JSR(A5) 	;
*				;;Trap SPACE, NULL and CR:
	CMP.B 	#' '+1,D0 	; CP ' '+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,READSYSTEM01
	BCC.S 	LAB.849 	;
	JMP 	READSYSTEM01(A5) 	;
LAB.849:
*;;Trap illegal characters:
*;;(From page 11 'The Software Bus')
	CMP.B 	#'.',D0 	; CP '.' ;Name/Type separator
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.850 	;
	JMP 	SYS.RET(A5) 	;
LAB.850:
	CMP.B 	#',',D0 	; CP ',' ;Command line separator
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.851 	;
	JMP 	SYS.RET(A5) 	;
LAB.851:
	CMP.B 	#';',D0 	; CP ';' ;Password separator
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.852 	;
	JMP 	SYS.RET(A5) 	;
LAB.852:
	CMP.B 	#':',D0 	; CP ':' ;Drive spec
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.853 	;
	JMP 	SYS.RET(A5) 	;
LAB.853:
	CMP.B 	#'=',D0 	; CP '=' ;Command line separator
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.854 	;
	JMP 	SYS.RET(A5) 	;
LAB.854:
	CMP.B 	#'?',D0 	; CP '?' ;Ambiguous
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.855 	;
	JMP 	SYS.RET(A5) 	;
LAB.855:
	CMP.B 	#'*',D0 	; CP '*' ;Ambiguous
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.856 	;
	JMP 	SYS.RET(A5) 	;
LAB.856:
	CMP.B 	#'[',D0 	; CP '[' ;Option separator
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.857 	;
	JMP 	SYS.RET(A5) 	;
LAB.857:
	CMP.B 	#']',D0 	; CP ']' ;Option separator
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.858 	;
	JMP 	SYS.RET(A5) 	;
LAB.858:
	MOVE.B 	D0,0(a4,D3.W) 	; LD (DE),A
	ADDQ.W 	#1,D1 	; INC HL
	ADDQ.W 	#1,D3 	; INC DE
	SUBQ.W 	#1,D2 	; DEC BC
	JMP 	READSYSTEMID(A5) 	; JR READSYSTEMID
*				;;
READSYSTEM01 	EQU	*-PRG.STRT 	;READSYSTEM01
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;Copied all specified chars, Return A=0 if valid name teminator
READSYSTEM02 	EQU	*-PRG.STRT 	;READSYSTEM02
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
	CMP.B 	#' '+1,D0 	; CP ' '+1 ;Check for SPACE, NULL and CR
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET NC
	BCS.S 	LAB.859 	;
	JMP 	SYS.RET(A5) 	;
LAB.859:
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Read line from keyboard to BUFFER.
*;;
squasherinputline 	EQU	*-PRG.STRT 	;squasherinputline
	MOVE.W 	#BUFFER,D1 	; LD HL,BUFFER
	MOVE.B 	#ASCIINULL,0(a4,D1.W; JR Z,INLIN04
	BNE.S 	LAB.862 	;
	JMP 	INLIN04(A5) 	;
LAB.862:
	CMP.B 	#ASCIIDEL,D0 	; CP ASCIIDEL
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,INLIN04
	BNE.S 	LAB.863 	;
	JMP 	INLIN04(A5) 	;
LAB.863:
	MOVE 	F(A5),SR 	; JR NC,INLIN01
	BCS.S 	LAB.864 	;
	JMP 	INLIN01(A5) 	;
LAB.864:
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,INLIN02
	BCC.S 	LAB.865 	;
	JMP 	INLIN02(A5) 	;
LAB.865:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.B 	D0,D2 	; LD C,A
	MOV; JR Z,INLIN04
	BNE.S 	LAB.862 	;
	JMP 	INLIN04(A5) 	;
LAB.862:
	CMP.B 	#ASCIIDEL,D0 	; CP ASCIIDEL
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,INLIN04
	BNE.S 	LAB.863 	;
	JMP 	INLIN04(A5) 	;
LAB.863:
	MOVE 	F(A5),SR 	; JR NC,INLIN01
	BCS.S 	LAB.864 	;
	JMP 	INLIN01(A5) 	;
LAB.864:
	CMP.B 	#' ',D0 	; CP ' '
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,INLIN02
	BCC.S 	LAB.865 	;
	JMP 	INLIN02(A5) 	;
LAB.865:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.B 	D0,D2 	; LD C,A
	MOVE.W 	#BUFFER,D3 	; LD DE,BUFFER
;	AND.B 	D0,D0 	; AND A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D1,D0 	; LD A,L
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	CMP.B 	#LINELENGTH,D0 	; CP LINELENGTH
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NC,INLIN03
	BCS.S 	LAB.866 	;
	JMP 	INLIN03(A5) 	;
LAB.866:
	MOVE.B 	D2,D0 	; LD A,C
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	MOVE.W 	#ECHOINPUTCHARACTER,D7 	; CALL ECHOINPUTCHARACTER
	JSR 	SYS.JSR(A5) 	;
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	#ASCIINULL,0(a4,D1.W) 	; LD (HL),ASCIINULL
	JMP 	INLIN01(A5) 	; JR INLIN01
INLIN02 	EQU	*-PRG.STRT 	;INLIN02 CALL ECHOINPUTCHARACTER
	MOVE.W 	#ECHOINPUTCHARACTER,D7 	;
	JSR 	SYS.JSR(A5) 	;
	JMP 	INLIN01(A5) 	; JR INLIN01
INLIN03 	EQU	*-PRG.STRT 	;INLIN03 LD A,ASCIIBELL
	MOVE.B 	#ASCIIBELL,D0 	;
	MOVE.W 	#ECHOINPUTCHARACTER,D7 	; CALL ECHOINPUTCHARACTER
	JSR 	SYS.JSR(A5) 	;
	JMP 	INLIN01(A5) 	; JR INLIN01
INLIN04 	EQU	*-PRG.STRT 	;INLIN04 LD DE,BUFFER
	MOVE.W 	#BUFFER,D3 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR Z,INLIN01
	BNE.S 	LAB.867 	;
	JMP 	INLIN01(A5) 	;
LAB.867:
	MOVE 	F(A5),SR 	; JR C,INLIN01
	BCC.S 	LAB.868 	;
	JMP 	INLIN01(A5) 	;
LAB.868:
	SUBQ.W 	#1,D1 	; DEC HL
	MOVE.B 	#ASCIINULL,0(a4,D1.W) 	; LD (HL),ASCIINULL
	MOVE.B 	#ASCIIDEL,D0 	; LD A,ASCIIDEL
	MOVE.W 	#ECHOINPUTCHARACTER,D7 	; CALL ECHOINPUTCHARACTER
	JSR 	SYS.JSR(A5) 	;
	JMP 	INLIN01(A5) 	; JR INLIN01
INLIN05 	EQU	*-PRG.STRT 	;INLIN05
	EOR.B 	D0,D0 	; XOR A ;Return 'NC'
	MOVE 	SR,F(A5) 	;
	JMP 	INLIN07(A5) 	; JR INLIN07
*				;;
INLIN06 	EQU	*-PRG.STRT 	;INLIN06
	MOVE.W 	#CHECKESCAPE,D7 	; CALL CHECKESCAPE
	JSR 	SYS.JSR(A5) 	;
	OR.B 	#17,F+1(A5) 	; SCF ;Return 'C'
*				;;
INLIN07 	EQU	*-PRG.STRT 	;INLIN07
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.B 	#ASCIICR,D0 	; LD A,ASCIICR
	MOVE.W 	#ECHOINPUTCHARACTER,D7 	; CALL ECHOINPUTCHARACTER
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Read keyboard
*;;
squasherosrdch 	EQU	*-PRG.STRT 	;squasherosrdch
	MOVE.W 	#GETCHARACTER,D7 	; CALL GETCHARACTER
	JSR 	SYS.JSR(A5) 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,squasherosrdch
	BNE.S 	LAB.869 	;
	JMP 	squasherosrdch(A5) 	;
LAB.869:
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Check if key pressed
*;;
GETCHARACTER 	EQU	*-PRG.STRT 	;GETCHARACTER
 jmp sys.ret ;********
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	MOVE.B 	#CPNDCI,D2 	; LD C,CPNDCI ;Direct console I/O
	MOVE.B 	#$FF,D3 	; LD E,$FF ;Input
	MOVE.W 	#CPMENTRY,D7 	; CALL CPMENTRY
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Display in-line string terminated by NULL.
*;;
squasherprs 	EQU	*-PRG.STRT 	;squasherprs
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
squasherprs1 	EQU	*-PRG.STRT 	;squasherprs1 LD A,(HL)
	MOVE.B 	0(a5,D1.W),D0 	; get message from within code
	ADDQ.W 	#1,D1 	; INC HL
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,squasherprs2
	BNE.S 	LAB.870 	;
	JMP 	squasherprs2(A5) 	;
LAB.870:
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	JMP 	squasherprs1(A5) 	; JR squasherprs1
squasherprs2 	EQU	*-PRG.STRT 	;squasherprs2 JP (HL)
* make sure d1.w is even.
 btst #0,d1
 beq.s squasherprseven
 addq.w #1,d1
squasherprseven
	JMP 	0(a5,D1.W) 	;
*;;
*;;-----
*;;
DISPLAYAHEX 	EQU	*-PRG.STRT 	;DISPLAYAHEX
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE 	F(A5),SR 	; RRA 
	ROXR.B 	#1,D0 	;
	MOVE 	SR+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,DISPLAYHEXNYBBLE01
	BCC.S 	LAB.871 	;
* ... Address below has been altered slightly ....
	JMP 	DISPLAY01HEXNYBBLE(A5) 	;
LAB.871:
	ADD.B 	#'A'-'0'-10,D0 	; ADD A,'A'-'0'-10
	MOVE 	SR,F(A5) 	;
DISPLAY01HEXNYBBLE 	EQU	*-PRG.STRT 	;DISPLAYHEXNYBBLE01 JP squasheroswrch
	JMP 	squasheroswrch(A5) 	;
*;;
*;;-----
*;;
*;;Open file for writing. File name in SYSTEMFCB,
*;;HL address of SERIALFCB.
*;;
OPENSERIALWRITE 	EQU	*-PRG.STRT 	;OPENSERIALWRITE
	SUBQ+1
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,DISPLAYHEXNYBBLE01
	BCC.S 	LAB.871 	;
* ... Address below has been altered slightly ....
	JMP 	DISPLAY01HEXNYBBLE(A5) 	;
LAB.871:
	ADD.B 	#'A'-'0'-10,D0 	; ADD A,'A'-'0'-10
	MOVE 	SR,F(A5) 	;
DISPLAY01HEXNYBBLE 	EQU	*-PRG.STRT 	;DISPLAYHEXNYBBLE01 JP squasheroswrch
	JMP 	squasheroswrch(A5) 	;
*;;
*;;-----
*;;
*;;Open file for writing. File name in SYSTEMFCB,
*;;HL address of SERIALFCB.
*;;
OPENSERIALWRITE 	EQU	*-PRG.STRT 	;OPENSERIALWRITE
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#OPENSYSTEMWRITE,D7 	; CALL OPENSYSTEMWRITE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; RET C ;Error
	BCC.S 	LAB.872 	;
	JMP 	SYS.RET(A5) 	;
LAB.872:
	JMP 	SERIALOPEN(A5) 	; JP SERIALOPEN
*;;
*;;-----
*;;
*;;Open file for reading. File name in SYSTEMFCB,
*;;HL address of SERIALFCB
*;;
OPENSERIALREAD 	EQU	*-PRG.STRT 	;OPENSERIALREAD
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#OPENSYSTEMREAD,D7 	; CALL OPENSYSTEMREAD
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; RET C ;Error
	BCC.S 	LAB.873 	;
	JMP 	SYS.RET(A5) 	;
LAB.873:
	JMP 	SERIALOPEN(A5) 	; JP SERIALOPEN
*;;
*;;-----
*;;
*;;Open file for serial access following OPENSYSTEMREAD or
*;;OPENSYSTEMWRITE. Requires a 294 byte Control Block
*;;
SERIALOPEN 	EQU	*-PRG.STRT 	;SERIALOPEN
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#SYSTEMFCB,D1 	; LD HL,SYSTEMFCB
	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.B 	#$00,0(a4,D1.W) 	; LD (HL),$00
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	#$00,0(a4,D1.W) 	; LD (HL),$00
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Read one byte from file following SERIALOPEN.
*;;
SERIALREADBYTE 	EQU	*-PRG.STRT 	;SERIALREADBYTE
 move.b (a3)+,d0
 jmp sys.ret(a5)

; cmp.b #asciieof,d0
; beq.s srbeof
; move.b #0,ccr ; reset carry
; MOVE 	SR,F(A5)
; jmp sys.ret(a5)
;srbeof
; move.b #$ff,ccr ; set carry
; MOVE 	SR,F(A5)
; jmp sys.ret(a5)
;	SUBQ.W 	#2,D6 	; PUSH HL
;	MOVE.W 	D1,0(a4,D6.W) 	;
;	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
;	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
;	JSR 	SYS.LDIR(A5) 	; LDIR 
;	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
;	ADDQ.W 	#1,D1 	; INC HL
;	ROR.W 	#8,D2 	; LD B,(HL)
;	MOVE.B 	0(a4,D1.W),D2 	;
;	ROR.W 	#8,D2 	;
;	ROR.W 	#8,D2 	; LD A,B
;	MOVE.B 	D2,D0 	;
;	ROR.W 	#8,D2 	;
;	OR.B 	D2,D0 	; OR C
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; JR NZ,SERIALRB01
;	BEQ.S 	LAB.874 	;
;	JMP 	SERIALRB01(A5) 	;
;LAB.874:
;	ADDQ.W 	#1,D1 	; INC HL
;	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
;	MOVE.W 	#READSECTOR,D7 	; CALL READSECTOR
;	JSR 	SYS.JSR(A5) 	;
;	MOVE.W 	0(a4,D6.W),D1 	; POP HL
;	ADDQ.W 	#2,D6 	;
;	MOVE 	F(A5),SR 	; RET C
;	BCC.S 	LAB.875 	;
;	JMP 	SYS.RET(A5) 	;
;LAB.875:
;	SUBQ.W 	#2,D6 	; PUSH HL
;	MOVE.W 	D1,0(a4,D6.W) 	;
;	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
;	ADD.W 	D2,D1 	; ADD HL,BC 
;	MOVE 	SR,F(A5) 	;
;	MOVE.B 	#DMALEN,0(a4,D1.W) 	; LD (HL),DMALEN
;	ADDQ.W 	#1,D1 	; INC HL
;	MOVE.B 	#$00,0(a4,D1.W) 	; LD (HL),$00
;SERIALRB01 	EQU	*-PRG.STRT 	;SERIALRB01 POP HL
;	MOVE.W 	0(a4,D6.W),D1 	;
;	ADDQ.W 	#2,D6 	;
;	SUBQ.W 	#2,D6 	; PUSH HL
;	MOVE.W 	D1,0(a4,D6.W) 	;
;	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
;	ADD.W 	D2,D1 	; ADD HL,BC 
;	MOVE 	SR,F(A5) 	;
;	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
;	ADDQ.W 	#1,D1 	; INC HL
;	ROR.W 	#8,D2 	; LD B,(HL)
;	MOVE.B 	0(a4,D1.W),D2 	;
;	ROR.W 	#8,D2 	;
;	SUBQ.W 	#1,D2 	; DEC BC
;	ROR.W 	#8,D2 	; LD (HL),B
;	MOVE.B 	D2,0(a4,D1.W) 	;
;	ROR.W 	#8,D2 	;
;	SUBQ.W 	#1,D1 	; DEC HL
;	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
;	MOVE.B 	#$7F,D0 	; LD A,$7F
;	SUB.B 	D2,D0 	; SUB C
;	MOVE 	SR,F(A5) 	;
;	MOVE.B 	D0,D2 	; LD C,A
;	MOVE.W 	0(a4,D6.W),D1 	; POP HL
;	ADDQ.W 	#2,D6 	;
;	SUBQ.W 	#2,D6 	; PUSH HL
;	MOVE.W 	D1,0(a4,D6.W) 	;
;	ADD.W 	D2,D1 	; ADD HL,BC 
;	MOVE 	SR,F(A5) 	;
;	MOVE.W 	#$0026,D2 	; LD BC,$0026
;	ADD.W 	D2,D1 	; ADD HL,BC 
;	MOVE 	SR,F(A5) 	;
;	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL)
;	MOVE.W 	0(a4,D6.W),D1 	; POP HL
;	ADDQ.W 	#2,D6 	;
;	MOVE.W 	D3,-(SP) 	; EX DE,HL
;	MOVE.W 	D1,D3 	;
;	MOVE.W 	(SP)+,D1 	;
;	MOVE.W 	#SYSTEMFCB,D1 	; LD HL,SYSTEMFCB
;	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
;	JSR 	SYS.LDIR(A5) 	; LDIR 
;	OR.B 	D0,D0 	; OR A
;	MOVE 	SR,F(A5) 	;
;	JMP(a4,D6.W) 	;
	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
	ADD.W 	D2,D1 	; ADD HL,BC 
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADD.W 	D2,D1 	; ADD HL,BC 
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	ADDQ.W 	#1,D2 	; INC BC
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ROR.W 	#8,D2 	; LD (HL),(a4,D6.W) 	;
	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
	ADD.W 	D2,D1 	; ADD HL,BC 
	MOVE 	SR,F(A5) 	;
	MOVE.B 	0(a4,D1.W),D2 	; LD C,(HL)
	ADDQ.W 	#1,D1 	; INC HL
	ROR.W 	#8,D2 	; LD B,(HL)
	MOVE.B 	0(a4,D1.W),D2 	;
	ROR.W 	#8,D2 	;
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ADDQ.W 	#1,D1 	; INC HL
	ADD.W 	D2,D1 	; ADD HL,BC 
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D0,0(a4,D1.W) 	; LD (HL),A
	ADDQ.W 	#1,D2 	; INC BC
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	ROR.W 	#8,D2 	; LD (HL),B
	MOVE.B 	D2,0(a4,D1.W) 	;
	ROR.W 	#8,D2 	;
	SUBQ.W 	#1,D1 	; DEC HL
	MOVE.B 	D2,0(a4,D1.W) 	; LD (HL),C
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR NZ,SERIALWB01
	BEQ.S 	LAB.876 	;
	JMP 	SERIALWB01(A5) 	;
LAB.876:
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
SERIALWB01 	EQU	*-PRG.STRT 	;SERIALWB01 POP HL
	MOVE.W 	0(a4,D6.W),D1 	;
	ADDQ.W 	#2,D6 	;
SERIALWB02 	EQU	*-PRG.STRT 	;SERIALWB02
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	MOVE.W 	#SYSTEMFCB,D3 	; LD DE,SYSTEMFCB
	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
	JSR 	SYS.LDIR(A5) 	; LDIR 
	MOVE.B 	#$00,0(a4,D1.W) 	; LD (HL),$00
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	#$00,0(a4,D1.W) 	; LD (HL),$00
	ADDQ.W 	#1,D1 	; INC HL
	MOVE.B 	#$01,D0 	; LD A,$01
	MOVE.W 	#WRITESYSTEMPAGES,D7 	; CALL WRITESYSTEMPAGES
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; RET C ;Error
	BCC.S 	LAB.877 	;
	JMP 	SYS.RET(A5) 	;
LAB.877:
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#SYSTEMFCB,D1 	; LD HL,SYSTEMFCB
	MOVE.W 	#FCBLENGTH,D2 	; LD BC,FCBLENGTH
	JSR 	SYS.LDIR(A5) 	; LDIR 
	EOR.B 	D0,D0 	; XOR A ;Return 'NC'
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Flush buffer and close file opened for serial
*;;following SERIALOPEN.
*;;
CLOSESERIALWRITE 	EQU	*-PRG.STRT 	;CLOSESERIALWRITE
 jmp sys.ret(a5)
	MOVE.W 	#SERIALWB02,D7 	; CALL SERIALWB02
	JSR 	SYS.JSR(A5) 	;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	#CLOSESYSTEMWRITE,D7 	; CALL CLOSESYSTEMWRITE
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Convert A to lower-case.
*;;Returns 'A'. Flags corrupted.
LOWER 	EQU	*-PRG.STRT 	;LOWER CP 'A'
	CMP.B 	#'A',D0 	;
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; RET C
	BCC.S 	LAB.878 	;
	JMP 	SYS.RET(A5) 	;
LAB.878:
	CMP.B 	#'Z'+1,D0 	; CP 'Z'+1
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; RET NC
	BCS.S 	LAB.879 	;
	JMP 	SYS.RET(A5) 	;
LAB.879:
	ADD.B 	#$20,D0 	; ADD A,$20
;	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;
*;;Returns condition 'C' if Escape pressed.
*;;AF corrupted.
CHECKESCAPE 	EQU	*-PRG.STRT 	;CHECKESCAPE
*;;
*;;Unknown computer, Return non-escape
*;;
	EOR.B 	D0,D0 	; XOR A
	MOVE 	SR,F(A5) 	;
	JMP 	sys.ret(A5) 	; JR CHECKESC04
*;;
*;;-----
*;;
*;;Display a hex address
*;;Corrupts A.
DISPLAYHLHEX 	EQU	*-PRG.STRT 	;DISPLAYHLHEX
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	MOVE.W 	#DISPLAYAHEX,D7 	; CALL DISPLAYAHEX
	JSR 	SYS.JSR(A5) 	;
	MOVE.B 	D1,D0 	; LD A,L
	JMP 	DISPLAYAHEX(A5) 	; JP DISPLAYAHEX
*;;
*;;-----
*;;
*;;Display HL in decimal.
*;;Nothing corrupted.
DISPLAYDECIMAL 	EQU	*-PRG.STRT 	;DISPLAYDECIMAL
 clr.l d0
 move.w d1,d0
 movem.l d0-d7/a0-a6,-(sp)
 bsr printdecimald0
 movem.l (sp)+,d0-d7/a0-a6
 jmp sys.ret(a5)

;---
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH BC
	MOVE.W 	D2,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH AF
	MOVE.W 	D0,0(a4,D6.W) 	;
	MOVE.W 	#DD01,D7 	; CALL DD01
	JSR 	SYS.JSR(A5) 	;
	MOVE.W 	0(a4,D6.W),D0 	; POP AF
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D2 	; POP BC
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
DD01 	EQU	*-PRG.STRT 	;DD01
	ROR.W 	#8,D1 	; LD A,H
	MOVE.B 	D1,D0 	;
	ROR.W 	#8,D1 	;
	OR.B 	D1,D0 	; OR L
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,DD05
	BNE.S 	LAB.883 	;
	JMP 	DD05(A5) 	;
LAB.883:
	MOVE.B 	#0,D2 	; LD C,0 ;Reset flag
	MOVE.W 	#DD06,D3 	; LD DE,DD06
	LEA 	PRTPTR(A5),A0 	; LD (PRTPTR),DE
	MOVE.B 	D3,(A0) 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	D3,1(A0) 	;
	ROR.W 	#8,D3 	;
*				;;Find current digit value
DD02 	EQU	*-PRG.STRT 	;DD02
	SUBQ.W 	#2,D6 	; PU 	; LD A,D
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	OR.B 	D3,D0 	; OR E
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.884 	;
	JMP 	SYS.RET(A5) 	;
LAB.884:
*				;;Find current digit
	ROR.W 	#8,D2 	; LD B,'0'
	MOVE.B 	#'0',D2 	;
	ROR.W 	#8,D2 	;
DD03 	EQU	*-PRG.STRT 	;DD03
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,DD04
	BCC.S 	LAB.885 	;
	JMP 	DD04(A5) 	;
LAB.885:
	ADD.W 	#$100,D2 	; INC B
 	; LD A,D
	MOVE.B 	D3,D0 	;
	ROR.W 	#8,D3 	;
	OR.B 	D3,D0 	; OR E
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; RET Z
	BNE.S 	LAB.884 	;
	JMP 	SYS.RET(A5) 	;
LAB.884:
*				;;Find current digit
	ROR.W 	#8,D2 	; LD B,'0'
	MOVE.B 	#'0',D2 	;
	ROR.W 	#8,D2 	;
DD03 	EQU	*-PRG.STRT 	;DD03
;	EOR.B 	D0,D0 	; XOR A
;	MOVE 	SR,F(A5) 	;
;	MOVE 	F(A5),SR 	; SBC HL,DE
	SUB.W 	D3,D1 	;
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR C,DD04
	BCC.S 	LAB.885 	;
	JMP 	DD04(A5) 	;
LAB.885:
	ADD.W 	#$100,D2 	; INC B
	MOVE.B 	#1,D0 	; LD A,1
	MOVE.B 	D0,D2 	; LD C,A
	JMP 	DD03(A5) 	; JR DD03
*				;;
DD04 	EQU	*-PRG.STRT 	;DD04
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.B 	D2,D0 	; LD A,C
	OR.B 	D2,D0 	; OR C
	MOVE 	SR,F(A5) 	;
	MOVE 	F(A5),SR 	; JR Z,DD02
	BNE.S 	LAB.886 	;
	JMP 	DD02(A5) 	;
LAB.886:
	ROR.W 	#8,D2 	; LD A,B
	MOVE.B 	D2,D0 	;
	ROR.W 	#8,D2 	;
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	JMP 	DD02(A5) 	; JR DD02
*				;;
DD05 	EQU	*-PRG.STRT 	;DD05
	MOVE.B 	#'0',D0 	; LD A,'0'
	MOVE.W 	#squasheroswrch,D7 	; CALL squasheroswrch
	JSR 	SYS.JSR(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*				;;
DD06 	EQU	*-PRG.STRT 	;DD06
	DC.b 	$10,$27	; DEFW 10000
	DC.b 	$e8,$03	; DEFW 1000
	DC.b 	$64,0	; DEFW 100
	DC.b 	$0a,0	; DEFW 10
	DC.b 	1,0 	; DEFW 1
	DC.b 	0,0 	; DEFW 0
*;;
*;;-----
*;;
 even
*;;Parse a number at (HL)
*;;Returns 'Z' if nothing entered. 'C' if error.
*;;Otherwise returns 'NZ', 'NC' and HL=value.
*;;
squasherreaddecimal 	EQU	*-PRG.STRT 	;squasherreaddecimal
	MOVE.W 	#0,D3 	; LD DE,0
	MOVE.W 	#READEOLN,D7 	; CALL READEOLN ;Skip spaces
	JSR 	SYS.JSR(A5) 	;
	MOVE 	F(A5),SR 	; RET Z ;NULL found
	BNE.S 	LAB.887 	;
	JMP 	SYS.RET(A5) 	;
LAB.887:
*				;;
READDEC02 	EQU	*-PRG.STRT 	;READDEC02
	MOVE.B 	0(a4,D1.W),D0 	; LD A,(HL) OR A JR Z,READDEC04
	BNE.S 	LAB.888 	;
	JMP 	READDEC04(A5) 	;
LAB.888:
	CMP.B 	#' ',D0 	; CP ' ' JR Z,READDEC04
	BNE.S 	LAB.889 	;
	JMP 	READDEC04(A5) 	;
LAB.889:
	ADDQ.W 	#1,D1 	; INC HL
	SUB.B 	#'0',D0 	; SUB '0' JR C,READDEC03 ;Error. Character < '0'
	BCC.S 	LAB.890 	;
	JMP 	READDEC03(A5) 	;
LAB.890:
	CMP.B 	#10,D0 	; CP 10 JR NC,READDEC03 ;Error. Character > '9'
	BCS.S 	LAB.891 	;
	JMP 	READDEC03(A5) 	;
LAB.891:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	SUBQ.W 	#2,D6 	; PUSH DE
	MOVE.W 	D3,0(a4,D6.W) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	#6554,D2 	; LD BC,6554 ; AND A; SBC HL,BC
	SUB.W 	D2,D1 	;
	MOVE.W 	0(a4,D6.W),D3 	; POP DE
	ADDQ.W 	#2,D6 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR NC,READDEC03 ;Error. Number > 6553
	BCS.S 	LAB.892 	;
	JMP 	READDEC03(A5) 	;
LAB.892:
	SUBQ.W 	#2,D6 	; PUSH HL
	MOVE.W 	D1,0(a4,D6.W) 	;
	ROR.W 	#8,D1 	; LD H,D
	ROR.W 	#8,D3 	;
	MOVE.B 	D3,D1 	;
	ROR.W 	#8,D3 	;
	ROR.W 	#8,D1 	;
	MOVE.B 	D3,D1 	; LD L,E
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	ADD.W 	D1,D1 	; ADD HL,HL
	MOVE 	SR,F(A5) 	;
	ADD.W 	D1,D1 	; ADD HL,HL
	MOVE 	SR,F(A5) 	;
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	ROR.W 	#8,D3 	; LD D,0
	MOVE.B 	#0,D3 	;
	ROR.W 	#8,D3 	;
	MOVE.B 	D0,D3 	; LD E,A
	ADD.W 	D3,D1 	; ADD HL,DE
	MOVE 	SR,F(A5) 	;
	MOVE.W 	D3,-(SP) 	; EX DE,HL
	MOVE.W 	D1,D3 	;
	MOVE.W 	(SP)+,D1 	;
	MOVE.W 	0(a4,D6.W),D1 	; POP HL
	ADDQ.W 	#2,D6 	;
	MOVE 	F(A5),SR 	; JR NC,READDEC02
	BCS.S 	LAB.893 	;
	JMP 	READDEC02(A5) 	;
LAB.893:
*;;Error. Number too big.
*;;
READDEC03 	EQU	*-PRG.STRT 	;READDEC03
	OR.B 	#17,F+1(A5) 	; SCF ;Error
	JMP 	SYS.RET(A5) 	; RET 
*				;;
READDEC04 	EQU	*-PRG.STRT 	;READDEC04
	MOVE.B 	#1,D0 	; LD A,1
	OR.B 	D0,D0 	; OR A
	MOVE 	SR,F(A5) 	;
	JMP 	SYS.RET(A5) 	; RET 
*;;
*;;-----
*;;-----