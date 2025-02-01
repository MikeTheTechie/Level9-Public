 page 128,122 ;length,width
;IBM KAOS DRIVER. driver routines common to MENU and AINT.

;DRIVER.ASM

;Copyright (C) 1987,1988,1989 Level 9 Coputing

;-----

NAME DRIVER

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
 include common.asm
 include consts.asm

;...e

;...sPublics and externals:0:

 public BreakPoint
 public chain 
 public Dchecksum
 public DisplayDosDecimal
 public displayhex
 public displayword
 public GeneralLoadFile
 public GeneralSaveFile
 public initialiseall
 public InLineDos
 public MCInvertedOSwrchV1
 public MCClearRectangle
 public MCOSwrchV1
 public Doswrch
 public SetCursor
 public ScreenTable

;In AINT.ASM
 extrn aintrestart:near

;In BIN.ASM:
   IFE TwoD
 extrn AddrClearRectangle:dword
 extrn AddrPrintCharacter:dword
   ENDIF ;TwoD

;In GAME.ASM:
 extrn B_InvertFlag:byte
 extrn CGA_MustRebuild:byte
 extrn HiLo_CursorXpos:word
 extrn HiLo_CursorYpos:word
 extrn HiLo_TextBufferP:word
 extrn LoLongLogicalBase:word
 extrn LoLongTextScreenBase:word
 if TraceCode          ;@
 extrn debugword:word  ;@
 endif ;TraceCode      ;@
   IF TwoD
 if TraceCode          ;@
 extrn CheckChain:near ;@
 endif ;TraceCode      ;@
 extrn Pass_Variables:near
 extrn Retrieve_variables:near
   ENDIF ;TwoD

;In HANDLER.ASM:
 if TwoD
  extrn Screen1Status:word
  extrn Screen2Status:word 
 endif ;TwoD

;In HUGE.ASM:
 extrn CharThisAddr:word
 extrn CharThisSize:word
;! extrn CS_CGA_Screen1:word
;! extrn CS_CGA_Screen2:word
;! extrn CS_CGA_FontSegment:word
 extrn CS_Acode:word
 extrn CS_AcodeSize:word
 extrn CS_GameData:word
;! extrn CS_ScreenMode:byte
 extrn DumpRegisters:near
 extrn SafeShutDown:near

;In INTRPT.ASM:
 extrn DisplayVisible:near
 extrn SilentFatalError:near

;In MCODE.ASM:
 extrn CS_ClipPosition:word
 extrn CS_LastTopLine:word
 extrn CS_TextDestination:word
 extrn Game_HandleCR:near
 extrn MCReturn:near

;In PRINT.ASM:
   IF TwoD
 extrn EGA2DCLEARRECTANGLE:near
 extrn EGAPrintCharacter:near
   ENDIF ;TwoD

;*****
 extrn AddressGameDataDat:word

;...e

;-----

;...sTables:0:

;Constants likely to change:

;Ascii/BBC control codes:
asciibs = 08h
asciilf = 0Ah
asciicr = 0Dh
space = ' '

;...e

;-----

code SEGMENT public 'code'
 ASSUME cs:code,ds:code

;-----

;...sSubroutines:0:

returnwidth proc near

 mov al,ds:[characterwidth]
 mov ds:0[si],al
 ret

returnwidth endp

;-----

getcharacter proc near

 push si
 push bx
 push cx
 push dx
 call gc02
 pop dx
 pop cx
 pop bx
 pop si
 ret

gc02:
 cmp ds:[kbdbuflen],0
 je readkeyboard

 mov al,ds:[kbdbuffer]
 mov si,offset kbdbuffer+1
 mov cx,kbdbufsize-1
 push ax
 mov di,offset kbdbuffer
ldirds:
 cmp cx,0
 je ldirdsend
 mov al,ds:0[si]
 mov ds:0[di],al
 inc di
 inc si
 dec cx
 jmp short ldirds
ldirdsend:
 pop ax
 dec ds:[kbdbuflen]

 ret

readkeyboard:
 mov ah,01                  ;Service 1 (Report keyboard)
 int 16h                    ;ROM-BIOS keyboard service
 jnz getch2
 mov al,0
 ret
getch2:
 mov ah,00h                 ;Service 0 (Read Next Keyboard Character)
 int 16h                    ;ROM-BIOS keyboard service
 cmp ax,04800h              ;Cursor up
 jne notup2
 mov ax,21
 ret
notup2:
 cmp ax,04b00h              ;Cursor left
 jne notleft
 mov ax,2
 ret
notleft:
 cmp ax,04d00h              ;Cursor right
 jne notright
 mov ax,6
 ret
notright:
 cmp ax,05000h              ;Cursor down
 jne notdown2
 mov ax,4
 ret
notdown2:
 cmp ax,04700h              ;Home
 je keypad
 cmp ax,04900h              ;PgUp
 je keypad
 cmp ax,04F00h              ;End
 je keypad
 cmp ax,05100h              ;PgDn
 je keypad
 cmp ax,00F00h              ;Reverse TAB
 jne rk01
keypad:
 mov ax,9

rk01:
 ret

getcharacter endp

;-----

osrdch proc near

 call getcharacter
 mov ds:0[si],al
 ret

osrdch endp

;-----

Dchecksum proc near

 mov bl,cs:2[si]            ;End address
 mov bh,cs:3[SI]
 mov dl,cs:0[SI]            ;Start address
 mov dh,cs:1[SI]
 sub bx,dx
 mov cx,bx
 xchg dx,bx                 ;hl=Start address

 inc cx
 mov dl,0
checksum1:
 cmp cx,0
 je checksum2
 add dl,es:[bx]
 inc bx
 dec cx
 jmp short checksum1
checksum2:
 mov cs:0[si],dl            ;Result
 ret

Dchecksum endp

;-----

ldir proc near

 cmp cx,0
 je ldirend
 mov al,ds:0[si]
 mov ds:0[di],al
 inc di
 inc si
 dec cx
 jmp short ldir
ldirend:
 ret

ldir endp

;-----

;Input:
;   es:si address
;   ds:bx name
;   dx,cx max length

;Return code:
;   al=0, ok
;   al=1, missing
;   al=2, other error (e.g. read error)

GeneralLoadFile proc near

 push cx                    ;Length
 push dx
 push es                    ;Load address
 push si

 mov dx,bx                  ;filename
 mov al,0                   ;non-private/compatable/read-only
 mov ah,61                  ;Open file
 int 21h                    ;extended DOS function

 jnc le01                   ;file exists

 pop si                     ;correct stack
 pop es
 pop dx
 pop cx

 mov al,1                   ;File not found
 ret

