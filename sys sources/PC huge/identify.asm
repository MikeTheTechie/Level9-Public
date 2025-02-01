;Identifies boards in system
;Board types
; 0 - none    - a very useful display type, especially for adventuring!
; 1 - MDA     - use MDA mode
; 2 - CGA     - use CGA 40/80 pictures mode - depends what width is already
; 3 - EGA     - use EGA fastest mode
; 4 - MCGA    - use MGA 40/80 pictures mode - depends what width is already
; 5 - VGA     - use EGA fastest mode
; 6 - not assigned!
; 7 - HGC     - use MGA 40/80 pictures mode - depends what width is already
; 8 - HGC+    - use MGA 40/80 pictures mode - depends what width is already
; 9 - HIC     - use something
;
;Display types - don't know if this will be needed
; 0 - none    - useful!
; 1 - MDA monochrome
; 2 - CGA monitor
; 3 - EGA monitor
; 4 - PS/2 monochrome
; 5 - PS/2 colour

;           Either   Signed   Unsigned
;    <=              jle      jbe
;    <               jl       jb/jc
;    =      je/jz
;    <>     jnz/jne
;    >=              jge      jae/jnc
;    >               jg       ja

;---

MDA          equ 1
CGA          equ 2
EGA          equ 3
MCGA         equ 4
VGA          equ 5
;not used    equ 6
HGC          equ 7
HGCplus      equ 8
InColour     equ 9

MDAdisplay   equ 1
CGAdisplay   equ 2
EGAdisplay   equ 3
PS2mono      equ 4
PS2colour    equ 5

true         equ 1
false        equ 0

;---

 public VideoID  ;entry point

 public Video0Type
 public Display0Type
 public Video1Type
 public Display1Type

;---

code   SEGMENT public 'code'
       ASSUME cs:code,ds:code

VideoID     PROC near
 push si

 mov ax,cs ;*
 mov ds,ax ;*

 mov Word ptr Video0Type,0
 mov Word ptr Video1Type,0

 mov byte ptr CGAflag,true
 mov byte ptr EGAflag,true
 mov byte ptr Monoflag,true
 mov cx,NumberofTests
 mov si,offset cs:TestSequence

L01:
 lodsb
 test al,al
 lodsw
 jz L02

 push si
 push cx
 call ax
 pop cx
 pop si

L02:
 loop L01

 call FindActive

 pop si
 ret

VideoID     ENDP

;---

FindPS2     PROC near
 mov ax,01A00h
 int 10h

 cmp al,01Ah
 jne L13

 mov cx,bx
 xor bh,bh
 or ch,ch
 jz L11

 mov bl,ch
 add bx,bx
 mov ax,word ptr cs:[bx+offset DCCtable]

 mov Word ptr Video1Type,ax

 mov bl,cl
 xor bh,bh

L11:
 add bx,bx
 mov ax,word ptr cs:[bx+offset DCCtable]

 mov Word ptr Video0Type,ax

 mov byte ptr CGAflag,false
 mov byte ptr EGAflag,false
 mov byte ptr Monoflag,false

 lea bx,Video0Type
 cmp byte ptr [bx],MDA
 je L12

 lea bx,Video1Type
 cmp byte ptr [bx],MDA
 jne L13

L12:
 mov word ptr [bx],0
 mov byte ptr Monoflag,true

L13:
 ret

FindPS2     ENDP

;---

FindEga     PROC near
 mov bl,10h
 mov ah,12h
 int 10h

 cmp bl,10h
 je L22

 mov al,cl
 shr al,1
 mov bx,offset cs:EGADisplays
 xlat
 mov ah,al
 mov al,EGA
 call FoundDevice

 cmp ah,MDAdisplay
 je L21

 mov byte ptr CGAflag,false
 jmp short L22

L21:
 mov byte ptr Monoflag,false

L22:
 ret

FindEga     ENDP

;---

FindCGA     PROC near
 mov dx,03D4h
 call Find6845
 jc L31

 mov al,CGA
 mov ah,CGAdisplay
 call FoundDevice

L31:
 ret

FindCGA     ENDP

;---

FindMono    PROC near
 mov dx,03B4h
 call Find6845
 jc L44

 mov dl,0BAh
 in al,dx
 and al,080h
 mov ah,al
 mov cx,08000h

L41:
 in al,dx
 and al,080h
 cmp ah,al
 loope L41

 jne L42

 mov al,MDA
 mov ah,MDAdisplay
 call FoundDevice
 jmp short L44

L42:
 in al,dx
 mov dl,al

 mov ah,MDAdisplay

 mov al,HGC
 and dl,01110000b
 jz L43

 mov al,HGCplus
 cmp dl,00010000b
 je L43

 mov al,InColour
 mov ah,EGAdisplay

L43:
 call FoundDevice

L44:
 ret

FindMono    ENDP

;---

Find6845    PROC near
 mov al,00Fh
 out dx,al
 inc dx

 in al,dx
 mov ah,al
 mov al,066h
 out dx,al

 mov cx,00100h

L51:
 loop L51

 in al,dx
 xchg ah,al

 out dx,al

 cmp ah,066h
 je L52

 stc

L52:
 ret

Find6845    ENDP

;---

FindActive  PROC near
 cmp word ptr Video1Type,0
 je L63

 cmp Video0Type,4
 jge L63
 cmp Video1Type,4
 jge L63

 mov ah,00Fh
 int 10h

 and al,7
 cmp al,7
 je L61

 cmp Display0Type,MDAdisplay
 jne L63
 jmp short L62

L61:
 cmp Display0Type,MDAdisplay
 je L63

L62:
 mov ax,Word ptr Video0Type
 xchg ax,Word ptr Video1Type
 mov Word ptr Video0Type,ax

L63:
 ret

FindActive  ENDP

;---

FoundDevice PROC near
 lea bx,Video0Type
 cmp byte ptr [bx],0
 je L71

 lea bx,Video1Type

L71:
 mov [bx],ax
 ret

FoundDevice ENDP

;---

EGAdisplays  db CGAdisplay
             db EGAdisplay
             db MDAdisplay
             db CGAdisplay
             db EGAdisplay
             db MDAdisplay

DCCtable     db 0,0
             db MDA,MDAdisplay
             db CGA,CGAdisplay
             db 0,0
             db EGA,EGAdisplay
             db EGA,MDAdisplay
             db 0,0
             db VGA,PS2mono
             db VGA,PS2colour
             db 0,0
             db MCGA,EGAdisplay
             db MCGA,PS2mono
             db MCGA,PS2colour

TestSequence db 1
             dw FindPS2

EGAflag      db 1
             dw FindEGA


CGAflag      db 1
             dw FindCGA

Monoflag     db 1
             dw Findmono

NumberofTests   EQU (this byte - TestSequence)/3

Video0Type   = this word
   db 0
Display0Type = this byte
   db 0
Video1Type   = this word
   db 0
Display1Type = this byte
   db 0

code ENDS

END



