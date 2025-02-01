 page 128,122 ;length,width
;IBM KAOS adventure system. memory allocator/loader

;INSTALL.ASM

;Copyright (C) 1989 Level 9 Computing

;-----

;Source for INSTALL.BIN; when MENU.EXE is run it checks for an installer
;present in the current directory. If it's missing defaults are assumed.

;This version of INSTALL.BIN scans the current directory and all
;sub directories recursively to find up to a maximum of ten *.BIN
;files (but not INSTALL.BIN). If only one file is found this must
;be the HEADER.BIN file. Otherwise a keyboard choice is offered
;and the selected file loaded in place of HEADER.BIN.

;-----

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
; include consts.asm

;...e

;...sPublics and externals:0:

 public BothGetChar ;*
 public VectorTerminate ;*
 extrn SetUpConfig:near ;*
 extrn CurrentVideoModeNumber:byte ;*
 extrn CurrentVideoName:byte ;*

;...e

;-----

;           Either   Signed   Unsigned
;    <=              jle      jbe
;    <               jl       jb/jc
;    =      je/jz
;    <>     jnz/jne
;    >=              jge      jae/jnc
;    >               jg       ja

;-----

 name install

code segment public 'code'

 assume cs:code
 assume ds:code

;-----

DTALength=43                ;MS-DOS workspace length
MaxDepth=4                  ;max depth of sub directories
MaxPathLength=60            ;max length of path+filename
MaxFiles=10                 ;max number of files to find

;...sParameter/communication area:0:

 jmp start
 jmp InstallEntry

AuxMode db 0                ;SCREEN type ;driver dependant
 db 0                       ;Reserved for SPEAKER type (0=no sound)
 db 0                       ;Reserved for KEYBOARD type (0=PC)
 db 0                       ;Reserved for JOYSTICK type (0=none)
 db 0                       ;Reserved for MOUSE type ;(0=none)
DriverFileName = this byte
 db MaxPathLength dup (0)   ;Asciiz filename of DRIVER.BIN

VectorGetChar dd 0
VectorTerminate dd 0

;...e

;----

;...sVariables:0:

DiskTransferArea = this byte
 rept MaxDepth
             db DTALength dup(0)     ;MS-DOS workspace for FILE SEARCH
 endm ;rept
WhichDTA     dw 0                    ;address of current DiskTransferArea
PathName     db MaxPathLength dup(0) ;Current path+wildcards
             db 11 ;safety
BinList = this byte
    db MaxFiles*MaxPathLength dup(0) ;list of BIN files found
Digit        db 0                    ;ascii key stroke for NEXT filename
WhichBinList dw 0                    ;address to store NEXT filename

;...e 

;-----

;...sSubroutines:0:
 
start:                      ;Stand alone entry point
 call Installer

 mov ah,04Ch                ;Terminate process
 int 21h                    ;DOS Function

;-----

InstallEntry:
 call Installer
 retf

;-----

Installer:
 mov ax,cs
 mov ds,ax
 mov es,ax

 mov ds:Digit,'1'
 mov ds:WhichBinList,offset BinList
 mov ds:WhichDTA,offset DiskTransferArea ;current level search
 mov si,offset WildCard     ;set initial path name = current dir
 mov di,offset PathName
 mov cx,LengthWildCard
 rep movsb






 mov ax,0 ;segment - use default
 mov bx,0 ;offset  - use default
 mov cx,0 ;no load, no save
 call SetUpConfig                  ;*

 mov si,offset CurrentVideoName    ;*
 mov di,offset DriverFileName      ;*
 mov ax,cs                         ;*
 mov ds,ax                         ;*
 mov es,ax                         ;*
 mov cx,MaxPathLength              ;*
 rep movsb                         ;*

 mov al,cs:CurrentVideoModeNumber  ;*
 mov cs:AuxMode,al                 ;*






;* mov bx,offset Welcome
;* call DisplayVisibleString

;* call SearchDirectory

;* cmp ds:Digit,'1'
;* je sorry                   ;No BIN files found

;* cmp ds:Digit,'2'
;* je OneFile                 ;Only the one file

;* mov bx,offset AskFile
;* call DisplayVisibleString

;*AskAgain:
;* call BothGetChar

;* cmp al,'0'
;* jl AskAgain
;* jne notten
;* mov al,':'
;*notten:
;* cmp al,ds:Digit
;* jae AskAgain

;* mov si,offset BinList
;* mov dx,MaxPathLength
;* mov ah,0
;* sub al,'1'
;* mul dx
;* add si,ax ;filename
;* jmp short CopyFileName     ;Copy selected file

;*OneFile:                    ;Only the one file
;* mov si,offset BinList

;*CopyFileName:
;* mov di,offset DriverFileName
;* mov cx,MaxPathLength
;* rep movsb

;* mov al,0Dh
;* call DisplayVisible
;* mov al,0Dh
;* call DisplayVisible

 ret

sorry:
 ret

;-----

BothGetChar:
 mov ax,word ptr cs:VectorGetChar
 cmp ax,0
 je getchar
 call dword ptr cs:VectorGetChar
 ret

GetChar:
;* mov ah,1 ;keyboard input
;* int 21h                    ;DOS Function
 ret

;-----

SearchDirectory:
 mov dx,ds:WhichDTA
 mov ah,01Ah                ;Set Disk Transfer Area
 int 21h                    ;DOS Function

 mov dx,offset PathName     ;filename "*.*"
 mov cx,10h                 ;attributes, normal files + directories
 mov ah,4Eh                 ;Find First
 int 21h                    ;DOS Function
NextFile:
 jnc CheckFile
 ret                        ;No more files