le01:
 push ax                    ;File handle

 mov bx,ax
 mov al,0                   ;relative to start of file
 mov cx,0                   ;relative position (high)
 mov dx,0                   ;relative position (low)
 mov ah,66                  ;move file pointer
 int 21h                    ;extended DOS function

 pop ax                     ;file handle
 pop si                     ;Load address
 pop es
 pop dx                     ;Length
 pop cx

le02:
 push ax                    ;File handle
 push ds

 cmp cx,0
 jnz le03                   ;length not a multiple of 64K
 cmp dx,0
 jz le06                    ;length=0, reached limit of number of bytes to load

;set CX as actual number of bytes (1 thru 65535) loaded this time...

 cmp cx,0 ;*****
 je le02a ;*****
 cmp cx,8000h
 jc le03                    ;first, make remainder of file a multiple of 32K

le02a: ;*
 push cx                    ;save requested length
 push dx
 mov cx,8000h               ;instead, load 32K bytes
 jmp short le04

le03:                       ;length not a multiple of 64K/32K
 push cx                    ;length
 push dx
le04:

;Load CX bytes

 mov bx,ax                  ;file handle
                            ;cx=length
 mov ax,es
 mov ds,ax
 mov dx,si                  ;address DS:DX
 mov ah,63                  ;Read from file
 int 21h                    ;extended DOS function
 jnc le05

;Error

 pop dx                     ;correct stack
 pop cx
 pop ds
 pop bx                     ;File handle

 mov ah,62                  ;Close file handle
 int 21h                    ;extended DOS function

 mov al,2                   ;read error
 ret

;OK

le05:
 pop dx                     ;length
 pop cx

 cmp ax,0
 jz le06                    ;Reached EOF before 'max length'
 
 sub cx,ax                  ;Number of bytes loaded
 jnc le05a
 dec cx
le05a:
 pop ds
 pop ax                     ;File handle
 jmp short le02

;End of file

le06:
 pop ds
 pop bx                     ;File handle

 mov ah,62                  ;Close file handle
 int 21h                    ;extended DOS function

 mov al,0                   ;OK!
 ret

GeneralLoadFile endp

;-----

;Input:
;   es:si address
;   ds:bx name
;   dx,cx length

;Return code:
;   al=0, ok
;   al=1, can't create
;   al=2, other error (e.g. read/write error)

GeneralSaveFile proc near

 push cx                    ;Length
 push dx
 push es                    ;Load address
 push si

 mov dx,bx                  ;filename
 mov cl,0                   ;File attribute
 mov ah,60                  ;Create file
 int 21h                    ;extended DOS function

 jnc se01                   ;Create OK

 pop si                     ;correct stack
 pop es
 pop dx
 pop cx

 mov al,1                   ;Can't create
 ret

se01:
 pop si                     ;Load address
 pop es
 pop dx                     ;Length
 pop cx

se02:
 push ax                    ;File handle
 push ds

 cmp cx,0
 jnz se03                   ;length not a multiple of 64K
 cmp dx,0
 jz se06                    ;length=0, saved all

;set CX as actual number of bytes (1 thru 65535) to save this this time...

 cmp cx,8000h
 jc se03                    ;Make length 32K

 push cx                    ;save requested length
 push dx
 mov cx,8000h               ;instead, load 32K bytes
 jmp short se04

se03:                       ;length not a multiple of 64K/32K
 push cx                    ;length
 push dx
se04:

;Load CX bytes

 mov bx,ax                  ;file handle
                            ;cx=length
 mov ax,es
 mov ds,ax
 mov dx,si                  ;address DS:DX
 mov ah,64                  ;Write to file
 int 21h                    ;extended DOS function
 jnc se05

;Error

se04b:
 pop dx                     ;correct stack
 pop cx
 pop ds
 pop bx                     ;File handle

 mov ah,62                  ;Close file handle
 int 21h                    ;extended DOS function

 mov al,2                   ;Write error
 ret

;OK

se05:
 pop dx                     ;length
 pop cx

 cmp ax,0
 jz se04b                   ;Did not write anything
 
 sub cx,ax                  ;Number of bytes written
 jnc se05a
 dec cx
se05a:
 pop ds
 pop ax                     ;File handle
 jmp short se02

;ALl data written

se06:
 pop ds
 pop bx                     ;File handle

 mov ah,62                  ;Close file handle
 int 21h                    ;extended DOS function

 mov al,0                   ;OK!
 ret

GeneralSaveFile endp

;-----

GameFileName:
 db "GAMEDATA.DAT",0

AcodeFileName:
 db "ACODE.ACD",0

chain proc near

 mov ax,cs
 mov ds,ax
 assume ds:code
 mov bx,offset GameFileName ;Filename
 mov es,cs:CS_GameData      

 mov si,cs:AddressGameDataDat ;Load address
 mov dx,0
 mov cx,65535
 sub cx,si                    ;length
;   es:si address
;   ds:bx name
;   dx,cx max length
 call GeneralLoadFile
;   dx,cx = Length of file
 cmp al,0
 jne Missing

 cmp cs:CS_AcodeSize,0
 je NoAcode
 mov bx,offset AcodeFileName  ;Filename
 mov es,cs:CS_Acode

 mov si,SizeRunTimeSystem     ;Load address
 mov dx,0
 mov cx,65535
 sub cx,si                    ;length
;   es:si address
;   ds:bx name
;   dx,cx max length
 call GeneralLoadFile
;   dx,cx = Length of file
 cmp al,0
 jne Missing
NoAcode:
 jmp aintrestart

 jmp aintrestart

Missing:
 call SafeShutDown ;restore vectors
 mov ax,0003h ;Set screen mode 3 (80x25 text)
 int 10h
 call InLineDos
 db "GAMEDATA.DAT; can't open$"
 mov ah,04Ch                ;Terminate process
 int 21h

; call InLineDos
; db asciicr,asciilf,"EOF error.",asciicr,asciilf,"$"

; call InLineDos
; db asciicr,asciilf,"Insert game disk then press space: $"

;
;chain4:
; call getcharacter
; cmp al,3
; jne chain5

terminate:                  ;Acode 'STOP' function
 mov ah,76                  ;Terminate
 int 21h                    ;DOS Service

;chain5:
; cmp al," "
; jne short chain4
;
; call InLineDos
; db asciicr,asciilf,"$"
;
; pop si
; jmp chain1

chain endp

 assume ds:nothing

;-----

DisplayDosDecimal proc near

