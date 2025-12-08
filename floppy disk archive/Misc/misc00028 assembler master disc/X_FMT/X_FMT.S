;***********************************************************************
;* XFORMAT.PRG  Ver 2.0 An enhanced disk formatter. David Jones.       *
;* Yields more disk space available to user by formatting disk with    *
;* more sectors per track and more tracks per side than the GEM disk   *
;* format routine.                                                     *
;* Revised by M.Mills- 20/12/86                                        *
;***********************************************************************

           OPT      ABS         ;assembler option- can be removed
           SECTION  FMT         ;'SECTION' req'd by GST assembler

CR         EQU      13          ;Carriage return code
LF         EQU      10          ;Line feed code
EOL        EQU      0           ;End-Of-Line delimiter

;************************************
;* Startup code for memory management
;************************************

INIT       MOVE.L   A7,A5               ;get old stack pointer
           LEA      USTACK,A7           ;set new local stack
           MOVE.L   4(A5),A5            ;get memory for SETBLOCK function
           MOVE.L   $C(A5),D0           ;get text segment length
           ADD.L    $14(A5),D0          ;get data segment length
           ADD.L    $1C(A5),D0          ;get block segment length
           ADD.L    #$100,D0            ;offset into base page
           MOVE.L   D0,-(SP)            ;set memory space req'd as
           MOVE.L   A5,-(SP)            ;parameters for TOS
           MOVE.W   #0,-(SP)            ;save dummy word on stack
           MOVE.W   #$4A,-(SP)          ;SETBLOCK function to reserve
           TRAP     #1                  ;space for program.
           LEA      12(SP),SP           ;correct stack
           MOVE.L   #16384,-(SP)        ;reserve 16k words of RAM
           MOVE.W   #$48,-(SP)          ;using MALLOC function. For use
           TRAP     #1                  ;as a buffer in the format
           ADDQ.L   #6,SP               ;process.
           MOVE.L   D0,BUFFER           ;save buffer address

;*********************************
;* End of initialization
;*********************************
MAIN
           DC.W      $A00A              ;Turn mouse display off
           PEA       CLR_SCRN           ;address of clear screen string
           MOVE.W    #9,-(SP)           ;and print it so that screen is
           TRAP      #1                 ;cleared.
           ADDQ.L    #6,SP
           PEA      TITLE               ;get address of title line
           MOVE.W   #9,-(SP)            ;and call 'PRINT LINE' function
           TRAP     #1
           ADDQ.L   #6,SP

;*************************************
; Get number of sides to format
;*************************************
CMD1       MOVE.W   #1,-(SP)            ;wait for a user to select 1 or
           TRAP     #1                  ;2 sided format
           ADDQ.L   #2,SP
           CMP.B    #'Q',D0             ;was it Q for quit?
           BEQ      END_FMT             ;yes- quit program.
           CMP.B    #'q',D0             ;check for lowercase 'q'
           BEQ      END_FMT
           CMP.B    #$31,D0             ;no- compare to '1'
           BLO.S    CMD1                ;if lower than 1 go get again
           CMP.B    #$32,D0             ;compare it to '2'
           BHI.S    CMD1                ;if higher than 2 go get again
           SUB.B    #$31,D0             ;subtract ASCII '1' from char
                                        ;so that '1' entered results in
                                        ;0 being stored and '2' entered
                                        ;results in 1 being stored
           MOVE.B   D0,DSIDED           ;save it

;************************************
;* Get disk name for format
;************************************
           MOVE.B   #13,NAME
           PEA      PROMPT              ;get address of prompt
           MOVE.W   #9,-(SP)            ;and print it.
           TRAP     #1          
           ADDQ.L   #6,SP
           PEA      NAME                ;get address of name buffer
           MOVE.W   #10,-(SP)           ;and call READLINE to wait for
           TRAP     #1                  ;user to enter disk name
           ADDQ.L   #6,SP
           LEA      NAME,A0             ;get address of name buffer
           MOVE.W   #'A:',(A0)          ;and set drive ID in string.

;************************************
;* Do disk format
;************************************
           MOVEQ    #0,D3               ;clear D3 register
           MOVE.W   #$E5E5,VIRGIN       ;set standard format value
