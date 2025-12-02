endmemory equ *-prg.strt
 dc.w 0

startfilebuffer equ *-prg.strt
 dc.l 0

startvariablearea EQU *-PRG.STRT
;
;'Checksum' reserved as first byte following last byte of code:
CHKSUM 	EQU	*-PRG.STRT 	;CHKSUM
	DS.B 	1 	; DEFS 1
*				;;
squashercomputertype 	EQU	*-PRG.STRT 	;squashercomputertype
	DC.B 	0 	; DEFB 0 ;Default to 'Uknown'
*				;;
	DS.B 	$80 	; DEFS $80
STACK 	EQU	*-PRG.STRT 	;STACK
*				;;
PRTPTR 	EQU	*-PRG.STRT 	;PRTPTR
	DS.B 	2 	; DEFS 2
*				;;
BUFFER 	EQU	*-PRG.STRT 	;BUFFER
	DS.B 	200 ;****** LINELENGTH+1 	; DEFS LINELENGTH+1
BUFFEREND 	EQU	*-PRG.STRT 	;BUFFEREND
	DS.B 	1 	; DEFS 1
*				;;
SYSTEMFCB 	EQU	*-PRG.STRT 	;SYSTEMFCB
SYSTEMFCBDRIVE 	EQU	*-PRG.STRT 	;SYSTEMFCBDRIVE DEFS 1
	DS.B 	1 	;
SYSTEMFCBNAME 	EQU	*-PRG.STRT 	;SYSTEMFCBNAME DEFS 8
	DS.B 	8 	;
SYSTEMFCBTYPE 	EQU	*-PRG.STRT 	;SYSTEMFCBTYPE DEFS 3
	DS.B 	3 	;
SYSTEMFCBEX 	EQU	*-PRG.STRT 	;SYSTEMFCBEX DEFS 1
	DS.B 	1 	;
* ... Altered ...
	DS.B 	19 	; DEFS 19;h1,h2,rc,u0-uF
SYSTEMFCBCR 	EQU	*-PRG.STRT 	;SYSTEMFCBCR DEFS 1
	DS.B 	1
* ... Altered ... 
	DS.B 	3 	; DEFS 3;r0-r2
*				;;
*				;;----------------------------------------
*                       	;0001 ;MESSAGE.TXT to SQUASH.DAT compresser
*				;;
*				;;24/06/86
*				;;
*				;;RAM.Z80
*				;;
*				;;-----
*				;;
*				;;General workspace:
*				;;
*				;;Register save area for debugging:
AFSAVE 	EQU	*-PRG.STRT 	;AFSAVE DEFS 2
	DS.B 	2 	;
HLSAVE 	EQU	*-PRG.STRT 	;HLSAVE DEFS 2
	DS.B 	2 	;
DESAVE 	EQU	*-PRG.STRT 	;DESAVE DEFS 2
	DS.B 	2 	;
BCSAVE 	EQU	*-PRG.STRT 	;BCSAVE DEFS 2
	DS.B 	2 	;
*				;;
*				;;If status messages requested holds 'Y':
NOISY 	EQU	*-PRG.STRT 	;NOISY DEFS 1
	DS.B 	1 	;
*				;;
*				;;If in debug mode holds 'Y'.
DEBUG 	EQU	*-PRG.STRT 	;DEBUG DEFS 1
	DS.B 	1 	;
*				;;
*				;;Maximum number of entries in 'Common Word Dictionary':
COMMONMAXENTRIES 	EQU	*-PRG.STRT 	;COMMONMAXENTRIES DEFS 1
	DS.B 	1 	;
*				;;
*				;;UNSQUASH screen width:
WRAPWIDTH 	EQU	*-PRG.STRT 	;WRAPWIDTH DEFS 1
	DS.B 	1 	;
*				;;
*				;;Length OF B:MESSAGE.TXT input file:
INPUTLENGTH 	EQU	*-PRG.STRT 	;INPUTLENGTH DEFS 2
	DS.B 	2 	;
*				;;
*				;;Length of temporary file B:SQUASH.TMP
LENGTHSMT 	EQU	*-PRG.STRT 	;LENGTHSMT DEFS 2
	DS.B 	2 	;
*				;;
*				;;Input file line number for error reports:
LINENUM 	EQU	*-PRG.STRT 	;LINENUM DEFS 2
	DS.B 	2 	;
