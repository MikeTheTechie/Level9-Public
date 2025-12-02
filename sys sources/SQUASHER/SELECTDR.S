; General purpose directory selector.
; Modified from version used in MENU.S
;
; Copyright (C) 1986 M.J.Austin 1986
;
; Last change: 10/12/86
;
;---
selectdirectory
 movem.l d0-d7/a0-a6,-(sp)
 lea filenamelist,a5
 bsr absselectdirectory
 movem.l (sp)+,d0-d7/a0-a6
 rts
;---
absselectdirectory
 move.b #0,d7 * number of files found

 dc.w $A00A * Line A function to hide mouse
 
 lea filenamelist,a5
 clr.b d7 * number of files found
 bsr prs
 dc.b 27,'E' * cursor home
 dc.b 27,'J' * clear screen below cursor
 dc.b cr,cr
 dc.b "                             Level 9 Adventures",cr,cr
 dc.b "                    "
 dc.b "Copyright (C) 1986 Level 9 Computing",cr,cr,cr,cr,cr,0
 even

* look in current directory for interesting sub-directories - 
* i.e. those which match with directoryname
 lea fileblock(pc),a0
 move.l a0,-(sp)
 move.w #$1a,-(sp) * function number setdta
 trap #1

 addq.l #6,sp
 move.w #$10,-(sp) * attribute byte - find sub-directories
 lea directoryname(pc),a0
 move.l a0,-(sp)
 move.w #$4e,-(sp) * function number sfirst
 trap #1
 addq.l #8,sp

 tst d0 * file found ?
 bne nofiles

menuprintfname
* filename is at $1e(fileblock)
* first, add it to the list of names
* a5.l=current position in list

 bsr prs
 dc.b "                               ",0
 even

 addq.b #1,d7 * number of files found so far
 clr.l d0
 move.b d7,(a6)
 add.b #"1"-1,(a6)
 move.b #oswrchdcode,d0
 bsr driver
 bsr prs
 dc.b " .. ",0
 even

 clr.b d3 * flag which is set when a dot has been encountered -
* designed to prevent printing .L9 extension after filename

 clr.w d2 * move.w #0,d2
 lea fileblock(pc),a0
menuprintfname1
 move.b $1e(a0,d2),d1
 move.b d1,(a5)+
 beq.s nextfile

 cmp.b #'.',d1
 bne.s mpfnotdot
 move.b #1,d3 * set flag to prevent printing rest of name
mpfnotdot
 tst.b d3 * in filename extension?
 bne.s mpfnoprint

 move.b d1,(a6)
 move.b #oswrchdcode,d0
 bsr driver
mpfnoprint
 addq.l #1,d2 * offset into filename
 bra.s menuprintfname1

nextfile
 move.b #cr,(a6)
 move.b #oswrchdcode,d0
 bsr driver

 move.w #$4f,-(sp) * snext function - any more files?
 trap #1
 addq.l #2,sp
 tst d0
 beq menuprintfname
* no more files
 bra getselection

nofiles
 bsr prs
 dc.b 'no suitable files on disk',cr,0
 bsr waitkey
 bra returntogem

getselection
 cmp.b #1,d7
 bne.s getsel0
 bsr prs
 dc.b "Only one directory available - proceeding with squash",cr,0
 even
 move.b #1,d0
 bra loadfiled0

getsel0
 bsr prs
 dc.b cr,cr,"Press the key corresponding to your choice "
 dc.b "or 'Help' for more information. ",0
 even

* now get a digit, '1'..d7+'1'
displayhelp
getsel1
 move.b #osrdchdcode,d0
 bsr driver
 move.b (a6),d0
 beq.s getsel1

 cmp.b #helpkey,d0
 beq displayhelp

 bsr converttouppercase

 move.w d0,-(sp) * echo character, leave cursor where it is
 bsr protectedoswrch
 move.b #8,(a6) * backspace cursor
 move.b #oswrchdcode,d0
 bsr driver
 move.w (sp)+,d0

 sub.b #'0',d0
 beq getsel1 * '@' is not allowed
 cmp.b d7,d0
 bhi.s getsel1 * unsigned >

loadfiled0
* d0.b is number of directory to enter
* so go through filenamelist to find its name
 lea filenamelist,a0
 move.w #0,d1 * offset
searchfilenamelist
 subq.b #1,d0
 beq sflfound
sfl2
 move.b $0(a0,d1),d2
 add.w #1,d1
 tst.b d2
 beq.s searchfilenamelist
 bra.s sfl2

sflfound
* load game from sub-directory whose name is at $0(a0,d1)
 pea $0(a0,d1) * path name
 move.w #$3b,-(sp) * chdir
 trap #1
 addq.l #6,sp
 tst.w d0 * error?
 bne ; opt d+
 LEA PRG.STRT,A5
 lea startvariablearea(A5),a4
 add.l #50000,a4 ; give space for -ve values of 16 bit offsets

 lea endmemory(a5),a0
 move.w #$08fe,(a0) ; set up end of memory (relative to a4)
; i.e. the z80 data area. (number is in z80 form