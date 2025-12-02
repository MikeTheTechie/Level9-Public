; opt d+
 LEA PRG.STRT,A5
 lea startvariablearea(A5),a4
 add.l #50000,a4 ; give space for -ve values of 16 bit offsets

 lea endmemory(a5),a0
 move.w #$08fe,(a0) ; set up end of memory (relative to a4)
; i.e. the z80 data area. (number is in z80 format)

 move.l a4,a1
 add.l #40000,a1 ; give plenty of room for z80 address space
 lea startfilebuffer(a5),a0
 move.l a1,(a0) ; set up buffer for 68000 file handling

 bsr setsupervisormode
 jmp prg.code
 include c:\driver.s
 include selectdr.s
 include standard.s
 include chain.s
 include stage1.s
 include stage2.s
 include ram.s
