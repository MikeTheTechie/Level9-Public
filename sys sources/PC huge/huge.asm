 page 128,122 ;length,width
;IBM 2D\3D HERO adventure system.

;HUGE.ASM

;Copyright (C) 1988,1989 Level 9 Computing

;-----

;6/10/89
;  Allowed driver to select Clock (Timer 0) handler

;21/9/89
;  Removed 'driverresult' and associated parameter passing. made ds:[bp]
;  always point to next ACODE.ACD byte.

;14/9/89
;  Interpreted list writes were ignoring list address set up in list11.

;13/9/89
;  Checks for ACODE.ACD file allocates space, but does not load.

;24/4/89
;  Altered (improved?) text printing (to BufferScreen2; stop CGA flicker)

;19/4/89
;  Graphics driver/Get character did not advance read-pointer.

;13/4/89
;  GETNEXT was old version

;13/4/89
;  MCOSWRCHV1 did not correctly set ES every time (printed wrong ascii code)

;16/3/89
;  Debug/Installer written.

;15/3/89.
;  Moved 'InLineDos' to 'DisplayVisibleString'
;  Bug in critical error handler (corrupted DI; error code)
;  checked memory allocation; changed 'c:1024' to 'c:1'

;14/3/89.
;  Corrected ScreenFlip errors when unitialised
;  Critical Dos Error handler.
;  SetUpPalette, Acode error reporting.

;10/3/89.
;  SetTextWindow, DX is number of lines-1.

;8/3/89.
;  Adjust 'ManageWindow' for buffer coords relative to (0,0)
;  removed 'NewDriver'; pre-load for cell 0; CGA requester code.
;  Get key press for driver.
;  Multi-tasking now NOT in DRIVER.BIN or SEG CODE; this cures ANOTHER
;    tasking bug & allows disk system to multi-task during init.

;6/3/89.
;  'Zero' cell bug found (& fixed) in EGA 3D driver
;  Added 'TwoD' 'NewDriver' and 'Production' options
;  Corrected CloseDown bug; errors recovery before DRIVER.BIN loaded

;Animated adventures. 2/3/89.
;  Acode '0Ch' instruction is now re-entrant
;  VBLhandler modified; used to crash (I presume because of nested interrupts)
;  Advance cursor; remove off-screen trap
;  irq-scheduler still has problems; acode does not required it (yet); removed
;  added better crash-error messages.
;  palette & HEADER.BIN names for demo versions.
;  CHAIN modified; uses GeneralLoadFIle

;Animated adventures. 1/3/89.
;  Hard disk ROM-BIOS requires use of unspecified INT's; re-ordered startup
;  Removed Check_Vectors, Save_Vectors; Divide/Overflow INTs removed.
;  New EGA driver; 50 Hz timer; Graphics text output
;  MCCopy disabled, MCSetPalette added.
;  Interrupt/Task-swap/VBL was not working; corrected, but occasionally crashes

;Animated adventures. 28/2/89.
;  CS_SnoozeInProgress added (text printing; 'false' reset-cursor bug)
;  reset palette in CloseDown
;  started changes for PC printing (new arguments for AddrPrintChar)
;  remove FLUSH from DISPLAYMESSAGE in AINT; required for ADEPT, but not GRANGE
;  TextOutIBM added; default SetWidow in OnceOnlyInit
;  LoadDriver requires MOV SI,0 before CALL GeneralLoadFile

;Animated Adventures. 25/2/89. Changes for DRIVER.BIN..
;  list 0 is ACB+Structure file
;  All driver calls via CALL DWORD PTR CS:vector
;  Remove VARIABLES.ASM Pass_Variables and Retrieve_Variables
;  Add InitBootPrg, SetUpPtrs and SetUpVariablesPtrs
;  CloseDown calls UnhookDiscBase
;  Add GrabAllMemory; Correct GrabMemory bug (jb -> jbe)
;  ScreenFlip and OnceOnlyInit return arguments.
;  MCOnceOnlyInit calls SetUpPalette
;  Change CS_ScreenMode in places
;  ObjectHandler requires RasterOffset

;Animated Adventures. 23/2/89. bug fixes for USA demonstration.
;  Change EXIT table.

;-----

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
 include consts.asm
 include common.asm
 include structs.asm

;...e

;...sPublics and externals:0:

 public CharacterHeap1
 public CharacterHeap2
 public CharLastAddr
 public CharLastSize
 public CharThisAddr
 public CharThisSize
;! public CS_CGA_CellSegment
;! public CS_CGA_FontSegment
;! public CS_CGA_LastFrame
;! public CS_CGA_Screen1
;! public CS_CGA_Screen2
;! public CS_CGA_ThisFrame
;! public CS_CGA_TransSegment
 public CS_AcodeSize
IFE TwoD
 public CS_DriverSeg
ENDIF ;TwoD
 public CS_FatalDiskErrors
 public CS_FreeParagraphs
 public CS_Acode
 public CS_GameData
 IF TwoD
  public CS_List3 ;I don't think this is neede
;!  public CS_ListsSegment
 ENDIF ;TwoD
;! public CS_ScreenMode
 public CS_ScreenSubMode
 public DriverSeed
 public DumpRegisters
 public HeroInit
 public MCCloseDown
 public SafeShutDown
 public TopOfMemoryAllocated

 if TwoD
  public CS_ViewSegment
  public EGA2DHeroReturn
 endif ;TwoD

