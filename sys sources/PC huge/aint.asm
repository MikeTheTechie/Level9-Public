 page 128,122 ;length,width
;Acode interpreted for IBM PC

;AINT.ASM

;Copyright (C) 1987,1988,1989 Level 9 Computing

;Modified to interface to compiled acode/machine code.

;BUGS: Do not alter list2 list3 list9 via LIST11
;      if you use these lists in interpreted mode.

;Currently (17/9/89) under modification...
;ds=CS_Acode:              es=CS_Gamedata:
;    ret                       exits
;    retf                      table.dat
;    list11 contents           squash data
;    vars
;    acode

;-----

 name aint

;...sPublics and externals:0:
 public AddressGameDataDat
 public aint
 public aintrestart
 public MCcontinue
 public prgstr
 public start

;In DRIVER.ASM:
 extrn chain:near
 extrn Dchecksum:near
 extrn Doswrch:near
 extrn DriverSeed:word
 extrn initialiseall:near
 extrn InLineDos:near

;In HUGE.ASM:
 extrn CS_Acode:word
 extrn CS_AcodeSize:word
 extrn CS_GameData:word
 extrn HeroInit:near
 extrn MCCloseDown:near
 extrn SafeShutDown:near

 ;In MCODE.ASM:
 extrn AcodeOverlay:near
 extrn MachineCode:near

;...e

;-----

code segment public 'code'
 assume cs:code
 assume ds:nothing

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
 include common.asm

;...e

;...sVariables:0:

;if running with separate ACODE.ACD file...
;   ds: is acode segment (also contains ACODE, LIST 11, Acode vars)
;   cs:AddressGameDataDat = 0
;if running with combined GAMEDATA.DAT file...
;   ds: = cs: is segment containing ACODE, LIST 11, Acode vars, SQUASH.DAT
;             EXITS TABLE.DAT.
;   cs:AddressGameDataDat = SizeRunTimeSystem

AddressGameDataDat dw SizeRunTimeSystem

romext dw 0
list2  dw 0 ;List 2
list3  dw 0 ;List 3
list9  dw 0 ;List 9
prgstr dw 0

textmode db 0

obuff db 33 dup(0)          ;lower case input word
ibuff db 83 dup(0)          ;Ascii input buffer
wrapbuffer db 33 dup(0)     ;Can only SQUASH 32 chars per word
ibuffpointer dw 0           ;Pointer to start of word in IBUFF

prntblpointer dw 0
wrapbufferpointer dw 0
list9pointer dw 0           ;Pointer into LIST9

startmd dw 0                ;Start of Message Descriptors
endmd dw 0                  ;End address+1 of Message Descriptors
endwdp5 dw 0                ;Address+6 of end of Word Dictionary

var1 db 0
extst db 0
rndsed dw 0

currentflags db 0           ;Bit 5 and Bit 6 of current opcode

nchars db 0

mdtmode  db 0
startmsg dw 0               ;Also used for INPUT
wordtype db 0
keywordnumber dw 0
wordnumber    dw 0
abrevword     dw 0
wordaddress   dw 0
blockpointer  dw 0
headerpointer dw 0
unpack1 db 0
unpack2 db 0
unpack3 db 0
unpack4 db 0
unpack5 db 0
unpack6 db 0
unpack7 db 0
unpack8 db 0
threecharacters db 32 dup(0)
unpackpointer   db 0
lastchar        db 0
pendspace       db 0
width0          db 39
lastheader      db 0
wordcase        db 0

; workspace and symbols for getnextobject
searchdepth db 0
hisearchpos db 0
searchpos   db 0
object      db 0
hlsave      dw 0
numobjectfound  db 0
inithisearchpos db 0
hipos db 0
hisearchposvar dw 0
searchposvar   dw 0
nonspecific equ 31
gnosp     dw 0
maxobject db 0

gnospbase db 60 dup(0)
gnomaxsp  equ this byte
gnoscratch db nonspecific dup(0)

numericbuffer db 3 dup(0)

driverbuffer db 7 dup(0)

hiresbuffer dw 0

;...e

;-----

;...sTables:0:

;Constants likely to change:

;-----

cret equ 13

Aint_Vars equ startsavearea

listarea equ startsavearea+(numvar*2)

;-----

;Special short-codes:
longc equ 1Ah               ;Long escape code
header equ 1Ch              ;Header short-code
endseg equ 1Bh              ;Segment end marker

uppercasemark equ 10h

;...e

;----- 

;...sSubroutines:0:

;Currently (17/9/89) under modification...
;ds=CS_Acode:              es=CS_Gamedata: (or other segment)
;    ret opcode                exits
;    retf opcode               table.dat
;    list11 contents           squash data
;    vars
;    acode

;(19/9/89) ds: was set to cs: during interpreter, so all interpreter
;          workspace could be accessed by either segment register.
;          All workspace is now cs: (ds: is used when ACODE.ACD file
;          is present.)

aint:
;Now make data table at start of data into absolute addresses etc.

 mov ax,cs
 mov ds,ax
 assume ds:code

 mov si,offset ibuff
 push es                    ;Save GAMEDATA paragraph address
 push di
 push si
 push bx
 push dx
 push cx
 call initialiseall
 pop cx
 pop dx
 pop bx
 pop si
 pop di
 pop es                     ;Restore GAMEDATA paragraph address
;; mov al,initdcode
;; call driver

 mov ax,cs:DriverSeed
 mov cs:rndsed,ax

 mov al,1
 mov cs:textmode,al

 mov byte ptr cs:0[si],1
 jmp chain

;CHAIN always returns here:

aintrestart:
 call initacode
 call AcodeOverlay
 jmp heroinit

;-----

initacode:
 mov es,cs:CS_GameData  ;Save/Restore workspace.
 mov ds,cs:CS_Acode     ;list 11 ptrs
 mov si,offset IBUFF

 call checksum

;Get LIST pointers from GAMEDATA.DAT...
;  18 romext  address of EXIT.TXT
;  20 list 0
;  22 list 1  default list ptrs...
;  24 list 2
;  26 list 3
;  28 list 4
;  30 list 5
;  32 list 6
;  34 list 7
;  36 list 8
;  38 list 9
;  40 acode ptr, if acode stored in gamedata

;Copy values from GAMEDATA.DAT used to set up ROMEXT, PRGSTR, Lists...
; si = cs:AddressGameDataDat
; ds = cs:CS_Acode
; es = cs:CS_GameData
; di   index into PClistVector table (ds:)
; dx   segment address

 mov si,cs:AddressGameDataDat
 mov ax,es:18[si] ;romext
 add ax,si
 mov cs:romext,ax
 mov ax,es:40[si] ;prgstr
 add ax,si
 mov cs:prgstr,ax

 cmp cs:CS_AcodeSize,0
 je NoAcode
 mov cs:prgstr,SizeRunTimeSystem+2 ;Skip Acode vars, list11, acode length
NoAcode:

 mov bx,20 ;list 0
 mov cx,10 ;process from to list9
 mov di,PClistVector
nick:
 mov ax,es:[si+bx]

 and ax,ax
 js ListIsWorkspace

 add ax,si              ;convert offset to address in GAMEDATA.DAT
 mov dx,cs:CS_GameData
 jmp short StoreList

ListIsWorkspace:
 sub ax,8000h           ;reset 'workspace' flag
 add ax,listarea        ;convert offset to address
 mov dx,cs:CS_Acode

StoreList:
 mov ds:2[di],dx ;segment address
 mov ds:0[di],ax ;offset within segment
 add bx,2
 add di,4
 loop nick

 mov ax,word ptr ds:PClistVector+2*4
 mov cs:list2,ax
 mov ax,word ptr ds:PClistVector+3*4
 mov cs:list3,ax
 mov ax,word ptr ds:PClistVector+9*4
 mov cs:list9,ax

; si = cs:AddressGameDataDat
; ds = cs:CS_Acode
; es = cs:CS_GameData

;Copy values from GAMEDATA.DAT...
;Set up common values required from GAMEDATA file (in es:)

 mov bx,si
 mov bx,es:[bx+2]           ;Offset to Message Descriptors
 mov cx,si
 add bx,cx
 mov cs:startmd,bx
 mov di,si
 mov cx,es:[di+4]           ;Length of Message Descriptors
 add bx,cx
 mov cs:endmd,bx
 mov bx,si
 mov bx,es:[bx+8]           ;Length of 'Word Dictionary'
 mov dx,si
 add dx,5               ;skip first 5 bytes (8 packed entries)
 add bx,dx
 mov di,si
 mov dx,es:[di+6]           ;Offset start Word Dictionary
 add bx,dx
 mov cs:endwdp5,bx

 sub bx,bx                  ;Set up ACODE offset to be cold start for program

 call wrapreset
 mov cs:ibuffpointer,0

 ret

