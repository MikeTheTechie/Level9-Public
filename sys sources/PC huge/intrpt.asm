 page 128,122 ;length,width
;IBM HERO. Handle all exception interrupts

;INTRPT.ASM

;Copyright (C) 1988,1989 Level 9 Computing

;-----

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
 include common.asm
 include consts.asm

;...e

;...sPublics and externals:0:

;* public counter ;>

 public ClockTickOldSeg ;*
 public ClockTickOldVal ;*
 public CS_Hero_Clock
 public DisplayVisible
 public DisplayVisibleString
 public FiftyHertzTimer
 public Graphics_Count
 public GSX_Down
 public GSX_Queue
 public GSX_WritePtr
 public Keyboardtable
 public MCInitTask
 public MCSnooze
 public NewTimer      ;*
 public OriginalVectors
 public OriginalTimer ;*
 public SilentFatalError
 public VectorsInit


 if DosKeyboard
 public ConvertRealKeyboard
 else ;DosKeyboard
 public kbdinit
 public Kbd_Unhook
 endif ;DosKeyboard

;In AINT.ASM:
 extrn prgstr:word

;In BIN.ASM:
   IFE TwoD
 extrn AddrClearChangeMaps:dword
 extrn AddrScreenFlip:dword
   ENDIF ;TwoD

;In DRIVER.ASM:
 extrn BreakPoint:near

;In GAME.ASM
 extrn B_JoystickStatus:byte
 extrn B_LastKeyPressed:byte
 extrn HiLo_LoLongCurrentTask:word
 extrn HiLo_LoLongNextTask:word
 extrn HiLo_SuspendTaskSwap:word
 extrn HiLo_VBLDisabled:word
 extrn L_MTCB:dword
 if TraceCode         ;@
 extrn debugword:word ;@
 endif ;TraceCode     ;@

;In HUGE.ASM:
 extrn CS_Acode:word
 extrn CS_GameData:word
 extrn CS_FatalDiskErrors:word
 extrn TopOfMemoryAllocated:word

;In MCODE.ASM:
 extrn Game_VBL:near
 extrn Game_Scheduler:near
 extrn MCReturn:near

;...e

;-----

code segment public 'code'

 assume cs:code

;           Either   Signed   Unsigned
;    <=              jle      jbe
;    <               jl       jb/jc
;    =      je/jz
;    <>     jnz/jne
;    >=              jge      jae/jnc
;    >               jg       ja

;...sTables:0:

TimerCount = 8352 ; 4971 ;* 4261 ;* 5966           ;gives 199.9967 Hz (5.000084 ms)
VBL_TimerCount = 18024      ;Divide 200 Hz to give 50 Hz

Shift_Bit = 1
Ctrl_Bit  = 2
Alt_Bit   = 4
Del_Bit   = 8

;-----

SaveVector macro p1,p2,p3

 mov ax,3500h+p1            ;p1=interrupt number.
 int 21h                    ;DOS function. Get interrupt vector
 mov p2,es                  ;Save location for segment
 mov p3,bx                  ;Save location for offset

 endm ;SaveVector

;-----

NewVector macro p1,p2

 mov dx,offset p2
 mov ax,2500h+p1            ;Clock tick
 int 21h                    ;DOS function. Set interrupt vector

 endm ;NewVector

;...e

;-----

;...sSubroutines:0:

SetTimer proc near

;Set system timer to 'BX'

 cli                        ;disable interrupts 
 mov dx,43h                 ;Timer Write Control Port
;* mov al,0B6h                ;Set counter 2, both bytes, mode 3, non-BCD
 mov al,036h                ;Set counter 0, both bytes, mode 3, non-BCD
 out dx,al

 mov dx,40h                 ;Clock Data
 mov cx,10
delay1:
 loop delay1
 mov al,bl                  ;first byte (lo)
 out dx,al
 mov cx,10
delay2:
 loop delay2
 mov al,bh                  ;second byte (hi)
 out dx,al
 sti                        ;enable interrupts
 ret

SetTimer endp

;-----

FiftyHertzTimer proc near

 mov ax,cs:CS_FiftyHertz
 ret

FiftyHertzTimer endp

;-----

VectorsInit proc near

 SaveVector 08h,cs:ClockTickOldSeg,cs:ClockTickOldVal ;Timer interrupt

 mov cs:ClockVectorAddr,bx  ;Make a "JMP es:bx" instruction
 mov cs:ClockVectorSeg,es

;Set clock to run at 200 Hz.

 mov bx,TimerCount
 call SetTimer

 SaveVector 0Dh,cs:GraphicsOldSeg,cs:GraphicsOldVal ;Invalid memory
   If 0 EQ (TwoD OR DosKeyboard)
 SaveVector 24h,cs:CriticalOldSeg,cs:CriticalOldVal ;Critical DOS error
   ENDIF ;TwoD+DosKeyboard

 push ds
 mov ax,cs
 mov ds,ax
 assume ds:code

 NewVector 08h,ClockTick         ;Timer interrupt
 NewVector 0Dh,GraphicsInterrupt ;Invalid graphics memory
   If 0 EQ (TwoD OR DosKeyboard)
 NewVector 24h,CriticalInterrupt ;Critical DOS error
   ENDIF ;TwoD+DosKeyboard

 pop ds
 assume ds:nothing
 ret

VectorsInit endp

;-----

RestoreVector macro p1,p2,p3

 mov ds,p2                  ;Segment address
 assume ds:nothing
 mov dx,p3                  ;Offset address
 mov ax,2500h+p1            ;p1 = interrupt number
 int 21h                    ;DOS function. Set interrupt vector

 endm ;RestoreVector

;-----

;unhook any pre hooked interrupts

OriginalVectors proc near

 RestoreVector 08h,cs:ClockTickOldSeg,cs:ClockTickOldVal ;Timer interrupt

;Reset clock to 18.2 Hz

 mov bx,0
 call SetTimer

 RestoreVector 0Dh,cs:GraphicsOldSeg,cs:GraphicsOldVal ;Invalid memory
   If 0 EQ (TwoD OR DosKeyboard)
 RestoreVector 24h,cs:CriticalOldSeg,cs:CriticalOldVal ;Critical DOS error
   ENDIF ;TwoD+DosKeyboard
 ret

OriginalVectors endp

;-----

;*****
OriginalTimer proc near

;Reset vector BEFORE onceonlyinit
 mov bx,0
 call SetTimer
 RestoreVector 08h,cs:ClockTickOldSeg,cs:ClockTickOldVal ;Timer interrupt
 ret

OriginalTimer endp

 purge RestoreVector        ;speed up assembly

;-----

NewTimer proc near

;Restore vector AFTER onceonlyinit
 mov bx,TimerCount
 call SetTimer
 mov ax,cs
 mov ds,ax
 assume ds:code
 NewVector 08h,ClockTick         ;Timer interrupt
 ret