;In AINT.ASM:
 extrn aint:near
 extrn AddressGameDataDat:word
 
;In BIN.ASM:
IFE TwoD
 extrn AddrCloseDown:dword ;*
 extrn AddrScreenFlip:dword
 extrn AddrSetupPalette:dword
 extrn AddrUnHookDiscBase:dword
 extrn CS_DriverClock:byte ;*
 extrn SetDriver:near
ENDIF ;TwoD

;In DRIVER.ASM:
 extrn displayhex:near
 extrn DisplayWord:near
 extrn GeneralLoadFile:near
 extrn InLineDos:near
 extrn SetCursor:near

;In GAME.ASM:
 IF TwoD
 extrn Pass_Variables:near
 extrn Retrieve_variables:near
;!  extrn B_LastKeyPressed:byte
 ENDIF ;TwoD
 extrn HiLongFreeWorkspace:word
 extrn HiLo_CursorXpos:word
 extrn HiLo_CursorYpos:word
 extrn HiLo_ScreenXpos:word
 extrn HiLo_ScreenYpos:word
 extrn HiLo_VBLdisabled:word
 extrn LoLongFreeWorkspace:word
 extrn LoLongPhysicalBase:word
 extrn LoLongTextScreenBase:word
 extrn SpriteTable:byte
   IF TwoD
 if TraceCode          ;@
 extrn CheckChain:near ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD
 if TraceCode          ;@
 extrn DebugWord:word  ;@
 endif ;TraceCode      ;@

;In IDENTIFY.ASM:
 extrn VideoID:near  ;entry point

;In INTRPT.ASM:
 extrn DisplayVisibleString:near
 extrn Graphics_Count:word
 extrn GSX_Queue:word
 extrn GSX_WritePtr:word
 extrn OriginalVectors:near
 extrn VectorsInit:near
 if DosKeyboard
  if TwoD
   extrn ConvertRealKeyboard:near
  endif ;TwoD
 else ;DosKeyboard
  extrn kbdinit:near
  extrn Kbd_Unhook:near
 endif ;DosKeyboard

;In MCODE.ASM:
 extrn Game_AcodeStart:near
 extrn GrabLowMemory:near
 extrn GSX_ReadPtr:word
 extrn SetUpHeroLists:near

   IF TwoD
;In MOVE.ASM:
 extrn SpriteTptr:word
   ENDIF ;TwoD

;In TABLES.ASM:
 extrn DefaultCells:byte

 IF TwoD
  extrn EGA2DHeroStart:near
  extrn EGA2DSCREENFLIP:near
  extrn PhysicalScreen:word
 ENDIF ;TwoD

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

 name run

code segment public 'code'

 assume cs:code

;Ascii/BBC control codes:
asciilf = 0Ah
asciicr = 0Dh

;-----

;...sCode entry point:0:

 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov ds:HiLo_VBLDisabled,100h ;ensure multi-tasking cannot start

;* call VideoID               ;Get display type(s)

 call InterruptInit         ;Set up keyboard & timer

 call MemoryInit            ;Grab all free memory

 cmp cs:CS_FreeParagraphs,(MultiTaskStackSize/16)
 jbe NoStackSpace

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

;Move STACK to the top of memory, this makes it easier to incorporate
;the stack as part of a segment allocation.

 mov ax,ds:LoLongFreeWorkspace
 add ax,cs:CS_FreeParagraphs ;ax=top of memory
 sub ax,(MultiTaskStackSize/16)
 mov ss,ax                  ;protected move - stack valid all the time
 mov sp,MultiTaskStackSize
 
;Allocate stack space for multi-tasking:
 mov ds:TopOfMemoryAllocated,(MultiTaskStackSize/16)
 sub cs:CS_FreeParagraphs,(MultiTaskStackSize/16)

;Initialise CGA 2D character plotting stacks...
 mov CharThisAddr,offset CharacterHeap1
 mov CharLastAddr,offset CharacterHeap2
 mov CharThisSize,0
 mov CharLastSize,0

 IFE TwoD
 call LoadInstaller
 ENDIF ;TwoD

   IFE TwoD
 call LoadDriver
   ENDIF ;TwoD

 call Disk_Init

   IF TwoD
 jmp EGA2DHeroStart
EGA2DHeroReturn:
   ENDIF ;TwoD

 jmp aint

NoStackSpace:
 mov ax,cs
 mov ds,ax

 mov dx,offset StackError
 mov ah,9                   ;Universal function 9, Display String
 int 21h
 mov ah,04Ch                ;Terminate process
 int 21h

StackError:
 db "Out of memory; Can't set stack.",0Dh,0Ah,"$"

;-----

InterruptInit:

 ife DosKeyboard
 call kbdinit
 endif ;DosKeyboard
 call VectorsInit

 ret

;-----

MemoryInit:
;; mov ax,seg vars
;; mov ds,ax
;; assume ds:vars

 mov bx,0FFFFh              ;Request 0FFFF0h bytes of memory
 mov ah,048h                ;Allocate memory
 int 21h                    ;Universal DOS function

;bx is now the actual number of free memory paragraphs

  IFE Production
; sub bx,3F30h ;* 2E87h ;For debugging: take out 152K
  ENDIF ;Production