MCcontinue:
 mov es,cs:CS_GameData  ;Exits, TABLE.DAT, SQUASH.DAT
 mov ds,cs:CS_Acode     ;List 11, vars, acode

 mov bp,bx              ;compiler exits with bx=OFFSET of next instruction
 add bp,cs:prgstr       ;thoughout: ds:[bp] is next ACODE instruction

start:
;next 5 instructions are very useful for debugging...
; mov bx,bp
; mov si,offset ibuff
; call prnthl
; mov al," "
; call printchar        ;for debugging: address of each interpreted acode opcode

 mov si,offset IBUFF ;*****complete waste of a register...

 mov ax,offset start
 push ax                ;setup return address

 mov al,ds:[bp]         ;acode. Get acode instruction from GAMEDATA
 mov cs:CurrentFlags,al ;Save bit 6 (8-bit) and bit 5 (relative)

 and al,10011111b
 js  ain003
 inc bp                 ;point to next acode instruction
 xor ah,ah
 shl al,1
 mov di,ax
 jmp word ptr cs:jumpt[di]

ain003:
 jmp list		;list instruction

;...sold code for getting acode instructions:0:
; and al,10011111b
; cmp al,35
; jb ain003
; cmp al,128
; jb ain002
; jmp list
;ain002:
; jmp ilins
;ain003:
; xchg dx,bx
; shl al,1
; mov bl,al
; sub bh,bh
; mov cx,word ptr cs:jumpt[bx]
; xchg dx,bx
; inc bx
; push cx
; ret
;...e

;-----

;...sjump table for Acode instructions:0:
even

jumpt:
 dw goto
 dw gosub
 dw return
 dw printn
 dw printv ;4
 dw printc
 dw function
 dw input
 dw varcon ;var=cons
 dw varvar
 dw add0
 dw sub0
 dw MachineCode ;12
 dw notimp
 dw jump
 dw exit
 dw ifeqvt ;16
 dw ifnevt
 dw ifltvt
 dw ifgtvt
 dw screen ;20
 dw cleartg
 dw picture
 dw getnextobject
 dw ifeqct ;24
 dw ifnect
 dw ifltct
 dw ifgtct
 dw printinput ;28
 dw notimp ;ifnecg
 dw notimp ;ifltcg
 dw notimp ;ifgtcg

;-----

checksum proc near

 mov bx,cs:AddressGameDataDat

 mov cs:0[si],bx
 mov di,bx
 mov cx,es:[di+0]           ;Offset to checksum in GAMEDATA
 add bx,cx
 mov cs:2[si],bx            ;End address for checksum

;*****
 push es                    ;Save GAMEDATA paragraph address
 push di
 push si
 push bx
 push dx
 push cx
 call Dchecksum
 pop cx
 pop dx
 pop bx
 pop si
 pop di
 pop es                     ;Restore GAMEDATA paragraph address

;; mov al,checksumdcode
;; call driverresult
 mov al,cs:0[si]
 or al,al
;* jnz ain004
 ret                        ;Checksum ok

ain004:
 call SafeShutDown ;restore vectors
 mov ax,0003h ;Set screen mode 3 (80x25 text)
 int 10h
 call InLineDos
 db "GAMEDATA: bad checksum$"

 mov bx,cs:AddressGameDataDat ;*

 mov ah,04Ch                ;Terminate process
 int 21h

checksum endp

;-----

DOSoswrch proc near

 mov ah,14                  ;Write character as TTY
 int 10h
 ret

DOSoswrch endp

;-----

notimp proc near

 call SafeShutDown ;restore vectors
 call InLineDos
;**** It would be nice to report the address, but I don't have a decimal
;**** (or hex) print routine that does not use the DRIVER.BIN
 db "Illegal instruction$"
 mov ah,04Ch                ;Terminate process
 int 21h

notimp endp

;-----

;...sGetHLVal and GetVal:0:
;This is not compatable with save/restore positions
;produced by previous interpreters...
;Given (HL) as var num, returns BC value, DE address

;Entry  bx - address in Acode of variable number
;  [or] al - variable number
;Exit   bx - address in Acode
;	cx - value of variable
;	dx - address of variable 

gethlval proc near
 mov al,ds:[bp]         ;acode. Read var number (0-255) from GAMEDATA

getval:                 ;Given A=Var num, returns BC=Current
                        ;value and DE=address of variable
 xor ah,ah
 mov si,ax
 shl si,1
 add si,offset Aint_Vars
 mov dx,si
 mov cx,ds:[si] ;acode variable
 ret

gethlval endp

;-----

goto proc near

 call getadr
 mov bp,dx
 ret

goto endp

;-----

gosub proc near

 pop cx
 call getadr
 push bp
 push cx
 mov bp,dx
 ret

gosub endp

;-----

getadr proc near

 test cs:CurrentFlags,20h
 jnz getad1

 mov dx,ds:[bp]         ;read from acode
 add bp,2

 mov bx,cs:prgstr
 add bx,dx
 mov dx,bx
 ret

getad1:                ;8 bit address
 mov dl,ds:[bp]        ;read from acode
 sub dh,dh
 test dl,080h
 jz getad2
 mov dh,0FFh           ;Backwards relative jump
getad2:
 add dx,bp
 inc bp
 ret

getadr endp

;-----

return proc near

 pop cx                ;set cx='offset start:'
 pop bp
 jmp start

return endp

;-----

screen proc near

 mov al,ds:[bp]         ;ignore instruction, but need to know length
 inc bp
 or al,al
 jz screent             ;Set text screen
 inc bp
screent:
 ret

; call SafeShutDown ;restore vectors
; mov ax,0003h ;Set screen mode 3 (80x25 text)
; int 10h
; call InLineDos
; db "illegal SCREEN instruction$"
; mov ah,04Ch                ;Terminate process
; int 21h

screen endp

;-----

cleartg proc near

 call SafeShutDown      ;restore vectors
 mov ax,0003h           ;Set screen mode 3 (80x25 text)
 int 10h
 call InLineDos
 db "illegal CLEAR instruction$"
 mov ah,04Ch            ;Terminate process
 int 21h

;Clear text or graphics screen
; inc bp                ;skip over ACODE opcode
; ret

cleartg endp

;-----

picture proc near

 call SafeShutDown      ;restore vectors
 mov ax,0003h           ;Set screen mode 3 (80x25 text)
 int 10h
 call InLineDos
 db "illegal PICTURE instruction$"
 mov ah,04Ch            ;Terminate process
 int 21h

; inc bp
; ret

picture endp

;-----

function proc near

 mov al,ds:[bp]         ;Get acode argument from GAMEDATA
 inc bp
 cmp al,1
 je stop
 cmp al,2
 jne ain013
 jmp random
ain013:
 cmp al,3
 jne ain014
 jmp save
ain014:
 cmp al,4
 jne ain015
 jmp restore
ain015:
 cmp al,5
 jne ain016
 jmp clear
ain016:
 cmp al,6
 jne ain017
 jmp stackfunction
ain017:
 cmp al,7
 jne aint017c

aint017c:
 cmp al,250
 jne ain017a
 jmp short prs
ain017a:
ilins:

 call SafeShutDown      ;restore vectors
 mov ax,0003h           ;Set screen mode 3 (80x25 text)
 int 10h
 call InLineDos
 db "Illegal 06h instruction$"
 mov ah,04Ch            ;Terminate process
 int 21h

function endp

;-----

prs proc near

 mov al,ds:[bp]         ;Get ascii code, stored in GAMEDATA
 inc bp
 and al,al
 jz p2
 call printchar
 jmp short prs
p2:
 ret

prs endp

;-----

;STOP instruction now calls most DRIVER functions.
; calls to STOP, RAMSAVE and RAMLOAD are treated differently.

stop proc near

 call SafeShutDown ;restore vectors
 mov ax,0003h ;Set screen mode 3 (80x25 text)
 int 10h
 call InLineDos
 db "Illegal DRIVER instruction$"
 mov ah,04Ch                ;Terminate process
 int 21h

