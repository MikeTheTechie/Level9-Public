 page 128,122 ;length,width
;IBM KAOS adventure system. memory allocator/loader

;BINARY.ASM

;Copyright (C) 1987,1988,1989 Level 9 Computing

;-----

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
 include consts.asm

;...e

IFE TwoD

;...sPublics and externals:0:

 public AddrBuildRoom
 public AddrClearChangeMaps
 public AddrClearRectangle
 public AddrCloseDown ;*
; public AddrClearTextLine
 public AddrCopyTextArea
 public AddrFindObject
 public AddrOnceOnlyInit
 public AddrPrintCharacter
 public AddrScreenFlip
 public AddrSetGraphicsWindow
 public AddrSetUpPalette
 public AddrShiftRectangle
 public AddrUnHookDiscBase
 public AddrUpdateScreen
 public Addr3DEmptyRoom
 public Addr3DInitDisc
 public Addr3DLoadRange
 public Addr3DLoadRangeProtect
 public Addr3DObjectHandler
 public Addr3DPreLoadCells
 public Addr3DPlotLogicalScreen
 public Addr3DPlotPhysicalScreen
 public Addr3DSetupPointers
 public Addr3DSetupVariablePointers
 public Addr3DUnplotScreen
 public SetDriver
 public AddrPurgeAllCells
  if Scroll
 public AddrInitialiseScrolling
 public AddrScrollDirection
 public AddrSetMaxFrameRate
  endif ;Scroll

;In BIN.ASM:
 extrn FiftyHertzTimer:near

;In GAME.ASM:
 extrn HiLo_ErrorNumber:word
 extrn HiLo_VBLDisabled:word ;*

;In HUGE.ASM:
 extrn MCCloseDown:near

;In INTRPT.ASM:
 extrn GSX_Queue:word
 extrn GSX_ReadPtr:word
 extrn GSX_WritePtr:word

;In MCODE.ASM:
 extrn Game_ErrorHandler:near
 extrn Game_Scheduler:near ;*
 extrn Game_VBL:near       ;*
 extrn GrabAllMemory:near
 extrn GrabHighMemory:near
 extrn GrabLowMemory:near

 if DosKeyboard
 extrn ConvertRealKeyboard:near
 endif ;DosKeyboard

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

 name entry

code segment public 'code'

 assume cs:code

;-----

;...sSubroutines:0:
; ax - Driver segment

SetDriver:
 mov cx,cs
 mov es,cx

 mov di,offset StartTable+2
 mov cx,(EndTable-StartTable)/4
sd01:
 stosw                     ;Put DRIVER segment address in table
 add di,2
 loop sd01

;Calls from driver TO 'seg code'

 mov es,ax                 ;Segment 'DRIVER.BIN' to patch
 mov ax,seg code
 mov word ptr es:[0],offset Far_GrabAllMemory
 mov word ptr es:[2],ax
 mov word ptr es:[4],offset Far_GrabHighMemory
 mov word ptr es:[6],ax
 mov word ptr es:[8],offset Far_GrabLowMemory
 mov word ptr es:[10],ax
 mov word ptr es:[12],offset Far_Terminate
 mov word ptr es:[14],ax
 mov word ptr es:[16],offset Far_Timer
 mov word ptr es:[18],ax
 mov word ptr es:[20],offset Far_ErrorHandler
 mov word ptr es:[22],ax
 mov word ptr es:[24],offset Far_GetKeyPress
 mov word ptr es:[26],ax
 mov word ptr es:[28],offset Far_MultiTaskInterrupt ;*
 mov word ptr es:[30],ax ;*

 ret 

;-----

StartTable = this dword

 if Scroll
AddrInitialiseScrolling     dd 040h
AddrScrollDirection         dd 044h
AddrSetMaxFrameRate         dd 048h
 endif ;Scroll