NewTimer endp

 purge NewVector            ;speed up assembly
 assume ds:nothing
;*****

;-----

 even
ClockTickOldSeg dw 0
ClockTickOldVal dw 0

GraphicsOldSeg dw 0
GraphicsOldVal dw 0

   If 0 EQ (TwoD OR DosKeyboard)
CriticalOldSeg dw 0
CriticalOldVal dw 0
   ENDIF ;TwoD+DosKeyboard

;-----

 even
Graphics_Count dw 0

;-----

GraphicsInterrupt: ;Invalid graphics memory
 inc cs:Graphics_Count
 iret                       ;restore flags

;-----

 IF 0 EQ (TwoD OR DosKeyboard)

CriticalInterrupt:          ;ah/di are error flags
 push ds
 push es
 push bx
 push cx
 push dx

 call DisplayError          ;make sense of AH and DI registers

;supplied registers are no longer needed (but some need to be preserved)

 cmp word ptr cs:AddrClearChangeMaps,0
 je NoDriver
 call cs:AddrClearChangeMaps ;tell DRIVER.BIN screen is corrupted
NoDriver:

 assume ds:vars             ;assembler bug: do this before MOV BX,SEG VARS
 mov bx,seg vars
 mov ds,bx

 mov bx,HiLo_VBLDisabled
 push bx
 mov HiLo_VBLDisabled,100h  ;shut-down multitasking
 sti                        ;enable interrupts
 call GetResponse
 cli                        ;disable interrupts 
 push ax                    ;error/return code

 call ClearError            ;clear screen

 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 pop ax                     ;error/return code
 pop bx
 mov HiLo_VBLDisabled,bx    ;re-start multitasking

 pop dx
 pop cx
 pop bx
 pop es
 pop ds
 assume ds:nothing

 cmp al,2                   ;'kill' selected
 je adjuststack

 iret                       ;'retry' selected

adjuststack:
 inc cs:CS_FatalDiskErrors

 mov bp,sp
 or word ptr ss:28[bp],1    ;Set user carry flag

 pop ax ;(0)                ;junk IP
 pop ax ;(2)                ;junk CS
 pop ax ;(4)                ;junk FLAGS

 pop ax ;(6)                ;Registers for original INT 21h request
 pop bx ;(8)
 pop cx ;(10)
 pop dx ;(12)
 pop si ;(14)
 pop di ;(16)
 pop bp ;(18)
 pop ds ;(20)
 pop es ;(22)
 iret   ;(24=IP 26=CS 28=flags)

 ENDIF ;TwoD+DosKeyboard
 
;-----

 If 0 EQ (TwoD OR DosKeyboard)

;this is only called from MS-DOS; most registers are preserved
;  ah<128, al=Drive ID, ah && 7=error type
;  ah>127, di=error code
DisplayError:
 test ah,80h
 jz DiskError

;Other error
 mov ax,di

 mov di,offset WriteProtect
 cmp al,0 ;Write protect
 je DisplayCriticalError

 mov di,offset InvalidDrive
 cmp al,1 ;Invalid drive
 je DisplayCriticalError

 mov di,offset NotReady
 cmp al,2 ;Drive not ready
 je DisplayCriticalError

; cmp al,3 ;Unknown command

 mov di,offset CRCerror
 cmp al,4 ;CRC error
 je DisplayCriticalError

; cmp al,5 ;Bad request structure length

 mov di,offset SeekError
 cmp al,6 ;Seek error
 je DisplayCriticalError

 mov di,offset UnknownMedia
 cmp al,7 ;Unknown media
 je DisplayCriticalError

 mov di,offset SectorNotFound
 cmp al,8 ;Sector not found
 je DisplayCriticalError

; cmp al,9 ;Printer out of paper

 mov di,offset WriteError
 cmp al,10 ;Write error
 je DisplayCriticalError

 mov di,offset ReadError
 cmp al,11 ;Read error
 je DisplayCriticalError

; cmp al,12 ;General error

 mov di,offset OtherError
 jmp short DisplayCriticalError

;  ah<128, al=Drive ID, ah && 7=error type
DiskError:
 and ah,1 ;Get read/write flag

 mov di,offset ReadError
 cmp ah,0
 je DisplayCriticalError
 mov di,offset WriteError

DisplayCriticalError:
 push di

 cmp word ptr cs:AddrScreenFlip+2,0
 je de01
 call cs:AddrScreenFlip     ;set up Physical/Logical addresses
 call cs:AddrScreenFlip     ;ask which screen in displayed
 cmp ax,bx
 jb de01
 call cs:AddrScreenFlip     ;switch in lower screen as physical
de01:

 push cs
 pop ds
 assume ds:code

 mov dx,0A02h               ;row 10, column 2
 mov bx,offset Critical1
 call DisplayVisibleString

 mov dx,0B02h               ;row 11, column 2
 pop bx                     ;text of error message
 call DisplayVisibleString

 mov dx,0C02h               ;row 12, column 2
 mov bx,offset Critical2    ;text of error message
 call DisplayVisibleString

 mov dx,0D02h               ;row 13, column 2
 mov bx,offset Critical3    ;text of error message
 call DisplayVisibleString

 mov dx,0E02h               ;row 14, column 2
 mov bx,offset Critical4    ;text of error message
 call DisplayVisibleString

 ret

 ENDIF ;TwoD+DosKeyboard

;-----

 If 0 EQ (TwoD OR DosKeyboard)

ClearError:
 mov dx,0A02h               ;row 10, column 2
 mov cx,5
ce01:
 push cx
 push dx
 mov bx,offset BlankLine
 call DisplayVisibleString
 pop dx
 pop cx
 add dx,100h
 loop ce01

 ret

 ENDIF ;TwoD+DosKeyboard

;-----

 If 0 EQ (TwoD OR DosKeyboard)

;                   1234567890123456789012345678901234567890
WriteProtect:   db "º     Disc is write protected      º$"
InvalidDrive:   db "º         No such drive            º$"
NotReady:       db "º       Drive is not ready         º$"
CRCerror:       db "º       Disc is unreadable         º$"
SeekError:      db "º           Seek fault             º$"
UnknownMedia:   db "º        Unknown disc type         º$"
SectorNotFound: db "º        Disc is corrupted         º$"
WriteError:     db "º      Cannot write to disc        º$"
ReadError:      db "º        Cannot read disc          º$"
OtherError:     db "º      Can't determine fault       º$"

Critical1:      db 'ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»$'
Critical2:      db 'ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶$'
Critical3:      db 'º Press (A) to abort, (R) to retry º$'
Critical4:      db 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼$'

BlankLine:      db '                                    $'

 ENDIF ;TwoD+DosKeyboard

;-----

;cs:bx=message, dh=row, dl=column
DisplayVisibleString:
 push bx

 mov ah,2                   ;Set Cursor Position
 mov bh,0                   ;page
 int 10h                    ;Video Service

 mov ax,cs
 mov ds,ax
 pop bx

