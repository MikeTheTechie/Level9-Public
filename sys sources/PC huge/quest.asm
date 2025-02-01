;IBM animated adventure system installer 

;Quest.asm

;Copyright (C) 1989 Level 9 Computing

;-----


;...sInclude files:0:
;These include files must be named in MAKE.TXT:
; include consts.asm

;...e

;...sPublics and externals:0:
public FileSeg
public FileOffset
public PrintText
public SetUpConfig
public CurrentVideoModeNumber ;*
public CurrentVideoName ;*

 extrn BothGetChar:near ;*
 extrn VectorTerminate:dword ;*
;*extrn CopyFiles:near

;...e


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


;...sSubroutines:0:
;!! Constants
;...sConstants:0:
;!! Production constants

 VersionNumber=1

;also change Pathname in layout definition



;!! Testing

 BINFILE=0	;0 - running as EXE file,  1 - running as BIN file

;...e


;!! Entry Parameters
;...sParameters:0:
;!!  Entry Parameters

; ax - layout segment
; bx - layout offset

; cx - layout action
; bit0	0 - don't load config file
;	1 - load config file
; bit1	0 - don't save config file
;	1 - save config file



;...e


;!! Main Program
;...sMain Program:0:
start:
 call SetUpConfig
 jmp Terminate

;-----

;* Changed ",[bp" to ",ds:[bp"

SetUpConfig:
 mov bp,cs
 mov ds,bp

;...sFind video address and set mode accordingly:0:

 ife BINFILE

 xor ax,ax	;running as EXE file - use internal Layout
 mov bx,ax
 mov cx,3

 endif


 push ax	;layout segment
 push bx	;layout offset
 mov Action,0 ;* mov Action,cx

 xor ax,ax
 mov es,ax

 mov ax,es:[0463h]
 cmp ax,03D4h
 jne MonochromeSetMode

 mov ax,0003h
 int 10h

 mov word ptr ScreenSeg,0B800h
 mov byte ptr LineAttrib,04h
 mov byte ptr NormalAttrib,007h
 mov byte ptr InvertAttrib,070h
 mov byte ptr BrightAttrib,00Fh

 jmp short Setmode

MonochromeSetmode:

 mov ax,0007h
 int 10h

 mov word ptr ScreenSeg,0B000h
 mov byte ptr LineAttrib,0Fh
 mov byte ptr NormalAttrib,007h
 mov byte ptr InvertAttrib,070h
 mov byte ptr BrightAttrib,00Fh

SetMode:
 mov ah,2
 mov bh,0
 mov dx,01900h
 int 10h		;hide cursor

 pop bx
 pop ax

 cmp ax,0	;segment zero - internal config file
 jne ExternalConfig

 mov ax,cs
 mov bx,offset Layout

ExternalConfig:
 mov FileSeg,ax
 mov FileOffset,bx


;...e

;...sLoad configuration:0:
;!! Load configuration

 test word ptr action,1
 jne LoadConfiguration

BadConfigurationFile:
 mov ax,cs
 cmp ax,FileSeg
 jne MoveLayout
 jmp LoadingFinished

MoveLayout:
 mov es,FileSeg
 mov di,FileOffset
 mov si,offset Layout
 mov cx,LayoutLength

 rep movsb

 jmp LoadingFinished

LoadConfiguration:

 mov dx,offset FileName
 mov ax,03d00h
 int 21h	;open file

 jc BadConfigurationFile

 mov handle,ax
 
 mov bx,ax
 mov cx,LayoutLength
 mov dx,offset FileBuffer
 mov ax,03F00h
 int 21h

 jc  BadConfigurationRead

 mov si,offset FileBuffer
 add si,LayoutVersion
 cmp word ptr [si],VersionNumber
 jne BadConfigurationRead

 mov es,FileSeg
 mov di,FileOffset
 mov si,offset FileBuffer
 mov cx,LayoutLength

 rep movsb

 mov bx,handle
 mov ax,03E00h
 int 21h

 jmp LoadingFinished

BadConfigurationRead:
 mov bx,handle
 mov ax,03E00h
 int 21h

 jmp short BadConfigurationFile

LoadingFinished:


;...e

;...sOpening screen:0:
;!! print top box
 xor al,al
 mov bl,al
 mov cx,80
 mov si,offset TopBoxText 
 call PrintText

;!! print information box
 xor al,al
 mov bl,03
 mov cx,80
 mov si,offset InfoBoxText 
 call PrintText

 call getkeypress

;!! print left box
 xor al,al
 mov bl,03
 mov cx,29
 mov si,offset LeftBoxText 
 call PrintText

;!! print right box
 mov al,29
 mov bl,03
 mov cx,51
 mov si,offset VideoBoxText 
 call PrintText

;!! print help box
 mov al,29
 mov bl,16
 mov cx,51
 mov si,offset HelpBoxText 
 call PrintText

;...e

;...sExtract information:0:
 mov es,FileSeg
 mov di,FileOffset
 add di,LayoutExitNumber
 mov word ptr es:[di],0

 mov di,FileOffset
 add di,LayoutInstallNumber
 mov word ptr es:[di],0

ExtractInformation:
 mov si,StackPointer
 mov bl,[si+2]		;choice
 mov si,[si]		;offset to info

ExtractInformation1:
 call UpdatePanel
 inc bl
 cmp bl,[si+7]
 jbe ExtractInformation1

;...e

;...sGet selections:0:
 mov al,1
 mov bl,6
 mov cl,25
 mov dl,1
 mov dh,InvertAttrib
 call ChangeText