;Print number AX in decimal
 and ax,ax
 jz dd05

 sub cl,cl                  ;Reset flag
 mov si,offset prntbl
;Find current digit value
dd01:
 mov dx,cs:[si]
 inc si
 inc si
 and dx,dx
 jnz dd02
 ret                        ;5 digits found

dd02:
;Find current digit
 mov ch,'0'
dd03:
 sub ax,dx
 jb dd04
 inc ch
 mov cl,1
 jmp short dd03

dd04:
 add ax,dx
 or cl,cl
 jz dd01
 push ax
 mov al,ch
 call printchar
 pop ax
 jmp short dd01

dd05:
 mov al,'0'
printchar:
 push ax
 push cx
 push dx
 push si
 push ds

 call DisplayChar

 pop ds
 pop si
 pop dx
 pop cx
 pop ax
 ret

prntbl:
 dw 10000
 dw 1000
 dw 100
 dw 10
 dw 1
 dw 0                       ;end

DisplayDosDecimal endp

 assume ds:nothing

;-----

InLineDos proc near

 pop si

 mov ax,cs
 mov ds,ax
 assume ds:nothing

id01:
 mov al,cs:[si]
 cmp al,"$"
 jz id02

 push si
 call DisplayVisible
 pop si
 
 inc si
 jmp short id01

id02:
 inc si
 push si
 ret

InLineDos endp

;-----

CopyDisplayArea:
 mov si,0
 mov di,si
 mov cx,2000h               ;8K words
 rep movsw
 ret

;-----

AdvanceCursor proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov ax,HiLo_CursorXpos
 xchg ah,al
 add ax,8
 cmp ax,320-8
 ja newline
 xchg ah,al
 mov HiLo_CursorXpos,ax
 ret
newline:
 mov HiLo_CursorXpos,0

 mov ax,HiLo_CursorYpos
 xchg ah,al
 add ax,8
 cmp ax,200-8
 jbe AdvanceOK
 ret
AdvanceOK:
 xchg ah,al
 mov HiLo_CursorYpos,ax
 ret

AdvanceCursor endp

;-----

EGA_DisplayDL proc near

 mov ax,ds:HiLo_CursorXpos
 xchg ah,al
 mov bx,ds:HiLo_CursorYpos
 xchg bh,bl
 mov dh,ds:B_InvertFlag

; ax - xpos
; bx - ypos
; dh - invertflag
; dl - character
; es - base screen address
 cmp ax,320-8
 ja OutOfRange
 cmp bx,200-8
 ja OutOfRange

 mov cx,bx
 mov bp,7
; ax - xpos
; bx - screen ypos
; cx - buffer ypos
; dh - invertflag
; dl - character
; bp - destination (1-Buffer,2-Logical,4-Physical)

   IF TwoD
 call EGAPrintCharacter
   ELSE ;TwoD
 call cs:AddrPrintCharacter
   ENDIF ;TwoD
 call AdvanceCursor
OutOfRange:
 ret

EGA_DisplayDL endp

;-----

Display_AL proc near ;All 2D printing

;! cmp cs:CS_ScreenMode,0
;! jne EGA_Display_AL
;!
;!;CGA_DisplayAL...
;!
;! mov es,cs:CS_CGA_Screen2
;!
;! mov dx,ds:HiLo_CursorYpos
;! xchg dh,dl
;! mov cx,HiLo_CursorXpos
;! xchg ch,cl
;!
;! call CGA_ZapCharacter
;! call AdvanceCursor
;! ret

EGA_Display_AL: ;EGA 2D printing
 mov dl,al

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov es,ds:LoLongLogicalBase ;2D logical screen
 jmp EGA_DisplayDL

Display_AL endp

 assume ds:nothing

;-----

;Display character in (IY)
;All decompressed character output (after word-wrapping)

Doswrch:
 push bx
 push cx
 push dx
 push si
 push di
 push es
 push ds
 push bp
 call oswrch
 pop bp
 pop ds
 pop es
 pop di
 pop si
 pop dx
 pop cx
 pop bx
 ret

OSWRCH proc near

 cmp al,23h                 ;Convert '#' to pound
 jne os01
 mov al,60h

os01:
 push ds
 call os02
 pop ds
 ret

os02:
 cmp cs:CS_TextDestination,0
 je os03                    ;Use ST/AMIGA-style output

 jmp DisplayCharacter3D

os03:
 push ax
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 pop ax
 mov bx,ds:HiLo_TextBufferP
 xchg bh,bl                 ;For OswrchToBuffer
 cmp bx,0
 jne OswrchToBuffer         ;All 2D output goes to buffer

;All 3D output

 cmp al,' '
 jb OswrchNoPrint           ;3D control code

 mov dl,al                  ;ascii code
 mov ax,ds:LoLongTextScreenBase ;3D text screen copy
 mov es,ax
 jmp EGA_DisplayDL          ;3D display

OswrchNoPrint:
 cmp al,13
 je OswrchNewLine
 ret

OswrchNewLine:
 jmp Game_HandleCR          ;3D. Let acode 'DoCr'

OswrchToBuffer:
 push es
 mov es,cs:CS_Acode
 les si,es:[PCListVector+24*4] ;Table 24. Text buffer
 mov es:[si+bx],al
 pop es

 inc bx
 xchg bh,bl
 mov HiLo_TextBufferP,bx
 ret

OSWRCH endp

;-----

;!DisplayCharPhysical proc near
;!
;! push bx
;! push dx
;! push cx
;! push si
;!
;! push cx
;! push dx
;!
;! assume ds:vars
;! push ds
;! mov cx,seg vars
;! mov ds,cx
;! mov cx,ds:HiLo_CursorXpos
;! xchg ch,cl
;! mov dx,ds:HiLo_CursorYpos
;! xchg dh,dl
;!
;! cmp cx,320-7               ;Character must be entirely on the screen
;! jae dc04
;! cmp dx,200-7
;! jae dc04
;! cmp al,' '
;! jb dc04
;! cmp al,07Fh
;! jae dc04
;! 
;! push ax
;! mov ax,0B800h
;! mov es,ax
;! pop ax
;!
;! call CGA_ZapCharacter 
;!
;!dc04:
;! call AdvanceCursor
;! pop ds
;! assume ds:nothing
;! pop dx
;! pop cx
;!
;! pop si
;! pop cx
;! pop dx
;! pop bx
;! ret
;!
;!DisplayCharPhysical endp

 assume ds:nothing

;-----