da01:
 mov al,ds:[bx]
 cmp al,'$'
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

  IF TwoD
 mov bx,7  ;page=0, Attribute=7
  ELSE ;TwoD
 mov bx,1  ;page=0, Attribute=1
  ENDIF ;TwoD
 mov cx,1  ;count
 mov ah,9  ;Display character and Attribute
 int 10h   ;Video Service
 mov ah,3  ;Read cursor
 mov bh,0  ;page
 int 10h   ;Video Service
 inc dl    ;advance cursor
 mov ah,2  ;Set cursor
 mov bh,0  ;page
 int 10h   ;Video Service

 pop bx
 ret

;-----

 If 0 EQ (TwoD OR DosKeyboard)

GetResponse:
 mov cs:Response_On,1       ;turn off keyboard buffer
gr01:
 cmp cs:Response_On,0
 jne gr01                   ;no key pressed
 mov al,2                   ;'kill' return code
 cmp cs:Response_Code,30    ;key scan for 'A'
 je gr02
 mov al,1                   ;retry return code
 cmp cs:Response_Code,19    ;key scan for 'R'
 je gr02
 jmp short GetResponse

gr02:
 ret

 ENDIF ;TwoD+DosKeyboard

;-----

 even
CS_Hero_Clock dw 0

;---------------------------5ms timer interrupt-----------------------
;Get here every 5 ms.

ClockTick:
 push ax
 push bx
 push cx
 push dx
 push es
 push ds

;---------------------------200Hz acode clock---------------------------

 inc cs:CS_Hero_Clock

;--------------------------Trap keyboard reboot-------------------------

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

;* mov al,Shift_Status        ;Get keyboard status
;* and al,Alt_Bit+Del_Bit+Ctrl_Bit
;* cmp al,Alt_Bit+Del_Bit+Ctrl_Bit
;* jne notreset
;* jmp SilentFatalError

;Not about to re-boot, so reduce 200 Hz clock to 18.2 Hz for MS-DOS.

;*notreset:
;* assume ds:nothing

 add cs:CS_ClockCount,TimerCount
 jnc nonsystemtick

;count wrapped. Make this clock tick also drive system clock.

;---------------------------55ms MS-DOS clock---------------------------

;When running under SYMDEB, keyboard scan codes must be put in
;the DOS buffer. (This code is a kludge to still give a
;near-correct use of the KeyPad for the joystick). Note that
;clock ticks still occur even after a break-point (INT 3) is
;encountered. So do NOT set breakpoints (or single-step) any of
;the keyboard/interrupt handler code.

;Now return 18.2 Hz clock tick to MS-DOS.

 pop ds
 assume ds:nothing
 pop es
 pop dx
 pop cx
 pop bx
 pop ax

;Now exit to the MS-DOS interrupt routine; This needs the stack
;balanced, keeps the TOD clock, resets the interrupt controller.

 db 0EAh ;Dissassembles as "JMP xxxx:xxxx" (inter-segment jump)
ClockVectorAddr dw 0
ClockVectorSeg  dw 0

;-------------------Interrupt not required by BIOS/MSDOS----------------

nonsystemtick:
;As MS-DOS will not now be processing this
;interrupt I must kick the harware myself.

 mov dx,0020h               ;Reset interupt controller
 mov al,dl
 out dx,al

;200 ticks per second. MS-DOS only needs 18.2 ticks per second,
;leaving 181.8 'spare' ticks reaching 'nonsystemtick'. It is
;difficult to get the multitasking correct while still calling
;the MS-DOS interrupt handler, so only the 'spare' ticks drive
;task-swapping.

;-------------------Interrupt now availbe for our own use---------------

IFE TwoD
 add cs:CS_FiftyCount,VBL_TimerCount ;Divide 182 Hz to give 50 Hz
 jnc NotFifty ;count wrapped.
 inc cs:CS_FiftyHertz       ;come hell and high water: exactly 50 Hz
NotFifty:

 add cs:CS_VBLCount,VBL_TimerCount ;Divide 182 Hz to give near-50 Hz
 jc VBLHandler ;count wrapped.
ENDIF ;TwoD

 pop ds
 assume ds:nothing
 pop es
 pop dx
 pop cx
 pop bx
 pop ax
 iret ;enable interrupts

;---------------------------------------------------------------------
;On the ST two separate 50 Hz timers (one occurs with V sync)
;are used for VBL (mouse driver and frame flipping) and Scheduler
;---------------------------------------------------------------------

VBLHandler:
;IRQVblHandler - Timer B, Scheduler
;IRQHblHandler - Frame Swap & VBL (mouse)

 cmp ds:HiLo_VBLDisabled,0
 jnz VBLdOff                ;VBL processing is a true 'subroutine'
 call Game_VBL              ;so can be called in the middle of IRQ.
VBLdOff:

;----------------------------50Hz Scheduler-----------------------------

 push si
 push di
 push bp

;I do not task-swap while in DRIVER.BIN, as this then
;allows the screen driver to be written non-reentrant.

;8/3/89 task-swaps in 'SEG CODE' (the machine code) appeared to
;screw the system, as the % time spent in this code is small I
;have disabled this.

;screen accesses, keyboard and joystick go to hardware directly,
;so MS-DOS and the BIOS will only be invoked by one task, so do
;not need to be re-entrant.

   IFE TwoD
 mov bp,sp
 mov ax,ss:20[bp]           ;Code segment where interrupt occurred.
 cmp ax,seg code
; je vh09                    ;interrupt occured in machine-code, stop multi-task
; cmp ax,cs:CS_DriverSeg
 jne vh01                   ;interrupt occured in DRIVER.BIN
   ENDIF ;TwoD

;Set counter to trap another interrupt in 5 ms time.

vh09:
 sub cs:CS_VBLCount,VBL_TimerCount
 pop bp
 pop di
 pop si

 pop ds
 assume ds:nothing
 pop es
 pop dx
 pop cx
 pop bx
 pop ax
 iret ;enable interrupts

;---------------------------------------------------------------------
;The 8086 stack structure make it difficult to do anything whilst
;inside an interrupt routine, so first I pretent to the hardware
;that interrupt processing has finished
;---------------------------------------------------------------------

vh01:
 pop bp
 pop di
 pop si
 pop ds
 assume ds:nothing
 pop es
 pop dx
 pop cx
 pop bx
 pop ax

;I now have all the registers, except cs:ip and flags

 mov cs:IRQ_AX,ax
 pop ax
 mov cs:IRQ_IP,ax
 pop ax
 mov cs:IRQ_CS,ax
 pop ax                     ;flags at time of interrupt; interrupts enabled
 and ax,0FDFFh              ;disable interrupts
 push ax                    ;copy task flags to real flags
 popf                       ;flags at time of interrupt; interrupts disabled

;-----------------------------------------------------------------------

 mov ax,cs:IRQ_CS           ;Put on values for RETF
 push ax
 mov ax,cs:IRQ_IP
 push ax