AddrBuildRoom               dd 080h
Addr3DEmptyRoom             dd 084h
Addr3DObjectHandler         dd 088h
Addr3DLoadRange             dd 08Ch
Addr3DLoadRangeProtect = this byte ;      dd 090h
Addr3DPreLoadCells          dd 094h
Addr3DPlotLogicalScreen     dd 098h
Addr3DPlotPhysicalScreen    dd 09Ch
Addr3DUnplotScreen          dd 0A0h
AddrUpdateScreen            dd 0A4h
AddrScreenFlip              dd 0A8h
AddrOnceOnlyInit            dd 0ACh
Addr3DSetupPointers         dd 0B0h
Addr3DSetupVariablePointers dd 0B4h
Addr3DInitDisc              dd 0B8h
AddrPrintCharacter          dd 0BCh 
AddrClearRectangle          dd 0C0h
AddrShiftRectangle          dd 0C4h
AddrUnHookDiscBase          dd 0C8h
AddrSetUpPalette            dd 0CCh
;AddrSetTextWindow           dd 0D0h
;AddrClearTextLine           dd 0D4h
AddrCopyTextArea            dd 0D8h
AddrSetGraphicsWindow       dd 0DCh
AddrClearChangeMaps         dd 0E0h
AddrFindObject              dd 0E4h
;AddrHookDiscBase            dd 0E8h
AddrPurgeAllCells           dd 0ECh
AddrCloseDown               dd 0F0h ;*

EndTable = this dword

;-----

;Subroutines called by driver

Far_GrabAllMemory proc far

 call GrabAllMemory
 retf

Far_GrabAllMemory endp

;-----

Far_GrabHighMemory proc far

 call GrabHighMemory
 retf

Far_GrabHighMemory endp

;-----

Far_GrabLowMemory proc far

 call GrabLowMemory
 retf

Far_GrabLowMemory endp

;-----

Far_Terminate proc far

 call MCCloseDown
 retf

Far_Terminate endp

;-----

Far_Timer proc far

 call FiftyHertzTimer
 retf
 
Far_Timer endp

;-----

Far_ErrorHandler proc far

 push ax
 push bx
 push cx
 push dx
 push ds
 push es
 push si
 push di
 push bp

 assume ds:vars
 mov bx,seg vars
 mov ds,bx
 xchg ah,al                 ;error code from driver
 mov ds:HiLo_ErrorNumber,ax
 call Game_ErrorHandler

 pop bp
 pop di
 pop si
 pop es
 pop ds
 pop dx
 pop cx
 pop bx
 pop ax
 retf

 assume ds:nothing

Far_ErrorHandler endp

;-----

Far_GetKeyPress proc far

;Wait for key press

 sti                        ;enable interrupts
 push ds
 push si

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 if DosKeyboard
 call ConvertRealKeyboard
 endif ;DosKeyboard

NoKey:
 mov si,ds:GSX_ReadPtr
 cmp si,ds:GSX_WritePtr
 je NoKey                   ;No key, so wait for one

 mov ax,ds:GSX_Queue[si]    ;Codes: al=ascii, ah=GSX
 add byte ptr ds:GSX_ReadPtr,2
 mov ah,0                   ;ax=ascii code

 pop si
 pop ds
 assume ds:nothing

 retf

Far_GetKeyPress endp

;-----

Far_MultiTaskInterrupt proc far

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

;***
 cmp ds:HiLo_VBLDisabled,0 ;ST system tests this for VBL and Task interrupts
 jnz SchedOff
 call Game_Scheduler
SchedOff:
;****

 call Game_VBL       ;*
 retf

Far_MultiTaskInterrupt endp

;...e

;-----

code ends

;-----

;...sVariables:0:

vars segment word public 'data'

vars ends

;...e

;-----

;...sStart up stack:0:

;Folowing way of defining stack is recognised by linker and generates
;a code file which auto sets-up stack:

stacks segment stack 'stack'

 db 256 dup (0) ;Only for initialise
LinkerStackSize = this byte

stacks ends

;...e

;-----

ENDIF ;TwoD

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################