;; push si                    ;Aint's driver parameter call block
;; push bx                    ;Next acode instruction (in GAMEDATA)
;;
;;;List 9 contains arguments for driver call:
;;;   byte 0 - Driver call number
;;;   byte 1 - 1st argument
;;;   byte 2 - 2nd argument
;;;   byte 3 - 3rd argument
;;;   byte 4 - 4th argument
;;;   byte 5 - 5th argument
;;;   byte 6 - 6th argument
;;;list 9 is in the GAMEDATA/VARS paragraph (which driver cannot
;;;access) so this is copied to 'driverbuffer':
;;
;;;Copy six bytes from LIST9, stored with variables below GAMEDATA
;; mov si,cs:list9
;; mov al,es:1[si]
;; mov byte ptr cs:0[driverbuffer],al
;; mov al,es:2[si]
;; mov byte ptr cs:1[driverbuffer],al
;; mov al,es:3[si]
;; mov byte ptr cs:2[driverbuffer],al
;; mov al,es:4[si]
;; mov byte ptr cs:3[driverbuffer],al
;; mov al,es:5[si]
;; mov byte ptr cs:4[driverbuffer],al
;; mov al,es:6[si]
;; mov byte ptr cs:5[driverbuffer],al
;;
;; mov al,es:[si]             ;Get driver call number from LIST 9
;; cmp al,32                  ;Displayhires driver code
;; jne stop1
;; mov ah,cs:textmode
;; and ah,ah
;; jnz stop1
;; mov al,01                  ;Return code
;; jmp short stop2
;;
;;stop1:
;; mov si,offset driverbuffer
;; call driverrequest         ;Execute driver call
;;
;; mov ax,word ptr cs:driverbuffer ;Return code
;;stop2:
;;;Store return code in LIST 9 below GAMEDATA
;; mov si,cs:list9
;; mov es:0[si],al            ;(Inherited bug fix)
;; mov es:1[si],ax            ;Save return code (For driver call
;;                            ;34 returns 2-byte picture number)
;; pop bx
;; pop si
;; ret

stop endp

;-----

;Execute driver call 'AL' with up to three arguments
;in 'driverbuffer':

;;driverrequest proc near
;;
;; cmp al,stopdcode
;; je quit
;;
;; cmp al,ramsavedcode
;; jne ain018
;; jmp short ramio
;;ain018:
;; cmp al,ramloaddcode
;; jne ain019
;; jmp short ramio
;;ain019:
;; jmp driver
;;
;;driverrequest endp

;-----

quit proc near

 call checksum
;; mov bx,0FFFFh
;;quit1:
;; dec bx
;; mov al,bh
;; or al,bl
;; jnz quit1
;; mov al,stopdcode
;; call driver
 jmp MCCloseDown

quit endp

;-----

printn proc near

;code 3
 call gethlval
 inc bp
 mov bx,cx
 call prnthl
 ret

printn endp

;-----

prnthl proc near

;Print number HL in decimal
 mov al,bh
 or al,bl
 jz prnth3
 sub cl,cl                  ;Reset flag
 mov dx,offset prntbl
 mov cs:prntblpointer,dx
;Find current digit value
prnth1:
 push bx
 mov bx,cs:prntblpointer
 mov dx,cs:[bx]
 inc bx
 inc bx
 mov cs:prntblpointer,bx
 pop bx
;Check 5 digits found
 mov al,dh
 or al,dl
 jnz ain020
 ret
ain020:
;Find current digit
 mov ch,'0'
prnth2:
 sub bx,dx
 jb prnth4
 inc ch
 mov al,1
 mov cl,al
 jmp short prnth2

prnth4:
 add bx,dx
 mov al,cl
 or al,cl
 jz prnth1
 mov al,ch
 call printchar
 jmp short prnth1

prnth3:
 mov al,'0'
 jmp printchar

prnthl endp

;-----

prntbl proc near

 dw 10000
 dw 1000
 dw 100
 dw 10
 dw 1
 dw 0                       ;end

prntbl endp

;-----

printc proc near

;code 5
 call getcon
 dec bp
 jmp short prin1

printc endp

;-----

printv proc near

;code 4
 call gethlval
prin1:
 mov bx,cx
 call displaymessage
 inc bp
 ret

printv endp

;-----

varcon proc near

;var=cons (8)
 call getcon
 dec bp
 jmp short varv1

varcon endp

;-----

varvar proc near

;Var=Var (9)
 call gethlval
varv1:
 push cx
 inc bp
 call gethlval
 pop cx
 xchg dx,bx
 mov ds:[bx],cx
 inc bp
 ret

varvar endp

;-----

add0 proc near

;var,var (10.)
 call gethlval
 push cx                ;source var
 inc bp
 call gethlval

 pop ax                 ;source var value
 mov bx,ax

 add bx,cx              ;add source,dest values
add1:
 xchg dx,bx             ;bx=dest var address

 mov ds:[bx],dx         ;Write to variable, below GAMEDATA
 inc bp
 ret

add0 endp

;-----

sub0 proc near

;var,var (11.)
 call gethlval
 push cx                ;source value
 inc bp
 call gethlval

 pop ax                 ;source value
 mov bx,ax              ;source value

 xchg bx,cx             ;bx=dest old value, cx=source value

 sbb bx,cx              ;dest old - source
 jmp short add1         ;dx=dest address. acode ptr on stack

sub0 endp

;-----

jump proc near

;Addr,Var
 mov dx,ds:[bp]         ;Get acode argument from GAMEDATA
 inc bp
 inc bp
 push dx
 call gethlval
 add cx,cx                ;index into table
 pop bx                   ;offset of jump table
 add bx,cx
 mov cx,cs:prgstr         ;acode start
 add bx,cx

 mov bp,cs:prgstr
 add bp,ds:[bx]           ;read from acode value stored in "DATA @label"
 ret

jump endp

;-----

chkequ proc near

;Var1=Var2
;If Var1>Var2 ,carry
;If Var1<=Var2 ,nc
 call gethlval
 push cx
 inc bp
 call gethlval
 push cx
 pop dx                 ;var2
 inc bp
 jmp short chk1

chkequ endp

;-----

ifeqvt proc near

;If V=V then
 call chkequ
 jz ain021
 ret
ain021:
 jmp short ifthen

ifeqvt endp

;-----

ifnevt proc near

;If V<>V then
 call chkequ
 jnz ain022
 ret
ain022:
 jmp short ifthen

ifnevt endp

;-----

ifltvt proc near

;If V<V then
 call chkequ
 jnz ain023
 ret
ain023:
 jnb ain024
 ret
ain024:
 jmp short ifthen

ifltvt endp

;-----

ifgtvt proc near

;If V>V then
 call chkequ
 jb ain025
 ret
ain025:
 jmp short ifthen

ifgtvt endp

;-----

chkeqv proc near

;var1=cons ?
 call gethlval
 push cx
 inc bp
 call getcon
 push cx
 pop dx
chk1:
 pop cx
 xchg dx,bx
 push bx
 and al,al
 sbb bx,cx                  ;cons-var1
 pop di
 xchg dx,bx
 lahf                       ;Save flags
 xchg al,ah
 push ax
 xchg al,ah

 call getadr
 pop ax
 xchg al,ah

 sahf                       ;Restore flags
 ret

chkeqv endp

;-----

ifeqct proc near

;if v=c then
 call chkeqv
 jz ain026
 ret
ain026:
 jmp short ifthen

ifeqct endp

;-----

ifnect proc near

;if v<>c then
 call chkeqv
 jnz ain027
 ret
ain027:
 jmp short ifthen

ifnect endp

;-----

ifltct proc near

;if v<c then
 call chkeqv
 jnz ain028
 ret
ain028:
 jnb ain029
 ret
ain029:
 jmp short ifthen

ifltct endp

;-----

ifgtct proc near

;if v>c then
 call chkeqv
 jb ain030
 ret
ain030:
 jmp short ifthen

ifgtct endp

;-----

ifthen proc near

;Handle GOTO for IF
 mov bp,dx
 ret

ifthen endp

;-----

printinput proc near

; Acode instruction with no arguments
; Print last input word processed - i.e. contents of OBUFF
 mov dx,offset obuff
printinput1:
 xchg si,dx
 mov al,cs:[si]
 xchg si,dx
 cmp al,' '
 jne ain031
 ret