; sub bx,(640-512)*64 ;**********

 mov cs:CS_FreeParagraphs,bx
 mov ah,048h                ;Allocate memory
 int 21h                    ;Universal DOS function

 mov es,ax
 mov ds:LoLongFreeWorkspace,ax
 mov ax,0
 mov ds:HiLongFreeWorkSpace,ax

 mov cx,cs:CS_FreeParagraphs ;Length

 jcxz cleared               ;No free space!
clear:
 xor ax,ax
clear2:
 mov di,ax
 stosw ; mov word ptr es:[di],0 : add di,2
 stosw
 stosw
 stosw
 stosw
 stosw
 stosw
 stosw
 mov bx,es
 inc bx
 mov es,bx
 loop clear2

cleared:
 ret

;-----

;Public variables in 'code:'...

CS_GameData        dw 0      ;paragraph address for GAMEDATA segment
CS_Acode           dw 0      ;paragraph address for ACODE segment

 IF TwoD
CS_List3           dw 0      ;General compiled-acode workspace
 ENDIF ;TwoD

DriverSeed         dw 0      ;A truely random value

CS_FreeParagraphs  dw 0      ;free space

  IFE TwoD
CS_DriverSeg       dw 0      ;paragraph fro DRIVER.BIN
  ENDIF ;TwoD

CS_FatalDiskErrors dw 0     ;number of "(A) to abort" selects.

CS_ScreenSubMode   db 0

;-----

cpnrst = 13                 ;Reset disk system
cpnof  = 15                 ;Open File
cpncf  = 16                 ;Close File
cpndf  = 19                 ;Delete File
cpnrs  = 20                 ;Read Sequential
cpnws  = 21                 ;Write Sequential
cpnmf  = 22                 ;Make File

;Ascii/BBC control codes:
asciibs = 08h
asciilf = 0Ah
asciicr = 0Dh
asciiesc= 1Bh

;-----

;Values of ds: and es: must be readily available.

;!CS_CGA_FontSegment  dw 0

;!CS_CGA_Cellsegment  dw 0

;!CS_ListsSegment     dw 0
 
;!CS_CGA_TransSegment dw 0

 IF TwoD
CS_ViewSegment      dw 0
 ENDIF ;TwoD

;!CS_CGA_Screen1      dw 0
;!CS_CGA_Screen2      dw 0

;!CS_CGA_ThisFrame    dw 0
;!CS_CGA_LastFrame    dw 0

;!CS_ScreenMode db 0          ;0 = 2D, 1 = 3D

;-----

 IFE TwoD
LoadInstaller proc near

 mov ax,cs
 mov ds,ax
 assume ds:nothing

 mov dx,0
 mov cx,cs:CS_FreeParagraphs ;dx,cx = Size available
 cmp cx,1000h
 jb Plenty1                 ;More than 64K available
 mov cx,00FFFh
Plenty1:
 rept 4
 shl cx,1                   ;Bytes of free space
 endm ;rept

 mov ax,seg code
 mov ds,ax
 assume ds:code
 mov bx,offset InstallName

 mov es,ds:LoLongFreeWorkspace
 mov si,0
;   es:si address
;   ds:bx name
;   dx,cx max length
 call GeneralLoadFile
;   dx,cx = Length of file
 cmp al,0
 jne MissingInstall

;dx,cx is size of file
 cmp dx,0
 jne BadInstall
 cmp cx,0FFF0h
 ja BadInstall
 add cx,15                 ;round up to a whole number of paragraphs
 rept 4
 shr cx,1                  ;Convert file length to paragraphs
 endm ;rept

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov es,ds:LoLongFreeWorkspace
 mov word ptr cs:Vector+2,es
 mov word ptr es:[47h],offset InstallGetChar
 mov word ptr es:[4Bh],offset MCCloseDown
 mov ax,cs
 mov word ptr es:[49h],ax
 mov word ptr es:[4Dh],ax

; 0 jmp start
; 3 jmp InstallEntry
; 6 SCREEN type ;driver dependant
; 7 Reserved for SPEAKER type (0=no sound)
; 8 Reserved for KEYBOARD type (0=PC)
; 9 Reserved for JOYSTICK type (0=none)
; A Reserved for MOUSE type ;(0=none)
; B Asciiz filename of DRIVER.BIN
;47 Vector for GetChar
;4B Vector for terminate

 call cs:Vector

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ds,ds:LoLongFreeWorkspace
 mov al,byte ptr ds:[6]     ;SCREEN
 and al,1 ;*
 mov cs:CS_ScreenSubMode,al
 mov si,000Bh
 mov al,ds:[si]             ;NAME
 cmp al,0
 je NotInstalled
 mov di,offset DriverName
 mov ax,cs
 mov es,ax
 mov cx,DriverNameLength ;Length of path name
 rep movsb

NotInstalled:
 ret

Vector dd 3

MissingInstall:
BadInstall:
 mov dx,1302h               ;row 19, column 2
 mov bx,offset InstallError
 call DisplayVisibleString
 ret

InstallError:
 db "Can't load INSTALL.BIN...$"

InstallName:
 db "INSTALL.BIN",0

LoadInstaller endp

ENDIF ;TwoD

;-----

  IFE TwoD

InstallGetChar:
 push ds
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