GetWindowInfo:
 mov si,StackPointer
 mov bl,[si+2]		;choice
 mov si,[si]		;offset to info

MainGetLoop:
 call GetKeyPress

 mov KeyPressed,ax

 cmp ax,05000h		;down arrow
 je  downarrow
 cmp al,'2'
 jne uptest
downarrow:
 cmp bl,[si+7]
 je  MainGetLoop
 inc bl
 call DealWindow
 jmp short MainGetLoop

uptest:
 cmp ax,04800h		;up arrow
 je  uparrow
 cmp al,'8'
 jne righttest
uparrow:
 cmp bl,1
 je  MainGetLoop
 dec bl
 call DealWindow
 jmp short MainGetLoop

righttest:
 cmp ax,04D00h		;right arrow
 je  rightarrow
 cmp al,'6'
 jne lefttest
rightarrow:
 cmp byte ptr [si+7],0
 je  MainGetLoop
 call DownWindow
 jmp short MainGetLoop
 
lefttest:
 cmp ax,04B00h		;left arrow
 je  leftarrow
 cmp al,'4'
 jne rettest
leftarrow:
 cmp StackPointer,offset StackBit
 je  MainGetLoop
 call UpWindow
 jmp short MainGetLoop
 
rettest:
 cmp al,0dh
 jne KeyboardTest

 jmp FinishInput ;*
;* mov es,FileSeg
;* mov di,FileOffset
;* add di,LayoutExitname

;* cmp word ptr es:[di],00001h
;* jne Return2Test

;* cmp StackPointer,offset StackBit+StackLump
;* jne Return2Test

;* mov bp,offset LeftBoxInfo
;* mov al,ds:[bp+7]
;* mov bp,offset StackBit
;* cmp ds:[bp+2],al
;* je  FinishInput
;* jmp short RealReturn

;*Return2Test:
;* mov di,FileOffset
;* add di,LayoutInstallNumber
;* cmp byte ptr es:[di],002h
;* jne RealReturn

;* cmp StackPointer,offset StackBit+StackLump
;* jne RealReturn

;* mov bp,offset LeftBoxInfo
;* mov al,ds:[bp+7]
;* dec al			;penultimate one
;* mov bp,offset StackBit
;* cmp ds:[bp+2],al
;* jne RealReturn

;* call getvariable

;*RealReturn:
;* call DownWindow

;* jmp MainGetLoop

 
KeyboardTest:
 cmp byte ptr [si+8],'L'
 jne KeyboardTest2

 and al,01Fh
 jz  EndKeyboardTest

 cmp al,[si+7]
 ja  EndKeyboardTest

 mov bl,al
 call DealWindow


KeyboardTest2:
EndKeyboardTest:
 jmp MainGetLoop


FinishInput:



;...e

;...sSave configuration:0:
;!! Save configuration

 test word ptr action,2
 je SavingFinished


 mov dx,offset FileName
 xor cx,cx
 mov ah,03Ch
 int 21h	;create/open file

 jc SavingFinished

 mov handle,ax
 
 mov bx,ax
 mov cx,LayoutLength
 mov dx,FileOffset
 mov ds,FileSeg
 mov ax,04000h
 int 21h

 mov ax,cs
 mov ds,ax

 mov bx,handle
 mov ax,03E00h
 int 21h

SavingFinished:


;...e

;...scall copier:0:
;!! CopyFiles

;* call CopyFiles

;...e

 ret ;**********

;...sTerminate process:0:
Terminate:
 mov ah,04Ch ;Terminate process
 int 21h
 jmp Terminate
;...e

;...e


;!! Subroutines
;...sPrintText:0:
;!!  Print Text to Screen

PrintText:
 mov es,ScreenSeg

 cmp si,0
 je  PrintCharLine2

 xor ah,ah
 mov bh,ah
 mov ch,ah
 shl bl,1
 mov di,[bx+offset ScreenTable]
 shl ax,1
 add di,ax
 mov dx,cx

PrintCharLine:
 lodsb
 cmp al,0
 je  PrintCharLine2
 cmp al,80h
 jae NotCharacter
 mov ah,NormalAttrib
 stosw
 loop PrintCharLine
 jmp short PrintCharLine1

NotCharacter:
 mov ah,LineAttrib
 stosw
 loop PrintCharLine

PrintCharLine1:
 mov cx,dx	;restore cx
 sub di,cx
 sub di,cx
 add di,160
 jmp short PrintCharLine

PrintCharLine2:
 ret

;...e
;...sPrintChar:0:
;!!  Print Char to Screen

PrintChar:
 mov es,ScreenSeg

 xor ah,ah
 mov bh,ah
 shl bl,1
 mov di,[bx+offset ScreenTable]
 shl ax,1
 add di,ax

 mov es:[di],cl

 ret

;...e
;...sChangeText:0:
;!!  Change Text on Screen

ChangeText:
 mov es,ScreenSeg

 xor ah,ah
 mov bh,ah
 mov ch,ah
 jcxz ChangeTextReturn

ChangeCharLine:
 push ax
 push bx
 push cx

 shl bx,1
 mov di,[bx+offset ScreenTable]
 shl ax,1
 add di,ax
 mov al,dh

ChangeCharLine2:
 inc di
 stosb
 loop ChangeCharLine2

 pop cx
 pop bx
 pop ax

 inc bx

 dec dl
 jnz ChangeCharLine

ChangeTextReturn:
 ret

;...e
;...sGetKeyPress:0:
;!! Get key press