*				;;
*				;;Message number:
MSGNUM 	EQU	*-PRG.STRT 	;MSGNUM DEFS 2
	DS.B 	2 	;
*				;;
*				;;Serial input control block:
FCB1 	EQU	*-PRG.STRT 	;FCB1
	DS.B 	SERIALFCBLENGTH 	; DEFS SERIALFCBLENGTH
*				;;
*				;;Serial output control block:
FCB2 	EQU	*-PRG.STRT 	;FCB2
	DS.B 	SERIALFCBLENGTH 	; DEFS SERIALFCBLENGTH
*				;;
*				;;Address of serial SMT buffer:
STARTBUFFER 	EQU	*-PRG.STRT 	;STARTBUFFER DEFS 2
	DS.B 	2 	;
*				;;
*				;;Bytes left in serial buffer:
BUFFERSIZE 	EQU	*-PRG.STRT 	;BUFFERSIZE DEFS 2
	DS.B 	2 	;
*				;;
*				;;Bytes unprocessed in serial buffe:
UNREADSIZE 	EQU	*-PRG.STRT 	;UNREADSIZE DEFS 2
	DS.B 	2 	;
*				;;
*				;;-----
*				;;
*				;;Phase 2 (Sort input file) workspace:
*				;;
*				;;Address following '[' or ':' in input buffer
*				;;(Also used by Phase 6 for Address of Message Descriptor Header Byte)
STARTMSG 	EQU	*-PRG.STRT 	;STARTMSG DEFS 2
	DS.B 	2 	;
*				;;
*				;;Address of ']' in input buffer
ENDMSG 	EQU	*-PRG.STRT 	;ENDMSG DEFS 2
	DS.B 	2 	;
*				;;
*				;;Non-zero if serial input EOF stored in buffer:
INPUTEOF 	EQU	*-PRG.STRT 	;INPUTEOF DEFS 1
	DS.B 	1 	;
*				;;
*				;;Number of input characters excluding brackets
NUMCHARACTERS 	EQU	*-PRG.STRT 	;NUMCHARACTERS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Number of messages:
NUMMESSAGES 	EQU	*-PRG.STRT 	;NUMMESSAGES DEFS 2
	DS.B 	2 	;
*				;;
*				;;Number of characters in input file
*				;;entered in inverted case:
MODIFYCOUNT 	EQU	*-PRG.STRT 	;MODIFYCOUNT DEFS 2
	DS.B 	2 	;
*				;;
*				;;Last char/start-of-word input char
LASTSIGCHAR 	EQU	*-PRG.STRT 	;LASTSIGCHAR DEFS 1
	DS.B 	1 	;
*				;;
*				;;Non-zero once warned about comments
SEENCOMMENT 	EQU	*-PRG.STRT 	;SEENCOMMENT DEFS 1
	DS.B 	1 	;
*				;;
*				;;-----
*				;;
*				;;Phase 3 (Construct Frequency Table) workspace:
*				;;
 even
STARTFT 	EQU	*-PRG.STRT 	;STARTFT DEFS 2
	DS.B 	2 	;
*				;;
ENDFT 	EQU	*-PRG.STRT 	;ENDFT DEFS 2
	DS.B 	2 	;
*				;;
*				;;Two-byte count for estimated number of occurances of
*				;;each ascii code $00 thru $7F not part of a 'word':
CHARACTERCOUNTS 	EQU	*-PRG.STRT 	;CHARACTERCOUNTS DEFS $100
	DS.B 	$100 	;
*				;;
*				;;Number		;;Phase 6 (Construct Message Descriptors) workspace:
*				;;
CURRENTMDT 	EQU	*-PRG.STRT 	;CURRENTMDT DEFS 2
	DS.B 	2 	;
*				;;
MAXMDT 	EQU	*-PRG.STRT 	;MAXMDT DEFS 2
	DS.B 	2 	;
*				;;
*				;;Address within SMT entry of a character in a message:
WORDADDRESS 	EQU	*-PRG.STRT 	;WORDADDRESS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Word-type character code for current word
WORDTYPE 	EQU	*-PRG.STRT 	;WORDTYPE DEFS 1
	DS.B 	1 	;
*				;;
*				;;MODE flag for splitting into words/spaces/characters:
P6M		;;Phase 6 (Construct Message Descriptors) workspace:
*				;;
CURRENTMDT 	EQU	*-PRG.STRT 	;CURRENTMDT DEFS 2
	DS.B 	2 	;