gc01:
 mov si,ds:GSX_ReadPtr
 cmp si,ds:GSX_WritePtr
 je gc01

 mov ax,ds:GSX_Queue[si]    ;Codes: al=ascii, ah=GSX
 add byte ptr ds:GSX_ReadPtr,2

 pop ds
 assume ds:nothing
 retf                       ;return to INSTALL.BIN
 
 ENDIF ;Twod

;-----

   IF TwoD
Allocate_Memory macro p1,p2
 mov bx,(p1/16)+1
 call GrabLowMemory
 mov cs:p2,ax
 endm ;Allocate_memory
   ENDIF ;TwoD

;-----

;Initialise hero. Follows AINT initialise.
;Do only init required before ACODE can run.

HeroInit:
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov byte ptr ds:horizontalstepsize,4
 mov byte ptr ds:verticalstepsize,4
 mov ds:HiLo_CursorXpos,0
 mov ds:HiLo_CursorYpos,0

 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov ax,ds:LoLongPhysicalBase
 mov ds:LoLongTextScreenBase,ax

 mov dx,offset diskbuffer
 mov ah,01Ah                ;Set Disk Transfer Area
 int 21h                    ;ROM-BIOS DOS Functions

mapsize = MapWidth*MapHeight*2

;Background MAPs requires 5000 bytes plus one sector

   IF TwoD
 Allocate_Memory (mapsize+100h),CS_ViewSegment
   ENDIF ;TwoD

;! cmp cs:CS_ScreenMode,0
;! jne NoCSCells

;! call CGA_AllocateCells     ;CGA uses 64 bytes per cell
;! mov sp,bx
;! mov ss,ax                  ;Set up stack at top of Transparency segment

;!NoCSCells:
 mov ax,seg vars
 mov ds,ax
 mov es,ax
 assume ds:vars

;! Allocate_Memory 8000h,CS_ListsSegment

;! cmp cs:CS_ScreenMode,0
;! jne SmallAllocate

;16K for each 'buffer' screen
;! Allocate_Memory 4000h,CS_CGA_Screen1
;! Allocate_Memory 4000h,CS_CGA_Screen2

;2 heaps
;! Allocate_Memory (maxmovingsprites+2)*8,CS_CGA_ThisFrame
;! Allocate_Memory (maxmovingsprites+2)*8,CS_CGA_LastFrame

;!SmallAllocate:
 IF TwoD
 Allocate_Memory 65535,CS_List3 ;Get 64K for Acode
 ENDIF ;TwoD

;! cmp cs:CS_ScreenMode,0
;! jne NoEGAfont
;! call CGA_StealFont
;! call LoadCGAtrans
;!NoEGAfont:

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

;Initialise starting position for background map
 mov ds:HiLo_ScreenXpos,0
 mov ds:HiLo_ScreenYpos,0

   IF TwoD
 mov di,offset SpriteTable
 mov cx,maxmovingsprites+2
setup:
 mov ds:Move_InfoPtr[di],0
 add di,size Move_Structure
 loop setup

 mov ds:SpriteTptr,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,600h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,601h ;@
 call CheckChain       ;@
 mov cs:debugword,602h ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 call SetUpHeroLists

 if TraceCode          ;@
 mov cs:debugword,603h ;@
 endif ;TraceCode      ;@

 jmp Game_AcodeStart

;-----

;!CGA_AllocateCells:
;! Allocate_Memory (NumberOfCells+3)*64,CS_CGA_Cellsegment
;!
;! mov ax,cs
;! mov ds,ax
;! assume ds:code
;! mov es,CS_CGA_Cellsegment
;! mov si,offset DefaultCells
;! mov di,0
;! mov cx,(NumberOfCells+1)*64/2
;! rep movsw
;!
;! mov bx,(NumberOfCells+11)*64/16 ;64 bytes per cell
;! push bx
;! call GrabLowMemory
;! mov cs:CS_CGA_TransSegment,ax
;! pop bx
;! mov cl,4
;! shl bx,cl
;!
;! ret

;-----

;Store character set 8 high, 8 wide (16 bytes.)