ScreenTable dw 0
            dw 2000h
            dw 0+1*80
            dw 2000h+1*80
            dw 0+2*80
            dw 2000h+2*80
            dw 0+3*80
            dw 2000h+3*80
            dw 0+4*80
            dw 2000h+4*80
            dw 0+5*80
            dw 2000h+5*80
            dw 0+6*80
            dw 2000h+6*80
            dw 0+7*80
            dw 2000h+7*80
            dw 0+8*80
            dw 2000h+8*80
            dw 0+9*80
            dw 2000h+9*80
            dw 0+10*80
            dw 2000h+10*80
            dw 0+11*80
            dw 2000h+11*80
            dw 0+12*80
            dw 2000h+12*80
            dw 0+13*80
            dw 2000h+13*80
            dw 0+14*80
            dw 2000h+14*80
            dw 0+15*80
            dw 2000h+15*80
            dw 0+16*80
            dw 2000h+16*80
            dw 0+17*80
            dw 2000h+17*80
            dw 0+18*80
            dw 2000h+18*80
            dw 0+19*80
            dw 2000h+19*80
            dw 0+20*80
            dw 2000h+20*80
            dw 0+21*80
            dw 2000h+21*80
            dw 0+22*80
            dw 2000h+22*80
            dw 0+23*80
            dw 2000h+23*80
            dw 0+24*80
            dw 2000h+24*80
            dw 0+25*80
            dw 2000h+25*80
            dw 0+26*80
            dw 2000h+26*80
            dw 0+27*80
            dw 2000h+27*80
            dw 0+28*80
            dw 2000h+28*80
            dw 0+29*80
            dw 2000h+29*80
            dw 0+30*80
            dw 2000h+30*80
            dw 0+31*80
            dw 2000h+31*80
            dw 0+32*80
            dw 2000h+32*80
            dw 0+33*80
            dw 2000h+33*80
            dw 0+34*80
            dw 2000h+34*80
            dw 0+35*80
            dw 2000h+35*80
            dw 0+36*80
            dw 2000h+36*80
            dw 0+37*80
            dw 2000h+37*80
            dw 0+38*80
            dw 2000h+38*80
            dw 0+39*80
            dw 2000h+39*80
            dw 0+40*80
            dw 2000h+40*80
            dw 0+41*80
            dw 2000h+41*80
            dw 0+42*80
            dw 2000h+42*80
            dw 0+43*80
            dw 2000h+43*80
            dw 0+44*80
            dw 2000h+44*80
            dw 0+45*80
            dw 2000h+45*80
            dw 0+46*80
            dw 2000h+46*80
            dw 0+47*80
            dw 2000h+47*80
            dw 0+48*80
            dw 2000h+48*80
            dw 0+49*80
            dw 2000h+49*80
            dw 0+50*80
            dw 2000h+50*80
            dw 0+51*80
            dw 2000h+51*80
            dw 0+52*80
            dw 2000h+52*80
            dw 0+53*80
            dw 2000h+53*80
            dw 0+54*80
            dw 2000h+54*80
            dw 0+55*80
            dw 2000h+55*80
            dw 0+56*80
            dw 2000h+56*80
            dw 0+57*80
            dw 2000h+57*80
            dw 0+58*80
            dw 2000h+58*80
            dw 0+59*80
            dw 2000h+59*80
            dw 0+60*80
            dw 2000h+60*80
            dw 0+61*80
            dw 2000h+61*80
            dw 0+62*80
            dw 2000h+62*80
            dw 0+63*80
            dw 2000h+63*80
            dw 0+64*80
            dw 2000h+64*80
            dw 0+65*80
            dw 2000h+65*80
            dw 0+66*80
            dw 2000h+66*80
            dw 0+67*80
            dw 2000h+67*80
            dw 0+68*80
            dw 2000h+68*80
            dw 0+69*80
            dw 2000h+69*80
            dw 0+70*80
            dw 2000h+70*80
            dw 0+71*80
            dw 2000h+71*80
            dw 0+72*80
            dw 2000h+72*80
            dw 0+73*80
            dw 2000h+73*80
            dw 0+74*80
            dw 2000h+74*80
            dw 0+75*80
            dw 2000h+75*80
            dw 0+76*80
            dw 2000h+76*80
            dw 0+77*80
            dw 2000h+77*80
            dw 0+78*80
            dw 2000h+78*80
            dw 0+79*80
            dw 2000h+79*80
            dw 0+80*80
            dw 2000h+80*80
            dw 0+81*80
            dw 2000h+81*80
            dw 0+82*80
            dw 2000h+82*80
            dw 0+83*80
            dw 2000h+83*80
            dw 0+84*80
            dw 2000h+84*80
            dw 0+85*80
            dw 2000h+85*80
            dw 0+86*80
            dw 2000h+86*80
            dw 0+87*80
            dw 2000h+87*80
            dw 0+88*80
            dw 2000h+88*80
            dw 0+89*80
            dw 2000h+89*80
            dw 0+90*80
            dw 2000h+90*80
            dw 0+91*80
            dw 2000h+91*80
            dw 0+92*80
            dw 2000h+92*80
            dw 0+93*80
            dw 2000h+93*80
            dw 0+94*80
            dw 2000h+94*80
            dw 0+95*80
            dw 2000h+95*80
            dw 0+96*80
            dw 2000h+96*80
            dw 0+97*80
            dw 2000h+97*80
            dw 0+98*80
            dw 2000h+98*80
            dw 0+99*80
            dw 2000h+99*80

;-----

kbdbuffer db kbdbufsize dup(0)
kbdbuflen db 0

characterwidth db 0

diskbuffer db 80h dup (0)
 db 1024 dup (0)            ;Make up to MS-DOS sector length (for trykdisk)

 db 7 dup(0)                ;Extended area
sysfcb = this byte
fcbdrive db 0
         db 8  dup(0)       ;name
         db 3  dup(0)       ;type
fcbex    db 20 dup(0)
fcbcr    db 4  dup(0)
fcbend = this byte
fcblen    = fcbend-sysfcb

;-----

initialiseall:
partialinit:
 mov ds:[kbdbuflen],0       ;Clear keyboard buffer

 mov dx,offset diskbuffer
 mov ah,01Ah                ;Set Disk Transfer Area
 int 21h                    ;ROM-BIOS DOS Functions

 ret

;-----

;Calculate number of pages that need to be read/written
;to ensure a minimum number of bytes are transfered.
;HL is number of bytes.
;Returns A as number of pages. Flags corrupted.
calcpages:
 push bx
 dec bx
 inc bh
 mov al,bh
 pop bx
 ret

;-----