LOOP1
           JSR      DFORM               ;Format 1 track
           TST.W    EFLAG               ;Error on that track
           BNE      BAD_FMT             ;Yes, process.
           ADDQ.W   #1,D3               ;increment track number
           CMP.W    #82,D3              ;83 (0-82) tracks done?
           BLS.S    LOOP1               ;nope! so do the next sector.

;*************************************
;* Initialize track 0 for boot sector
;*************************************
           MOVE.W   #0,VIRGIN           ;Use 0 as format value for track
           CLR.W    D3                  ;zero in readiness for boot
           JSR      DFORM               
           TST.W    EFLAG               ;Test for errors
           BNE      BAD_FMT             ;Yes- process it.

;***********************************
;* Create a boot sector for the disk
;***********************************
SETBTSEC   MOVE.W   #0,-(SP)            ;Set non-executable boot value
           MOVEQ    #2,D0               ;set disk type to default value
                                        ;i.e 80 Trk, Single sided.
           ADD.B    DSIDED,D0           ;Add DSIDED- if it is a double
                                        ;sided disk then DSIDED would=1
                                        ;so disk type would here be set
                                        ;to 3 i.e 80 Trk double sided.
           MOVE.W   D0,-(SP)            ;Save disk type
           MOVE.L   #$01000000,-(SP)    ;set disk serial number.
           MOVE.L   BUFFER,-(SP)        ;address of area to create sector
           MOVE.W   #18,-(SP)           ;call GEM function PROTOBT
           TRAP     #14
           LEA      14(SP),SP
           MOVE.L   BUFFER,A0           ;Get address of buffer
           MOVE.B   #$00,11(A0)         ;adjust standard boot sector         
           MOVE.B   #$02,12(A0)         ;values to reflect custom format
           MOVE.B   #$3E,19(A0)         ;set to single sided default
           MOVE.B   #$03,20(A0)         ;ditto
           TST.B    DSIDED              ;Double sided disk?
           BEQ.S    NOPBD               ;no so skip next bit
           MOVE.B   #$7C,19(A0)         ;adjust boot sector values for
           MOVE.B   #$06,20(A0)         ;double sided disk
NOPBD      MOVE.B   #10,24(A0)          ;set 10 sectors per track

;*************************************
;* Write sector to boot sector on disk
;*************************************
           MOVE.W   #1,-(SP)            ;one sector to be written
           MOVE.W   #0,-(SP)            ;write to side 0
           MOVE.W   #0,-(SP)            ;track 0
           MOVE.W   #1,-(SP)            ;sector 1
           MOVE.W   #0,-(SP)            ;on drive A:
           CLR.L    -(SP)               ;dummy (unused) longword
           MOVE.L   A0,-(SP)            ;address of buffer still in A0
           MOVE.W   #9,-(SP)            ;call GEM function FLOPWR
           TRAP     #14
           LEA      20(SP),SP
           TST.W    D0                  ;If D0<>0 then error occured
           BNE.S    BAD_FMT             ;so process it.

;*************************************
;* Write disk name (Vol ID)
;*************************************
DONAME
           MOVE.W   #0,-(SP)            ;Set drive to A: by using GEM
           MOVE.W   #$0E,-(SP)          ;function SETDRV
           TRAP     #1
           ADDQ.L   #4,SP
           PEA      NULL                ;Set pathname to root directory
           MOVE.W   #$3B,-(SP)
           TRAP     #1                  
           ADDQ.L   #6,SP

           MOVE.W   #8,-(SP)            ;Set file attribute to Vol ID.
           PEA      NAME                ;get address of name buffer
           MOVE.W   #$3C,-(SP)          ;And call CREATE function of GEM
           TRAP     #1                  ;(Usually used to create files)
           ADDQ.L   #8,SP               ;to write name to the disk.
           TST.W    D0                  ;Error occured?
           BMI.S    BAD_FMT             ;Yes so process it.
           MOVE.W   D0,-(SP)            ;File handle retained in D0
           MOVE.W   #$3E,-(SP)          ;Close file
           TRAP     #1          
           ADDQ.L   #4,SP
           BRA.L    MAIN                ;Go again for next disk

;***************************************
;* Error handler
;***************************************
BAD_FMT    PEA      ERRMSG              ;Inform user of error condition
           MOVE.W   #9,-(SP)            ;by printing error message.
           TRAP     #1
           ADDQ.L   #6,SP
           MOVE.W   #1,-(SP)            ;Wait for user to hit a key
           TRAP     #1                  
           ADDQ.L   #2,SP
           BRA      MAIN               ;Then go to start for next disk

