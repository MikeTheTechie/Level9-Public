;IBM animated adventure system installer

;Copier.asm

;Copyright (C) 1989 Level 9 Computing

;-----


;...sInclude files:0:
;These include files must be named in MAKE.TXT:
; include consts.asm

;...e

;...sPublics and externals:0:
extrn FileSeg:word
extrn FileOffset:word
extrn PrintText:near

public CopyFiles

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
;** Constants
;...sConstants:0:
;...e


;** Main Program
;...sMain Program:0:
CopyFiles:
 mov bp,cs
 mov ds,bp

;...sLoad configuration:0:
;** Load configuration


BadConfigurationFile:
 mov ax,cs
 cmp ax,FileSeg
 jne MoveLayout
 jmp LoadingFinished

MoveLayout:
 mov es,FileSeg
 mov di,FileOffset
; mov si,offset Layout
; mov cx,LayoutLength

 rep movsb

 jmp LoadingFinished

LoadConfiguration:

; mov dx,offset FileName
 mov ax,03d00h
 int 21h	;open file

 jc BadConfigurationFile

 mov handle,ax
 
 mov bx,ax
; mov cx,LayoutLength
; mov dx,offset FileBuffer
 mov ax,03F00h
 int 21h

 jc  BadConfigurationRead

; mov si,offset FileBuffer
; add si,LayoutVersion
; cmp word ptr [si],VersionNumber
 jne BadConfigurationRead

 mov es,FileSeg
 mov di,FileOffset
; mov si,offset FileBuffer
; mov cx,LayoutLength

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
;** print top box
 xor al,al
 mov bl,al
 mov cx,80
; mov si,offset TopBoxText 
 call PrintText

;** print information box
 xor al,al
 mov bl,03
 mov cx,80
; mov si,offset InfoBoxText 
 call PrintText

; call getkeypress

;** print left box
 xor al,al
 mov bl,03
 mov cx,29
; mov si,offset LeftBoxText 
 call PrintText

;** print right box
 mov al,29
 mov bl,03
 mov cx,51
; mov si,offset VideoBoxText 
 call PrintText

;** print help box
 mov al,29
 mov bl,16
 mov cx,51
; mov si,offset HelpBoxText 
 call PrintText

;...e




;...e


;** Subroutines


;** Variables
;...sVariables:0:
;** Variables

 even


 handle	dw 0

;...e

;...e

code ends

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