GetKeyPress:
 push bx
 push cx
 push dx
 push bp
 push si
 push di
 push ds
 push es
 call BothGetChar ;*
 pop es
 pop ds
 pop di
 pop si
 pop bp
 pop dx
 pop cx
 pop bx

;* xor ah,ah	;get key press
;* int 16h

 cmp al,01Bh
 je  Escaped

 ret

Escaped:
 call cs:VectorTerminate ;*
;* jmp Terminate

;...e
;...sDealWindow:0:
;!!  Deals with Window

DealWindow:
 push si

 cmp bl,0FFh
 jne DealWIndow0

 call FindVariable

DealWindow0:

 push bx

 mov bp,StackPointer
 mov al,ds:[bp+ThisXpos]
 mov bl,ds:[bp+ThisYpos]
 mov cl,ds:[bp+ThisWidth]
 mov dl,ds:[bp+ThisHeight]
 mov dh,NormalAttrib
 
 call ChangeText

 pop bx
 push bx

 dec bl		;count from 0 upwards

 xor bh,bh
 shl bx,1
 mov ax,bx
 shl bx,1
 add bx,ax
 add bx,9	;point to start of relevant y line info

 mov al,[si+bx]
 mov ah,[si+bx+1]
 mov cl,[si+bx+2]
 mov dl,[si+bx+3]
 mov si,[si+bx+4]	;for print text
 mov bl,ah

 mov ds:[bp+ThisXpos],al
 mov ds:[bp+ThisYpos],bl
 mov ds:[bp+ThisWidth],cl
 mov ds:[bp+ThisHeight],dl
 mov dh,InvertAttrib

 call ChangeText

 mov bp,si

 cmp bp,0
 je DealWindow1

 mov al,ds:[bp+2]
 mov bl,ds:[bp+3]
 mov cl,ds:[bp+4]
 mov si,ds:[bp+5]

 call PrintText

DealWindow1:
 pop bx
 pop si

;!! Do variable

 push si

 mov si,bp
 mov si,[si]
 cmp si,0
 je  NoVariable

 mov di,[si]
 add di,FileOffset
 add si,2

 mov es,FileSeg

 mov al,bl
 stosb		;write variable number

MoveVariable:
 lodsb
 cmp al,0
 je  LastZero 
 stosb		;write variable name
 jmp short MoveVariable

LastZero:
 stosb

NoVariable:
 pop si

 ret




;...e
;...sDownWindow:0:
;!!  Down Window

DownWindow:

 push bx

 mov bp,StackPointer
 mov ds:[bp+ThisChoice],bl

 add bp,StackLump

 dec bl		;count from 0 upwards

 xor bh,bh
 shl bx,1
 mov ax,bx
 shl bx,1
 add bx,ax
 add bx,13	;point to next window

 mov di,[si+bx]

 pop bx

 cmp byte ptr [di+7],0
 je DownWindowReturn

 mov si,di
 mov StackPointer,bp

 mov ds:[bp+ThisBox],si
 mov byte ptr ds:[bp+ThisChoice],0
 mov byte ptr ds:[bp+ThisWidth],0	;cancel normalisation of text

 mov al,ds:[bp+ThisXpos-StackLump]
 mov bl,ds:[bp+ThisYpos-StackLump]
 mov cl,ds:[bp+ThisWidth-StackLump]
 mov dl,ds:[bp+ThisHeight-StackLump]
 mov dh,BrightAttrib
 call ChangeText

 mov bl,0FFh

 call DealWindow

 ret

DownWindowReturn:
 cmp byte ptr KeyPressed,0Dh
 jne DownWindowReturn2

 mov bp,offset StackBit
 mov StackPointer,bp

 mov si,ds:[bp+ThisBox]
 mov bl,ds:[bp+ThisChoice]

 cmp bl,[si+7]
 jae DownWindowReturn1

 inc bl

DownWindowReturn1:
 call DealWindow

DownWindowReturn2:
 ret


;...e
;...sUpWindow:0:
;!!  Up Window

UpWindow:

 mov bp,StackPointer
 sub bp,StackLump
 mov StackPointer,bp

 mov si,ds:[bp+ThisBox]
 mov bl,ds:[bp+ThisChoice]

 call DealWindow

 ret


;...e
;...sFindVariable:0:
;!!  FindVariable

FindVariable:
 mov bp,[si+13]

 mov bp,ds:[bp]
 cmp bp,0
 je  NoFindVariable

 mov bp,ds:[bp]
 add bp,FileOffset

 mov es,FileSeg
 mov bl,es:[bp]

 cmp bl,0
 je  NoFindVariable
 ret

NoFindVariable:
 mov bl,1
 ret




;...e
;...sUpdatePanel:0:
;!!  Update Panel

UpdatePanel:
 push bx
 push si

 dec bl		;count from 0 upwards

 xor bh,bh
 shl bx,1
 mov ax,bx
 shl bx,1
 add bx,ax
 add bx,13	;point to next window

 mov si,[si+bx]

 cmp byte ptr [si+7],0
 je  UpdatePanelReturn

 call FindVariable

 dec bl		;count from 0 upwards

 xor bh,bh
 shl bx,1
 mov ax,bx
 shl bx,1
 add bx,ax
 add bx,13	;point to start of relevant y line info

 mov si,[si+bx]	;for print text

 cmp si,0
 je  UpdatePanelReturn

 mov al,[si+2]
 mov bl,[si+3]
 mov cl,[si+4]
 mov si,[si+5]

 call PrintText

UpdatePanelReturn:
 pop si
 pop bx
 ret