;Open system file for reading.
;DE is the address of the file control block
;initialised by GETNAME.
;Most registers corrupted.
openread:
 mov dx,offset sysfcb
 mov ah,cpnof
 int 21h                    ;Dos Service
 or al,al
 jnz short dbi027
 clc
 ret
dbi027:
 stc
 ret

;-----

;Read up to 'AL' pages or untiL EOF from the
;system file into memory starting at address
;'BX'. The file must have been opened by OPENREAD
;Returns condition 'C' on disk error

readfile:
rf01:
 mov dx,offset sysfcb
 or al,al
 jz rf03

 push ax
 call readblock
 jc rf02
 call readblock
 jc rf02
 pop ax
 dec al
 jmp short rf01

rf02:
 pop ax
 stc

rf03:
 ret

readblock:
 push ax
 push bx
 mov ah,cpnrs
 int 21h                    ;Dos service
 pop bx
 or al,al
 jnz short rb01
 pop ax
 push dx
 mov cx,128
 mov si,offset diskbuffer
 mov di,bx
ldirfromworkspace:
 cmp cx,0
 je short ldirfromend
 mov al,ds:0[si]
 mov es:0[di],al
 inc di
 inc si
 dec cx
 jmp short ldirfromworkspace
ldirfromend:
 mov bx,di
 pop dx
 xor al,al
 ret
rb01:
 pop ax
 stc
 ret

;-----

;Close system file previously
;opened by OPENREAD or OPENWRITE
;Registers AF,HL,DE,BC corrupted.
close:
 mov dx,offset sysfcb
 mov ah,cpncf
 int 21h                    ;Dos Service
 ret

;-----

;Prepare system FCB for a new file. Set drive
;to current login drive.
;Registers AF,HL,DE,BC corrupted.
fcbinit:
 mov ah,cpnrst
 int 21h                    ;Dos Service
 mov bx,offset sysfcb
 mov dx,offset sysfcb+1
 mov cx,fcblen-1
 mov byte ptr ds:[bx],space
 xchg bx,si
 xchg dx,di
 call ldir
 xchg bx,si
 xchg dx,di
 xor al,al
 mov ds:[fcbdrive],al
 mov ds:[fcbex],al
 mov ds:[fcbcr],al
 ret

;-----

dontclear:
 mov ah,2                   ;Service 2 - Set Cursor Position
 mov dl,0                   ;Column
 mov dh,24                  ;Row in WORDS mode
 int 10h                    ;ROM-BIOS video service
 ret

;-----

BreakPoint proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov dx,8                   ;Row
 mov cx,1                   ;Column
 call SetCursor

 call InLineDos
 db "ESC: $"

 if TraceCode        ;@
 mov ax,cs:debugword ;@
 endif ;TraceCode    ;@

 call displayword
 jmp SilentFatalError

;-----

display2n:
 push ax
 shr al,1
 shr al,1
 shr al,1
 shr al,1
 call displaynybble
 pop ax
 jmp short displaynybble

displayword:
 push ax
 mov al,ah
 call display2n
 pop ax

displayhex:
 call display2n
 mov al," "
 call displaychar
ds03:
 ret

displaynybble:
 and al,0Fh
 cmp al,10
 jae dn01
 add al,'0'
 jmp short displaychar
dn01:
 add al,'A'-10

displaychar:
 jmp DisplayVisible

BreakPoint endp

;-----

;al=Ascii code, cx=Pixel column, dx=row, es=address of screen