;JUMP to VirtualFarCall...
 pushf
 mov ax,cs
 push ax
 mov ax,offset VirtualFarCall
 push ax
 mov ax,cs:IRQ_AX
 iret                       ;keep interrupts disabled; flag interrupt complete

;---------------------As though done a CALL FAR to here-----------------

VirtualFarCall:
;As far as the hardware is concerned, interrupt processing is
;complete. We are now back at the point before the interrupt
;occurred with three exceptions
;   (1) cs:ip is 'here'
;   (2) the cs:ip at the point of the interrupt is on the stack.
;   (3) interrupts are disabled
;This happens to be as though the task had executed a 'CALL FAR'

 pushf
 push ax
 push bx
 push cx
 push dx
 push es
 push ds
 push si
 push di
 push bp

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 cmp ds:HiLo_VBLDisabled,0 ;ST system tests this for VBL and Task interrupts
 jnz SchedOff
 call Game_Scheduler
SchedOff:

 pop bp
 pop di
 pop si
 pop ds
 assume ds:nothing
 pop es
 pop dx
 pop cx
 pop bx
 pop ax
 popf                       ;keep interrupts disabled
 sti ;enable interrupts

Dummy proc far
 retf
Dummy endp

;-----

 even
IRQ_CS      dw 0
IRQ_IP      dw 0
IRQ_AX      dw 0

CS_ClockCount dw 0
CS_VBLCount   dw 0
CS_FiftyCount dw 0

CS_FiftyHertz dw 0

;-----

;CTRL-ALT-DEL or fatal error:

SilentFatalError:
 cli                        ;prevent further interrupts
 mov ax,0
 mov ds,ax                  ;Simulate hardware reset.
 assume ds:nothing
 mov ss,ax                  ;(protected move)
 mov es,ax
 push ax
 popf
 db 0EAh                    ;Dissassembles as "JMP 0FFFFh:0000"
 dw 00000h                  ;(intra-segment jump)
 dw 0FFFFh

;-----------------------------------------
;         KEYBOARD
;-----------------------------------------

 assume cs:code
 assume ds:nothing

 if DosKeyboard

ConvertRealKeyboard proc near

;When running under SYMDEB, keyboard scan codes must be put in
;the DOS buffer. This code is a kludge to still give a
;near-correct use of the KeyPad for the joystick. Note that clock
;ticks still occur even after a break-point (INT 3) is encountered.
;So do NOT set breakpoints (or single-step) any of the 
;keyboard/interrupt handler code.

 push si

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,40h
 mov es,ax
 assume es:nothing

 mov ds:B_JoystickStatus,0
 mov si,1Eh                 ;41E = Keyboard buffer
 mov cx,16                  ;16-words
st01:
 mov ax,es:[si]
 cmp al,0
 jne st03                   ;Not a cursor key.

 mov al,128                 ;Fire on
 cmp ah,59                  ;F1 = Fire (128)
 je st02
 cmp ah,76                  ;Keypad centre/Fire
 je st02
 cmp ah,6                   ;'5'
 je st02

 mov al,1+4                 ;Up+Left
 cmp ah,71                  ;'home'
 je st02
 cmp ah,8                   ;'7'
 je st02

 mov al,1                   ;Up
 cmp ah,72                  ;'cursor up'
 je st02
 cmp ah,9                   ;'8'
 je st02

 mov al,1+8                 ;Up+Right
 cmp ah,73                  ;PgUp
 je st02
 cmp ah,10                  ;'9'
 je st02

 mov al,4                   ;left
 cmp ah,75                  ;'cursor left'
 je st02
 cmp ah,5                   ;'4'
 je st02

 mov al,8                   ;Right
 cmp ah,77                  ;'cursor right'
 je st02
 cmp ah,7                   ;'6'
 je st02

 mov al,2+4                 ;Down+Left
 cmp ah,79                  ;'end'
 je st02
 cmp ah,2                   ;'1'
 je st02

 mov al,2                   ;Down
 cmp ah,80                  ;'cursor down'
 je st02
 cmp ah,3                   ;'2'
 je st02

 mov al,2+8                 ;Down+Right
 cmp ah,81                  ;'PgDn'
 je st02
 cmp ah,4                   ;'3'
 je st02

 mov al,0                   ;no joystick keys pressed
st02:
 or ds:B_JoystickStatus,al

 mov word ptr es:[si],0     ;Substitute ALT-000

st03:
 add si,2
 loop st01

 mov ax,0B800h
 mov es,ax

 pop si

;When running under SYMDEB, keyboard scan codes must be put in
;the DOS buffer. This code is a kludge to still give a 
;near-correct use of the KeyPad for the joystick.

 mov ah,0                   ;Read next keyboard
 int 16h                    ;Keyboard Service

 cmp ax,0                   ;Joystick code now overwritten by ALT-000
 je ConvertRealKeyboard

 mov al,ah
 mov ah,0
 mov si,ax

 push si
 mov ax,si
 add si,ax ;x2
 add si,si ;x4
 add si,ax ;x5
 mov ah,0
 mov al,byte ptr cs:KeyboardTable+2[si]
 pop si

 ret

ConvertRealKeyboard endp

;-----

 else ;DosKeyboard

;-----

MachineID db 0              ;machine-type

 even
Delay dw 0
Length0 dw 0

;One-shot keyboard...
Response_On   dw 0
Response_Code db 0
LastKeyCode   dw 0 ;IF set to 224 (0E0h) indicates Amstrad or 386
                   ;extended keycode.
;-----

kbdinit proc near

;Keyboard interrupt
 mov ax,seg vars
 mov es,ax
 mov ax,0
 mov si,offset GSX_Down
 mov cx,64 ;128 bytes
ClearGSX:
 stosw ; mov ds:[si],0
 loop ClearGSX

 push es
 SaveVector 09h,ds:vectorsave1,ds:vectorsave2
 pop es

 purge SaveVector           ;speed up assembly

 call L0858
 ret

kbdinit endp

Kbd_Unhook proc near

 push ds
 mov dx,ds:vectorsave2
 mov ds,ds:vectorsave1      ;segment
 assume ds:nothing
 mov ax,ds
 cmp ax,0
 je kr01
 assume ds:nothing
 mov ax,2509h               ;Keyboard interrupt
 int 21h                    ;DOS function. Set interrupt vector
kr01:
 pop ds
 assume ds:nothing
 ret

Kbd_Unhook endp

;-----

Break:                      ;ESCAPE key
 jmp BreakPoint

;-----

;Trap INT 9 and turn them into ASCII.

SimulateKeyboard proc near

;Extended keycodes produce same ASCII as there non-extended equivalent

 push ds

 push ax
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 pop ax

 push si
 push ax

; cmp al,61                  ;F3 key down
; je Break

 test al,0080h
 jz sk01                    ;key down
 jmp sk02             ;key up