;...e
;...sGetVariable:0:
;!! Alphanumeric typed

GetVariable:

 push bx

 mov bp,StackPointer
 mov al,ds:[bp+ThisXpos]
 mov bl,ds:[bp+ThisYpos]
 mov cl,ds:[bp+ThisWidth]
 mov dl,ds:[bp+ThisHeight]
 mov dh,BrightAttrib
 call ChangeText

 mov al,61
 mov bl,10
 mov cl,1
 mov dl,1
 mov dh,InvertAttrib
 call ChangeText

GetVariableKeyPress:
 call getkeypress

 cmp al,0dh
 je GetVariableReturn

 and al,05Fh
 cmp al,'A'
 jb  GetVariableKeyPress
 cmp al,'Z'
 ja  GetVariableKeyPress

 mov cl,al
 mov al,61
 mov bl,10
 call PrintChar

 mov bp,[si+19]
 mov di,ds:[bp+5]		;alter text
 mov [di],cl

 mov di,ds:[bp]		;alter variable
 mov [di+2],cl
 mov es,FileSeg
 mov di,[di]
 add di,FileOffset
 mov [di+1],cl

 push si

 mov al,ds:[bp+2]
 mov bl,ds:[bp+3]
 mov cl,ds:[bp+4]
 mov si,ds:[bp+5]
 call PrintText

 pop si

 jmp short GetVariableKeyPress


GetVariableReturn:
 pop bx
 ret

;...e


;!! Text
;...sText:0:
;!! Text definitions

;...sTop Box:0:
;!! Top box

TopBoxText:

 db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
 db '³ Level 9 Animated Adventure Installer              (C) 1989 Level 9 Computing ³'
 db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
 db 0

;...e
;...sInfo Box:0:
;!! Info box

InfoBoxText:

 db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
 db '³                                                                              ³'
 db '³                Welcome to Animated Adventures from Level 9                   ³'
 db '³                                                                              ³'
 db '³  For optimum performance of the game on your PC system, please ensure that   ³'
 db '³  you choose the best configuration available to you. The following tips      ³'
 db '³  should help you choose.                                                     ³'
 db '³                                                                              ³'
 db '³  Video system: VGA and MCGA offer better colours than the other 16 colour    ³'
 db '³                modes. If you have a slow PC, then use CGA modes for colour   ³'
 db '³                systems. Monochrome systems run as fast as possible.          ³'
 db '³                                                                              ³'
;* db '³  Hard disc   : It is highly recommended that you install the game onto your  ³'
 db '³  Hard disc   : It is highly recommended that you copy the game onto your     ³' ;*
 db '³                hard disc. This significantly speeds up disc accesses and     ³'
 db '³                helps the continuity of the game.                             ³'
 db '³                                                                              ³'
;* db '³  Disc backups: You are allowed to make copies for your own use only. The     ³'
;* db '³                program BACKUP is supplied so that you can do this.           ³'
 db '³                                                                              ³' ;*
;* db '³                                                                              ³' ;*
 db '³                                                                              ³' ;*
 db '³                                                                              ³'
 db '³           <Press any key to continue installation or ESC to exit>            ³'
 db '³                                                                              ³'
 db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
 db 0

;...e
;...sHelp Box:0:
;!! Help box

HelpBoxText:

 db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
;* db '³ Use the cursor keys to locate the highlight bar ³'
;* db '³ in the "Current choices" box, then RIGHT ARROW  ³'
;* db '³ to put the highlight bar in the "Selection" box.³'
;* db '³ Type either the letter of your selection or use ³'
;* db '³ the cursor keys to highlight your selection then³'
;* db '³ press ENTER to change the current choice.       ³'
;* db '³ Press ESC to abort installation at any time     ³'
 db '³ When the  "Current choices"  box indicates the  ³' ;*
 db '³ correct screen mode press ENTER. To change the  ³' ;*
 db '³ screen mode press RIGHT ARROW followed by UP    ³' ;*
 db '³ and DOWN ARROW.                                 ³' ;*
 db '³ Press ESC to return to DOS.                     ³' ;*
 db '³                                                 ³' ;*
 db '³                                                 ³' ;*
 db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
 db 0

;...e

;...sLeft Box:0:
;!! Left box

LeftBoxText:

 db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  '
 db '³ Current choices:        ³  '
 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  '
 db '³ Video System:           ³  '
 db '³                         ³  '
 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  '
 db '³                         ³  ' ;* db '³ Sound System:           ³  '
 db '³                         ³  '
 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  '
 db '³                         ³  ' ;* db '³ Keyboard:               ³  '
 db '³                         ³  '
 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  '
 db '³                         ³  ' ;* db '³ Pointer:                ³  '
 db '³                         ³  '
 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  '
 db '³                         ³  ' ;* db '³ Hard Disc Install:      ³  '
 db '³                         ³  ' ;* db '³ Drive:                  ³  '
 db '³                         ³  ' ;* db '³ Path : \Level9\Grange   ³  '
 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  '
 db '³                         ³  ' ;* db '³ Install configuration   ³  '
 db '³                         ³  ' ;* db '³       and exit          ³  '
 db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  '
 db 0



LeftBoxInfo:
 dw 0	;address of variable
 db 0	;x coord
 db 3	;y coord
 db 29	;width

 dw offset LeftBoxText	;address of text
 db 1 ;*****  db 6	;number of elements
 db ' '

 db 1	;x
 db 6	;y
 db 25	;width
 db 1	;height
 dw offset VideoBoxInfo