*				;;
MAXMDT 	EQU	*-PRG.STRT 	;MAXMDT DEFS 2
	DS.B 	2 	;
*				;;
*				;;Address within SMT entry of a character in a message:
WORDADDRESS 	EQU	*-PRG.STRT 	;WORDADDRESS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Word-type character code for current word
WORDTYPE 	EQU	*-PRG.STRT 	;WORDTYPE DEFS 1
	DS.B 	1 	;
*				;;
*				;;MODE flag for splitting into words/spaces/characters:
P6MODE 	EQU	*-PRG.STRT 	;P6MODE DEFS 1
	DS.B 	1 	;
*				;;
*				;;Stored character for inclusion with leading/trailing spaces:
P6CHAR 	EQU	*-PRG.STRT 	;P6CHAR DEFS 1
	DS.B 	1 	;
*				;;
*				;;Number of Message headers:
NUMMSGHEADS 	EQU	*-PRG.STRT 	;NUMMSGHEADS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Number of message skip bytes:
NUMJUMPHEADS 	EQU	*-PRG.STRT 	;NUMJUMPHEADS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Number of short references
NUMSHORTREFS 	EQU	*-PRG.STRT 	;NUMSHORTREFS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Number of long references:
NUMLONGREFS 	EQU	*-PRG.STRT 	;NUMLONGREFS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Length of current message:
MESSAGELENGTH 	EQU	*-PRG.STRT 	;MESSAGELENGTH DEFS 2
	DS.B 	2 	;
*				;;
*				;;Number of keywords defined in current message:
NUMKEYWORDS 	EQU	*-PRG.STRT 	;NUMKEYWORDS DEFS 2
	DS.B 	2 	;
*				;;
*				;;Length of ICF file (B:SQUASH2.TMP)
LENGTHICF 	EQU	*-PRG.STRT 	;LENGTHICF DEFS 2
	DS.B 	2 	;
*				;;
*				;;Length if Message Descriptors (in ICF)
INDEXMD 	EQU	*-PRG.STRT 	;INDEXMD DEFS 2
	DS.B 	2 	;
*				;;
LENGTHMD 	EQU	*-PRG.STRT 	;LENGTHMD DEFS 2
	DS.B 	2 	;
*				;;
STARTCONVERTEDMSG 	EQU	*-PRG.STRT 	;STARTCONVERTEDMSG DEFW 0 ;Address of last message header
	DC.W 	0 	;
* Warning 1 : the bytes in above word(s) may not be in required order
*				;;
*				;;-----
*				;;
*				;;Phase 7 (Construct Word Dictionary) workspace:
*				;;
UNPACK1 	EQU	BUFFER 	;UNPACK1 EQU BUFFER
UNPACK2 	EQU	BUFFER+1 	;UNPACK2 EQU BUFFER+1
UNPACK3 	EQU	BUFFER+2 	;UNPACK3 EQU BUFFER+2
UNPACK4 	EQU	BUFFER+3 	;UNPACK4 EQU BUFFER+3
UNPACK5 	EQU	BUFFER+4 	;UNPACK5 EQU BUFFER+4
UNPACK6 	EQU	BUFFER+5 	;UNPACK6 EQU BUFFER+5
UNPACK7 	EQU	BUFFER+6 	;UNPACK7 EQU BUFFER+6
UNPACK8 	EQU	BUFFER+7 	;UNPACK8 EQU BUFFER+7
*				;;
PACK1 	EQU	BUFFER+8 	;PACK1 EQU BUFFER+8
PACK2 	EQU	BUFFER+9 	;PACK2 EQU BUFFER+9
PACK3 	EQU	BUFFER+10 	;PACK3 EQU BUFFER+10
PACK4 	EQU	BUFFER+11 	;PACK4 EQU BUFFER+11
PACK5 	EQU	BUFFER+12 	;PACK5 EQU BUFFER+12
*				;;
*				;;Length of MD+WD
INDEXWD 	EQU	*-PRG.STRT 	;INDEXWD DEFS 2
	DS.B 	2 	;
*				;;
LENGTHWD 	EQU	*-PRG.STRT 	;LENGTHWD DEFS 2
	DS.B 	2 	;