;!CGA_ZapCharacter proc near
;!
;! sub al,32
;!
;! add dx,dx                  ;Index to look-up table
;! mov si,dx
;! mov si,cs:ScreenTable[si]  ;Start of left-side of screen
;!
;! mov bx,seg vars
;! mov ds,bx
;! assume ds:vars
;!
;! call CGA_AddCharHeap
;!
;! mov ah,ds:B_InvertFlag
;!
;! mov bx,cx                  ;Column, in pixels, convert to byte-offset
;! shr bx,1
;! shr bx,1
;! add si,bx                  ;address of top left of character
;!
;! mov bl,al
;! mov bh,0
;! add bx,bx
;! add bx,bx
;! add bx,bx
;! add bx,bx                  ;16-bytes store each character
;!
;! mov ds,cs:CS_CGA_FontSegment
;! assume ds:nothing
;!
;! test si,2000h
;! jz ZapEven
;! jmp ZapOddCharacter
;!
;!ZapEven:
;! cmp ah,0
;! je ZapNormal
;! jmp ZapInverted
;!
;!ZapNormal:
;! test cl,2
;! jz zc01
;! jmp zc02
;!zc01:
;! test cl,1
;! jz Aligned
;! jmp short NotAligned1
;!
;!Normal0 macro p1,p2
;! mov ax,ds:p1[bx]
;! mov es:p2[si],ax
;! endm
;!
;!Aligned:
;! Normal0 0,0
;! Normal0 2,2000h
;! Normal0 4,80
;! Normal0 6,2000h+80
;! Normal0 8,160
;! Normal0 10,2000h+160
;! Normal0 12,240
;! Normal0 14,2000h+240
;! ret
;!
;! purge Normal0              ;Speed up assembly
;!
;!Normal1 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0C000h
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],03Fh
;! mov es:p2+2[si],ch
;! endm
;!
;!NotAligned1:
;! Normal1 0,0
;! Normal1 2,2000h
;! Normal1 4,80
;! Normal1 6,2000h+80
;! Normal1 8,160
;! Normal1 10,2000h+160
;! Normal1 12,240
;! Normal1 14,2000h+240
;! ret
;!
;! purge Normal1              ;Speed up assembly
;!
;!zc02:
;! test cl,1
;! jz NotAligned2
;! jmp NotAligned3
;!
;!Normal2 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0F000h
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],00Fh
;! mov es:p2+2[si],ch
;! endm
;!
;!NotAligned2:
;! Normal2 0,0
;! Normal2 2,2000h
;! Normal2 4,80
;! Normal2 6,2000h+80
;! Normal2 8,160
;! Normal2 10,2000h+160
;! Normal2 12,240
;! Normal2 14,2000h+240
;! ret
;!
;! purge Normal2              ;Speed up assembly
;!
;!Normal3 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0FC00h
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],003h
;! mov es:p2+2[si],ch
;! endm
;!
;!NotAligned3:
;! Normal3 0,0
;! Normal3 2,2000h
;! Normal3 4,80
;! Normal3 6,2000h+80
;! Normal3 8,160
;! Normal3 10,2000h+160
;! Normal3 12,240
;! Normal3 14,2000h+240
;! ret
;!
;! purge Normal3              ;Speed up assembly
;!
;!;-----
;!
;!ZapInverted:
;! test cl,2
;! jz zi01
;! jmp zi02
;!zi01:
;! test cl,1
;! jz Inverted0
;! jmp short Inverted1
;!
;!InvertAlign0 macro p1,p2
;! mov ax,ds:p1[bx]
;! xor ax,0FFFFh
;! mov es:p2[si],ax
;! endm
;!
;!Inverted0:
;! InvertAlign0 0,0
;! InvertAlign0 2,2000h
;! InvertAlign0 4,80
;! InvertAlign0 6,2000h+80
;! InvertAlign0 8,160
;! InvertAlign0 10,2000h+160
;! InvertAlign0 12,240
;! InvertAlign0 14,2000h+240
;! ret
;!
;! purge InvertAlign0         ;Speed up assembly
;!
;!InvertAlign1 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0C000h
;! xor ax,03FFFh
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],03Fh
;! xor ch,0C0h
;! mov es:p2+2[si],ch
;! endm
;!
;!inverted1:
;! InvertAlign1 0,0
;! InvertAlign1 2,2000h
;! InvertAlign1 4,80
;! InvertAlign1 6,2000h+80
;! InvertAlign1 8,160
;! InvertAlign1 10,2000h+160
;! InvertAlign1 12,240
;! InvertAlign1 14,2000h+240
;! ret
;!
;! purge InvertAlign1         ;Speed up assembly
;!
;!InvertAlign2 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0F000h
;! xor ax,00FFFh
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],00Fh
;! xor ch,0F0h
;! mov es:p2+2[si],ch
;! endm
;!
;!zi02:
;! test cl,1
;! jz invert2
;! jmp inverted3
;!
;!invert2:
;! InvertAlign2 0,0
;! InvertAlign2 2,2000h
;! InvertAlign2 4,80
;! InvertAlign2 6,2000h+80
;! InvertAlign2 8,160
;! InvertAlign2 10,2000h+160
;! InvertAlign2 12,240
;! InvertAlign2 14,2000h+240
;! ret
;!
;! purge InvertAlign2         ;Speed up assembly
;!
;!InvertAlign3 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0FC00h
;! xor ax,003FFh
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],003h
;! xor ch,0FCh
;! mov es:p2+2[si],ch
;! endm
;!
;!inverted3:
;! InvertAlign3 0,0
;! InvertAlign3 2,2000h
;! InvertAlign3 4,80
;! InvertAlign3 6,2000h+80
;! InvertAlign3 8,160
;! InvertAlign3 10,2000h+160
;! InvertAlign3 12,240
;! InvertAlign3 14,2000h+240
;! ret
;!
;! purge InvertAlign3         ;Speed up assembly
;!
;!ZapOddCharacter:
;! sub si,2000h               ;When starting on an odd-row si will be 2000-4000h
;!
;! cmp ah,0
;! je OddNormal
;! jmp OddInverted
;!
;!OddNormal:
;! test cl,2
;! jz zo01
;! jmp zo02
;!zo01:
;! test cl,1
;! jz OddAligned
;! jmp short OddNot1
;!
;!OddNormal0 macro p1,p2
;! mov ax,ds:p1[bx]
;! mov es:p2[si],ax
;! endm ;OddNormal0
;!
;!OddAligned:
;! OddNormal0 0,2000h
;! OddNormal0 2,80
;! OddNormal0 4,2000h+80
;! OddNormal0 6,160
;! OddNormal0 8,2000h+160
;! OddNormal0 10,240
;! OddNormal0 12,2000h+240
;! OddNormal0 14,320
;! ret
;!
;! purge OddNormal0           ;Speed up assembly
;!
;!OddNormal1 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0C000h
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],03Fh
;! mov es:p2+2[si],ch
;! endm
;!
;!OddNot1:
;! OddNormal1 0,2000h
;! OddNormal1 2,80
;! OddNormal1 4,2000h+80
;! OddNormal1 6,160
;! OddNormal1 8,2000h+160
;! OddNormal1 10,240
;! OddNormal1 12,2000h+240
;! OddNormal1 14,320
;! ret
;!
;! purge OddNormal1           ;Speed up assembly
;!
;!zo02:
;! test cl,1
;! jz OddNotAligned2
;! jmp OddNotAligned3
;!
;!OddNormal2 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0F000h
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],00Fh
;! mov es:p2+2[si],ch
;! endm
;!
;!OddNotAligned2:
;! OddNormal2 0,2000h
;! OddNormal2 2,80
;! OddNormal2 4,2000h+80
;! OddNormal2 6,160
;! OddNormal2 8,2000h+160
;! OddNormal2 10,240
;! OddNormal2 12,2000h+240
;! OddNormal2 14,320
;! ret
;!
;! purge OddNormal2           ;Speed up assembly
;!
;!OddNormal3 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0FC00h
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],003h
;! mov es:p2+2[si],ch
;! endm
;!
;!OddNotAligned3:
;! OddNormal3 0,2000h
;! OddNormal3 2,80
;! OddNormal3 4,2000h+80
;! OddNormal3 6,160
;! OddNormal3 8,2000h+160
;! OddNormal3 10,240
;! OddNormal3 12,2000h+240
;! OddNormal3 14,320
;! ret
;!
;! purge OddNormal3           ;Speed up assembly
;!
;!;-----
;!
;!OddInverted:
;! test cl,2
;! jz oi01
;! jmp oi02
;!oi01:
;! test cl,1
;! jz OddInverted0
;! jmp short OddInverted1
;!
;!OddInvert0 macro p1,p2
;! mov ax,ds:p1[bx]
;! xor ax,0FFFFh
;! mov es:p2[si],ax
;! endm
;!
;!OddInverted0:
;! OddInvert0 0,2000h
;! OddInvert0 2,80
;! OddInvert0 4,2000h+80
;! OddInvert0 6,160
;! OddInvert0 8,2000h+160
;! OddInvert0 10,240
;! OddInvert0 12,2000h+240
;! OddInvert0 14,320
;! ret
;!
;! purge OddInvert0           ;Speed up assembly
;!
;!OddInvert1 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0C000h
;! xor ax,03FFFh
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],03Fh
;! xor ch,0C0h
;! mov es:p2+2[si],ch
;! endm
;!
;!OddInverted1:
;! OddInvert1 0,2000h
;! OddInvert1 2,80
;! OddInvert1 4,2000h+80
;! OddInvert1 6,160
;! OddInvert1 8,2000h+160
;! OddInvert1 10,240
;! OddInvert1 12,2000h+240
;! OddInvert1 14,320
;! ret
;!
;! purge OddInvert1           ;Speed up assembly
;!
;!OddInvert2 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0F000h
;! xor ax,00FFFh
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],00Fh
;! xor ch,0F0h
;! mov es:p2+2[si],ch
;! endm
;!
;!oi02:
;! test cl,1
;! jz OddInverted2
;! jmp OddInverted3
;!
;!OddInverted2:
;! OddInvert2 0,2000h
;! OddInvert2 2,80
;! OddInvert2 4,2000h+80
;! OddInvert2 6,160
;! OddInvert2 8,2000h+160
;! OddInvert2 10,240
;! OddInvert2 12,2000h+240
;! OddInvert2 14,320
;! ret
;!
;! purge OddInvert2           ;Speed up assembly
;!
;!OddInvert3 macro p1,p2
;! mov ax,ds:p1[bx]
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! shr ax,1
;! ror ch,1
;! and es:p2[si],0FC00h
;! xor ax,003FFh
;! mov es:p2[si],ax
;! and byte ptr es:p2+2[si],003h
;! xor ch,0FCh
;! mov es:p2+2[si],ch
;! endm
;!
;!OddInverted3:
;! OddInvert3 0,2000h
;! OddInvert3 2,80
;! OddInvert3 4,2000h+80
;! OddInvert3 6,160
;! OddInvert3 8,2000h+160
;! OddInvert3 10,240
;! OddInvert3 12,2000h+240
;! OddInvert3 14,320
;! ret
;!
;! purge OddInvert3           ;Speed up assembly
;!
;!CGA_ZapCharacter endp