;* db 1	;x
;* db 9	;y
;* db 25	;width
;* db 1	;height
;* dw offset SoundBoxInfo

;* db 1	;x
;* db 12	;y
;* db 25	;width
;* db 1	;height
;* dw offset KeyboardBoxInfo

;* db 1	;x
;* db 15	;y
;* db 25	;width
;* db 1	;height
;* dw offset PointerBoxInfo

;* db 1	;x
;* db 18	;y
;* db 25	;width
;* db 1	;height
;* dw offset InstallBoxInfo

;* db 1	;x
;* db 22	;y
;* db 25	;width
;* db 2	;height
;* dw offset ExitBoxInfo


;...e
;...sVideo Box:0:
;!! Video box

VideoBoxText:

 db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
 db '³ Video system selection:                         ³'
 db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
 db '³ A. VGA      16 colour  (PS/2 above model 30)    ³'
 db '³ B. MCGA     16 colour  (PS/2 model 25 and 30)   ³'
 db '³ C. EGA      16 colour  (EGA or CGA monitor)     ³'
 db '³ D. CGA       2 colour                           ³'
 db '³ E. CGA       4 colour                           ³'
 db '³ F. Tandy    16 colour  (Tandy 1000 series)      ³'
 db '³ G. Amstrad  16 colour  (Amstrad 1512 series)    ³'
 db '³ H. Hercules  2 colour                           ³'
 db '³ I. EGA       2 colour  (EGA with MDA monitor)   ³'
 db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
 db 0



VideoBoxInfo:
 dw 0	;address of variable

 db 29	;x coord
 db 3	;y coord
 db 51	;width
 dw offset VideoBoxText	;address of text
 db 9	;number of elements
 db 'L'


 db 30	;x
 db 6	;y
 db 49	;width
 db 1	;height
 dw offset VGAStuffBox

 db 30	;x
 db 7	;y
 db 49	;width
 db 1	;height
 dw offset MCGAStuffBox

 db 30	;x
 db 8	;y
 db 49	;width
 db 1	;height
 dw offset EGAStuffBox

 db 30	;x
 db 9	;y
 db 49	;width
 db 1	;height
 dw offset CGA2StuffBox

 db 30	;x
 db 10	;y
 db 49	;width
 db 1	;height
 dw offset CGA4StuffBox

 db 30	;x
 db 11	;y
 db 49	;width
 db 1	;height
 dw offset TandyStuffBox

 db 30	;x
 db 12	;y
 db 49	;width
 db 1	;height
 dw offset AmstradStuffBox

 db 30	;x
 db 13	;y
 db 49	;width
 db 1	;height
 dw offset HerculesStuffBox

 db 30	;x
 db 14	;y
 db 49	;width
 db 1	;height
 dw offset EGA2StuffBox






;!! VGA
VGAStuffBox:
 dw offset VGABoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset VGAStuffBoxText	;address of text
 db 0	;number of elements
 db ' '

VGAStuffBoxText:
 db 'VGA 16 colour    ',0
VGABoxVars:
 dw LayoutVideoNumber	;address of variable
 db '1EGA.VID',0


;!! MCGA
MCGAStuffBox:
 dw offset MCGABoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset MCGAStuffBoxText	;address of text
 db 0	;number of elements
 db ' '

MCGAStuffBoxText:
 db 'MCGA 16 colour   ',0
MCGABoxVars:
 dw LayoutVideoNumber	;address of variable
 db '0MCGA.VID',0


;!! EGA
EGAStuffBox:
 dw offset EGABoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset EGAStuffBoxText	;address of text
 db 0	;number of elements
 db ' '

EGAStuffBoxText:
 db 'EGA 16 colour    ',0
EGABoxVars:
 dw LayoutVideoNumber	;address of variable
 db '0EGA.VID',0


;!! CGA2
CGA2StuffBox:
 dw offset CGA2BoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset CGA2StuffBoxText	;address of text
 db 0	;number of elements
 db ' '

CGA2StuffBoxText:
 db 'CGA 2 colour     ',0
CGA2BoxVars:
 dw LayoutVideoNumber	;address of variable
 db '0CGA.VID',0


;!! CGA4
CGA4StuffBox:
 dw offset CGA4BoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset CGA4StuffBoxText	;address of text
 db 0	;number of elements
 db ' '

CGA4StuffBoxText:
 db 'CGA 4 colour     ',0
CGA4BoxVars:
 dw LayoutVideoNumber	;address of variable
 db '1CGA.VID',0


;!! Tandy
TandyStuffBox:
 dw offset TandyBoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset TandyStuffBoxText	;address of text
 db 0	;number of elements
 db ' '

TandyStuffBoxText:
 db 'Tandy 16 colour  ',0
TandyBoxVars:
 dw LayoutVideoNumber	;address of variable
 db '1MCGA.VID',0


;!! Amstrad
AmstradStuffBox:
 dw offset AmstradBoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset AmstradStuffBoxText	;address of text
 db 0	;number of elements
 db ' '

AmstradStuffBoxText:
 db 'Amstrad 16 colour',0
AmstradBoxVars:
 dw LayoutVideoNumber	;address of variable
 db '0AMSTRAD.VID',0


;!! Hercules
HerculesStuffBox:
 dw offset HerculesBoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset HerculesStuffBoxText	;address of text
 db 0	;number of elements
 db ' '

HerculesStuffBoxText:
 db 'Hercules 2 colour',0
HerculesBoxVars:
 dw LayoutVideoNumber	;address of variable
 db '0HERCULES.VID',0


