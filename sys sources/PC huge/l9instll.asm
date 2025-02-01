;IBM animated adventure data disc installer
; 9 & 10 sectors per track

;l9instll.asm

;Copyright (C) 1988 Level 9 Computing

;-----

 name demod

code segment public 'code'

 assume cs:code
 assume ds:code

;           Either   Signed   Unsigned
;    <=              jle      jbe
;    <               jl       jb/jc
;    =      je/jz
;    <>     jnz/jne
;    >=              jge      jae/jnc
;    >               jg       ja

;-----

;...sSubroutines:0:
;** Constants
;...sConstants:0:
;********  constants

 debug = 0  ;(0 for release, 1 for testing)

 readgap9   = 02ah
 writegap9  = 050h
 readgap10  = 005h
 writegap10 = 020h


;...e

;** Main Program
;...sMain Program:0:
InstallStart:
 mov ax,cs                    ;set up ds = es = cs
 mov ds,ax

 call allocatemem

 call readconfiguration

 call setdiscbase

 mov ax,cs
 mov ds,ax

 mov byte ptr drive,0
 mov byte ptr endmarker,0FFh
 mov byte ptr discnumber,30h

copydatadisc:
 inc byte ptr discnumber
 call checkdisc
 call copydata
 jnz copydatadisc

endcopy:

 mov dl,cs:lastdrive
 mov ah,0Eh
 int 21h
 
 mov bx,offset endmessage
 call printline

 jmp terminate

;...e

;** Main Subroutines
;...sRead Configuration:0:
;**********************************************************************
;*********  read configuration

ReadConfiguration:

;******** print title 

 mov bx,offset titlemessage
 call printline

;******** read current drive

 mov ah,19h
 int 21h
 
 mov lastdrive,al

;******** create output file

 mov ds,FileSeg
 mov dx,offset LayoutDriveName
 add dx,FileOffset


 mov ah,03ch      ;createfile
 mov al,000h      ;access code
 xor cl,cl	  ;zero attributes
 int 21h

 mov cx,cs
 mov ds,cx

 jnc nocreateerror


;??????

nocreateerror:
 mov handle,ax
 ret


;...e
;...sCopyData:0:
;**************************************************************************
;********  copy data to file

copydata:
 call setdatatype
 mov al,currenttrack

cdata0:
 mov maxsectors,20
 mov lumplength,20*512
cdata1:
 cmp al,9        ;find if either 5, 15, 25 ..
 jbe cdata2
 sub al,10
 jmp short cdata1

cdata2:
 cmp al,005h    ;check for five left over
 jne cdata5

 dec maxsectors
 sub lumplength,512
 
cdata5:
 mov al,currenttrack
 mov writetrack,al

 call copyfile

 inc currenttrack
 mov al,currenttrack
 cmp al,maxtracks
 jb  cdata0

 mov al,endmarker
 or al,al
 ret

;...e
;...sCopyFile:0:
;**************************************************************************
;********  copies file onto disc

copyfile:
 mov al,endmarker
 or al,al
 jnz copyfile1
 ret

copyfile1:
 xor bx,bx
 mov cx,maxsectors
 mov byte ptr writenumber,1

 mov byte ptr writeside,0
 mov byte ptr writesector,1

writenextsector:
 push bx
 push cx
 mov es,tracksegment
 call readasector
 pop cx
 pop bx
 add bx,512
 inc byte ptr writesector
 cmp byte ptr writesector,11
 jne writenextsector1

 mov byte ptr writeside,1
 mov byte ptr writesector,1

writenextsector1:
 loop writenextsector

;write to disc
 mov cx,LumpLength
 sub LowLength,cx
 sbb HighLength,0
 cmp HighLength,0FFFFh
 jne calcokay

 add cx,LowLength
 mov byte ptr endmarker,0