CheckFile:
 mov si,ds:WhichDTA
 mov al,ds:21[si]           ;attribute
 test al,10h
 jnz directory              ;go search sub directory

 add si,30 ;filename
 mov bx,0
searchterminator:
 mov al,ds:[si+bx]
 cmp al,0
 je terminator
 inc bx
 jmp short searchterminator
terminator:
 cmp bx,4 ;path at least 4 characters?
 jl notbin
 sub bx,4
 cmp byte ptr ds:0[si+bx],'.'
 jne notbin
 cmp byte ptr ds:1[si+bx],'B'
 jne notbin
 cmp byte ptr ds:2[si+bx],'I'
 jne notbin
 cmp byte ptr ds:3[si+bx],'N'
 jne notbin

 cmp bx,7
 jb notinstall
 sub bx,7
 cmp byte ptr ds:0[si+bx],'I'
 jne notinstall
 cmp byte ptr ds:1[si+bx],'N'
 jne notinstall
 cmp byte ptr ds:2[si+bx],'S'
 jne notinstall
 cmp byte ptr ds:3[si+bx],'T'
 jne notinstall
 cmp byte ptr ds:4[si+bx],'A'
 jne notinstall
 cmp byte ptr ds:5[si+bx],'L'
 jne notinstall
 cmp byte ptr ds:6[si+bx],'L'
 je notbin

notinstall:
 call ProcessBIN
 jmp EndFile

directory:
 call ProcessDirectory

EndFile:
 cmp ds:digit,'0'+MaxFiles+1
 jne notbin
 ret                        ;too many files

notbin:
 mov ah,4Fh                 ;Continue File Search
 int 21h                    ;DOS Function
 jmp NextFile

;-----

ProcessBIN:
 cmp ds:digit,'9'
 ja ten
; mov al,' '
; call DisplayVisible        ;Display digit
 mov al,ds:digit
 call DisplayVisible        ;Display digit
 jmp short bracket
ten:
; mov al,'1'
; call DisplayVisible        ;Display digit
 mov al,'0'
 call DisplayVisible        ;Display digit

bracket:
 mov bx,offset delimeter
 call DisplayVisibleString

 mov si,offset PathName
 mov di,ds:WhichBinList     ;Save filename to BinList
 mov bx,0
copypath1:
 mov al,ds:[si+bx]
 cmp al,'*'
 je copiedpath
 mov ds:[di],al
 inc bx
 inc di
 jmp short copypath1
copiedpath:
 mov si,ds:WhichDTA
 add si,30
copyname:
 mov al,ds:[si]
 mov ds:[di],al
 cmp al,0
 je copiedname
 inc si
 inc di
 jmp short copyname

copiedname:
 mov bx,ds:WhichBinList
 call DisplayVisibleString

 add ds:WhichBinList,MaxPathLength
 inc ds:digit
 mov al,0Dh
 call DisplayVisible
 ret

;-----

ProcessDirectory:
 cmp ds:WhichDTA,offset DiskTransferArea+((MaxDepth-1)*DTALength)
 jne DirectoryGo
 ret                        ;search depth too deep

DirectoryGo:
 mov di,offset PathName
findwild:
 cmp byte ptr ds:[di],'*'   ;file start of wild-card
 je foundwild
 inc di
 jmp short findwild
foundwild:

 mov si,ds:WhichDTA
 add si,30                  ;directory filename
 cmp byte ptr ds:[si],'.'
 jne pathok
 cmp byte ptr ds:1[si],0
 je illegalpath             ;exclude "."
 cmp byte ptr ds:1[si],'.'
 jne pathok
 cmp byte ptr ds:2[si],0
 je illegalpath             ;exclude ".."

pathok:
 push di                    ;save path length

copypath2:
 mov al,ds:[si]
 mov ds:[di],al
 inc si
 inc di
 cmp al,0
 jne copypath2
 dec di
 mov byte ptr ds:[di],'\'
 inc di
 mov si,offset WildCard
 mov cx,LengthWildCard
 rep movsb

 mov ax,ds:WhichDTA
 push ax
 add ds:WhichDTA,DTALength  ;step to use a new DTA

 call SearchDirectory
 
 pop dx
 mov ds:WhichDTA,dx         ;restore search position
 mov ah,01Ah                ;Set Disk Transfer Area
 int 21h                    ;DOS Function

 pop di                     ;restore path length
 mov si,offset WildCard
 mov cx,LengthWildCard
 rep movsb

illegalpath:
 ret

;-----

;              1234567890123456789012345678901234567890
Welcome:   db 13
           db "INSTALL.BIN Copyright (C) 1989 Level 9",13
           db 13
           db "For DEMO disks delete INSTALL.BIN",13
           db 13
           db "Searching disk...",13,13,0
delimeter: db ") ",0
AskFile:   db 13,13,"Which driver (0-9)? ",0

;-----

WildCard db "*.*",0
LengthWildCard = this byte - WildCard

;-----

;cs:bx=message, dh=row, dl=column
DisplayVisibleString:
 mov ax,cs
 mov ds,ax

da01:
 mov al,ds:[bx]
 cmp al,'$'
 je da02
 cmp al,0
 je da02
 call DisplayVisible
 inc bx
 jmp short da01
da02:
 ret

;----

;Display al in logical colour 1 (CGA bright white, EGA blue/white)
DisplayVisible:
 push bx

 cmp al,0Dh
 jne dv01

 mov ah,0Eh                 ;Write Character as TTY
 mov bx,7                   ;page=0, colour=7
 int 10h                    ;Video Service
 mov al,0Ah

dv01:
 mov ah,0Eh                 ;Write Character as TTY
 mov bx,7                   ;page=0, colour=7
 int 10h                    ;Video Service

 pop bx
 ret

;-----

;...e

 code ends

;-----

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################