ain031:
 call printchar
 inc dx
 jmp short printinput1
;-----
input:
 push bx

;(not multi) call snooze

;If last INPUT returned "end-of-line" then get
;more keyboard input

 mov bx,cs:ibuffpointer
 mov al,bh
 or al,bl
 jnz ip04

;Get keyboard input

 call flush
 call wrapreset
 mov bx,offset ibuff
 mov cs:ibuffpointer,bx
;; mov al,inputlinedcode
;; call driver
 push bx
 push cx
 push dx
 push si
 push di
 push es
;; call Dinputline
 pop es
 pop di
 pop si
 pop dx
 pop cx
 pop bx

;(IBUFFPOINTER) is address of end of previous word.
;Copy next input word to OBUFF converting to lower case
;and removing transparent characters.

ip04:
 mov bx,cs:ibuffpointer
 mov di,offset obuff
ip05:
 mov al,cs:[bx]                ;Find start of next word
 or al,al
 jnz ain032
 jmp ip20
ain032:                     ;End of input
 call partword
 jz ip06
 mov al,cs:[bx]
 inc bx
 cmp al,' '
 je ip05
 mov cs:ibuffpointer,bx
 mov bx,cs:list9 ;***should be les
 mov byte ptr es:[bx],0     ;LIST 9 below GAMEDATA
 inc bx
 mov es:[bx],al ;write to list
 inc bx
 mov byte ptr cs:[di],al       ;obuff
 mov byte ptr cs:1[di],' '     ;obuff+1
 mov cx,0FFFFh              ;Force PRINTINPUT to print OBUFF
 mov cs:keywordnumber,cx
 jmp ip19a

ip06:
 mov al,cs:[bx]
 cmp al,'-'                 ;Transparent character
 je ip07
 call partword
 jnz ain033
 jmp short ip07
ain033:
ip06a:
 mov byte ptr cs:[di],' '      ;Word terminator
 jmp short ip09
ip07:
 mov al,cs:[bx]                ;Copy one character of word
 call lower
 mov cs:[di],al
 inc di
 push bx
 push di
 pop bx
 mov cx,offset OBUFF+31
 sub bx,cx
 pop bx
 jnb ip06a                  ;Buffer full, simulate end-of-word
ip08:
 inc bx
 jmp short ip06
ip09:
 mov cs:ibuffpointer,bx

;Convert word in OBUFF to word-number

 mov bx,0FFFFh
 mov cs:abrevword,bx
 mov cs:keywordnumber,bx
 mov bx,cs:list9 ;***should be les
 mov cs:list9pointer,bx
 call setindex
 mov al,byte ptr cs:obuff
 sub al,'a'
 jnb ip10

 mov bx,cs:AddressGameDataDat
 mov bx,es:[bx+6]           ;Start of Word Dictionary, from GAMEDATA
 mov cs:wordaddress,bx
 sub cx,cx                  ;Non alpha keywords in first segment
 jmp short ip13a

ip10:
 cmp al,26
 jb ip11
 mov al,103
 jmp short ip13
ip11:
 add al,al
 add al,al
 mov ch,al
 mov al,byte ptr cs:obuff+1
 cmp al,' '
 jne ip12
 mov al,ch
 jmp short ip13
ip12:
 sub al,'a'
 shr al,1
 shr al,1
 shr al,1
 and al,03h                 ;4 minor segments per major segment
 add al,ch
ip13:
 sub ch,ch
 mov cl,al
 mov di,cs:AddressGameDataDat
 mov ax,es:[di+12]
 sub al,cl
 jnb ain034
 jmp ip22
ain034:                     ;No such segment
 add bx,cx
 add bx,cx
 add bx,cx
 add bx,cx
 mov cx,es:[bx]             ;Save address
 inc bx
 inc bx
 mov cs:wordaddress,cx
 mov cx,es:[bx]             ;Save word number
ip13a:
 mov cs:wordnumber,cx
 mov bx,cs:wordaddress
 call initunpack
ip14:
 call unpackword
 jnb ain035
 jmp ip21b
ain035:                     ;End of dictionary
 mov bx,offset obuff
 mov dx,offset threecharacters
 sub cx,cx                  ;Number of characters that match
ip15:
 push cx
 mov al,cs:[bx]
 mov ch,al
 xchg si,dx
 mov al,cs:[si]
 xchg si,dx
 and al,01111111b
 call lower
 cmp al,ch
 pop cx
 jnz ip16
 inc dx
 inc cx
 inc bx
 jmp short ip15
ip16:
 mov al,cs:[bx]                ;End of input word ?
 cmp al,' '
 je ain036
 jmp short ip17
ain036:                     ;No
 xchg si,dx
 mov al,cs:[si]
 xchg si,dx
 or al,al
 jnz ain037
 jmp short ip18
ain037:
 mov bx,cs:abrevword
 mov al,bh
 and al,bl
 cmp al,0FFh
 je ip22m
 jmp ip22
ip22m:
 mov al,cl
abrev equ 4                 ;Chars allowed as abreviation
 cmp al,abrev
 jb ain038
 jmp short ip18
ain038:
;Could be an abreviation
 mov bx,cs:wordnumber
 mov cs:abrevword,bx
 jmp short ip17b
ip17:
 mov bx,cs:abrevword
 mov al,bh
 and al,bl
 cmp al,0FFh
 jne ip18b
ip17b:
 mov cx,cs:wordnumber
 inc cx
 mov cs:wordnumber,cx
 jmp short ip14

;Fill LIST9 with a sequence of possible word-type/
;message-number possibilities terminated by 00h 00h.

ip18:
 mov bx,cs:wordnumber
ip18b:
 mov cs:keywordnumber,bx
 call findmsgequiv
 mov bx,0FFFFh
 mov cs:abrevword,bx
 mov bx,cs:list9pointer
 mov dx,cs:list9 ;****should be les
 mov al,bh
 cmp al,dh
 jne ip19
 mov al,bl
 cmp al,dl
 je ip17b                   ;No words found. Garbage word.
ip19:
 mov bx,cs:list9pointer
ip19a:
 mov word ptr es:[bx],0     ;Write terminator to LIST 9
 jmp short ip21
ip20:
 mov bx,cs:list9
 mov word ptr es:[bx],0     ;Write terminator to LIST 9
 mov cs:ibuffpointer,0
ip21:
 pop bx

;Skip over arguments to INPUT

 inc bp
 inc bp
 inc bp
 inc bp
 ret

ip21b:
 mov bx,cs:abrevword
 mov al,bh
 and al,bl
 cmp al,0FFh
 jne ip18b

;Not a keyword, try it for a number

ip22:
 mov al,byte ptr cs:obuff   ;Start with digit ?
 cmp al,'0'
 jb ip22z
 cmp al,'9'+1
 jnb ip22z
 mov bx,offset numericbuffer
 mov byte ptr cs:[bx],0        ;numericbuffer
 mov word ptr cs:1[bx],0       ;numericbuffer+1,2
 mov bx,offset obuff
ip22a:
 mov al,cs:[bx]
 cmp al,' '
 je ip22b
 sub al,'0'
 jb ip22z                   ;Contains a non-digit
 cmp al,10
 jnb ip22z                  ;Character > '9'
 mov cl,al                  ;Current 'carry' value
 push bx
 mov bx,offset numericbuffer
 call mult10
 inc bx
 call mult10
 inc bx
 call mult10
 pop bx
 mov al,cl
 or al,al
 jnz ip22z                  ;Too big,Return as a garbage word
 inc bx
 jmp short ip22a

ip22b: ;Found a numeric value 0-FFFFFFh in NUMERICBUFFER
 mov bx,cs:list9
 mov byte ptr es:[bx],1     ;Set List 9 return flag as 'numeric'
 inc bx
 mov al,byte ptr cs:0[numericbuffer]
 mov es:0[bx],al ;write to list
 inc bx
 mov al,byte ptr cs:1[numericbuffer]
 mov es:0[bx],al
 inc bx
 mov al,byte ptr cs:2[numericbuffer]
 mov es:0[bx],al
 inc bx
 jmp ip19a

;Garbage word, Return 00h 80h

ip22z:
 mov bx,cs:list9
 mov word ptr es:[bx],8000h ;Garbage word
 inc bx
 inc bx
 mov cs:list9pointer,bx
 jmp ip19

printinput endp

;-----