sk01:
 cmp al,29                  ;ctrl
 jne sk21
 or byte ptr ds:Shift_Status,Ctrl_Bit
 jmp sk03
sk21:
 cmp al,42                  ;shift
 jne sk22
 or byte ptr ds:Shift_Status,Shift_Bit
 jmp sk03
sk22:
 cmp al,54                  ;shift
 jne sk23
 or byte ptr ds:Shift_Status,Shift_Bit
 jmp sk03
sk23:
 cmp al,56                  ;alt
 jne sk24
 or byte ptr ds:Shift_Status,Alt_Bit
 jmp sk03
sk24:
 cmp al,83                  ;del
 jne sk25
 or byte ptr ds:Shift_Status,Del_Bit
 jmp sk03
sk25:
 and ax,07Fh                ;Make to 16-bit and mask top bit.
 mov si,ax

 mov al,byte ptr ds:Shift_Status
 and al,3                   ;Just get Ctrl and Shift status bitsd

 cmp al,0                   ;No Ctrl/No Shift
 jne sk10

 push si
 mov ax,si
 add si,ax ;x2
 add si,si ;x4
 add si,ax ;x5
 mov ah,0
 mov al,byte ptr cs:KeyboardTable+2[si]
 pop si

 jmp short sk13

sk10:
 cmp al,1                   ;Shift/No Ctrl
 jne sk11

 push si
 mov ax,si
 add si,ax ;x2
 add si,si ;x4
 add si,ax ;x5
 mov ah,0
 mov al,byte ptr cs:KeyboardTable+3[si]
 pop si

 jmp short sk13

sk11:
;Ctrl/No Shift or Ctrl/Shift
 push si
 mov ax,si
 add si,ax ;x2
 add si,si ;x4
 add si,ax ;x5
 mov ah,0
 mov al,byte ptr cs:KeyboardTable+4[si]
 pop si

sk13:

 mov ds:B_LastKeyPressed,al
 jmp short sk03

sk02:                       ;Key released
 and al,07Fh
  IFE TwoD
 mov ds:B_LastKeyPressed,0
  ENDIF ;TwoD
 cmp al,29                  ;ctrl
 jne sk31
 and byte ptr ds:Shift_Status,0FFh-Ctrl_Bit
 jmp short sk03
sk31:
 cmp al,42                  ;shift
 jne sk32
 and byte ptr ds:Shift_Status,0FFh-Shift_Bit
 jmp short sk03
sk32:
 cmp al,54                  ;shift
 jne sk33
 and byte ptr ds:Shift_Status,0FFh-Shift_Bit
 jmp short sk03
sk33:
 cmp al,56                  ;alt
 jne sk34
 and byte ptr ds:Shift_Status,0FFh-Alt_Bit
 jmp short sk03
sk34:
 cmp al,83                  ;del
 jne sk35
 and byte ptr ds:Shift_Status,0FFh-Del_Bit
 jmp short sk03
sk35:

sk03:
 pop ax
 pop si

 pop ds
 assume ds:nothing
 ret

SimulateKeyboard endp

;-----

SimulateGSX proc near

 push ax
 push si
 push ds
 cmp ax,80h
 ja sg01

 mov si,ax

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 cmp cs:LastKeyCode,000E0h
 je sg99

 ;Received an 0E0 key code, so try to interpret
 ;this as an extended key (Amstrads, Tandys and
 ;286/386 only)

 push si
 push ax
 mov ax,si
 add si,ax ;x2
 add si,si ;x4
 add si,ax ;x5
 pop ax
 mov ah,byte ptr cs:KeyboardTable+1[si]
 pop si

 cmp ah,0
 jne short sg98

sg99:
;non-extended key code

 push si
 push ax
 mov ax,si
 add si,ax ;x2
 add si,si ;x4
 add si,ax ;x5
 pop ax
 mov ah,byte ptr cs:KeyboardTable[si]
 pop si

sg98:
 mov al,ds:B_LastKeyPressed ;Set up by SimulateKeyboard
 and ax,ax
 je sg01 ;Key did not translate to ASCII or GSX (e.g. NUM LOCK)

 mov si,ds:GSX_WritePtr     ;Hi byte remains as zero
 mov word ptr ds:GSX_Queue[si],ax
 add byte ptr ds:GSX_WritePtr,2 ;Lo byte only

;>>>>>>>>>>>>>>>>>>>
;;ax is scan code
;* push ax
;* push bx
;* push es
;* push di
;* mov ah,07 ;normal
;* mov bx,0B000h ;monochrome
;* mov es,bx
;* mov di,cs:counter
;* stosw
;* add cs:counter,2

;* pop di
;* pop es
;* pop bx
;* pop ax

;>>>>>>>>>>>>>>>>>>

sg01:
 pop ds
 assume ds:nothing
 pop si
 pop ax
 ret

SimulateGSX endp

;-----

UpdateKeyDown proc near

 push ds
 push bx

 push ax
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 pop ax

 mov bx,ax
 and bx,007Fh

 push si
 push bx
 mov bx,si
 add si,bx ;x2
 add si,si ;x4
 add si,bx ;x5
 mov bl,byte ptr cs:KeyboardTable[si]
 pop bx
 pop si

 test al,128
 jnz uk01
 mov ds:GSX_Down[bx],1
 jmp short uk02
uk01:
 mov ds:GSX_Down[bx],0
uk02:

 pop bx
 pop ds
 assume ds:nothing
 ret

UpdateKeyDown endp

;-----

SimulateJoystick proc near

 push ds
 push ax

 push ax
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 pop ax

 push bx
 push cx
 mov bx,0
 mov cx,NumberCodes
Search:
 cmp cs:SetCodeTable[bx],al
 je FoundSet
 cmp cs:RelCodeTable[bx],al
 je FoundRel
 inc bx
 loop Search
 jmp short SetJoystick
FoundSet:
 mov cs:DebounceTable[bx],1
 jmp short SetJoystick
FoundRel:
 mov cs:DebounceTable[bx],0
SetJoystick:
 pop cx
 pop bx

 push bx
 push cx
 mov ds:B_JoystickStatus,0
 mov bx,0
 mov cx,NumberCodes
ScanPressed:
 cmp cs:DebounceTable[bx],0
 je NotPressed
 mov al,cs:PressTable[bx]
 or ds:B_JoystickStatus,al
NotPressed:
 inc bx
 loop ScanPressed
 pop cx
 pop bx

;Filter opposite keypresses...
 mov al,ds:B_JoyStickStatus
 mov ah,0
 mov si,ax
 mov al,byte ptr cs:OppositeClash[si]
 mov ds:B_JoyStickStatus,al

 cmp cs:DebounceTable+4,0   ;'5'
 jne sj20
 cmp cs:DebounceTable+9,0   ;F1=Fire
 jne sj20
 cmp cs:DebounceTable+14,0  ;pad centre
 je sj21
sj20:
 or ds:B_JoyStickStatus,128 ;fire