calcokay:
 mov ah,040h      ;write file
 mov bx,handle
 xor dx,dx        ;address

 mov ds,tracksegment    ;segment
 int 21h
 mov bx,cs
 mov ds,bx

if debug 
 jc  writelumperror
endif

 ret

if debug
writelumperror:
 call closefile
 call openerror
 jmp terminate
endif


;...e

;** Disc Checking
;...sCheck Disc:0:
;**************************************************************************
;********  check program disc

checkdisc:
 call setdostype
 call resetdisc

 mov bx,offset blanksector
 mov ax,cs
 mov es,ax
 mov writetrack,0
 mov writesector,1
 mov writeside,0
 mov writenumber,1
 call readasector

 mov cx,8
 mov di,offset blanksector+3
 mov si,offset l9name
 mov ax,cs
 mov es,ax
 repz cmpsb
 jz chkdisc1

if debug
 mov bx,offset notl9disc
 call printline
endif

chkdisc0:
 mov al,byte ptr discnumber
 mov byte ptr insertnumber,al
 mov bx,offset insertmessage
 call printline
 mov bx,offset pressakey
 call printline
 call getkey
 mov bx,offset spacemessage
 call printline

 jmp short checkdisc

chkdisc1:
 mov al,blanksector+509
 mov currenttrack,al

 mov ah,blanksector+508
 mov maxtracks,ah

 mov al,blanksector+507
 cmp al,discnumber
 jne chkdisc0

 cmp byte ptr discnumber,31h
 jne chkdiscret

 mov ax,word ptr blanksector+505
 mov highlength,ax

 mov ax,word ptr blanksector+503
 mov lowlength,ax
 
chkdiscret:
 ret

;...e

;** File Handler
;...sClose File:0:
;**********************************************************************
;*********  close file

closefile:
 mov ah,03eh      ;closefile
 mov bx,cs:handle
 int 21h
 ret 

;...e

;** Disc Handler
;...sClear Sector:0:
;**************************************************************************
;********  clear sector for disc

clearsector:
 xor ax,ax
 mov di,offset blanksector
 mov bx,ds
 mov es,bx
 mov cx,256
 rep stosw
 ret

;...e
;...sRead A Sector:0:
;**************************************************************************
;********  read sector from disc
; bx - address of buffer

readasector:
 mov trys,3

readasector1:
 mov dl,drive
 mov dh,writeside
 mov ch,writetrack
 mov cl,writesector
 mov al,writenumber
 mov ah,2 ;function
 int 13h
 jnc readasector2
 push ax
 call resetdisc
 pop ax
 dec trys
 jnz readasector1

 cmp byte ptr discnumber,031h
 jne readasectorerror
 cmp byte ptr writetrack,0h
 jne readasectorerror

 inc byte ptr drive
 cmp byte ptr drive,4
 jne readasector

 mov byte ptr drive,0

readasectorerror:

if debug
 call printerror
endif

readasector2:
 ret

;...e

;** Disc Setting
;...sReset Disc:0:
;**********************************************************************
;*********  resets disc system after error

resetdisc:
 xor ah,ah                    ;reset disc system
 mov dl,0
 int 13h
 ret

;...e
;...sSet Disc Base:0:
;**********************************************************************
;*********  sets up new disc base table

setdiscbase:
 xor ax,ax                    ;get old disc base table
 mov es,ax
 cli
 mov ax,es:[00078h]
 mov bx,es:[0007Ah]
 sti

 mov cx,cs
 cmp bx,cx
 je nobaseset
 cmp ax,offset discbasetable
 je nobaseset 

 mov [olddbaddress],ax
 mov [olddbsegment],bx
 mov ax,cs
 mov es,ax

 mov dx,offset discbasetable    ;used new one
 mov ax,0251Eh
 int 21h

nobaseset:
 mov ax,cs
 mov es,ax
 ret

;...e
;...sSet Dos Type:0:
;**************************************************************************
;********  sets type of disc for dos and data