;!! EGA2
EGA2StuffBox:
 dw offset EGA2BoxVars	;address of variable

 db 4	;x coord
 db 7	;y coord
 db 30	;width
 dw offset EGA2StuffBoxText	;address of text
 db 0	;number of elements
 db ' '

EGA2StuffBoxText:
 db 'EGA 2 colour     ',0
EGA2BoxVars:
 dw LayoutVideoNumber	;address of variable
 db '1HERCULES.VID',0


;...e
;...sSound Box:0:
;!! Sound box

;*SoundBoxText:
;*
;* db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
;* db '³ Sound system selection:                         ³'
;* db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³ A. IBM PC internal speaker                      ³'
;* db '³ B. Tandy 1000 internal speaker                  ³'
;* db '³ C. IBM Music Feature card                       ³'
;* db '³ D. Roland MT-32 Sound module                    ³'
;* db '³ E. Ad Lib Music Synthesiser card                ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
;* db 0
;*
;*
;*SoundBoxInfo:
;* dw 0	;address of variable
;*
;* db 29	;x coord
;* db 3	;y coord
;* db 51	;width
;* dw offset SoundBoxText	;address of text
;* db 5	;number of elements
;* db 'L'
;*
;* db 30	;x
;* db 8	;y
;* db 49	;width
;* db 1	;height
;* dw offset IBMSoundStuffBox
;*
;* db 30	;x
;* db 9	;y
;* db 49	;width
;* db 1	;height
;* dw offset TandySoundStuffBox
;*
;* db 30	;x
;* db 10	;y
;* db 49	;width
;* db 1	;height
;* dw offset IBMMusicSoundStuffBox
;*
;* db 30	;x
;* db 11	;y
;* db 49	;width
;* db 1	;height
;* dw offset RolandSoundStuffBox
;*
;* db 30	;x
;* db 12	;y
;* db 49	;width
;* db 1	;height
;* dw offset AdLibSoundStuffBox





;!! IBM PC
;*IBMSoundStuffBox:
;* dw offset IBMSoundBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 10	;y coord
;* db 30	;width
;* dw offset IBMSoundStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*IBMSoundStuffBoxText:
;* db 'IBM PC Speaker     ',0
;*IBMSoundBoxVars:
;* dw LayoutSoundNumber	;address of variable
;* db 'IBMPC.SND',0
;*
;*
;*;!! Tandy
;*TandySoundStuffBox:
;* dw offset TandySoundBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 10	;y coord
;* db 30	;width
;* dw offset TandySoundStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*TandySoundStuffBoxText:
;* db 'Tandy 1000 Speaker ',0
;*TandySoundBoxVars:
;* dw LayoutSoundNumber	;address of variable
;* db 'TANDY.SND',0
;*
;*
;*;!! IBM Music Card
;*IBMMusicSoundStuffBox:
;* dw offset IBMMusicSoundBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 10	;y coord
;* db 30	;width
;* dw offset IBMMusicSoundStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*IBMMusicSoundStuffBoxText:
;* db 'IBM Music Card     ',0
;*IBMMusicSoundBoxVars:
;* dw LayoutSoundNumber	;address of variable
;* db 'IBMMUSIC.SND',0
;*
;*
;*;!! Roland Music Card
;*RolandSoundStuffBox:
;* dw offset RolandSoundBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 10	;y coord
;* db 30	;width
;* dw offset RolandSoundStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*RolandSoundStuffBoxText:
;* db 'Roland MT-32 Module',0
;*RolandSoundBoxVars:
;* dw LayoutSoundNumber	;address of variable
;* db 'ROLAND.SND',0
;*
;*
;*;!! AdLib Music Card
;*AdLibSoundStuffBox:
;* dw offset AdLibSoundBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 10	;y coord
;* db 30	;width
;* dw offset AdLibSoundStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*AdLibSoundStuffBoxText:
;* db 'Ad Lib Music Card  ',0
;*AdLibSoundBoxVars:
;* dw LayoutSoundNumber	;address of variable
;* db 'ADLIB.SND',0
;*
;*
;*;...e
;*;...sKeyboard Box:0:
;*;!! KeyBoard box
;*
;*KeyBoardBoxText:
;*
;* db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
;* db '³ Keyboard type selection:                        ³'
;* db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³ A. Normal IBM PC keyboard                       ³'
;* db '³ B. Tandy 1000 PC keyboard                       ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
;* db 0
;*
;*
;*KeyBoardBoxInfo:
;* dw 0	;address of variable
;*
;* db 29	;x coord
;* db 3	;y coord
;* db 51	;width
;* dw offset KeyBoardBoxText	;address of text
;* db 2	;number of elements
;* db 'L'
;*
;* db 30	;x
;* db 9	;y
;* db 49	;width
;* db 1	;height
;* dw offset IBMKeyboardStuffBox
;*
;* db 30	;x
;* db 10	;y
;* db 49	;width
;* db 1	;height
;* dw offset TandyKeyboardStuffBox
;*
;*
;*
;*
;*;!! IBMKeyboard
;*IBMKeyboardStuffBox:
;* dw offset IBMKeyboardBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 13	;y coord
;* db 30	;width
;* dw offset IBMKeyboardStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*IBMKeyboardStuffBoxText:
;* db 'Normal IBM PC',0
;*IBMKeyboardBoxVars:
;* dw LayoutKeyBoardNumber	;address of variable
;* db 'IBMPC',0
;*
;*
;*;!! TandyKeyboard
;*TandyKeyboardStuffBox:
;* dw offset TandyKeyboardBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 13	;y coord
;* db 30	;width
;* dw offset TandyKeyboardStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*TandyKeyboardStuffBoxText:
;* db 'Tandy 1000 PC',0
;*TandyKeyboardBoxVars:
;* dw LayoutKeyBoardNumber	;address of variable
;* db 'TANDY',0
;*
;*
;*;...e
;*;...sPointer Box:0:
;*;!! Pointer Box
;*
;*PointerBoxText:
;*
;* db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
;* db '³ Pointer type selection:                         ³'
;* db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³ A. Keyboard numeric keypad                      ³'
;* db '³ B. IBM compatible joystick                      ³'
;* db '³ C. MicroSoft compatible mouse                   ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³ Note: Install the mouse driver before playing   ³'
;* db '³                                                 ³'
;* db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
;* db 0
;*
;*
;*PointerBoxInfo:
;* dw 0	;address of variable
;*
;* db 29	;x coord
;* db 3	;y coord
;* db 51	;width
;* dw offset PointerBoxText	;address of text
;* db 3	;number of elements
;* db 'L'
;*
;* db 30	;x
;* db 8	;y
;* db 49	;width
;* db 1	;height
;* dw offset KeyboardPointerStuffBox
;*
;* db 30	;x
;* db 9	;y
;* db 49	;width
;* db 1	;height
;* dw offset JoystickPointerStuffBox
;*
;* db 30	;x
;* db 10	;y
;* db 49	;width
;* db 1	;height
;* dw offset MousePointerStuffBox
;*
;*
;*
;*
;*
;*;!! KeyboardPointer
;*KeyboardPointerStuffBox:
;* dw offset KeyboardPointerBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 16	;y coord
;* db 30	;width
;* dw offset KeyboardPointerStuffBoxText	;address of text
;* db 0	;number of elements
;*
;*KeyboardPointerStuffBoxText:
;* db 'Keyboard',0
;*KeyboardPointerBoxVars:
;* dw LayoutPointerNumber	;address of variable
;* db 'KEYBOARD',0
;*
;*
;*;!! JoystickPointer
;*JoystickPointerStuffBox:
;* dw offset JoystickPointerBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 16	;y coord
;* db 30	;width
;* dw offset JoystickPointerStuffBoxText	;address of text
;* db 0	;number of elements
;*
;*JoystickPointerStuffBoxText:
;* db 'Joystick',0
;*JoystickPointerBoxVars:
;* dw LayoutPointerNumber	;address of variable
;* db 'JOYSTICK',0
;*
;*
;*;!! MousePointer
;*MousePointerStuffBox:
;* dw offset MousePointerBoxVars	;address of variable
;*
;* db 4	;x coord
;* db 16	;y coord
;* db 30	;width
;* dw offset MousePointerStuffBoxText	;address of text
;* db 0	;number of elements
;*
;*MousePointerStuffBoxText:
;* db 'Mouse   ',0
;*MousePointerBoxVars:
;* dw LayoutPointerNumber	;address of variable
;* db 'MOUSE',0