;-----

;Preserve all registers.
;cx=Pixel column, si=Address offset into screen row

;!CGA_AddCharHeap proc near
;!
;! push di
;!
;! mov di,ds:CharThisAddr
;! add di,ds:CharThisSize
;! add di,ds:CharThisSize
;! add di,ds:CharThisSize
;! add di,ds:CharThisSize
;! cmp ds:CharThisSize,CharStackMax/4
;! jae at01
;!
;! mov ds:0[di],cx
;! mov ds:2[di],si
;! inc ds:CharThisSize
;!
;!at01:
;! pop di
;! ret
;!
;!CGA_AddCharHeap endp

;-----

EGA_SetCursor proc near

 mov bh,0                   ;page
 mov dh,dl                  ;row
 mov dl,cl                  ;column
 mov ah,2                   ;Set Cursor Position
 int 10h
 ret

EGA_SetCursor endp

;-----

SetCursor proc near

 jmp EGA_SetCursor ;!

;! cmp cs:CS_ScreenMode,0
;! jnz EGA_SetCursor
;!
;! push ds
;! push cx
;! push dx
;! mov ax,seg vars
;! mov ds,ax
;! assume ds:vars
;! add cx,cx
;! add cx,cx
;! add cx,cx
;! xchg ch,cl
;! mov HiLo_CursorXpos,cx
;! add dx,dx
;! add dx,dx
;! add dx,dx
;! xchg dh,dl
;! mov HiLo_CursorYpos,dx
;! pop ds
;! pop cx
;! pop ds
;! ret

SetCursor endp

;...e

;-----

;...sAcode Subroutines:0:

MCClearRectangle proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD
 if TraceCode           ;@
 mov cs:debugword,0200h ;@
 call CheckChain        ;@
 endif ;TraceCode       ;@
   ENDIF ;TwoD

;!   IFE TwoD
;! cmp cs:CS_ScreenMode,0
;! jne cr01
;! call CGA_ClearRectangle
;! jmp short cr02

;!cr01:                       ;EGA
;!   ENDIF ;TwoD

 mov ax,ds:HiLo_CursorXpos  ;Window top margin
 xchg ah,al
 mov bx,ds:HiLo_CursorYpos  ;Window left margin
 xchg bh,bl
 mov es,cs:CS_Acode
 mov cx,es:V1               ;Window width
 mov dx,es:V2               ;Window height
 mov bp,2                   ;Text Output destination

; ax - xpos
; bx - ypos
; cx - width
; bp - height

 cmp ax,DisplayAreaWidth
 jae NoBackEffect2
 cmp bx,DisplayAreaHeight
 jae NoBackEffect2

 if TwoD
  mov cs:Screen1Status,0  ;mark screens as not valid
  mov cs:Screen2Status,0  ;mark screens as not valid
 endif ;TwoD

NoBackEffect2:

   IF TwoD
 call Pass_Variables
 call EGA2DClearRectangle
 call Retrieve_variables
   ELSE ;TwoD
 call cs:AddrClearRectangle
   ENDIF ;TwoD
cr02:

   IF TwoD
 if TraceCode           ;@
 mov cs:debugword,0201h ;@
 call CheckChain        ;@
 endif ;TraceCode       ;@
   ENDIF ;TwoD

 jmp MCReturn

;-----

;!CGA_ClearRectangle:
;! mov ax,ds:HiLo_CursorXpos  ;Window top margin
;! xchg ah,al
;! mov bx,ds:HiLo_CursorYpos  ;Window left margin
;! xchg bh,bl
;! mov es,cs:CS_Acode
;! mov cx,es:V1               ;Window width
;! mov dx,es:V2               ;Window height
;!
;!;If Sprites/Background cells are cleared (e.g. New Level, or when
;!;menu appears) then set next frame to re-fresh screen.
;!
;! cmp ax,DisplayAreaWidth
;! jae NoBackEffect
;! cmp bx,DisplayAreaHeight
;! jae NoBackEffect
;! cmp ds:CGA_MustRebuild,2
;! je NoBackEffect            ;Successive frames of menu display...
;!
;! push ds
;! push bx
;! push cx
;! push dx
;! push ax
;!
;! mov ax,0B800h
;! mov ds,ax
;! mov es,cs:CS_CGA_Screen2
;! call CopyDisplayArea
;!
;! mov ax,0B800h
;! mov ds,ax
;! mov es,cs:CS_CGA_Screen1
;! call CopyDisplayArea
;!
;! pop ax
;! pop dx
;! pop cx
;! pop bx
;! pop ds
;!
;! mov ds:CGA_MustRebuild,2   ;Do re-build during MENU display
;!NoBackEffect:
;!
;! cmp ax,320
;! jae offscreen
;! cmp bx,200
;! jae offscreen
;!
;!;Top left is on the screen, now do a rought check 
;!;that the width and height are not so ludicrous as
;!;to cause math-errors later on.
;!
;! cmp cx,320                 ;check for math-overflow
;! jb X_near
;! mov cx,319
;! sub cx,ax                  ;Set width up to right-edge
;!X_near:
;!
;! cmp dx,200                 ;check for math-overflow
;! jb Y_near
;! mov dx,199
;! sub dx,bx                  ;Set height to bottom-edge
;!Y_near:
;!
;! add cx,ax                  ;Get right-edge
;! cmp cx,320
;! jb X_ok
;! mov cx,319                 ;Set width to right-edge
;!X_ok:
;!
;! add dx,bx
;! cmp dx,200                 ;check for math-overflow
;! jb Y_ok
;! mov dx,199                 ;Set height up to bottom-edge
;!Y_ok:
;!
;!;ax,bx = top left
;!;cx,dx = bottom right
;!
;!clearrow:
;! cmp bx,dx
;! ja offscreen
;! push ax
;! push bx
;! push cx
;! push dx
;! call ClearLine
;! pop dx
;! pop cx
;! pop bx
;! pop ax
;! inc bx
;! jmp short clearrow
;!
;!offscreen:
;! ret