setdostype:
 mov [discbasetable+4],9
 mov al,readgap9
 mov [discbasetable+5],al
 mov al,writegap9
 mov [discbasetable+7],al
 ret

;...e
;...sSet Data Type:0:
setdatatype:
 mov [discbasetable+4],10
 mov al,readgap10
 mov [discbasetable+5],al
 mov al,writegap10
 mov [discbasetable+7],al
 ret
;...e

;** Memory Handler
;...sAllocate Memory:0:
;**********************************************************************
;*********  allocate memory

allocatemem:
 mov bx,22*512/16+8
 mov ah,048h ;Allocate memory
 int 21h ;Universal DOS function

if debug
 cmp ax,7 ;error?
 jz allocationerror
 cmp ax,8 ;error?
 jz allocationerror
endif

 mov cs:TrackSegment,ax
 ret

if debug
allocationerror:
 mov di,offset allocerror
 call printline

 jmp realterminate
endif

;...e
;...sTerminate:0:
;*************************************************************************
;********  terminate - unhooks disc base table

terminate:
 mov dx,[olddbaddress]    ;used new one
 mov ax,[olddbsegment]
 mov bx,ax
 or  bx,dx
 jz  realterminate
 mov ds,ax
 mov ax,0251Eh
 int 21h

realterminate:
 mov ah,04Ch
 int 21h

;...e

;** Keyboard Handler
;...sClear Buffer:0:
;**********************************************************************
;*********  clearbuffer  -  clears input buffer

clearbuffer:
 mov bx,offset inputbuffer
 mov cx,linelength
 mov al,020h
clearloop:
 inc bx
 mov [bx],al
 loop clearloop
 ret

;...e
;...sGet Line:0:
;**********************************************************************
;*********  getline -  gets line of text

getline:
 mov dx,offset inputbuffer
 mov bx,dx
 mov al,linelength
 mov [bx],al    ;set line length
 mov ah,0ah
 int 21h

 mov bx,offset inputbuffer
 inc bx
 mov al,[bx]
 or al,al
 jne getline2     ;checked for null input

; mov bx,offset promptmessage
; call printline
 jmp short getline

getline2:
 inc bx         ;point to first byte
 mov al,[bx]    
 cmp al,20h     ;strip leading spaces
 je getline2

 ret

;...e
;...sGet Key:0:
;**************************************************************************
;********  get key

getkey:
 xor ah,ah
 int 16h
 cmp al,3
 je ctrlc
 ret

ctrlc:
 jmp terminate

;...e

;** Printing Handler
;...sPrint Error:0:
;*********  prints error message
; ah - error code

if debug

printerror:
 mov al,ah          ;error code in ah
 xor ah,ah
 cmp ax,0Dh
 jb normalerror

 mov bx,offset crcerror
 cmp ax,10h
 je printmessage

 mov bx,offset failcontroller
 cmp ax,20h
 je printmessage

 mov bx,offset failseek
 cmp ax,40h
 je printmessage

 mov bx,offset timeout
 cmp ax,80h
 je printmessage

 mov bx,offset someerror
 jmp short printmessage

normalerror:
 shl ax,1
 mov si,offset messageptr
 add si,ax
 mov bx,ds:[si]     ;get start of message in bx

printmessage:
 call printline
 mov al,0Dh
 call printchar
 mov al,0Ah
 jmp printchar      ;exit

endif

;...e
;...sPrint Line:0:
;********  prints line of text
; bx - address start

printline:
 mov al,ds:[bx]     ;get character
 or al,al
 jnz printline2
 ret
printline2:
 call printchar
 inc bx
 jmp short printline

;...e
;...sPrint Char:0:
;********  print character
; al - character number

printchar:
 push bx
 mov bx,00007h
 mov ah,00Eh
 int 10h
 pop bx
 ret

;...e

;** Variables
;...sVariables:0:
;*************************************************************************
;********  variables

even