;...e
;...sInstall Box:0:
;!! Install box

;*InstallBoxText:
;*
;* db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
;* db '³ Hard disc installation:                         ³'
;* db 'ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´'
;* db '³                                                 ³'
;* db '³ A. No installation                              ³'
;* db '³ B. Install onto hard disc                       ³'
;* db '³                                                 ³'
;* db '³ Enter hard disc drive letter:                   ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³ Note: you need approximately 1.5M bytes free    ³'
;* db '³                                                 ³'
;* db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
;* db 0
;*
;*
;*InstallBoxInfo:
;* dw 0	;address of variable
;*
;* db 29	;x coord
;* db 3	;y coord
;* db 51	;width
;* dw offset InstallBoxText	;address of text
;* db 2	;number of elements
;* db 'L'
;*
;* db 30	;x
;* db 7	;y
;* db 49	;width
;* db 1	;height
;* dw NoInstallStuffBox
;*
;* db 30	;x
;* db 8	;y
;* db 49	;width
;* db 1	;height
;* dw InstallStuffBox
;*
;*
;*
;*
;*
;*;!! NoInstall
;*NoInstallStuffBox:
;* dw offset NoInstallBoxVars	;address of variable
;*
;* db 9	;x coord
;* db 19	;y coord
;* db 23	;width
;* dw offset NoInstallStuffBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*NoInstallStuffBoxText:
;* db 'Do not install',0
;*NoInstallBoxVars:
;* dw LayoutInstallNumber
;* db '@',0
;*
;*
;*;!! Install
;*InstallStuffBox:
;* dw offset DriveBoxVars		;address of variable
;*
;* db 9	;x coord
;* db 19	;y coord
;* db 23	;width
;* dw offset DriveBoxText	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*DriveBoxText:
;* db 'C             ',0
;*DriveBoxVars:
;* dw LayoutInstallNumber
;* db 'C',0




;!! Install
;InstallStuffBox:
; dw offset DriveBoxVars	;address of variable
;
; db 0	;x coord
; db 0	;y coord
; db 0	;width
; dw 0	;address of text
; db 1	;number of elements
; db 'A'
;
; db 61	;x
; db 10	;y
; db 1	;width
; db 1	;height
; dw DriveStuffBox
;
;
;!! DriveStuff
;DriveStuffBox:
; dw offset DriveBoxVars	;address of variable
;
; db 9	;x coord
; db 19	;y coord
; db 30	;width
; dw offset DriveBoxText	;address of text
; db 0	;number of elements
; db ' '
;
;DriveBoxText:
; db '              ',0
;DriveBoxVars:
; dw LayoutInstallNumber
; db 'C',0