;!CGA_StealFont:
;! Allocate_Memory 96*16,CS_CGA_FontSegment
;!
;!;Display each character in turn, and store it in the character font.
;! mov ah,0                   ;Video Service - Set Video Mode
;! mov al,4                   ;320x200 4-colour ;screen mode
;! int 10h                    ;ROM-BIOS Video Service
;!
;! mov ah,11                  ;Video service - Set color palette
;! mov bh,0                   ;Green/Red/Brown
;! mov bl,0                   ;Green/Red/Brown
;! int 10h                    ;ROM-BIOS Video Service
;!
;! mov ah,11                  ;Video service - Set color palette
;! mov bh,0                   ;Set background
;! mov bl,1                   ;blue
;! int 10h                    ;ROM-BIOS Video Service
;!
;! mov al,32                  ;Ascii code
;! mov bx,0                   ;Index into font data
;! mov cx,96                  ;Number of characters
;!ad01:
;! push ax
;! push bx
;! push cx
;!
;! push ax
;! mov dh,0                   ;Row
;! mov dl,0                   ;Column
;! mov bh,0                   ;Screen Page
;! mov ah,2                   ;Set Cursor Video Service
;! int 10h
;! pop ax
;! mov ah,9
;! mov bl,7                   ;white
;! mov cx,1
;! int 10h                    ;Display character
;!
;! pop cx
;! pop bx
;!
;! mov es,cs:CS_CGA_FontSegment
;! mov ax,0B800h
;! mov ds,ax
;! assume ds:nothing
;!
;! mov si,0
;! mov ax,word ptr ds:[si]
;! mov es:0[bx],ax
;! mov ax,word ptr ds:2000h[si]
;! mov es:2[bx],ax
;! mov ax,word ptr ds:80[si]
;! mov es:4[bx],ax
;! mov ax,word ptr ds:2000h+80[si]
;! mov es:6[bx],ax
;! mov ax,word ptr ds:160[si]
;! mov es:8[bx],ax
;! mov ax,word ptr ds:2000h+160[si]
;! mov es:10[bx],ax
;! mov ax,word ptr ds:240[si]
;! mov es:12[bx],ax
;! mov ax,word ptr ds:2000h+240[si]
;! mov es:14[bx],ax
;!
;! mov ax,seg vars
;! mov ds,ax
;! assume ds:vars
;!
;! pop ax
;! inc al
;! add bx,16
;! loop ad01
;!
;!;Remove character-font display from  screen...
;! mov ah,0                   ;Video Service - Set Video Mode
;! mov al,4                   ;320x200 4-colour ;screen mode
;! int 10h                    ;ROM-BIOS Video Service
;! ret
;!
;! purge Allocate_Memory      ;speed up assembly

;-----

;!LoadCGAtrans:
;! mov es,cs:CS_CGA_TransSegment
;! mov ax,cs
;! mov ds,ax
;! assume ds:nothing
;! mov cx,(NumberOfCells+11)*64/16 ;64 bytes per cell
;! mov dx,offset TransFileName
;! call LoadUpFile
;!
;! cmp al,3
;! je sm05
;! cmp al,0
;! jne sm04
;! ret                         ;Got dummy transparencies
;!
;!sm04:
;! mov di,offset cantopenmap
;! call directprs
;! jmp TerminateCLS
;!
;!cantopenmap:
;! db asciicr,asciilf
;! db "file missing."
;! db asciicr,asciilf
;! db 0
;!
;!sm05:
;! mov di,offset maperror
;! call directprs
;!
;!maperror:
;! db asciicr,asciilf
;! db "can't read file."
;! db asciicr,asciilf
;! db 0

;-----

;Load a file, maximum length CX, name in DX, to address ES:0
;Returns AL=0 if OK (cx=bytes loaded)
;        AL=1 if file not found
;        AL=3 if file can't load

LoadUpFile:
 push cx                    ;Length
 push si                    ;Load address

 mov al,0                   ;non-private/compatable/read-only
 mov ah,61                  ;Open file
 int 21h                    ;extended DOS function

 pop si                     ;Load address
 pop cx                     ;Length

 jnc le01
 mov al,1                   ;File not found
 ret

le01:
 push ax                    ;File handle
 push cx                    ;length
 push si                    ;Load address
 mov bx,ax
 mov al,0                   ;relative to start of file
 mov cx,0                   ;relative position (high)
 mov dx,0                   ;relative position (low)
 mov ah,66                  ;move file pointer
 int 21h                    ;extended DOS function
 pop si                     ;Load address
 pop cx                     ;length
 pop ax                     ;file handle

 push ax                    ;File handle
 push ds

 mov bx,ax                  ;file handle
                            ; cx=length
 mov ax,es
 mov ds,ax
 mov dx,si                  ;address DS:DX = ES:SI
 mov ah,63                  ;Read from file
 int 21h                    ;extended DOS function
 jnc le02

;Error
 pop ds
 pop bx                     ;File handle
 mov ah,62                  ;Close file handle
 int 21h                    ;extended DOS function

 mov al,3                   ;File can't load
 ret

le02:
 mov cx,ax                  ;Number of bytes loaded
 pop ds
 pop bx                     ;File handle
 push cx

 mov ah,62                  ;Close file handle
 int 21h                    ;extended DOS function

 pop cx                     ;number of bytes read
 mov al,0                   ;File loaded!
 ret

;-----

;Print string at [di]
directprs:
 mov al,cs:[di]
 cmp al,0
 je short directprs1 
 mov al,cs:0[di]
 call directoutput
 inc di
 jmp short directprs
directprs1:
 ret

;-----

directoutput:
 mov dl,al
 mov ah,2                   ;Universal Function 2 - Display Output
 int 21h                    ;Universial Function
 ret

;-----

TransFilename:
 db "TRANS.DAT"
 db 0                       ;Any drive

;...e

;-----

;...sAcode Subroutines:

MCCloseDown:
 cmp cs:CS_FatalDiskErrors,0 ;number of "(A) to abort" selects.
 je NoErrors

 mov dx,1500h               ;row=21, column=0
 mov bx,offset cd01
 call DisplayVisibleString

NoErrors:
 cmp cs:Graphics_Count,0    ;Number of bus-errors
 jz Shutdown                ;(e.g. non-existant screen memory)

 mov dx,1700h               ;row=23, column=0
 mov bx,offset cd02
 call DisplayVisibleString

Shutdown:
 jmp TotalShutdown

;    1234567890123456789012345678901234567890
cd01:
 db "Un-recovered disk error(s) occurred$"

cd02:
 db "Non-Fatal Error(s) occurred$"

;-----