;-----

;ax,bx = top left
;cx,dx = bottom right

;!ClearLine:
;! cmp ax,cx
;! je EndClear
;! push ax
;! push bx
;! push cx
;! push dx
;!
;! push ax
;! and ax,0003h
;! cmp ax,0
;! pop ax
;! jne ClearPixel
;!
;!ClearByte:
;! push cx
;! sub cx,ax
;! cmp cx,4
;! pop cx
;! jb ClearPixel
;!
;!;Got 4-bytes byte-aligned
;! add bx,bx
;! mov si,cs:ScreenTable[bx]
;! shr ax,1
;! shr ax,1
;! add si,ax
;! mov es,cs:CS_CGA_Screen2
;! mov byte ptr es:[si],0
;!
;! pop dx
;! pop cx
;! pop bx
;! pop ax
;! add ax,4
;! jmp short ClearLine
;!
;!ClearPixel:
;! add bx,bx
;! mov si,cs:ScreenTable[bx]
;! push ax
;! shr ax,1
;! shr ax,1
;! add si,ax
;! mov es,cs:CS_CGA_Screen2
;! pop ax
;!
;! and al,3
;! cmp al,0
;! jne cp01
;! mov al,03Fh
;! jmp short cp04
;!cp01:
;! cmp al,1
;! jne cp02
;! mov al,0CFh
;! jmp short cp04
;!cp02:
;! cmp al,2
;! jne cp03
;! mov al,0F3h
;! jmp short cp04
;!cp03:
;! mov al,0FCh
;!cp04:
;! and es:[si],al
;!
;! pop dx
;! pop cx
;! pop bx
;! pop ax
;! add ax,1
;! jmp short ClearLine
;!
;!EndClear:
;! ret

MCClearRectangle endp

;-----

;Print es:V1, if WordWS(ByteInvertFlag) <> 0 then display black-on-white.

MCOSwrchV1 proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov es,cs:CS_Acode     ;2D
 mov al,es:[v1]
 cmp cs:CS_TextDestination,0
 jne Print3D

;Use ST/AMIGA-style output
 call Display_AL            ;2D display
 jmp MCReturn

Print3D:
 call DisplayCharacter3D
 jmp MCReturn

MCOSwrchV1 endp

;-----

MCInvertedOSwrchV1 proc near

 call DumpRegisters
 db 0D0h ;Generate a 'Not implemented' break point

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov al,ds:B_InvertFlag
 push ax
 mov ds:B_InvertFlag,1

 cmp cs:CS_TextDestination,0
 jne Invert3d

;Use ST/AMIGA-style output
 mov es,cs:CS_Acode
 mov al,es:[v1]
 call Display_AL            ;2D. Print es:V1 inverted
 jmp short InvertEnd

Invert3d:
 mov es,cs:CS_Acode
 mov al,es:[v1]
 call DisplayCharacter3D    ;3D

InvertEnd:
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 pop ax
 mov ds:B_InvertFlag,al

;MCReturn resets ds=CS_Acode, dh=0, es=dont care
 jmp MCReturn

MCInvertedOSwrchV1 endp

;-----

DisplayCharacter3D proc near

;Once the Acode has execute MCtextOutIBM, all text output goes through
;the driver; CS_TextDestination selects which buffer(s)/screen(s) are
;written to

 cmp al,13
 jne dc03

 mov ax,seg vars
 mov ds,ax
 assume ds:Vars

 mov ax,ds:HiLo_CursorYpos
 xchg ah,al
 cmp ax,192
 jae dc02                   ;3D on bottom line

 add ax,8                   ;3D not on bottom line
 xchg ah,al
 mov ds:HiLo_CursorYpos,ax
 mov ds:HiLo_CursorXpos,0
 ret

dc02:
 jmp Game_HandleCR          ;3D. Let acode 'DoCr'

 assume ds:nothing
dc03:
 mov dl,al                  ;ascii code

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,ds:HiLo_CursorXpos
 xchg ah,al
 mov bx,ds:HiLo_CursorYpos
 xchg bh,bl
 mov dh,ds:B_InvertFlag

;Now set up values for...
; bx - screen ypos
; cx - buffer ypos

 mov cx,bx
 cmp bx,cs:CS_ClipPosition  ;In scrolling area?
 jc Wrap                    ;No - write to screen only
 
;Inside scrolling area so adjust 'Buffer' Y-coord to allow for scroll.

 add cx,cs:CS_LastTopLine   ;beyond end of buffer?
 sub cx,cs:CS_ClipPosition
 cmp cx,193
 jc Wrap
 sub cx,200 ;reset Y coord  ;yes; then cx = (bx-200)+LastTop
 add cx,cs:CS_ClipPosition
Wrap:
 mov bp,cs:CS_TextDestination
 jmp InRange

;Outside scrolling area so disable printing to buffer

OutRange:
 mov bp,cs:CS_TextDestination
 and bp,6 ;prevent write to buffer

; ax - xpos
; bx - screen ypos
; cx - buffer ypos
; dh - invertflag
; dl - character
; bp - destination (1-Buffer,2-Logical,4-Physical)

InRange:
   IFE TwoD
 call cs:AddrPrintCharacter
   ENDIF ;TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,HiLo_CursorXpos
 xchg ah,al
 add ax,8
 xchg ah,al
 mov HiLo_CursorXpos,ax
 ret

DisplayCharacter3D endp

;...e

;-----

code ends

;-----

;...sVariables:0:

vars segment word public 'data'
vars ends

;...e

;-----

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