;...e
;...sExit Box:0:
;!! Install box

;*ExitBoxText:

;* db 'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³        Install configuration and exit           ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³                 A. Yes                          ³'
;* db '³                 B. No                           ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db '³                                                 ³'
;* db 'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ'
;* db 0


;*ExitBoxInfo:
;* dw 0	;address of variable
;*
;* db 29	;x coord
;* db 3	;y coord
;* db 51	;width
;* dw offset ExitBoxText	;address of text
;* db 2	;number of elements
;* db 'L'
;*
;* db 46	;x
;* db 10	;y
;* db 8	;width
;* db 1	;height
;* dw offset ExitStuffBox
;*
;* db 46	;x
;* db 11	;y
;* db 8	;width
;* db 1	;height
;* dw offset NoExitStuffBox
;*
;*
;*
;*
;*;!! Exit
;*ExitStuffBox:
;* dw offset ExitStuffBoxVars	;address of variable
;*
;* db 0	;x coord
;* db 0	;y coord
;* db 0	;width
;* dw 0	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*ExitStuffBoxVars:
;* dw LayoutExitNumber
;* db 1,0
;*
;*NoExitStuffBox:
;* dw offset NoExitStuffBoxVars	;address of variable
;*
;* db 0	;x coord
;* db 0	;y coord
;* db 0	;width
;* dw 0	;address of text
;* db 0	;number of elements
;* db ' '
;*
;*NoExitStuffBoxVars:
;* dw LayoutExitNumber
;* db 0,0


;...e



;...e


;!! ConfigFile
;...sLayout:0:
;!! Configuration File Layout

Layout:
LayoutLength		dw LayoutEnd-Layout
CurrentVersion		dw VersionNumber
CurrentDriveLetter	db ' :'
CurrentPathname		db '\Level9\Grange',0

CurrentPathPadding:
 db 24-(CurrentPathPadding-Layout) dup (0)

CurrentVideoNumber:
 db 0
CurrentVideoModeNumber:
 db 0
CurrentVideoName:
 db 12 dup (0)
 db 0
CurrentVideoPadding:
 dw 0

CurrentSoundNumber:
 db 0
CurrentSoundName:
 db 12 dup(0)
 db 0
CurrentSoundPadding:
 dw 0

CurrentKeyboardNumber:
 db 0
CurrentKeyboardName:
 db 6 dup (0)
 db 0
CurrentKeyboardPadding:
 dw 0

CurrentPointerNumber:
 db 0
CurrentPointerName:
 db 9 dup (0)
 db 0
CurrentPointerPadding:
 dw 0

CurrentInstallNumber:
 db 0
CurrentInstallName:
 db ' '
 db 0

CurrentExitNumber:
 db 0
CurrentExitName:
 dw 0

LayoutEnd: 


 LayoutVersion=CurrentVersion-Layout
 LayoutDriveLetter=CurrentDriveLetter-Layout
 LayoutPathname=CurrentPathname-Layout
 LayoutVideoNumber=CurrentVideoNumber-Layout
 LayoutVideoModeNumber=CurrentVideoModeNumber-Layout
 LayoutVideoName=CurrentVideoName-Layout
 LayoutSoundNumber=CurrentSoundNumber-Layout
 LayoutSoundName=CurrentSoundName-Layout
 LayoutKeyboardNumber=CurrentKeyboardNumber-Layout
 LayoutKeyboardName=CurrentKeyboardName-Layout
 LayoutPointerNumber=CurrentPointerNumber-Layout
 LayoutPointerName=CurrentPointerName-Layout
 LayoutInstallNumber=CurrentInstallNumber-Layout
 LayoutInstallName=CurrentInstallName-Layout
 LayoutExitNumber=CurrentExitNumber-Layout
 LayoutExitName=CurrentExitName-Layout
 
;...e


;!! Tables
;...sScreenTable:0:
;!! address of start of character line

 even

ScreenTable:

 dw 0
 dw 160
 dw 160*2
 dw 160*3
 dw 160*4
 dw 160*5
 dw 160*6
 dw 160*7
 dw 160*8
 dw 160*9
 dw 160*10
 dw 160*11
 dw 160*12
 dw 160*13
 dw 160*14
 dw 160*15
 dw 160*16
 dw 160*17
 dw 160*18
 dw 160*19
 dw 160*20
 dw 160*21
 dw 160*22
 dw 160*23
 dw 160*24
 dw 160*25



;...e
;...sStackBit:0:
;!!  Holds Stack

even

StackPointer dw offset StackBit

StackBit:
 dw offset LeftBoxInfo
 db 1
 db 1
 db 6
 db 25
 db 1

 dw 15 dup (0)


StackLump=7

ThisBox=0
ThisChoice=2
ThisXpos=3
ThisYpos=4
ThisWidth=5
ThisHeight=6



;...e
;...sVariables:0:
;!! Variables

 even

 ScreenSeg	dw 0
 LineAttrib	db 0
 NormalAttrib	db 0
 InvertAttrib	db 0
 BrightAttrib	db 0


 even

 KeyPressed	dw 0

 FileSeg	dw 0
 FileOffset	dw 0

 Action		dw 0
 Handle		dw 0
 

 Filename	db 'CONFIG.DAT',0

;...e

;!! File Buffer
;...sFileBuffer:0:
FileBuffer:

 db 256 dup (0)

 
;...e


;...e

code ends

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
