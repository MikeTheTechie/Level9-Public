 page 128,122 ;length,width
;IBM HERO adventure system.

;JOYSTICK.ASM

;Copyright (C) 1989 Level 9 Computing

;-----

;...sPublics and externals:0:

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

 name joystick

code segment public 'code'

 assume cs:code
 assume ds:code

;-----

;...sSubroutines:0:

 jmp short L003A

 db 00  ;2
 db 0   ;3
 db 21h ;4
 db 43h ;5
 db 65h ;6
 db 87h ;7
 db 03h ;8

 db 0Ch ;clear screen
 db "joystick.drv",17h,"IBM compatible joystick"

L002E dw Entry0 ;013E - initialise
      dw Entry1 ;0101
      dw Entry2 ;01ED - not used
      dw Entry3 ;0077
      dw Entry4 ;01EB - not used
      dw Entry5 ;01EC - not used

L003A:
 push ds
 mov bx,ds
 mov es,bx
 mov bx,cs
 mov ds,bx
 call ds:[bp+L002E]
 pop ds
 retf

L004A dw 0
L004C dw 0
L004E dw 0
L0050 dw 0
L0052 dw 0
L0054 dw 0
L0056 dw 0
L0058 dw 0
L005A dw 0
L005C dw 0
L005E dw 0
L0060 dw 0
L0062 dw 0
L0064 dw 0008h
 dw 1
 dw 2
 dw 7
 dw 0
 dw 3
 dw 6
 dw 5
 dw 4
 db 0

Entry3:
L0077:
 mov word ptr es:[si],0000
 cmp [L004A],+00
 jz L00F7
 mov [L005A],0000
 cmp dx,[L0056]
 jg L0093
 cmp ax,[L0058]
L0093:
 jl L00ad
 mov [L005A],0001
 mov [L0056],dx
 mov [L0058],ax
 add [L0058],+0Ch
 jnb L00AD
 inc [L0056]
L00AD:
 call L0163
 mov ax,[L0052]
 cmp ax,[L0054]
 jz L00CB
 cmp ax,0001
 jnz L00C3
 mov ax,0100h
 jmp short L00C6
L00C3:
 mov ax,0200h
L00C6:
 mov es:[si],ax
 jmp short L00F7
L00CB:
 call L01AE
 cmp ax,[L0050]
 jz L00E2
 mov word ptr es:[si],0040h
 mov es:[si+02],ax
 mov [L0050],ax
 jmp short L00F7
L00E2:
 cmp [L005A],+01
 jnz L00F7
 cmp ax,0000
 jz L00F7
 mov word ptr es:[si],0040h
 mov es:[si+02],ax
L00F7:
 mov ax,[L0052]
 mov [L0054],ax
 mov ax,es:[si]
 ret

Entry1:
L0101:
 call L013E
 or ax,ax
 jnz L0109
 ret
L0109:
 call L0163
 mov ax,[L004C]
 mov [L005C],ax
 mov [L005E],ax
 shr ax,1
 sub [L005C],ax
 add [L005E],ax
 mov ax,[L004E]
 mov [L0060],ax
 mov [L0062],ax
 shr ax,1
 sub [L0060],ax
 add [L0062],ax
 xor ax,ax
 mov [L0050],ax
 mov [L0052],ax
 mov [L0054],ax
 ret

;----- Initialise -----

Entry0:
L013E:
 mov bl,0FFh
 mov cx,0400h
 mov dx,0201h
 out dx,al
L0147:
 in al,dx
 cmp al,bl
 ja L0154
 mov bl,al
 test al,03
 jz L0154
 loop L0147
L0154:
 xor ax,ax
 jcxz L015D
 cmp al,bl
 ja L015D
 inc ax
L015D:
 mov [L004A],ax 
 test ax,ax      ;stange?
 ret
L0163:
 xor bx,bx
 mov cx,bx       ;number of tries?
 mov dx,0201h
 cli
 out dx,al
L016C:
 in al,dx
 test al,01
 jz L017A
 add bx,+01
 cmp bx,0400h
 ja L01A7
L017A:
 test al,02
 jz L0187
 add cx,+01
 cmp cx,0400h   ;tries = 1024 ?
 ja L01A7
L0187:
 test al,03
 jnz L016C
 sti
 mov cs:[L004C],bx
 mov cs:[L004E],cx
 xor dx,dx          ;=0
 and al,30h ;'0'
 cmp al,30h ;'0'
 jz L019F
 inc dx
L019F:
 mov cs:[L0052],dx  ;=0
 or bx,cx
 ret
L01A7:              ;too many retries
 sti
 xor ax,ax
 mov [L004A],ax     ;=0
 ret

;-----

L01AE:
 mov ax,[L004E]
 cmp ax,[L0060]
 jg L01bc
 mov bx,0000
 jmp short L01CA
L01BC:
 cmp ax,[L0062]
 jge L01C7
 mov bx,0006
 jmp short L01CA
L01C7:
 mov bx,000Ch
L01CA:
 mov ax,[L004C]
 cmp ax,[L005C]
 jg L01D8
 add bx,+00
 jmp short L01E6
L01D8:
 cmp ax,[L005E]
 jge L01E3
 add bx,+02
 jmp short L01E6
L01E3:
 add bx,+04
L01E6:
 mov ax,[bx+L0064]
 ret

;-----

Entry4:
L01EB:
 ret

Entry5:
L01EC:
 ret

Entry2:
L01ED:
 ret

;...e

;-----

code ends

;-----

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