;Controlled break-point, does not required 'symdeb' and works with
;full interrupt system present. Returns to DOS when complete.

; CALL DumpRegisters
; DB x ;Break point types.

;'x' may be any value 0-FF to aid YOU in tracing faults/bugs. As a guide
;I have already used codes in the following ranges:
;    C0 - CF  Environment error (e.g. memory error)
;    D0 - DF  Not implemented in PC version. (=ST FNcall only)
;    E0 - EF  Limit exceeded.
;    F0 - FF  Invalid address.

DumpRegisters:
 push es                    ;All registers to be displayed, in reverse order.
 push ds
 push di
 push si
 push bp
 push dx
 push cx
 push bx
 push ax

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov dx,11                  ;Row
 mov cx,0                   ;Column
 call SetCursor

 call InLineDos
 db "AX=$"
 pop ax                     ;Register ax
 call displayword

 call InLineDos
 db "BX=$"
 pop ax                     ;Register bx
 call displayword

 call InLineDos
 db "CX=$"
 pop ax                     ;Register cx
 call displayword

 call InLineDos
 db "DX=$"
 pop ax                     ;Register dx
 call displayword

 call InLineDos
 db "BP=$"
 pop ax                     ;Register bp
 call displayword

 mov dx,13                  ;Row
 mov cx,0                   ;Column
 call SetCursor

 call InLineDos
 db "SI=$"
 pop ax                     ;Register si
 call displayword

 call InLineDos
 db "DI=$"
 pop ax                     ;Register di
 call displayword

 call InLineDos
 db "DS=$"
 pop ax                     ;Register ds
 call displayword

 call InLineDos
 db "ES=$"
 pop ax                     ;Register es
 call displayword

 call InLineDos
 db "IP=$"
 pop ax                     ;Register IP
 push ax
 call displayword

 mov dx,9                   ;Row
 mov cx,0                   ;Column
 call SetCursor
 call InLineDos
 db "Break Point Type: $"
 pop bx
 mov al,cs:[bx]             ;Value, following CALL DumpRegisters
 call displayhex

 if TraceCode        ;@
 call InLineDos ;@
 db " DebugWord=$"   ;@
 mov ax,cs:debugword ;@
 call displayword    ;@
 endif ;TraceCode    ;@

 mov dx,15                  ;Row
 mov cx,0                   ;Column
 call SetCursor

;Normal program exit, returns to DOS.

TotalShutdown:
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ds:HiLo_VBLDisabled,100h ;turn off multi-tasking

 mov ax,seg stacks
 mov ss,ax                  ;Protected move
 mov sp,offset LinkerStackSize

 call SafeShutDown ;tidy up vectors
 jmp TerminateCLS ;clear screen. release memory. return to dos

;-----

SafeShutDown:
;----------Can now do quite a lot to recover the system, with---------
;----------the aim of succesfully returning control to MS-DOS.--------

 mov ax,word ptr cs:AddrSetUpPalette[2]
 cmp ax,0
 je NoDriver                ;the driver is not loaded; do not close it down

 cmp cs:CS_DriverClock,0 ;*
 je CloseMyDriver        ;*

 call cs:AddrCloseDown   ;*
 jmp short NoDriver      ;*

CloseMyDriver:
 call cs:AddrUnHookDiscBase

NoDriver:
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 ife DosKeyboard
 call Kbd_Unhook            ;Reset interrupt 9
 endif ;DosKeyboard

 call OriginalVectors       ;Reset interrupt 13

 ret

;-----

TerminateCLS:
 mov ax,0003h ;Set screen mode 3 (80x25 text)
 int 10h

 mov ah,04Ch                ;Terminate process
 int 21h
 jmp short TerminateCLS

palette:
; RGBI format

 db 0, 0000b  ;00h  ;black
 db 0, 1111b  ;17h  ;i white
 db 0, 1001b  ;14h  ;i red
 db 0, 1001b  ;14h  ;i red

 db 0, 0111b  ;13h  ;i cyan
 db 0, 0001b  ;10h  ;dark grey
 db 0, 1000b  ;04h  ;red
 db 0, 1110b  ;07h  ;normally black, replace with white

 db 0, 1000b  ;04h  ;red
 db 0, 1100b  ;06h  ;brown
 db 0, 1100b  ;06h  ;brown
 db 0, 1101b  ;16h  ;i yellow

 db 0, 1001b  ;14h  ;i red
 db 0, 1110b  ;07h  ;light grey
 db 0, 0001b  ;10h  ;dark grey
 db 0, 0100b  ;02h  ;green

;-----

IFE TwoD

LoadDriver proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov dx,0
 mov cx,cs:CS_FreeParagraphs ;dx,cx = Size available
 cmp cx,1000h
 jb Plenty2                 ;More than 64K available
 mov cx,00FFFh
Plenty2:
 rept 4
 shl cx,1                   ;Bytes of free space
 endm ;rept

 mov ax,seg code
 mov ds,ax
 assume ds:code
 mov bx,offset DriverName

 mov es,ds:LoLongFreeWorkspace
 mov si,0
;   es:si address
;   ds:bx name
;   dx,cx max length
 call GeneralLoadFile
;   dx,cx = Length of file
 cmp al,0
 jne Missing