;****************************************
;* Quit program
;****************************************
END_FMT    CLR.W    -(SP)               ;exit program back to desktop
           TRAP     #1                  ;bye!

;****************************************
;* Track format subroutine.
;****************************************
DFORM
           MOVE.W   VIRGIN,-(SP)        ;set 'virgin' value.
           MOVE.L   #$87654321,-(SP)    ;set 'magic' value.
           MOVE.W   #1,-(SP)            ;set interleave value.
           MOVE.W   #0,-(SP)            ;set side to format
           MOVE.W   D3,-(SP)            ;D3 contains track to format
           MOVE.W   #10,-(SP)           ;format with 10 sectors per track
           MOVE.W   #0,-(SP)            ;set device to drive A:
           CLR.L    -(SP)               ;set dummmy longword (unused)
           MOVE.L   BUFFER,-(SP)        ;set address of format buffer
           MOVE.W   #10,-(SP)           ;and call FLOPFMT function
           TRAP     #14                 ;call GEM
           LEA      26(SP),SP           ;correct stack
           MOVE.W   D0,EFLAG            ;Save D0 for error checking
           TST.W    D0                  ;Did an error occur
           BNE.S    NOFMTS2             ;If so then quit routine
           TST.B    DSIDED              ;Two sided format?
           BEQ.S    NOFMTS2             ;If DSIDED=0 then no- skip next
           MOVE.W   VIRGIN,-(SP)        ;Reproduce format setup but for
           MOVE.L   #$87654321,-(SP)    ;side 2 of the disk.
           MOVE.W   #1,-(SP)            ;interleave the same
           MOVE.W   #1,-(SP)            ;side 2
           MOVE.W   D3,-(SP)            ;sector is still the same
           MOVE.W   #10,-(SP)           ;same sectors per track
           MOVE.W   #0,-(SP)            ;same device
           CLR.L    -(SP)
           MOVE.L   BUFFER,-(SP)        ;use same buffer
           MOVE.W   #10,-(SP)           ;call GEM routine to format
           TRAP     #14                 ;the second side.
           LEA      26(SP),SP
           MOVE.W   D0,EFLAG            ;Save D0 for error checking
NOFMTS2    RTS                          ;return from subroutine

;**************************************
;* Program storage area
;**************************************
DSIDED     DC.W     0           ;SS/DS flag, 0=SS, 1=DS
VIRGIN     DS.W     1           ;value to write during format process
EFLAG      DS.W     1           ;Hold status for error check
NULL       DC.B     'A:\',EOL        ;Null pathname
CLR_SCRN   DC.B     27,'E',EOL
CRS        DC.B     CR,LF,LF,LF,EOL  ;Space down 3 lines on screen
;
           DS.W     0
TITLE      DC.B     7
           DC.B     '**********************************',CR,LF
           DC.B     '*             XFORMAT            *',CR,LF
           DC.B     '* ATARI ST EXTRA TRACK FORMATTER *',CR,LF
           DC.B     '*   By David Jones - May 1986    *',CR,LF
           DC.B     '*  Revision 2 M.Mills. Dec 1986  *',CR,LF
           DC.B     '**********************************',CR,LF,LF,LF
           DC.B     'Place disk to be formatted in '
           DC.B     27,'pDRIVE A',27,'q',CR,LF,LF
           DC.B     'Key 1 = Single Sided',CR,LF
           DC.B     'Key 2 = Double sided',CR,LF
           DC.B     'Key Q = Quit program',CR,LF,LF
           DC.B     'Choice>'
           DC.B     EOL,EOL
PROMPT     DC.B     CR,LF,LF,'Enter disk name >',EOL
           DS.W     0
ERRMSG     DC.B     CR,LF,LF,7
           DC.B     '**** UNABLE TO FORMAT! ****',CR,LF,LF
           DC.B     'Press any key to retry.....',CR,LF,0
NAME       DC.B     13,0
           DC.B     '             '   ;buffer for disk name
           DC.B     EOL,EOL
BUFFER     DS.L     1    ;Pointer to buffer address
           DS.L     128  ;Local stack area
USTACK     DC.L     0
;************************************************************************
;* END OF CODE FOR XFORMAT.PRG                                          *
;************************************************************************
           END      ;Assembler directive