;Do one stage of V = (HL)*10 + C
; Return: (HL) = V MOD 256
;         C = V DIV 256

mult10 proc near

 mov al,cs:[bx]
 push bx
 mov bl,al
 sub bh,bh
 add bx,bx
 mov dl,bl
 mov dh,bh
 add bx,bx
 add bx,bx
 add bx,dx
 sub dh,dh
 mov dl,cl
 add bx,dx
 xchg dx,bx
 pop bx
 mov cs:[bx],dl                ;Return V MOD 256
 mov cl,dh                  ;Return carry
 ret

mult10 endp

;-----

exit proc near

;From, Dir, Status, Newroom
 call gethlval
 mov al,cl
 mov cs:var1,al
 inc bp
 call gethlval
 mov dh,cl
 inc bp
 mov al,cs:var1

 mov dl,al
 call exit1
 mov cs:extst,al
 mov al,cl              ;'to' room
 push ax
 call gethlval
 mov al,cs:extst
 and al,70h             ;Reset bottom 4 bits + Top bit
 sar al,1
 sar al,1
 sar al,1
 sar al,1
 mov si,dx 
 xor ah,ah
 mov ds:[si],ax ;write to vars
 inc bp
 call gethlval
 pop ax
 mov si,dx
 xor ah,ah
 mov ds:[si],ax ;write to vars.
 xchg si,dx ;0
 inc bp
 ret
;-----                  
exit1:                  ;Given D=Dir, E=From room
;Return status byte in A, 'to' room in C
 mov bx,cs:Romext
;Find E'th entry on list
 mov ch,dl
 dec ch
 mov al,ch
 jz exit3
exit2:
 mov al,es:[bx] ;es=exit table
 and al,al              ;Short exit-table for KAOS 9/87
 jz notfn4
 test al,080h
 lahf                   ;required
 inc bx
 inc bx
 sahf                   ;required
 jz exit2               ;Not end of room list yet
 dec ch
 jz ain039
 jmp short exit2
ain039:
;Got room E
;Now find an entry direction D
exit3:
 mov al,es:[bx] ;es=exit table
 and al,0Fh             ;Separate out direction
 cmp al,dh
 jne exit4
 mov al,es:[bx]
 inc bx
 mov cl,es:[bx]
 ret

exit4:
 mov al,es:[bx]
 test al,080h
 jnz notfn4
 inc bx
 inc bx
 jmp short exit3

notfn4:                 ;First pass failed, so try reversible
;First invert direction
 mov cl,dh
 sub ch,ch
 mov bx,offset dorrev
 add bx,cx
 mov dh,cs:[bx]                ;(In DORREV) New direction
;Find A to room=E, Dirction=D, reversible
 mov bx,cs:romext
 mov cl,1                   ;Current room number
exit5:
 mov al,es:[bx] ;exit table
 test al,00010000b          ;Reversible ?
 jz exit6
;It's reversible, but is it the right direction ?
 and al,0Fh                 ;Filter direction
 cmp al,dh
 jne exit6
;and does it go to the right place ?
 inc bx
 mov al,es:[bx] ;exit table
 cmp al,dl
 lahf                       ;required
 dec bx
 sahf                       ;required
 jnz exit6
;C=Destination
 mov al,es:[bx] ;exit table
 ret
;-----
exit6:                      ;Try another exit
 mov al,es:[bx] ;exit table
 test al,080h
 jz exit7
 inc cl                     ;Current room number on list
exit7:
 mov al,es:[bx] ;exit table
 inc bx
 inc bx
 or al,al
 jnz exit5
;Not found at all !
 sub cl,cl                  ;Destination (or lack of)
 ret

exit endp

;-----
dorrev:
 db 0
 db 5
 db 6
 db 7
 db 8
 db 1
 db 2
 db 3
 db 4
 db 0Ah
 db 9
 db 0Ch
 db 0Bh
 db 0Dh                     ;Exit reversal table for KAOS 9/87
 db 0Eh
 db 0Fh                     ;Jump
;-----

lstvlv proc near

;var=listn(var)

 sub al,160
 call lstv2
 call getval
;cx=var (index)

lstvl1: ;es:[bx] is list start
 add bx,cx
 inc bp
 mov al,ds:[bp]         ;acode. Destination var number
 call getval
;si=destination variable address
 mov al,es:[bx]         ;Read value from list
 xor ah,ah
 xchg si,dx
 mov ds:[si],ax         ;write to vars.
 inc bp
 mov es,cs:CS_GameData  ;restore es:
 mov si,offset IBUFF ;*
 ret

lstvlv endp

;-----

list proc near

 mov al,ds:[bp]
 inc bp
 cmp al,224
 jnb lstvv
 cmp al,192
 jnb lstvlc
 cmp al,160
 jnb lstvlv

;List N (Cons)=Var
 sub al,128
 call getind
 mov bx,cx             ;es:bx is list
 mov cl,ds:[bp]        ;get index from acode
 sub ch,ch

;es:bx is list start
;bp    is acode ptr
;cx    is index value
 jmp short lstvv1

list endp

;-----

getind proc near

; add al,al
; mov cl,al
; sub ch,ch
; mov bx,offset lsttbl
; add bx,cx
; mov cx,cs:[bx]
 push bx
 push si
 mov bh,0
 mov bl,al
 add bx,bx
 add bx,bx
 les si,ds:PCListVector[bx] ;Read from list11
 mov cx,si
 pop si
 pop bx
 ret

getind endp

;-----

lstvv proc near

;List N (var)=var
 sub al,224
 call getind

 push cx          ;es:cx is list start
 mov al,ds:[bp]   ;get var number
 call getval      ;get cx=var 1
 pop bx           ;es:bx is list start

;es:bx is list start
;bp    is acode ptr
;cx    is index value

lstvv1:
 inc bp
 add bx,cx        ;list start+index
 push bx          ;list address
 call gethlval    ;get dx=dest var address
 xchg dx,bx
 pop bx           ;pop es:bx=list address

 mov es:[bx],cl ;write to list
 mov es,cs:CS_GameData ;*
 mov si,offset IBUFF ;*
 inc bp
 ret

lstvv endp

;-----

lstvlc proc near

;Var=List N(Cons)
 sub al,192
 call lstv2
 mov cl,al
 sub ch,ch
 push es
 jmp lstvl1             ;es on stack. es:[bx] is list start

lstvlc endp

;-----

lstv2 proc near
;Given AL=list number
;Acode:[bp] is next acode byte (preserved)
;returns es:[bx] as address of list

 push si
 mov bh,0
 mov bl,al
 add bx,bx
 add bx,bx
 les si,ds:PCListVector[bx] ;read from list11
 mov dx,si
 pop si
 xchg dx,bx             ;Start of list in HL
 push es
 mov es,cs:CS_Acode     ;acode.
 mov al,ds:[bp]         ;Next acode byte
 pop es
 ret

lstv2 endp

;-----

random proc near

;Random V1
 call gethlval
 inc bp
 call randno                ;Random number in A
 xor ah,ah
 mov si,dx
 mov ds:[si],ax             ;write to vars.
 ret
;-----
randno:                     ;Returns 0-255 in A
 mov bx,cs:rndsed
 push dx
 xchg dx,bx
 mov bh,dl
 mov bl,10
 or al,al
 sbb bx,dx
 add bx,bx
 add bx,bx
 add bx,dx
 inc bx
 mov cs:rndsed,bx
 mov al,bl
 pop dx
 ret

random endp

;-----

getcon proc near

 test cs:CurrentFlags,40h
 jnz getcn1

 mov cx,ds:[bp]         ;16 bit constant from ACODE
 add bp,2

 ret

getcn1:
 mov cl,ds:[bp]         ;8 bit unsigned constant from ACODE
 inc bp
 sub ch,ch
 ret

getcon endp

;-----

clear proc near

;Reset workspace
 push bx
 mov ax,numvar
 add ax,ax
 mov cx,ax
 mov bx,offset Aint_Vars
clear1:
 mov byte ptr ds:[bx],0 ;write to acode vars.
 inc bx
 dec cx
 jcxz ain040
 jmp short clear1
ain040:
 pop bx
 ret

clear endp

;-----

stackfunction proc near

;Reset stack - meaningless in multitasking environment.
 ret

stackfunction endp

;-----

restore proc near

 ret

restore endp

;-----

save proc near

 ret ;;

save endp

;-----