;for formatting
maxsectors dw 0
drive      db 0
trys       db 0

;for disc base table
olddbaddress  dw 0
olddbsegment  dw 0

;generalinfo
maxtracks   db 0
discnumber  db 0

;splitinfo
currenttrack    db 0

;writeinfo
writeside       db 0
writetrack      db 0
writesector     db 0
writenumber     db 0

 even

;allocinfo
tracksegment    dw 0

;openinfo
handle          dw 0
endmarker       db 0

 even

;length info
lumplength	dw 0
lowlength	dw 0
highlength	dw 0

lastdrive	db 0

;*************************************************************************
;********  lists
even

discbasetable     db 0CFh,002h,025h,002h,009h
                  db 010h,0FFh,020h,0F6h,001h
                  db 004h


;...e
;...sError Text:0:
if debug

;********
even

messageptr  dw noerror         ;0
            dw badcommand      ;1
            dw nomark          ;2
            dw nowrite         ;3
            dw nosector        ;4
            dw harderror ;noreset     ;5
            dw nodisc          ;6
            dw harderror ;badtable    ;7
            dw dmaover         ;8
            dw dmacross        ;9
            dw harderror ;badsectflag ;A
            dw harderror ;badtrkflag  ;B
            dw nomedia         ;C

;********
even

fileptr     dw noerror
            dw nofile
            dw nopath
            dw nohandle
            dw noaccess
            dw badhandle
            dw badblocks
            dw nomemory
            dw badaddress
            dw badenviro
            dw badformat
            dw badaccesss
            dw baddata
            dw noerror
            dw baddrive
            dw baddir
            dw baddevice
            dw morefiles

;********
even

noerror     db 'No error',0
badcommand  db 'Invalid Command',0
nomark      db 'No address mark',0
nowrite     db 'Write protected',0
nosector    db 'Sector not found',0
nodisc      db 'Floppy disc removed',0
dmaover     db 'DMA overrun',0
dmacross    db 'DMA crossed boundary',0
nomedia     db 'Media type not found',0
crcerror    db 'CRC error',0
failcontroller    db 'Controller failed',0
failseek    db 'Seek failed',0
timeout     db 'Disc not responding',0
harderror   db 'Hard disc error',0
someerror   db 'Some error',0

nofile      db 'File not found',0
nopath      db 'Path not found',0
nohandle    db 'No handle available',0
noaccess    db 'Access denied',0
badhandle   db 'Invalid handle',0
badblocks   db 'Memory destroyed',0
nomemory    db 'Insufficient memory',0
badaddress  db 'Invalid memory address',0
badenviro   db 'Invalid environment',0
badformat   db 'Invalid format',0
badaccesss  db 'Invalid access',0
baddata     db 'Invalid data',0
baddrive    db 'Invalid drive',0
baddir      db 'Bad attempt',0
baddevice   db 'Bad device',0
morefiles   db 'More files',0

allocerror  db 'Memory allocation error',0

endif
;...e
;...sMessage Text:0:
l9name     	  db 'Level 9 '

titlemessage      db 0dh,0ah
                  db 'Installing data on hard disc',0dh,0ah,0

InsertMessage     db 0dh,0ah
		  db 'Insert disc number '
insertnumber	  db '0'
		  db ' in disc drive',0

pressakey         db 0dh,0ah,'Press a key',0

spacemessage	  db 0dh,'            ',0dh,0

endmessage        db 0dh,0ah
	          db 'Installation finished',0dh,0ah,0

if debug
notl9disc	  db 0dh,0ah
		  db 'Not a Level 9 disc!',0dh,0ah,0
endif




;...e

;...sBuffers:0:
;***********************************************************************
;********  input buffer reservation

linelength = 20h

inputbuffer db linelength+5 dup (0)
            db 0FFh          ;endstop

;******** blank sector

blanksector db 530 dup (0)

;********
;...e

;...e

code ends

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