;dx,cx is size of file
 cmp dx,0
 jne BadFile
 cmp cx,0FFF0h
 ja BadFile
 add cx,15                 ;round up to a whole number of paragraphs
 rept 4
 shr cx,1                  ;Convert file length to paragraphs
 endm ;rept

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

; mov es,ds:LoLongFreeWorkspace ;*
; mov al,cs:CS_ScreenSubMode    ;*
; mov byte ptr es:[105h],al     ;*

 push cx                   ;size of DRIVER.BIN
 mov ax,ds:LoLongFreeWorkspace
 mov cs:CS_DriverSeg,ax
 call SetDriver
 pop cx

 add ds:LoLongFreeWorkspace,cx
 sub cs:CS_FreeParagraphs,cx

 ret

Missing:
 mov dx,23                  ;Row
 mov cx,0                   ;Column
 call SetCursor

 mov dx,1700h               ;row=23, column=0
 mov bx,offset ld01
 call DisplayVisibleString
 jmp MCCloseDown
ld01:
 db "Missing HEADER.BIN$"

BadFile:
 mov dx,1700h               ;row=23, column=0
 mov bx,offset ld02
 call DisplayVisibleString
 jmp MCCloseDown
ld02:
 db "Bad HEADER.BIN$"

LoadDriver endp

ENDIF ;TwoD

;-----

DriverName:
 db "HEADER.BIN",0
 db 40 dup(0)               ;allow to be overwritten
DriverNameLength = this byte - DriverName

;-----

;The MicroSoft assembler refuses to allow subroutines to be
;defined in one segment and CALLed from another, while a
;FAR PROCedure can only be called from a difference segment.
;(This makes NO difference to the object code generated, but
;satisfies the strong type-conventions of the assembler.)

Disk_Init proc near

 mov ax,seg code
 mov ds,ax
 assume ds:code

 mov dx,offset CS_DiskBuffer
 mov ah,01Ah                ;Set Disk Transfer Area
 int 21h                    ;ROM-BIOS DOS Functions

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 call ExamineDisk           ;Find size of thoses *.DAT files which vary

 mov ax,seg code
 mov ds,ax
 assume ds:code

 mov dx,offset CS_DiskBuffer
 mov ah,01Ah                ;Set Disk Transfer Area
 int 21h                    ;ROM-BIOS DOS Functions

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 ret

Disk_Init endp

;-----

CS_GameSize dw 0            ;Size of largest GAMEDAT?.DAT
CS_AcodeSize dw 0           ;size of largest ACODE?.ACD

;Disk DMA buffer
CS_DiskBuffer db 128 dup(0) ;Disk I/O buffer

;-----

setfcbgame:
 call FCBinit
 mov si,offset gamefilename
 mov di,offset SYSFCB
 mov bx,offset lengthgamefilename
 call CopyCSDS
 ret

;-----

setfcbacode:
 call FCBinit
 mov si,offset acodefilename
 mov di,offset SYSFCB
 mov bx,offset lengthacodefilename
 call CopyCSDS
 ret

;-----

;Find size of thoses Gamedata ('AL'.DAT) files which vary...

FindDatSize proc near

 push ax
 call setfcbgame
 pop ax
 mov byte ptr ds:7[fcbname],al

 mov al,1                   ;Load first sector
 call loadstart             ;Get first sector of GAMEDATA
 cmp al,0
 jne fs01                   ;gamedata file missing
 mov ax,word ptr cs:CS_DiskBuffer
 cmp ax,cs:CS_GameSize
 jb fs01                    ;this gamedata file smaller than others
 mov cs:CS_GameSize,ax
fs01:
 ret

FindDatSize endp

;-----

;Find size of thoses ACODE ('AL'.DAT) files which vary...

FindACDSize proc near

 push ax
 call setfcbacode
 pop ax
 mov byte ptr ds:5[fcbname],al

fs03:
 mov al,1                   ;Load first sector
 call loadstart             ;Get first sector of GAMEDATA
 cmp al,0
 jne fs01                   ;acode file missing
 mov ax,word ptr cs:CS_DiskBuffer
 cmp ax,cs:CS_AcodeSize
 jb fs02                    ;this acode file smaller than others
 mov cs:CS_AcodeSize,ax
fs02:
 ret

FindACDSize endp

;-----

ExamineDisk proc near

 assume ds:vars

 mov word ptr cs:CS_GameSize,0
 mov word ptr cs:CS_AcodeSize,0
 mov al,'A'
 call FindDatSize           ;Check if 'GAMEDATA'DAT' exists
 mov al,'1'
ed01:
 push ax
 call FindDatSize           ;Check for 'GAMEDAT1.DAT' thru 'GAMEDAT9.DAT'
 pop ax
 add al,1
 cmp al,'9'+1               ;Scanned all GAMEDATA files?
 jb ed01

 mov al,' '
 call FindACDSize           ;Check if 'ACODE.DAT' exists
 mov al,'1'
ed02:
 push ax
 call FindACDSize           ;Check for 'ACODE1.ACD' thru 'ACODE9.ACD'
 pop ax
 add al,1
 cmp al,'9'+1               ;Scanned all ACODE files?
 jb ed02

;A single segment shares the GAMEDATA, Save-Restore WORKSPACE, and the
;vectors to switch betwwen compiled-machine code (contained within the
;GAMEDATA) and the HERO code.