;If message number 'HL' exists it is displayed.

displaymessage proc near
 xchg dx,bx
 mov bx,cs:startmd          ;Start address of Message Descriptors

;Start of message ?

lm01:
 call checkmdt
 jb ain042
 ret
ain042:                     ;Message off end
 mov al,dh
 or al,dl
 jz lm04

 mov al,es:[bx] ;read from SQUASH.DAT ;Message header byte
 inc bx
 test al,080h               ;JUMPH, Jump header ?
 jnz lm02

;Skip message

 dec bx
 call getmdlength
 add bx,cx

;End of message

 dec dx
 jmp short lm01

;Skip header

lm02:
 and al,7Fh                 ;Skip in message numbers
 mov ch,al
lm03:
 mov al,dh
 or al,dl
 jnz ain043
 ret                        ;No such message

ain043:
 dec dx
 mov al,ch
 or al,al
 jz lm01
 dec ch
 jmp short lm03

;Found required message header

lm04:
 mov al,es:[bx] ;squash.dat
 test al,080h               ;JUMPH, Jump header ?
 jz ain044
 ret
ain044:
 mov cs:startmsg,bx

 call getmdlength
lm05:
 mov al,ch
 or al,cl
 jnz ain045
; call flush                 ;28/11/88
 ret

ain045:
 mov dl,es:[bx] ;squash.dat
 test dl,080h               ;LONG, Long form ?
 jnz lm06

;Short form reference

;*****
 push bx
 push cx
 sub dh,dh
 mov bx,cs:AddressGameDataDat
 mov bx,es:[bx+14] ;squash.dat         ;Common Word Dictionary
 mov cx,cs:AddressGameDataDat
 add bx,cx
 add bx,dx
 add bx,dx
 mov dh,es:[bx] ;squash.dat
 inc bx
 mov dl,es:[bx]
 pop cx
 pop bx
 jmp short lm07

;Long form reference

lm06:
 mov dh,es:[bx] ;squash.dat
 inc bx
 dec cx
 mov dl,es:[bx]
lm07:
 inc bx
 dec cx

;Display word reference 'DE'

 mov al,dh
 cmp al,8Fh
 je ain046
 jmp short lm08
ain046:
 mov al,dl
 cmp al,80h
 jne lm08
 ret                        ;'|' terminator
lm08:
 push cx
 push bx
 call displaywordref
 pop bx
 pop cx
 jmp short lm05

displaymessage endp

;-----

;HL is the address in the Message Descriptors of a Message header
;Returns HL as the address of the first word-reference of that
;message and BC as the messages length (in bytes).

getmdlength proc near

 sub cx,cx
gl01:
 mov al,es:[bx] ;squash.dat
 inc bx
 and al,03Fh
 or al,al
 jne gl02
 push bx
 mov bx,003Fh
 add bx,cx
 mov cx,bx
 pop bx
 jmp short gl01
gl02:
 dec al
 push bx
 sub bh,bh
 mov bl,al
 add bx,cx
 mov cx,bx
 pop bx
 ret

getmdlength endp

;-----

checkmdt proc near

 push bx
 push dx
 mov dx,cs:endmd            ;Start address of Message Descriptors
 sub bx,dx
 pop dx
 pop bx
 ret

checkmdt endp

;-----

;Display word reference 'DE'

displaywordref proc near

 mov al,dh
 shr al,1
 shr al,1
 shr al,1
 shr al,1
 and al,07h
 mov cs:wordtype,al

 mov al,dh
 and al,0Fh
 mov bh,al
 mov bl,dl
 mov cx,0F80h
 mov cs:wordcase,0
 sub bx,cx
 jb dn01

;Single character

 push bx
 mov al,cs:wordtype
 test al,00000010b
 mov al,' '
 jz ain048
 call printchar
ain048:
 mov al,2
 mov cs:mdtmode,al
 pop bx
 mov al,bl
 cmp al,"~"
 je join
 call printchar
join:
 mov al,cs:wordtype
 test al,00000001b
 mov al,' '
 jz ain049
 call printchar
ain049:
 ret

;Word reference

dn01:
 mov al,cs:mdtmode
 cmp al,1
 mov al,' '
 jne ain050
 call printchar
ain050:
 mov al,1
 mov cs:mdtmode,al

;Display word number DE

 mov al,dh
 and al,0Fh
 mov ch,al
 mov cl,dl
 call setindex
dn02:
;BC is word number to display
;HL is address of current index entry
;DE is number of index segments left
 mov al,dh
 or al,dl
 jz dn04
 push bx
 inc bx
 inc bx
 mov al,es:[bx] ;squash.dat ;(In GAMEDATA paragraph)
 inc bx
 mov bh,es:[bx]             ;(In GAMEDATA paragraph)
 mov bl,al
 sbb bx,cx
 pop bx
 jz dn03
 jnb dn04
dn03:
 push cx
 mov cx,es:[bx]             ;(In GAMEDATA paragraph)
 inc bx
 inc bx
 mov cs:wordaddress,cx
 mov cx,es:[bx]             ;(In GAMEDATA paragraph)
 inc bx
 inc bx
 mov cs:wordnumber,cx
 pop cx
 dec dx
 jmp short dn02
dn04:

;Skip remaining words individually

 mov bx,cx
 mov cx,cs:wordnumber
 sub bx,cx
 push bx                    ;Word number offset

 mov bx,cs:wordaddress
 pop cx
 call initdict
 xchg dx,bx
 mov ch,cl                  ;Word number within this segment
 inc ch
 jmp short dn05

;Long code: Extract ascii code from next 10 bits

dn06a:
 push dx
 call getlongcode
 pop dx
 jmp short dn06b

;Not a header

dn06:
 cmp al,longc
 jnb dn06a

;Normal alpha

 add al,'a'

dn06b:
 xchg si,dx
 mov cs:[si],al
 xchg si,dx
 inc dx

dn05:
 call getdictionarycode
 cmp al,header
 jb dn06

 and al,03h                 ;Get 'length'
 mov dl,al
 sub dh,dh
 mov bx,offset threecharacters
 add bx,dx
 xchg dx,bx
 dec ch
 jz ain051
 jmp short dn05
ain051:

 mov bx,offset threecharacters
dn09:
 or al,al
 jz dn10
 push ax
 mov al,cs:[bx]
 call printautocase
 pop ax
 dec al
 inc bx
 jmp short dn09
dn10:
;Unpack dictionary word
 call getdictionarycode
 cmp al,endseg              ;Header or end of segment ?
 jb ain052
 ret

ain052:
 call getdictionary
 call printautocase
 jmp short dn10

displaywordref endp

;-----

setindex proc near

 mov di,cs:AddressGameDataDat
 mov cs:wordnumber,0
 mov bx,es:[di+6] ;squash.dat ;Address of word number 0
 mov cs:wordaddress,bx
 mov bx,es:[di+10]          ;Word dictionary index
 add bx,di
 mov dx,es:[di+12]
 ret

setindex endp

;-----

;A is the current short-code.
;Returns A as the next unpacked ascii code.

getdictionary proc near

 cmp al,longc
 jnb getlongcode

;Normal alpha

 add al,'a'
 ret

;Long escape short code

getlongcode:
 call getdictionarycode
 cmp al,uppercasemark
 jne ga02

;Upper-case-only marker

 mov al,1
 mov cs:wordcase,al
 call getdictionarycode
 jmp short getdictionary

ga02:
 rcl al,1
 rcl al,1
 rcl al,1
 rcl al,1
 rcl al,1
 and al,0E0h
 mov dl,al
 push dx
 call getdictionarycode
 and al,1Fh
 pop dx
 or al,dl
 or al,10000000b            ;Flag character as a long-code
 ret

getdictionary endp

;-----

;Unpack and Return bytes from Word Dictionary

getdictionarycode proc near

;Preserves registers B and DE
 mov al,cs:unpackpointer
 cmp al,8
 jne ain053
 call unpackbytes
ain053:
 mov cl,al
 inc al
 mov cs:unpackpointer,al
 mov al,ch
 sub ch,ch
 mov bx,offset unpack1
 add bx,cx
 mov ch,al
 mov al,cs:[bx]
 ret

getdictionarycode endp

;-----