sj21:

 pop ax
 pop ds
 assume ds:nothing
 ret

SimulateJoystick endp

SetCodeTable  db 2,3,4,5,6,7,8,9,10,59,71,72,73,75,76,77,79,80,81
RelCodeTable  db 128+2,128+3,128+4,128+5,128+6,128+7,128+8,128+9
              db 128+10,128+59,128+71,128+72,128+73,128+75,128+76
              db 128+77,128+79,128+80,128+81
DebounceTable db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

PressTable db 0110b ;1    sw down+left
           db 0010b ;2    s  down
           db 1010b ;3    se down+right
           db 0100b ;4    w  left
           db 0
           db 1000b ;6    e  right
           db 0101b ;7    nw up+left
           db 0001b ;8    n  up
           db 1001b ;9    ne up+right
           db 0     ;F1
           db 0101b ;Home nw up+left
           db 0001b ;     n  up
           db 1001b ;PgUp ne up+right
           db 0100b ;     w  left
           db 0
           db 1000b ;     e  right
           db 0110b ;End  sw
           db 0010b ;     s
           db 1010b ;PgDn se
NumberCodes = this byte - PressTable

OppositeClash = this byte
 db 0     ;no key pressed
 db 0001b ;n
 db 0010b ;s
 db 0     ;n+s
 db 0100b ;w
 db 0101b ;n+w
 db 0110b ;s+w
 db 0     ;w+n+s
 db 1000b ;e
 db 1001b ;n+e
 db 1010b ;s+e
 db 0     ;s+e+n
 db 0     ;w+e
 db 0     ;w+e+n
 db 0     ;w+e+s
 db 0     ;w+e+s+n

 endif ;DosKeyboard

;-----

; db A ;GSX code
; db B ;GSX code (non-zero) when extended (B=0 implies B=A)
; db C ;ascii code
; db D ;ascii code with SHIFT
; db E ;ascii code with CTRL (overrides SHIFT)

;Note: Extended key codes send TWO bytes (packets) and are used
;on Amstrad and 386 machines which have two many keys for some
;BIOSs to handle. Extended keys are signaled by the first byte=224

;MS-DOS appears to convert to ASCII as though the 224 was missing.
;It is up to application programs to distinguish them (this allows
;cursor keys and HOME/END/PGUP/PGDOWN to be separate keys)

;I use extended keys to map on to those keys the ST has but IBM
;does not: such as HELP and UNDO (needed for editor)