; mov ax,cs:CS_GameSize ;*
; mov bx,cs:CS_AcodeSize ;*
; add cs:CS_GameSize,200h ;*
; add cs:CS_AcodeSize,200h ;*
; int 3 ;*****

 mov ax,seg code
 mov es,ax

 mov bx,cs:CS_AcodeSize      ;Get max acode size
 cmp bx,0
 je NoAcode

;ACODE.ACD contains acode, so set up two segments...
; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ds:0                             ³ ³es:0                       ³
; ³AddressGameDataDat:              ³ ³      GameData.Dat (exits, ³
; ³                     ret opcode  ³ ³      tables, squash)      ³
; ³                     retf opcode ³ ³                           ³
; ³                     list11      ³ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
; ³                     acode vars  ³
; ³                     Acode.acd   ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 mov cs:AddressGameDataDat,0
 add bx,workspacesize+PCvarsoffset+128 ;Add vars,lists,spare sector

 shr bx,1                   ;Convert bytes to paragraph
 shr bx,1
 shr bx,1
 shr bx,1
 call GrabLowMemory

 mov es:CS_Acode,ax

 mov bx,cs:CS_GameSize      ;Get max gamedata size
;* jmp WithAcode
 add bx,workspacesize+PCvarsoffset+128 ;Add vars,lists,spare sector

 shr bx,1                   ;Convert bytes to paragraph
 shr bx,1
 shr bx,1
 shr bx,1
 call GrabLowMemory

 mov es:CS_GameData,ax      ;( es: = code: )
 ret

NoAcode:
;GAMEDATA.DAT contains acode. so set up a single segment...
; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ds:0 = es:0         ret opcode                                  ³
; ³                    retf opcode                                 ³
; ³                    list11                                      ³
; ³                    acode vars                                  ³
; ³AddressGameDataDat:                                             ³
; ³                    gamedata.dat (exits, tables, squash, acode) ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 mov cs:AddressGameDataDat,offset SizeRunTimeSystem

 mov bx,cs:CS_GameSize      ;Get max gamedata size
;*WithAcode: ;*
 add bx,workspacesize+PCvarsoffset+128 ;Add vars,lists,spare sector

 shr bx,1                   ;Convert bytes to paragraph
 shr bx,1
 shr bx,1
 shr bx,1
 call GrabLowMemory

 mov es:CS_GameData,ax      ;( es: = code: )
 mov es:CS_Acode,ax
 ret

ExamineDisk endp

;-----

;Load the ax'th sector of a file, name in CS_SYSFCB, to CS_DiskBuffer.
;Returns AL=0 if OK

loadstart:
 push ax                    ;Number of sectors
 mov dx,offset SYSFCB
 mov ah,cpnof               ;Open file
 int 21h                    ;CP/M emulation
 cmp al,0
 je short ls01

 pop ax
 mov al,1                   ;Error code 1 - File not found
 ret

ls01:
 pop ax
 cmp al,0
 je ls02                    ;exit with ax=0
 dec ax
 push ax

 mov dx,offset SYSFCB
 mov ah,cpnrs
 int 21h

 push ax                    ;Save return code
 mov dx,offset SYSFCB
 mov ah,cpncf
 int 21h
 pop ax                     ;get return code
 cmp al,0
 je ls01                    ;loaded ok

;error, exit with ax<>0
 pop bx

ls02:
 ret

;-----

;Copies a block of data from cs to ds
;from 0[si] to 0[di] length bx.

CopyCSDS:
 cmp bx,0
 jne short copy1
 ret
copy1:
 mov al,cs:[si]
 mov ds:[di],al
 inc si
 inc di
 dec bx
 jmp short CopyCSDS

;-----

;Name of file containing gamedata.

gamefilename:
 db 0                       ;Any drive
 db "GAMEDATA"
 db "DAT"
endgamefilename:
lengthgamefilename=endgamefilename-gamefilename

acodefilename:
 db 0                       ;Any drive
 db "ACODE   "
 db "ACD"
endacodefilename:
lengthacodefilename=endacodefilename-acodefilename

;-----

;Prepare system FCB for a new file. Set drive
;to current login drive.

FCBinit:
 mov byte ptr ds:FCBExtension,0
 mov ah,cpnrst
 int 21h
 mov al,0
 mov byte ptr ds:FCBDrive,al
 mov byte ptr ds:FCBEX,al
 mov byte ptr ds:FCBCR,al
 ret

;-----

code ends

;...e

;-----

;...sVariables:0:

vars segment word public 'data'

 even

fcbextension db 7 dup(0)    ;Extended area
fcbdrive = this byte
sysfcb  db 1  dup(0)
fcbname db 8  dup(' ')      ;name
        db 3  dup(' ')      ;type
fcbex   db 20 dup(0)
fcbcr   db 4  dup(0)

 even
;Disk DMA buffer
diskbuffer db 128 dup(0)    ;Disk I/O buffer

;Background scroll size.
 even
horizontalstepsize db 0
 even
verticalstepsize db 0
 even

CharThisAddr dw 0           ;These contain offset CharacterHeap1/CharacterHeap2
CharLastAddr dw 0

CharThisSize dw 0
CharLastSize dw 0

CharacterHeap1 dd CharStackMax dup (0)
CharacterHeap2 dd CharStackMax dup (0)

TopOfMemoryAllocated dw 0   ;number of paragraphs at top of memory

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

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################