unpackbytes proc near

 mov bx,cs:blockpointer
 mov al,es:[bx] ;squash.dat             ;aaaaabbb
 ror al,1
 ror al,1
 ror al,1
 and al,1Fh
 mov cs:unpack1,al          ;000aaaaa
 mov al,es:[bx]             ;aaaaabbb
 inc bx
 mov cl,es:[bx]             ;bbcccccd
 rcl cl,1
 rcl al,1
 rcl cl,1
 rcl al,1
 and al,1Fh
 mov cs:unpack2,al
 mov cl,es:[bx]             ;bbcccccd
 rcr cl,1
 inc bx
 mov al,es:[bx]             ;ddddeeee
 rcr al,1
 rcr al,1
 rcr al,1
 rcr al,1
 and al,1Fh
 mov cs:unpack4,al
 mov al,cl
 and al,1Fh
 mov cs:unpack3,al
 mov al,es:[bx]             ;ddddeeee
 inc bx
 mov cl,es:[bx]             ;efffffgg
 sal cl,1
 rcl al,1
 and al,1Fh
 mov cs:unpack5,al
 mov al,es:[bx]             ;efffffgg
 inc bx
 mov cl,es:[bx]             ;ggghhhhh
 rcr al,1
 rcr cl,1
 rcr al,1
 rcr cl,1
 and al,1Fh
 mov cs:unpack6,al
 mov al,cl
 rcr al,1
 rcr al,1
 rcr al,1
 and al,1Fh
 mov cs:unpack7,al
 mov al,es:[bx]             ;ggghhhhh
 and al,1Fh
 mov cs:unpack8,al
 inc bx
 mov cs:blockpointer,bx
 sub al,al                  ;Unpack pointer
 ret

unpackbytes endp

;-----

;Convert A to upper-case.
;Returns 'A'. Flags corrupted.

upper proc near

 cmp al,'a'
 jnb ain054
 ret
ain054:
 cmp al,'z'+1
 jb ain055
 ret
ain055:
 sub al,20h
 ret

upper endp

;-----

;Convert A to lower-case.
;Returns 'A'. Flags corrupted.

lower proc near

 cmp al,'A'
 jnb ain056
 ret
ain056:
 cmp al,'Z'+1
 jb ain057
 ret
ain057:
 add al,20h
 ret

lower endp

;-----

;Print part of a word

printautocase proc near

 test al,10000000b          ;Long code ?
 jnz printchar
 push bx
 push ax
 mov al,cs:wordcase
 or al,al
 jnz dc02
 mov al,cs:wordtype
 cmp al,6
 jnb dc01
 pop ax
 jmp short dc03
dc01:
 mov cs:wordtype,0
dc02:
 pop ax
 call upper
dc03:
 pop bx

printchar:
 push bx
 push dx
 push cx
 push ax
 test al,10000000b
 jz pc00
 and al,01111111b           ;Remove escape-code flag
 jmp short pc02
pc00:
;Transparent characters: cr space " # $ % & ' ( )
 cmp al,' '
 je pc03
 cmp al,cret
 je pc03
 cmp al,'!'+1
 jb pc00a
 cmp al,')'+1
 jb pc03
pc00a:
;Sentance terminators: ! ? .
 mov al,cs:lastchar
 cmp al,'!'
 je pc01
 cmp al,'?'
 je pc01
 cmp al,'.'
 jne pc02
pc01:
 pop ax
 call upper
 push ax
pc02:
 pop ax
 and al,01111111b
 mov cs:lastchar,al
 push ax
pc03:
 cmp al,' '
 jne pc04
 call flush
 mov al,0FFh
 mov cs:pendspace,al
 jmp short pc06
pc04:
 cmp al,cret
 jne pc05
 call flush
 mov al,cret
 call wrapoutput
 jmp short pc06
pc05:
 mov bx,cs:wrapbufferpointer
 mov cs:[bx],al
 inc bx
 mov cs:wrapbufferpointer,bx

pc06:
 pop ax
 pop cx
 pop dx
 pop bx
 ret

printautocase endp

;-----

wrapreset proc near

;(bx not corrupted)
 mov cs:mdtmode,0
 mov cs:nchars,0
 mov cs:lastchar,'.'

 mov al,39                  ;Variable stores one less
 mov cs:Width0,al

 jmp short flush6

wrapreset endp

;-----

flush proc near

 mov al,cs:pendspace
 or al,al
 jz flush4
 mov al,cs:nchars
 mov ch,al
 mov bx,offset wrapbuffer
flush1:
 push bx
 mov dx,cs:wrapbufferpointer
 sub bx,dx
 pop bx
 jnb flush2
 inc bx
 inc ch
 jmp short flush1
flush2:
 mov al,cs:width0
 cmp al,ch
 mov al,' '
 jnb flush3
 mov al,cret
flush3:
 call wrapoutput
flush4:
 mov bx,offset wrapbuffer
flush5:
 push bx
 mov dx,cs:wrapbufferpointer
 sub bx,dx
 pop bx
 jnb flush6
 mov al,cs:[bx]
 call wrapoutput
 inc bx
 jmp short flush5
flush6:
 mov cs:wrapbufferpointer,offset wrapbuffer
 mov cs:pendspace,0
 ret

flush endp

;-----

wrapoutput proc near

 push bx
 push dx
 push cx
 cmp al,cret
 jne wrapoutput2
 mov al,cs:nchars
 or al,al
 jz wrapoutput3

 call oswrcr
wrapoutput1:
 mov cs:nchars,0
 jmp short wrapoutput3
wrapoutput2:
 call oswrch
 mov bx,offset nchars
 inc byte ptr cs:[bx]
wrapoutput3:
 pop cx
 pop dx
 pop bx
 ret

wrapoutput endp

;-----

unpackword proc near

 mov al,cs:lastheader       ;Get similarity count
 cmp al,endseg              ;Padder at end of segment ?
 stc
 jnz ain058
 ret
ain058:
 and al,3
 mov bx,offset threecharacters
 sub dh,dh
 mov dl,al
 add bx,dx
 mov cs:headerpointer,bx

uw01:
 call getdictionarycode
 push ax
 mov bx,cs:endwdp5
 mov dx,cs:blockpointer
 mov al,bh
 cmp al,dh
 je ain059
 jmp short uw02
ain059:
 mov al,bl
 cmp al,dl
 je ain060
 jmp short uw02
ain060:
;End of dictionary
 pop ax
 stc
 ret

uw02:
 pop ax
 cmp al,endseg
 jnb uw03

;Not a header

 call getdictionary
 mov bx,cs:headerpointer
 mov cs:[bx],al
 inc bx
 mov cs:headerpointer,bx
 jmp short uw01

uw03:
 mov cs:lastheader,al
 mov bx,cs:headerpointer
 mov byte ptr cs:[bx],0        ;Terminator
 ret

unpackword endp

;-----

;HL is the offset from STARTFILE of start of

initdict proc near

;*****
 push cx
 mov cx,cs:AddressGameDataDat
 add bx,cx
 mov cs:blockpointer,bx
 mov al,8
 mov cs:unpackpointer,al
 mov bx,offset threecharacters
 mov cs:headerpointer,bx
 pop cx
 ret

initdict endp

;-----

initunpack proc near

 call initdict
 mov al,header
 mov cs:lastheader,al
 jmp unpackword

initunpack endp

;-----

partword proc near

 call upper
 cmp al,"'"
 je pw02                    ;Quote ok
 cmp al,'0'
 jb pw01                    ;0-9 ok
 cmp al,'9'+1
 jb pw02
 cmp al,'A'
 jb pw01                    ;A-Z ok
 cmp al,'Z'+1
 jb pw02
;Not part of a word
pw01:
 mov al,1
 or al,al
 ret                        ;Return 'NZ'
;Not part of a word
pw02:
 xor al,al
 ret                        ;Return 'Z'

partword endp

;-----

findmsgequiv proc near

 mov cs:wordnumber,bx       ;Save Word number
 sub bx,bx                  ;Message number
 mov cs:startmsg,bx         ;Message Number
 mov bx,cs:startmd          ;Start address of Message Descriptors
 jmp short fe02

fe01:
 mov cx,cs:startmsg         ;Message Number
 inc cx
 mov cs:startmsg,cx         ;Message Number

fe02:
 call checkmdt
 jb ain061
 ret
ain061:                     ;Searched all messages

 mov al,es:[bx] ;squash.dat ;Message header byte
 inc bx
 test al,080h               ;JUMPH, Jump header ?
 jnz fe03