KeyBoardTable = this byte
 db 0,0,0,0,0          ;0 nul
 db 1,0,1Bh,1Bh,1Bh    ;1 ESC
 db 2,0,'1','!',0      ;2 1
 db 3,0,'2','@',0      ;3 2
 db 4,0,'3','#',0      ;4 3
 db 5,0,'4','$',0      ;5 4
 db 6,0,'5','%',0      ;6 5
 db 7,0,'6','^',0      ;7 6
 db 8,0,'7','&',0      ;8 7
 db 9,0 ,'8','*',0     ;9 8
 db 0Ah,0,'9','(',0    ;10 9
 db 0Bh,0,'0',')',0    ;11 0
 db 0Ch,0,'-','_',8    ;12 -
 db 0Dh,0,'=','+',9    ;13 =  The GSX code 0Dh is not documented in the Atari
                       ;      ST manual and no code is listed for '=';
 db 0Eh,0,8,8,8        ;14 backspace
 db 0Fh,0,9,9,9        ;15 tab

 db 10h,0,'q','Q','q'  ;16 Q
 db 11h,0,'w','W','w'  ;17 W
 db 12h,0,'e','E','e'  ;18 E
 db 13h,0,'r','R','r'  ;19 R
 db 14h,0,'t','T','t'  ;20 T
 db 15h,0,'y','y','y'  ;21 Y
 db 16h,0,'u','U','u'  ;22 U
 db 17h,0,'i','I','i'  ;23 I
 db 18h,0,'o','O','o'  ;24 O
 db 19h,0,'p','P','p'  ;25 P
 db 1Ah,0,'[','{','['  ;26 [
 db 1Bh,0,']','}',']'  ;27 ]
 db 1Ch,0,0Dh,0Dh,0Dh  ;28 enter
 db 1Dh,0,0,0,0        ;29 ctrl (right ctrl)
 db 1Eh,0,'a','A','a'  ;30 A
 db 1Fh,0,'s','S','s'  ;31 S

 db 20h,0,'d','D','d'  ;32 D
 db 21h,0,'f','F','f'  ;33 F
 db 22h,0,'g','G','g'  ;34 G
 db 23h,0,'h','H','h'  ;35 H
 db 24h,0,'j','J','j'  ;36 J
 db 25h,0,'k','K','k'  ;37 K
 db 26h,0,'l','L','l'  ;38 L
 db 27h,0,';',':',0    ;39 ;
 db 28h,0,"'",'"',0    ;40 '
 db 29h,0,"`",'~',0    ;41 `
 db 2Ah,0,0,0,0        ;42 shift
 db 2Bh,0,'\','|',0    ;43 \
 db 2Ch,0,'z','Z','z'  ;44 Z
 db 2Dh,0,'x','X','x'  ;45 X
 db 2Eh,0,'c','C',3    ;46 C control-c
 db 2Fh,0,'v','V','v'  ;47 V

 db 30h,0,'b','B','b' ;48 B
 db 31h,0,'n','N','n' ;49 N
 db 32h,0,'m','M','m' ;50 M
 db 33h,0,',','<',0   ;51 ,
 db 34h,0,'.','>',0   ;52 .
 db 35h,0,'/','?',0   ;53 /
 db 36h,0,0,0,0        ;54 shift
 db 37h,0,'*',0,0      ;55 * prtsc
 db 38h,0,0,0,0        ;56 alt
 db 39h,0,' ',' ',' '  ;57 space
 db 3Ah,0,0,0,0        ;58 caps shift
 db 3Bh,0,0,0,0        ;59 F1
 db 3Ch,0,0,0,0        ;60 F2
 db 3Dh,0,0,0,0        ;61 F3
 db 3Eh,0,0,0,0        ;62 F4
 db 3Fh,0,0,0,0        ;63 F5
 
;Extended keyboards use dedicated keys for PrintScreen, Cursor keys etc...
 db 40h,0,0,0,0        ;64 F6
 db 41h,0,0,0,0        ;65 F7
 db 42h,0,0,0,0        ;66 F8
 db 43h,0,0,0,0        ;67 F9
 db 44h,0,0,0,0        ;68 F10
 db 0,0,0,0,0          ;69 num lock
 db 0,0,0,0,0          ;70 Scroll lock
 db 67h,0,'7',0,0      ;71 Pad 7
 db 48h,68h,'8',0,0    ;72 Pad 8   (Extended = Cursor Up)
 db 69h,0,'9',0,0      ;73 Pad 9
 db 4Ah,0,'-',0,0      ;74 Pad -
 db 4Bh,6Ah,'4',0,0    ;75 Pad 4   (Extended = Cursor Left)
 db 6Bh,0,'5',0,0      ;76 Pad 5
 db 4Dh,6Ch,'6',0,0    ;77 Pad 6   (Extended = Cursor right)
 db 4Eh,0,'+',0,0      ;78 Pad +
 db 6Dh,0,'1',0,0      ;79 Pad 1

 db 50h,6Eh,'2',0,0    ;80 Pad 2  (Extended = Cursor down)
 db 6Fh,0,'3',0,0      ;81 Pad 3
 db 70h,0,'0',0,0      ;82 ins
 db 71h,0,7Fh,7Fh,7FH  ;83 del
 db 98,0,0,0,0         ;84 sys Req (gives help)
 db 0,0,0,0,0          ;85
 db 0,0,0,0,0          ;86
 db 0,0,0,0,0          ;87
 db 0,0,0,0,0          ;88
 db 0,0,0,0,0          ;89
 db 0,0,0,0,0          ;90
 db 0,0,0,0,0          ;91
 db 0,0,0,0,0          ;92
 db 0,0,0,0,0          ;93
 db 0,0,0,0,0          ;94
 db 0,0,0,0,0          ;95

 db 0,0,0,0,0          ;96
 db 0,0,0,0,0          ;97
 db 0,0,0,0,0          ;98
 db 0,0,0,0,0          ;99
 db 0,0,0,0,0          ;100
 db 0,0,0,0,0          ;101
 db 0,0,0,0,0          ;102
 db 0,0,0,0,0          ;103
 db 0,0,0,0,0          ;104
 db 0,0,0,0,0          ;105
 db 0,0,0,0,0          ;106
 db 0,0,0,0,0          ;107
 db 0,0,0,0,0          ;108
 db 0,0,0,0,0          ;109
 db 0,0,0,0,0          ;110
 db 0,0,0,0,0          ;111

 db 0,0,0,0,0          ;112
 db 0,0,0,0,0          ;113
 db 0,0,0,0,0          ;114
 db 0,0,0,0,0          ;115
 db 0,0,0,0,0          ;116
 db 0,0,0,0,0          ;117
 db 0,0,0,0,0          ;118
 db 0,0,0,0,0          ;119
 db 0,0,0,0,0          ;120
 db 0,0,0,0,0          ;121
 db 0,0,0,0,0          ;122
 db 0,0,0,0,0          ;123
 db 0,0,0,0,0          ;124
 db 0,0,0,0,0          ;125
 db 0,0,0,0,0          ;126
 db 0,0,0,0,0          ;127

;-----

 ife DosKeyboard

;-----

;Interrupt handler

KeyboardAction:
 sti
 cld
 push ax
 push bx
 push cx
 push dx
 push si
 push di
 push ds
 mov ax,0040h               ;BIOS workspace
 mov ds,ax
 assume ds:nothing
 call L0782
 mov ah,al                  ;(keyboard code?)
 cmp al,0FFh
; jne L0303
; jmp short L06E1            ;Ignore code...
;L0303:
 je L06E1            ;Ignore code...
 cmp cs:Response_On,0
 je PutKeyboardBuffer

 mov cs:Response_Code,al
 mov cs:Response_On,0
 jmp short L06EB            ;invalid key code.. ignore the interrupt

PutKeyboardBuffer:
 mov ah,0
 call SimulateKeyboard

;*****
 push ax
 push ds
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov al,Shift_Status        ;Get keyboard status
 and al,Alt_Bit+Del_Bit+Ctrl_Bit
 cmp al,Alt_Bit+Del_Bit+Ctrl_Bit
 jne notreset
 jmp SilentFatalError
notreset:
 pop ds
 pop ax
;*****

 call SimulateGSX
 call SimulateJoystick
 call UpdateKeyDown
 mov cs:LastKeyCode,ax
 jmp short L06EB            ;invalid key code.. ignore the interrupt

;*counter dw 0 ;>>>>>>>>>>

L06E1:                      ;...Tidy up and return from interrupt
 cli
 mov al,20h
 out 20h,al                 ;Interrupt controller
 call L0737                 ;(flush)
 jmp short L06F0
L06EB:                      ;...Return from interrupt
 cli
 mov al,20h
 out 20h,al                 ;Interrupt controller
L06F0:
 call L0713                 ;(flush AT)
 cli
 pop ds
 assume ds:nothing
 pop di
 pop si
 pop dx
 pop cx
 pop bx
 pop ax
 iret ;also restores flags (and hence interrupts)

L0713:                      ;(flush AT)
 cmp cs:[MachineID],0FCh    ;Machine=AT?
 jne L0724
;AT only:
 cli
 call L084D
 mov al,0AEh
 out 64h,al                 ;Keyboard
 sti
L0724:
 ret

L0725:                      ;AT only:
 cmp cs:[MachineID],0FCh    ;Machine=AT?
 jne L0736
;AT only:
 cli
 call L084D
 mov al,0ADh
 out 64h,al                 ;Keyboard
 sti
L0736:
 ret

L0737:                      ;(flush)
 push ax
 push bx
 push cx
 mov bx,cs:[Length0]        ;(length)
 in al,61h                  ;Keyboard
 push ax
 and al,0FCh
L0744:
 xor al,02
 out 61h,al                 ;Keyboard
 mov cx,cs:[Delay]          ;(delay)
L074D:
 loop L074D
 dec bx
 jnz L0744
 pop ax
 out 61h,al                 ;Keyboard
 pop cx
 pop bx
 pop ax
 ret

 assume ds:nothing
L0782:
 cmp cs:[MachineID],0FCh    ;Machine=AT?
 je L079B
;PC/XT/PCjr:
 in al,60h                  ;Keyboard
 xchg ax,bx
 in al,61h                  ;Keyboard
 mov ah,al
 or al,80h
 out 61h,al                 ;Keyboard
 xchg ah,al
 out 61h,al                 ;Keyboard
 xchg ax,bx
 ret
L079B:
;AT only:
 call L0725
 cli
 call L084D
 in al,60h                  ;keyboard
 sti
 cmp al,0FEh
 jne L07B3
 cli
 or byte ptr ds:[0097h],20h
 pop bx
 jmp L06EB
L07B3:                      ;AT only
 cmp al,0FAh
 jnz L07C1
 cli
 or byte ptr ds:[0097h],10h
 pop bx
 jmp L06EB
L07C1:                      ;AT only
 call L07C5
 ret
L07C5:                      ;AT only
 push ax
 cli
 mov ah,ds:[0017h]          ;keyboard status
 and ah,70h                 ;Caps/Num/Scroll
 ROL ah,1
 ROL ah,1
 ROL ah,1
 ROL ah,1
 mov al,ds:[0097h]
 and al,07h
 cmp ah,al                  ;Keyboard state changed?
 je L0815
 test byte ptr ds:[0097h],40h
 jnz L0815
 or byte ptr ds:[0097h],40h
 mov al,20h
 out 20h,al                 ;Interrupt controller
 mov al,0EDh
 call L0818
 test byte ptr ds:[0097h],80h
 jnz L0810
 mov al,ah
 call L0818
 test byte ptr ds:[0097h],80h
 jnz L0810
 and byte ptr ds:[0097h],0F8h
 or ds:[0097h],ah
L0810:
 and byte ptr ds:[0097h],3Fh
L0815:
 pop ax
 sti
 ret
L0818:                      ;AT only
 push ax
 push cx
 mov ah,03
L081C:
 cli
 and byte ptr ds:[0097h],4Fh
 push ax
 call L084D
 pop ax
 out 60h,al                 ;Keyboard
 sti
 mov cx,2000h
L082D:
 test byte ptr ds:[0097h],30h
 jnz L0842
 loop L082D
L0836:
 dec ah
 jnz L081C
 or byte ptr ds:[0097h],80h
 jmp short L0849

L0842:
 test byte ptr ds:[0097h],20h
 jnz L0836
L0849:
 cli
 pop cx
 pop ax
 ret

L084D:                      ;AT only
 push cx
 xor cx,cx
L0850:
 in al,64h                  ;Keyboard
 test al,02
 loopnz L0850
 pop cx
 ret

;-----

;entry point:

L0858:
 push ds
 mov ax,cs
 mov ds,ax
 assume ds:code

 mov dx,offset KeyboardAction ;New keyboard interrupt handler = ds:dx
 mov ax,2509h
 int 21h                    ;DOS function. Set interrupt vector

 mov ax,0F000h
 mov ds,ax
 assume ds:nothing
 mov al,ds:[0FFFEh]         ;Get Machine ID
 mov cs:[MachineID],al
 pop ds
 assume ds:nothing
 mov dx,offset L0858+128    ;(End of resident program)
 cmp cs:[MachineID],0FCh    ;Machine=AT?
 jne L0920
;AT only:
 mov cs:[Delay],00CEh       ;(delay)
 mov cs:[Length0],0082h     ;(length)
L0920:
 sub dx,0000
 mov cl,04
 shr dx,cl
 mov ah,31h
 ret

 endif ;DosKeyboard

;...e

;-----

;...sAcode Subroutines:0:

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 49
;-------------------------------------

MCInitTask proc near        ;31

;V1 = offset into L_MTCB
;V2 = stack usage of all currently running tasks.
;V3 = ST 520/1040 entry point (relative AcodeFns)

 if TraceCode          ;@
 mov cs:debugword,800h ;@
 endif ;TraceCode      ;@

 mov es,cs:CS_Acode

;Assembler does not permit external constants, so I cannot assemble:
;  'mov offset StackSize'

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,ds:TopOfMemoryAllocated
 rept 4
 shl ax,1                   ;bytes between top of memory and 'ss:0'
 endm ;rept
 sub ax,es:V2               ;allow room for currently tunning tasks
 sub ax,es:V2
 mov bp,ax                  ;Save stack address for new task

 mov si,cs:prgstr

;es:si is now start of acode. For Hero/Adept this will be:
;   0,1  data @Dummy
;   2,3  data @Dummy
;   4    code +
;   5,6  data @AcodeFns
;   7,8  data @McFns

 add si,es:5[si]            ;Get value of 'AcodeFns'

 mov ax,es:V3               ;get entry point address
;ST entry points are four bytes
 shr ax,1
 shr ax,1                   ;ax is now entry point number
 add si,ax
 add si,ax
 add si,ax                  ;PC uses three bytes per entry

;Task will start running from a point within the subroutine
;'SNOOZE' where are the values for the processor status,
;including the task CS:IP are on the stack

 sub bp,24

;Save task entry point on new stack
 mov ss:22[bp],es           ;segment address
 mov ss:20[bp],si           ;entry point
 pushf
 pop ax
 mov ss:18[bp],ax           ;flags

;Note: All compiled acode requires ds=cs and dh=0 at all times,
;so this must be set for the first time acode is run, when a new
;acode task starts, and when returning from machine-code to
;compiled acode.

 mov ss:16[bp],0606h        ;ax
 mov ss:14[bp],0505h        ;bx
 mov ss:12[bp],0404h        ;cx
 mov word ptr ss:10[bp],0   ;dx, dh=0
 mov ax,cs:CS_GameData
 mov ss:08[bp],ax           ;es = GameData
 mov ax,cs:CS_Acode
 mov ss:06[bp],ax           ;ds = GameData
 mov ss:04[bp],0303h        ;si
 mov ss:02[bp],0202h        ;di
 mov ss:00[bp],0101h        ;bp

;and set up L_MTCB pointer to stack entries
 mov si,offset L_MTCB
 add si,es:V1               ;offset into L_MTCB

 mov ds:2[si],ss            ;write in stack segment
 mov ds:0[si],bp            ;write in stack pointer

 if TraceCode          ;@
 mov cs:debugword,801h ;@
 endif ;TraceCode      ;@

 jmp MCReturn

MCInitTask endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 50
;-------------------------------------

MCSnooze proc near          ;32

 pushf
 push ax
 push bx
 push cx
 push dx
 push es
 push ds

 push si
 push di
 push bp

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,100h
 xchg ax,ds:HiLo_SuspendTaskSwap ;interlock multi-tasking
 cmp ax,0
 je SuspendSet                   ;Was clear; Now set; proceed with swap
 xchg ax,ds:HiLo_SuspendTaskSwap ;Was set; restore previous count
 jmp short istnoswap

SuspendSet:
 mov bx,ds:HiLo_LoLongCurrentTask
 xchg bh,bl
 mov word ptr ds:L_MTCB+2[bx],ss ;save stack segment
 mov word ptr ds:L_MTCB+0[bx],sp ;save stack pointer

 mov ax,ds:HiLo_LoLongNextTask
 mov ds:HiLo_LoLongCurrentTask,ax
 xchg ah,al
 mov di,ax

;and now do the task swap!

 mov ss,word ptr ds:L_MTCB+2[di] ;protected move - stack valid all the time
 mov sp,word ptr ds:L_MTCB+0[di]

 mov ds:HiLo_SuspendTaskSwap,0   ;Re-enable task swapping

istnoswap:
 pop bp
 pop di
 pop si

 pop ds
 pop es
 pop dx
 pop cx
 pop bx
 pop ax
 popf

 jmp MCReturn

MCSnooze endp

;...e

;-----

code ends

;-----

;...sVariables:0:

vars segment word public 'data'

GSX_WritePtr dw 0

GSX_Queue db 256 dup (0) ;128 ascii codes + 128 GSX codes

GSX_Down db 128 dup(0)

 even
vectorsave1 dw 0
vectorsave2 dw 0

 even
Shift_Status db 0

vars ends

;...e

;-----

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################