*				;;
*				;;-----
*				;;
*				;;Phase 8 (Construct Index) workspace:
*				;;
*				;;Length of MD+WD+WDI
INDEXWDI 	EQU	*-PRG.STRT 	;INDEXWDI DEFS 2
	DS.B 	2 	;
*				;;
*				;;Number of Dictionary segments
NUMSEGS 	EQU	*-PRG.STRT 	;NUMSEGS DEFS 2
	DS.B 	2 	;
*				;;
*				;;-----
*				;;
*				;;Output file checksum
FINALCHECKSUM 	EQU	*-PRG.STRT 	;FINALCHECKSUM DEFS 1
	DS.B 	1 	;
*				;;
*				;;Pointer into BUFFER for packing/unpacking 5-bit codes:
*				;;(Also used by 'Construct Message Descriptors'
READWRITEPOINTER 	EQU	*-PRG.STRT 	;READWRITEPOINTER DEFS 2
	DS.B 	2 	;
*				;;
*				;;Pointer to the start of a 5-byte (40 bits) byte-aligned
*				;;in the 'Word Dictionary':
BLOCKPOINTER 	EQU	*-PRG.STRT 	;BLOCKPOINTER DEFS 2
	DS.B 	2 	;
*				;;
*				;;Current segment group
SEGNUM 	EQU	*-PRG.STRT 	;SEGNUM DEFS 1
	DS.B 	1 	;
*				;;
*				;;Last byte stored in dictionary
LASTBYTE 	EQU	*-PRG.STRT 	;LASTBYTE DEFS 1
	DS.B 	1 	;
*				;;
*				;;Pointers into byte-aligned boundaries of 'Word Dictionary':
SEGMENTADDRESSES 	EQU	*-PRG.STRT 	;SEGMENTADDRESSES
	DS.B 	416 	; DEFS 416 ; 26*4*4
*				;;
*				;;Pointer into next free pointer in SEGMENTADDRESSES:
LASTPOINTER 	EQU	*-PRG.STRT 	;LASTPOINTER
	DS.B 	2 	; DEFS 2
*				;;
*				;;Current word during 'Word Dictionary' construction:
WORDNUMBER 	EQU	*-PRG.STRT 	;WORDNUMBER DEFS 2
	DS.B 	2 	;
*				;;
*				;;First three characters (padded with nulls) of
*				;;word in 'Word Dictionary':
THREECHARACTERS 	EQU	*-PRG.STRT 	;THREECHARACTERS
	DS.B 	4 	; DEFS 4
*				;;
*				;;Non-zero if current dictionary word is all upper-case
WORDCASE 	EQU	*-PRG.STRT 	;WORDCASE
	DS.B 	1 	; DEFS 1
*				;;
*				;;-----
*				;;
*				;;Conversion READ address:
READPOSITION 	EQU	*-PRG.STRT 	;READPOSITION DEFS 2
	DS.B 	2 	;
*				;;
*				;;Conversion WRITE address:
WRITEPOSITION 	EQU	*-PRG.STRT 	;WRITEPOSITION DEFS 2
	DS.B 	2 	Last non-space character printed as part of an unsquashed
*				;;message. Used to decide upper/lower case:
LASTCHAR 	EQU	*-PRG.STRT 	;LASTCHAR DEFS 1
	DS.B 	1 	;
*				;;
*				;;True if next time BUFFER is printed it should
*				;;preceeded by a space (or newline) character:
PENDSPACE 	EQU	*-PRG.STRT 	;PENDSPACE DEFS 1
	DS.B 	1 	;
*				;;
*				;;-----
*				;;
squasherdriverblock
	ds.b 200


*				;;Memory here to just below BIOS allocated dynamically
*				;;at run-time for tables/buffers:
*	Last non-space character printed as part of an unsquashed
*				;;message. Used to decide upper/lower case:
LASTCHAR 	EQU	*-PRG.STRT 	;LASTCHAR DEFS 1
	DS.B 	1 	;
*				;;
*				;;True if next time BUFFER is printed it should
*				;;preceeded by a space (or newline) character:
PENDSPACE 	EQU	*-PRG.STRT 	;PENDSPACE DEFS 1
	DS.B 	1 	;
*				;;
*				;;-----
*				;;
squasherdriverblock
	ds.b 200


*				;;Memory here to just below BIOS allocated dynamically
*				;;at run-time for tables/buffers:
*				;;
STARTTABLEMEMORY 	EQU	0 ;STARTTABLEMEMORY
*				;;
*				;;-----