;Found a message header

 test al,040h               ;PARSE, Contains keywords ?
 jnz fe04                   ;Yes (usually false)
 dec bx
 call getmdlength
 add bx,cx
 jmp short fe01

;Skip header

fe03:
 and al,7Fh                 ;Skip in message numbers
 push bx
 mov bx,cs:startmsg         ;Message Number
 sub ch,ch
 mov cl,al
 add bx,cx
 inc bx
 mov cs:startmsg,bx         ;Message Number
 pop bx
 jmp short fe02

;Found a message header

fe04:
 dec bx
 call getmdlength
fe05:
 mov dx,cs:wordnumber
 jmp short fe08
fe06:
 inc bx
 dec cx
fe07:
 inc bx
 dec cx
fe08:
 mov al,ch
 or al,cl
 jz fe01
 mov al,es:[bx]             ;(In GAMEDATA paragraph)
 test al,080h               ;long
 jz fe07
;Compare long form reference
 cmp al,90h
 jb fe06                    ;Garbage word
 inc bx
 dec cx
 and al,0Fh
 cmp al,dh
 jne fe07
 mov al,es:[bx]             ;(In GAMEDATA paragraph)
 inc bx
 dec cx
 cmp al,dl
 jne fe08
;Hi byte of sequence is (HL-2)
 dec bx
 dec bx
 mov dh,es:[bx]             ;(In GAMEDATA paragraph)
 inc bx
 inc bx

;Message found D contains word-type

 push bx
 mov al,dh
 add al,al
 and al,0E0h
 mov bx,cs:startmsg         ;Message Number
 or al,bh
 mov bh,al
 xchg dx,bx
 mov bx,cs:list9pointer
 push bx
 push cx
 mov cx,cs:list9
 sub bx,cx
 mov al,bl                  ;Length of list
 cmp al,64
 pop cx
 pop bx
 jnb fe09                   ;List has 32 Entries

 mov es:[bx],dh             ;(In GAMEDATA paragraph)
 inc bx
 mov es:[bx],dl             ;(In GAMEDATA paragraph)
 inc bx
 mov cs:list9pointer,bx
 pop bx
 jmp short fe05

fe09:

 pop bx
 ret

findmsgequiv endp

;-----

getnextobject proc near

;*****BUGS: GETNEXT still accesses list2 and list3 via LSTTBL
;****       rather than LIST11, so do not redirect these lists
;****       via list11.

;** Given GETNEXT MAXOBJECT HISEARCHPOS SEARCHPOS --------------
;** Returns       --------- HISEARCHPOS OBJECT    NUMOBJECTFOUND
;** Return OBJECT and NUMBER of object in this pass
;** If HISEARCHPOS=0, then initialise tree search
;** At end of search, return OBJECT=0

 call gethlval
 mov cs:maxobject,cl
 inc bp

 call gethlval
 mov cs:hisearchpos,cl      ; A one-byte value
 mov cs:hisearchposvar,dx
 inc bp

 call gethlval
 mov cs:searchpos,cl        ; A one-byte value
 mov cs:searchposvar,dx
 inc bp
 mov cs:hlsave,bp

getnextobjectabs:
 mov al,cs:hisearchpos
 or  al,cs:searchpos
 jnz ain062
 jmp initgetobjsp

ain062:                     ; set up,ret
 cmp byte ptr cs:numobjectfound,0
 jnz gnonext
 mov al,cs:hisearchpos
 mov cs:inithisearchpos,al

gnonext:
 mov bl,cs:object
 xor bh,bh
 mov si,cs:list2            ; Current position of objects
 mov al,cs:searchpos
 mov ah,cs:maxobject
ain063:
 inc bl
 cmp bl,ah
 jae gnoNextEnd
;**********
 cmp al,es:[si+bx] ;read from list         ;gamedata. ; (In GAMEDATA segment)
 jne ain063
 mov cs:object,bl
 jmp gnomaybefound

gnoNextEnd:
 mov cs:object,bl

;** Have reached end of current pass
 cmp cs:inithisearchpos,nonspecific
 jne gnonewlevel

;** Started off as non-specific search, so there
;** may be unscanned directions to try
 xor bx,bx
 xchg bl,cs:hisearchpos
 mov byte ptr cs:gnoscratch[bx],bh

gnoloop:
 mov bl,cs:hisearchpos
 xor bh,bh
 cmp byte ptr cs:gnoscratch[bx],bh
 je  gnoloop1
 mov al,cs:searchpos
 call gnopush
 mov al,cs:hisearchpos
 call gnopush

gnoloop1:
 mov al,cs:hisearchpos
 inc al
 mov cs:hisearchpos,al
 cmp al,nonspecific
 jb gnoloop

gnonewlevel:
 call gnopop
 mov cs:hisearchpos,al
 call gnopop
 mov cs:searchpos,al

 mov byte ptr cs:numobjectfound,0
 mov al,cs:hisearchpos
 cmp al,nonspecific
 jne gnonewlevelcont

;** Nonspecific HISEARCHPOS, so this is a real new level
 inc byte ptr cs:searchdepth
gnonewlevelcont:
 call initgetobj
 cmp byte ptr cs:searchpos,0
 je  ain064
 jmp getnextobjectabs

ain064:
getnextfinish:

;** That's all folks !
 xor bx,bx
 mov cs:object,bl
 mov cs:searchpos,bl
 mov cs:hisearchpos,bl

gnoreturnargs:
 mov bx,cs:hisearchposvar
 mov al,cs:hisearchpos
 mov ds:[bx],al ;vars
 mov bx,cs:searchposvar
 mov al,cs:searchpos
 mov ds:[bx],al ;vars

 mov bp,cs:hlsave       ;acode ptr
 call gethlval
 mov al,cs:object
 xchg si,dx
 mov ds:[si],al ;vars
 xchg si,dx
 inc bp

 call gethlval
 mov al,cs:numobjectfound
 xchg si,dx
 mov ds:[si],al ;acode.
 xchg si,dx
 inc bp

 call gethlval
 mov al,cs:searchdepth
 xchg si,dx
 mov ds:[si],al ;acode.
 xchg si,dx
 inc bp

 ret

gnomaybefound:
;** Quick check suggests we may have something here
 call gnogethiobjectpos
 cmp al,cs:hisearchpos
 je  gnofound
 or  al,al
 jnz ain065
 jmp gnonext

ain065:
 cmp byte ptr cs:hisearchpos,0
 jne ain066
 jmp gnonext

ain066:
;** Want same obj in different containment
 cmp cs:hisearchpos,nonspecific
 je gnomf1

;** Note it down for reference at end
 mov bl,cs:hipos
 xor bh,bh
 mov byte ptr cs:gnoscratch[bx],bl
 jmp gnonext

gnomf1:
;** Start looking for this type rather than nonspecific type
 mov al,cs:hipos
 mov cs:hisearchpos,al

gnofound:
 inc cs:numobjectfound
 mov al,cs:object           ;Want references to this object
 call gnopush
 mov al,nonspecific
 call gnopush
;**  Found object, so return it to calling prog
 jmp gnoreturnargs


initgetobjsp:
 mov cs:gnosp,offset gnospbase
 mov byte ptr cs:searchdepth,0
 call initgetobj
 jmp gnoreturnargs

initgetobj:
 xor al,al
 mov cs:numobjectfound,al
 mov cs:object,al
 mov cx,nonspecific
 mov bx,offset gnoscratch
igo1:
 mov byte ptr cs:[bx],al
 inc bx
 loop igo1
 ret

gnopush:
 mov di,cs:gnosp
 mov cs:[di],al
 inc di
 mov cs:gnosp,di
 sub di,offset gnomaxsp
 jz  pusherror
 ret
pusherror:
 dec di
 mov cs:gnosp,di
poperror:
 xor al,al
 ret

gnopop:
 mov di,cs:gnosp
 cmp di,offset gnospbase
 jz poperror
 dec di
 mov cs:gnosp,di
 mov al,cs:[di]
 ret

gnogethiobjectpos:
;**  return HIPOS=Containment type
 mov bl,cs:object
 xor bh,bh
;*****
 mov si,cs:list3            ; hicurrentpos list
 mov al,es:[si+bx] ;read from list
 and al,1Fh
 mov cs:hipos,al
 ret

getnextobject endp

;-----

oswrcr:
 mov al,cret
oswrch:
 jmp Doswrch

;...e

;-----

code ends

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
