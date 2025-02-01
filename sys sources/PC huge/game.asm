 page 128,122 ;length,width
;IBM HERO

;GAME.ASM

;Copyright (C) 1988,1989 Level 9 Computing

;-----

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
 include common.asm
 include consts.asm
 include structs.asm

;...e

;...sPublics and externals:0:

 public ByteWS
 public B_FrameReadyFlag
 public B_InvertFlag
 public B_JoystickStatus
 public B_LastKeyPressed
 public B_StarPhase
 public B_WrapWidth
 public CGA_MustRebuild
 public CS_DriverClock ;*
 public HiLongFreeWorkSpace
 public HiLo_CursorXpos
 public HiLo_CursorYpos
 public HiLo_ErrorNumber
 public HiLo_FreeSprites
 public HiLo_LoLongCurrentTask 
 public HiLo_LoLongNextTask 
 public HiLo_PlayerSprite
 public HiLo_RasterIndex
 public HiLo_ScreenXblocks
 public HiLo_ScreenXpos
 public HiLo_ScreenYblocks
 public HiLo_ScreenYpos
 public HiLo_TextBufferP
 public HiLo_XposSave
 public HiLo_YposSave
 public HiLo_VblDisabled 
 public HiLo_SuspendTaskSwap 
 public List28
 public LoLongFreeWorkSpace
 public LoLongLogicalBase
 public LoLongPhysicalBase
 public LoLongTextScreenBase
 public LongWS
 public L_Mtcb 
 public MCCalculateMemoryFree
 public MCDisplayAllSprites
 public MCDoAllTimers
 public MCScrollTextLine
 public MCSpecials
 public MCHandlePlayerInput 
 public MCHeroInit
 public MCHeroInput
 public MCHeroOnceOnlyInit
 public MCMoveAllSprites
 public SpriteTable
 public TextBuffer
 public WordWS
 if TraceCode          ;@
  public debugword      ;@
 endif ;TraceCode      ;@
   IF TwoD
 if TraceCode          ;@
 public CheckSTaddress ;@
 public CheckChain     ;@
 public CheckCD        ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

;In BIN.ASM:
   IF TwoD
 extrn EGA2DPlotSprite:near
   ELSE ;TwoD
 extrn AddrBuildRoom:dword
 extrn AddrOnceOnlyInit:dword
 extrn AddrScreenFlip:dword
 extrn AddrSetupPalette:dword
 extrn AddrShiftRectangle:dword
 extrn AddrUpdateScreen:dword
   ENDIF ;TwoD

;In CGA.ASM:
;! extrn CGA_PlaceSprites:near
;! extrn CGA_RefreshAligned:near
;! if TraceCode         ;@
;! extrn CheckHeap:near ;@
;! endif ;TraceCode     ;@

;In HUGE.ASM:
 IF TwoD
  extrn CharLastSize:word
  extrn CharThisSize:word
;!  extrn CS_CGA_Screen2:word
 ENDIF ;TwoD
 extrn CS_Acode:word
 extrn CS_FreeParagraphs:word
;! extrn CS_ScreenMode:byte
 extrn CS_ScreenSubMode:byte
 extrn DumpRegisters:near
 extrn MCCloseDown:near

;In IDENTIFY.ASM:
 extrn Video0Type:byte
 extrn Display0Type:byte
 extrn Video1Type:byte
 extrn Display1Type:byte

;In INTRPT.ASM:
 if DosKeyboard
 extrn ConvertRealKeyboard:near
 endif ;DosKeyboard
 extrn ClockTickOldSeg:word ;*
 extrn ClockTickOldVal:word ;*
 extrn NewTimer:near        ;*
 extrn OriginalTimer:near   ;*

;In MCODE.ASM:
 extrn Game_SpecialMissile:near
 extrn MCReturn:near

   IF TwoD
;In MOVE.ASM:
 extrn CheckPlayerMove:near
 extrn D2:word
 extrn D3:word
 extrn D4:word
 extrn MoveAllSprites:near
 extrn SetUpNewSprite:near
 extrn SpriteTptr:word
   ENDIF ;TwoD

;In PRINT.ASM:
 IF TwoD
 extrn EGA2DShiftRectangle:near
 ENDIF ;TwoD

;In TABLES.ASM:
 extrn SpriteDataStructure:byte
 extrn ViewToXYConversionTable:word

  IF TwoD
 public Pass_Variables
 public Retrieve_variables
 extrn LogicalScreen:word
 extrn PhysicalScreen:word
 extrn EGA2DBUILDROOM:near
 extrn EGA2DONCEONLYINIT:near
 extrn EGA2DSCREENFLIP:near
 extrn EGA2DUpdateScreen:near
   ENDIF ;TwoD

;...e

;-----

DW_HiLo macro p1
 db (p1) / 256
 db (p1) mod 256
 endm ;DW_HiLo

;-----

;...sVariables:0:

vars segment word public 'data'

D6 dw 0

TextBuffer db 256 dup (0)
 db 256 dup (0)             ;Just In Case

 even
LongWS = this dword
                          dw 0,0 ;(0-3)
                          dw 0,0 ;(4-7)
                          dw 0 ;(8)  HiLongRandomSeed
                          dw 0 ;(10) LoLongRandomSeed
                          dw 0 ;(12) HiLongLogicalBase
LoLongLogicalBase         dw 0 ;(14)
                          dw 0 ;(16) HiLongPhysicalBase
LoLongPhysicalBase        dw 0 ;(18)
                          dw 0 ;(20) LongOSScreenAddress
                          dw 0 ;(22)
                          dw 0 ;(24) HiLongTextScreenBase
LoLongTextScreenBase      dw 0 ;(26)
                          dw 0 ;(28) HiLongCurrentTask
HiLo_LoLongCurrentTask    dw 0 ;(30)
                          dw 0 ;(32) LoLongNextTask
HiLo_LoLongNextTask       dw 0 ;(34)
L_MTCB                    dd 16 dup (0) ;(36-99) for a minimum of 16 tasks 
                          db 108-100 dup (0) ;(100-107)
                          dw 0 ;(108) HiLongSpriteDataPtr
                          dw 0 ;(110) LoLongSpriteDataPtr
                          db 124-112 dup (0) ;(112-123)
HiLongFreeWorkSpace       dw 0 ;(124)
LoLongFreeWorkSpace       dw 0 ;(126)

;Word workspace is read-write by ACODE, so must be stored HI-byte first.

 even
WordWS = this word
HiLo_CursorXpos      dw 0 ;(0) 0..319 Rectangle top-left/Character position
HiLo_CursorYpos      dw 0 ;(2) 0..199
HiLo_FrameTime       dw 0 ;(4)
HiLo_PlayerSprite    dw 0 ;(6) Offset into LIST 28 for player sprite.  
HiLo_ScreenXpos      dw 0 ;(8) 0..799 Position of top-left of screen relative to map
HiLo_ScreenYpos      dw 0 ;(10) 0..799
HiLo_ScreenXmax = this word ;(assembler bug)
                     DW_HiLo MapWidth*CellWidth-DisplayAreaWidth    ;ScreenXmax
HiLo_ScreenYmax = this word
                     DW_HiLo MapHeight*CellHeight-DisplayAreaHeight ;ScreenYmax
                     DW_HiLo (MapWidth-6)*CellWidth      ;(16) PlayerXmax
                     DW_HiLo (MapHeight-6)*CellHeight    ;(18) PlayerYmax
HiLo_ScreenXblocks = this word
                     DW_HiLo MapWidth                    ;(20) ScreenXblocks
HiLo_ScreenYblocks = this word
                     DW_HiLo MapHeight                   ;(22) ScreenYblocks
HiLo_XposSave        dw 0 ;(24)
HiLo_YposSave        dw 0 ;(26)
HiLo_TextBufferP     dw 0 ;(28) offset
HiLo_FreeSprites     dw 0 ;(30)
                     dw 0 ;(32) MouseXdistance
                     dw 0 ;(34) MouseYdistance
HiLo_SuspendTaskSwap dw 0 ;(36) SuspendedTaskSwap
                     dw 0 ;(38)
HiLo_VBLDisabled     dw 0 ;(40)
                     db 56-42 dup(0) ;42-55
HiLo_RasterIndex     dw 0 ;(56)
                     db 66-58 dup(0) ;58-65
HiLo_ErrorNumber     dw 0 ;(66)

                     db 298-60 dup(0) ;60-297

 purge DW_HiLo              ;speed up assembly

 even
ByteWS = this byte
B_JoystickStatus  db 0      ;0
B_LastKeyPressed  db 0      ;1
                  db 0      ;2 Frame Ready
B_InvertFlag      db 0      ;3
                  db 0      ;4 Break Point Armed
                  db 0      ;5 Scroll Step
B_CurrentWeapon   db 0      ;6
                  db 0      ;7 LineCleared
                  db 0      ;8 PageSwapped
B_FrameReadyFlag  db 0      ;9
B_StarPhase       db 0      ;10
B_WrapWidth       db 0      ;11
                  db 0      ;12
                  db 0      ;13
                  db 0      ;14
                  db 0      ;15
                  db 0      ;16
                  db 0      ;17
                  db 0      ;18
                  db 0      ;19
                  db 0      ;20
B_SourceWeapon    db 0      ;21
B_SpecialMissile  db 0      ;22
                  db 0      ;23 True Joystick Status
                  db 0      ;24 Player speed

;36 longs, 38 words, 25 bytes => 99 bytes

 even
SpriteTable = this byte
List28 = this byte
  .xlist ;supress *.LST
 rept MaxMovingSprites+2
 Move_Structure <>
 endm ;rept
  .list ;resume *.LST
EndSpriteTable = this byte

 db 400 dup(0)              ;Pad out table to 4000 bytes.

PlayerDirection db 0
;   5  4  6  Values 1 thru 15 if
;   1  0  2  background scrolls one
;   9  8 10  pixel in direction shown.

 even
CGA_MustRebuild db 0        ;zero supresses background re-build.

 even
WindowJitterCount db 0

 even
HorizontalMove dw 0
VerticalMove dw 0

 even
FireButtonHeld db 0

 even
Random dw 0

vars ends

;...e

;-----

code segment public 'code'

 assume cs:code
 assume ds:vars

;           Either   Signed   Unsigned
;    <=              jle      jbe
;    <               jl       jb/jc
;    =      je/jz
;    <>     jnz/jne
;    >=              jge      jae/jnc
;    >               jg       ja

;-----

;...sSubroutines:0:

 if TraceCode

;For debugging only. All registers except ax are preserved.
;On entry: cs:ax is the address of a possible Sprite Data Structure
;On exit:  ax=0, if the address was a valid Sprite Data Structure (SDS)
;          Otherwise an error is output.

CheckCD proc near

 cmp ax,0
 je cc13
 sub ax,offset SpriteDataStructure
 cmp ax,0
 je cc13
cc11:
 cmp ax,size Perm_Structure
 jl cc12
 je cc13
 sub ax,size Perm_Structure
 jmp short cc11

cc12:
 call DumpRegisters
 db 0F0h ;generate an 'Invalid-address'  break point

cc13:
 ret

CheckCD endp

 endif ;TraceCode

;-----

 if TraceCode

;For debugging only. All registers are preserved.
;On entry: si is a possible offset into the (moving) Sprite Table.
;On exit:  no change if the address was a valid Sprite Data Structure (SDS)
;          Otherwise an error is output.

CheckSTaddress proc near

;! push ax
;! push bx
;! push cx
;! call CheckHeap
;! pop cx
;! pop bx
;! pop ax

 push bx
 push si
 mov cx,maxmovingsprites
 cmp si,0
 je aa02
aa01:
 cmp si,offset SpriteTable
 je aa02
 sub si,size Move_Structure
 loop aa01

 call DumpRegisters
 db 0F1h ;generate an 'Invalid-address'  break point

aa02:
 pop si
 pop bx
 ret

CheckSTaddress endp

 endif ;TraceCode

;-----

   IF TwoD
if TraceCode

;For debugging only. All registers are preserved.
;On exit:  'SpriteTptr' points to a valid entry in the (moving) SpriteTable;
;          Each Move_NextPtr points to a valid entry in the SpriteTable;
;          and the Move_LastPtr points to the previous entry, without
;          loops, etc.
;          Otherwise an error is output.

CheckChain proc near

 pushf
 push ax
 push cx
 push si
 push di
 push ds
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov si,ds:SpriteTptr
 cmp ds:Move_InfoPtr[si],0
 je cc02

 call CheckSTaddress

 mov ax,ds:Move_InfoPtr[si]
 call CheckCD

 mov ax,maxmovingsprites
 mov di,0
cc01:
 cmp si,0
 je cc02
 cmp di,ds:Move_LastPtr[si]
 jne cc03                   ;loop
 mov di,si
 mov si,ds:Move_NextPtr[si]
 dec ax
 cmp ax,0
 je cc02
 jmp short cc01
cc02:
 pop ds
 assume ds:nothing
 pop di
 pop si
 pop cx
 pop ax
 popf
 ret
cc03:
 call DumpRegisters
 db 0F2h ;generate an 'Invalid-address'  break point
 
CheckChain endp

 endif ;TraceCode
   ENDIF ;TwoD

;-----

RefreshAligned:

;EGA...
 mov ax,seg code
 mov ds,ax
 assume ds:nothing

   IF TwoD
 call Pass_Variables
 call EGA2DBuildRoom
 call Retrieve_Variables
   ELSE ;TwoD
 call cs:AddrBuildRoom
   ENDIF ;TwoD

 ret

;-----

   IF TwoD
RedisplaySprites proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov si,ds:SpriteTptr
 mov cx,maxmovingsprites+2
 mov ds:HiLo_FreeSprites,0
              
ds02:
 and si,si
 jz ds06

 push ax
 push cx
 push si

 mov ax,ds:Move_Xpos_HiLo[si]
 xchg ah,al
 mov bx,HiLo_ScreenXpos
 xchg bh,bl
 sub ax,bx                  ;X pos
 cmp ax,DisplayAreaWidth-16
 jae ds05

 mov bx,ds:Move_Ypos_HiLo[si]
 xchg bh,bl
 mov cx,HiLo_ScreenYpos
 xchg ch,cl
 sub bx,cx                  ;Y pos
 cmp bx,DisplayAreaHeight-16
 jae ds05

 mov dx,ds:Move_DataPtr[si]
 cmp dx,-1                  ;Animation not initialised, so transparent
 jz ds05

 IF TwoD
  call Pass_Variables
  call EGA2DPlotSprite
  call Retrieve_Variables
 ENDIF ;TwoD

ds05:
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 inc ds:HiLo_FreeSprites    ;Count the number of sprites 'LoHi'

 pop si
 pop cx
 pop ax
 mov si,ds:Move_NextPtr[si]
 loop ds02

 call DumpRegisters
 db 0E2h ;generate an 'limit-exceeded'  break point

ds06:
 mov ax,maxmovingsprites
 sub ax,ds:HiLo_FreeSprites ;'LoHi'
 cmp ax,0
 jg ds07
 mov ax,0                   ;Don't return a -ve value
ds07:
 xchg ah,al
 mov ds:HiLo_FreeSprites,ax ;'HiLo'

 ret

RedisplaySprites endp
   ENDIF ;TwoD

;-----

;          +---------------------------+
;          +                           +
;          +      A------B------C      +
;          +      +             +      +
;          +      H             D      +
;          +      +             +      +
;          +      G------F------E      +
;          +                           +
;          +---------------------------+

;If the player moves outside the central window area (A-C-E-G above)
;we re-position but always keeping the entire screen covering MAP data.
;(thus the player is warned of the approach of the edge.)

;Where we try to re-position to depends on the direction of motion:

;          E  F  G
;            \|/
;          D -+- H
;            /| \
;          C  B  A

AdjustScreenWindow proc near

 cmp ds:CGA_MustRebuild,2
 je as01                    ;Menu display in progress. Do NOT reposition window

 cmp byte ptr ds:WindowJitterCount,0
 je as02
 dec byte ptr ds:WindowJitterCount ;Don't keep repositioning too often.
as01:
 ret

as02:
 mov cx,ds:HiLo_ScreenXpos
 xchg ch,cl                 ;Original X offset into map

 mov dx,ds:HiLo_ScreenYpos
 xchg dh,dl                 ;Original Y offset into map

 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 add ax,offset SpriteTable
 mov si,ax                  ;Get address of Move_Structure

 mov ax,ds:Move_Xpos_HiLo[si]
 xchg ah,al
 sub ax,cx                  ;Get offset of sprite as it would display on screen

 cmp ax,HorizontalMargin
 jl OutsideX
 cmp ax,DisplayAreaWidth-CellWidth-HorizontalMargin
 jg OutSideX

 mov ax,ds:Move_Ypos_HiLo[si]
 xchg ah,al
 sub ax,dx                  ;Get row of sprite as it would display on screen

 cmp ax,VerticalMargin
 jl OutsideY
 cmp ax,DisplayAreaHeight-CellHeight-VerticalMargin
 jg OutSideY

 ret                        ;Player is within central area

;Player is outside the central A-C-E-G area

OutsideX:
OutSideY:
 mov al,ds:PlayerDirection  ;Choose new window area from direction of travel
 cmp al,10
 je ChooseA
 cmp al,8
 je ChooseB
 cmp al,9
 je ChooseC
 cmp al,1
 je ChooseD
 cmp al,5
 je ChooseE
 cmp al,4
 je ChooseF
 cmp al,6
 je ChooseG
 cmp al,2
 je ChooseH

;Player is stationary - We can get here when the edge of the map is
;displayed. So only jump-scroll if the player is invisible (off-screen)

 mov ax,ds:Move_Xpos_HiLo[si]
 xchg ah,al
 sub ax,cx                  ;Get offset of sprite as it would display on screen
 cmp ax,DisplayAreaWidth
 jae JumpCenter

 mov ax,ds:Move_Ypos_HiLo[si]
 xchg ah,al
 sub ax,dx                  ;Get row as it would display on screen
 cmp ax,DisplayAreaHeight
 jae JumpCenter

;Keep coords the same:

 xchg ch,cl
 mov ds:HiLo_ScreenXpos,cx
 xchg dh,dl
 mov ds:HiLo_ScreenYpos,dx
 ret

;Don't understand player direction, so re-position at center of screen

JumpCenter:
 mov ax,ds:Move_Xpos_HiLo[si]
 xchg ah,al
 sub ax,DisplayAreaWidth/2
 xchg ah,al
 mov ds:HiLo_ScreenXpos,ax

 mov ax,ds:Move_Ypos_HiLo[si]
 xchg ah,al
 sub ax,DisplayAreaHeight/2
 xchg ah,al
 mov ds:HiLo_ScreenYpos,ax

 jmp short CheckNewPosition

ChooseA:                    ;Player was moving Down and right
 call SetLeftX
 jmp short ChooseTop

ChooseB:                    ;Player was moving down
 call SetCenterX
 jmp short ChooseTop

ChooseC:                    ;Player was moving down and left
 call SetRightX
ChooseTop:
 call SetTopY
 jmp short CheckNewPosition

ChooseD:                    ;Player was moving left
 call SetRightX
 jmp short ChooseMiddle

ChooseE:                    ;Player was moving left and up
 call SetRightX
 jmp short ChooseLower

ChooseF:                    ;Player was moving up
 call SetCenterX
 jmp short ChooseLower

ChooseG:                    ;Player was moving up and right
 call SetLeftX
ChooseLower:
 call SetLowerY
 jmp short CheckNewPosition

ChooseH:                    ;Player was moving right
 call SetLeftX
ChooseMiddle:
 call SetCenterY
; jmp short CheckNewPosition

;-----

CheckNewPosition:
;Validate new position for outside map area

 mov ax,ds:HiLo_ScreenXpos
 xchg ah,al
 mov bx,ds:HiLo_ScreenXmax
 xchg bh,bl
 cmp ax,bx
 jb cn03                    ;unsigned
 cmp ax,0
 jl cn01                    ;signed
 mov ax,bx                  ;ScreenXmax
 jmp short cn02
cn01:
 mov ax,0
cn02:
 xchg ah,al
 mov ds:HiLo_ScreenXpos,ax
cn03:

 mov ax,ds:HiLo_ScreenYpos
 xchg ah,al
 mov bx,ds:HiLo_ScreenYmax
 xchg bh,bl
 cmp ax,bx
 jb cn06                    ;unsigned
 cmp ax,0
 jl cn04                    ;signed
 mov ax,bx
 jmp short cn05
cn04:
 mov ax,0
cn05:
 xchg ah,al
 mov ds:HiLo_ScreenYpos,ax
cn06:

;If the screen backgrund has moved then this has to be re-build before
;the next screen display.

 mov ax,ds:HiLo_ScreenXpos
 xchg ah,al
 cmp ax,cx                  ;changed
 jne NewBackground

 mov ax,ds:HiLo_ScreenYpos
 xchg ah,al
 cmp ax,dx                  ;changed
 jne NewBackground
 ret

NewBackground:
 mov ds:CGA_MustRebuild,1
 mov byte ptr ds:WindowJitterCount,10 ;Suppress re-build for ten frames
 ret

;-----

SetLeftX:
 mov ax,ds:Move_Xpos_HiLo[si]
 xchg ah,al
 sub ax,HorizontalMargin+CellWidth
 jmp short StoreX

SetRightX:
 mov ax,ds:Move_Xpos_HiLo[si]
 xchg ah,al
 sub ax,DisplayAreaWidth-(2*CellWidth)-HorizontalMargin
 jmp short StoreX

SetCenterX:
 mov ax,ds:Move_Xpos_HiLo[si]
 xchg ah,al
 sub ax,DisplayAreaWidth/2
StoreX:
 and ax,-CellWidth
 xchg ah,al
 mov ds:HiLo_ScreenXpos,ax
 ret

SetTopY:
 mov ax,ds:Move_Ypos_HiLo[si]
 xchg ah,al
 sub ax,VerticalMargin+CellHeight
 jmp short StoreY

SetLowerY:
 mov ax,ds:Move_Ypos_HiLo[si]
 xchg ah,al
 sub ax,DisplayAreaHeight-(2*CellHeight)-VerticalMargin
 jmp short StoreY

SetCenterY:
 mov ax,ds:Move_Ypos_HiLo[si]
 xchg ah,al
 sub ax,DisplayAreaHeight/2
StoreY:
 and ax,-CellHeight
 xchg ah,al
 mov ds:HiLo_ScreenYpos,ax
 ret

AdjustScreenWindow endp

;-----

;Filter opposite key presses:
;8=Down, 4=Up, 2=Right, 1=Left

DirectionAdjust:
 db 0  ;no key pressed
 db 1  ;w
 db 2  ;e
 db 0  ;left+right
 db 4  ;n
 db 5  ;nw
 db 6  ;ne
 db 4  ;n left+right
 db 8  ;down
 db 9  ;sw
 db 10 ;se
 db 8  ;s left+right
 db 0  ;down + up
 db 1  ;w down+up
 db 2  ;e down+up
 db 0  ;down+up left+right

;Convert PlayerDirection to PlayerView (required by acode)
PlayerViewAdjust:
 db -1 ;do not change
 db 6  ;west
 db 2  ;east
 db -1
 db 0  ;n
 db 7  ;nw
 db 1  ;ne
 db -1
 db 4  ;s
 db 5  ;sw
 db 3  ;se
 db -1
 db -1
 db -1
 db -1
 db -1

;-----

;Anytime the entire screen is going to be draw (e.g. before a jump-scroll)
;align the background map to be on screen boundaries

AlignForJump proc near

 assume ds:vars

 mov ax,HiLo_ScreenXpos
 xchg ah,al
 add ax,CellWidth/2
 and ax,-CellWidth
 xchg ah,al
 mov HiLo_ScreenXpos,ax

 mov ax,HiLo_ScreenYpos
 xchg ah,al
 add ax,CellHeight/2
 and ax,-CellHeight
 xchg ah,al
 mov HiLo_ScreenYpos,ax
 ret

AlignForJump endp

;-----

 IF TwoD
Pass_variables proc near

 push ax
 push ds
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov ax,ds:LoLongLogicalBase
 mov cs:LogicalScreen,ax
 mov ax,ds:LoLongPhysicalBase
 mov cs:PhysicalScreen,ax
 pop ds
 pop ax
 ret

Pass_variables endp
 ENDIF ;TwoD

;-----

 IF TwoD
Retrieve_variables proc near

 push ax
 push ds
 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov ax,cs:LogicalScreen
 mov ds:LoLongLogicalBase,ax
 mov ax,cs:PhysicalScreen
 mov ds:LoLongPhysicalBase,ax
 pop ds
 pop ax
 ret

Retrieve_variables endp
 ENDIF ;TwoD

 assume ds:nothing

;-----

;Wait approx cx frames (i.e. fields, or 1/60 sec.)

framedelay:                 ;cx=Number of frames to wait.
 push ax
 push dx
 mov dx,03DAh
fd01:
 jcxz fd04
fd02:
 in ax,dx
 test al,8
 jz fd02                    ;Wait for sync to start
fd03:
 in ax,dx
 test al,8
 jnz fd03                   ;Wait for sync to end
 dec cx
 jmp short fd01
fd04:
 pop dx
 pop ax
 ret

 if TraceCode
DebugWord dw 0
 endif ;TraceCode

;...e

;-----

;...sAcode Subroutines:0:

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 0
;-------------------------------------

;Required on ST to do machine-code initialise. On PC this is
;all done before any ACODE is run, to avoid memory-management
;problems.

MCHeroOnceOnlyInit proc near
 
   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,400h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ds:HiLo_VBLDisabled,100h
 mov ds:HiLo_SuspendTaskSwap,100h
 
   IF TwoD
 call EGA2DOnceOnlyInit
 call Retrieve_variables
   ELSE ;TwoD

 call OriginalTimer ;*Reset MS-DOS timer
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov bl,cs:Video0Type
 mov bh,cs:Display0Type     ;bx=primary display
 mov cl,cs:Video1Type
 mov ch,cs:Display1Type     ;cx=secondary display

 mov ah,0
 mov al,cs:CS_ScreenSubMode ;0=EGA/MGA, 1=VGA/CGA
 call cs:AddrOnceOnlyInit

   ENDIF ;TwoD

 mov cx,seg vars
 mov ds,cx
 assume ds:vars

 mov ds:LoLongPhysicalBase,ax
 mov ds:LoLongLogicalBase,bx

;*****
 mov cs:CS_DriverClock,0FFh
 mov ax,3508h               ;Get interrupt 08h (Timer 0/clock)
 int 21h                    ;DOS function. Get interrupt vector

;** multitasking stuff
 cmp cs:ClockTickOldVal,bx
 jne DriverClock
 mov ax,es
 cmp cs:ClockTickOldSeg,ax ;ax=es
 jne DriverClock
 call NewTimer ;HUGE.EXE to handler interrupts, reinstall vector
 mov cs:CS_DriverClock,0
DriverClock:
;*****

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,401h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,402h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 mov bx,LoLongFreeWorkSpace ;bx=paragraph (address*16) of free space

 mov es,cs:CS_Acode
 mov di,offset PCListVector+(17*4)
 mov ax,0                   ;Table 17 (driver block) starts as free space ptr
 stosw ;mov es:[di],ax:add di,2
 mov ax,bx
 stosw ;mov es:[di],ax:add di,2

 mov ax,0                   ;Also put in table 18.
 stosw ;mov es:[di],ax:add di,2   
 mov ax,bx
 stosw ;mov es:[di],ax:add di,2

   IFE TwoD
 mov si,offset palette     ;Set up default palette and windows
 mov ax,cs
 mov es,ax
 mov ax,16
 call cs:AddrSetupPalette
   ENDIF ;TwoD

 jmp MCReturn

palette:
; RGBI format

demo=0

 if demo

;New Demo...
 db 00h,00h ;db 0, 0000b  ;00h  ;0 black
 db 77h,7Fh ;db 0, 1111b  ;17h  ;1 i white
 db 72h,39h ;db 0, 1001b  ;14h  ;2 i red
 db 03h,46h ;db 0, 0110b  ;14h  ;3 cyan

 db 06h,77h ;db 0, 0111b  ;13h  ;4 i cyan
 db 20h,3Ah ;db 0, 1010b  ;10h  ;5 violet
 db 02h,63h ;db 0, 0011b  ;04h  ;6 i blue
   if Production
 db 00h,00h ;db 0, 0000b  ;00h  ;7 black
   else ;Production
 db 22h,25h ;db 0, 0101b  ;07h  ;7 purple
   endif ;Production

 db 20h,08h ;db 0, 1000b  ;04h  ;8 red
 db 00h,42h ;db 0, 0010b  ;06h  ;9 blue
 db 32h,0Ch ;db 0, 1100b  ;06h  ;10 brown
 db 52h,0Ch ;db 0, 1100b  ;06h  ;11 orange
;;;;;; db 52h,6Bh ;db 0, 1011b  ;16h  ;11 i violet

 db 76h,2Dh ;db 0, 1101b  ;14h  ;12 i yellow
 db 55h,5Eh ;db 0, 1110b  ;07h  ;13 light grey
 db 22h,21h ;db 0, 0001b  ;10h  ;14 dark grey
 db 03h,04h ;db 0, 0100b  ;02h  ;15 green


 else ;demo

;Grange Murder...
 db 00h,00h ;db 0, 0000b  ;00h  ;black
 db 77h,7Fh ;db 0, 1111b  ;17h  ;i white
 db 53h,39h ;db 0, 1001b  ;14h  ;i red
 db 53h,39h ;db 0, 1001b  ;14h  ;i red

 db 55h,57h ;db 0, 0111b  ;13h  ;light grey
 db 22h,21h ;db 0, 0001b  ;10h  ;dark grey
 db 20h,08h ;db 0, 1000b  ;04h  ;red
   if Production
 db 00h,00h ;db 0, 0000b  ;00h  ;black
   else ;Production
 db 22h,25h ;db 0, 0101b  ;07h  ;purple
   endif ;Production

 db 20h,08h ;db 0, 1000b  ;04h  ;red
 db 32h,0Ch ;db 0, 1100b  ;06h  ;brown
 db 32h,0Ch ;db 0, 1100b  ;06h  ;brown
 db 76h,2Dh ;db 0, 1101b  ;16h  ;i yellow

 db 73h,39h ;db 0, 1001b  ;14h  ;i red
 db 55h,5Eh ;db 0, 1110b  ;07h  ;light grey
 db 22h,21h ;db 0, 0001b  ;10h  ;dark grey
 db 03h,04h ;db 0, 0100b  ;02h  ;green

 endif ;demo

;-----

;...
;; db 00h,00h  ;db 0, 0000b  ;00h  ;black
;; db 77h,7Fh ;db 0, 1111b  ;17h  ;i white
;; db 53h,39h ;db 0, 1001b  ;14h  ;i red
;; db 54h,39h ;db 0, 1001b  ;14h  ;i red
;;
;; db 66h,67h ;db 0, 0111b  ;13h  ;i cyan
;; db 33h,31h ;db 0, 0001b  ;10h  ;dark grey
;; db 50h,08h ;db 0, 1000b  ;04h  ;red
;;   if Production
;; db 00h,00h ;db 0, 0000b  ;00h  ;black
;;   else ;Production
;; db 22h,25h ;db 0, 0101b  ;07h  ;purple
;;   endif ;Production
;;
;; db 20h,08h ;db 0, 1000b  ;04h  ;red
;; db 31h,0Ch ;db 0, 1100b  ;06h  ;brown
;; db 32h,0Ch ;db 0, 1100b  ;06h  ;brown
;; db 77h,0Dh ;db 0, 1101b  ;16h  ;i yellow
;;
;; db 74h,29h ;db 0, 1001b  ;14h  ;i red
;; db 55h,5Eh ;db 0, 1110b  ;07h  ;light grey
;; db 22h,21h ;db 0, 0001b  ;10h  ;dark grey
;; db 03h,04h ;db 0, 0100b  ;02h  ;green

MCHeroOnceOnlyInit endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 1
;-------------------------------------

;Initialise each time game re-starts.

MCHeroInit proc near

;Force RefreshAligned for first frame of each new level...
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ds:CGA_MustRebuild,1

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,403h ;@
 call CheckChain       ;@
 mov cs:debugword,406h ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 jmp MCReturn

MCHeroInit endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 12
;-------------------------------------

MCDoAllTimers proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD
 call EGA2DUpdateScreen   ;2D only
   ELSE ;TwoD
 call cs:AddrUpdateScreen ;never called in 3D
   ENDIF ;TwoD

 jmp MCReturn

MCDoAllTimers endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 14
;-------------------------------------

MCHeroInput proc near

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,408h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@ 
   ENDIF ;TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

;If ACODE has set FrameReadyFlag...
;Now do stuff for EGA screen flipping...

 cmp B_FrameReadyFlag,0
 je NoEGAflip               ;Continue with current screen
;! cmp cs:CS_ScreenMode,0
;! je NoEGAflip               ;CGA?

   IF TwoD
 call Pass_variables
 call EGA2DScreenFlip
 assume ds:nothing
 call Retrieve_variables

 mov ax,seg vars
 mov ds,ax
 assume ds:vars
   ELSE ;TwoD
 call cs:AddrScreenFlip

 mov cx,seg vars
 mov ds,cx
 assume ds:vars
 
 mov ds:LoLongPhysicalBase,ax
 mov ds:LoLongLogicalBase,bx
   ENDIF ;TwoD

 mov dx,03DAh
WaitFrame:
 in ax,dx
 test al,8
 jz WaitFrame               ;Wait for sync to start

;!NoMenu2:
 mov byte ptr B_FrameReadyFlag,0
NoEGAflip:

;!;Now do stuff for CGA screen flipping...
;!
;! cmp cs:CS_ScreenMode,0
;! jne NoMenu                 ;EGA?
;! cmp ds:CGA_MustRebuild,2
;! jne NoMenu                 ;Not in MENU.
;!
;!;When MENU is displayed, the last non-menu frame is saved to CS_BufferScreen1.
;!;then copied each 'frame' to CS_CGA_Screen2;
;!;MCClearRectangle then erases the menu 'window', the text is printed, then
;!;MCHeroInput copies the entire frame to the real screen.
;!
;!;During a MENU display the meanings of the buffers changes...
;!
;! IF TwoD
;!  mov ds,cs:CS_CGA_Screen2
;!  assume ds:nothing
;! 
;!  mov ax,0B800h
;!  mov es,ax
;!  mov si,0
;!  mov di,si
;!  mov cx,02000h              ;8K words
;!  rep movsw
;! 
;!  mov ax,seg vars
;!  mov ds,ax
;!  assume ds:vars
;! 
;!  mov CharThisSize,0
;!  mov CharLastSize,0
;! ENDIF ;TwoD
;!
;!NoMenu:
 if DosKeyboard
 call ConvertRealKeyboard
 endif ;DosKeyboard

 cmp ds:B_LastKeyPressed,3
 jne notterminate

 jmp MCCloseDown

notterminate:
   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,409h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,40Ah ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 jmp MCReturn

MCHeroInput endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 23
;-------------------------------------

MCHandlePlayerInput proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 call ReadJoystick          ;Set up direction player faces/fires

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,40Bh ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

;Convert direction requested by player to one that is acheivable,
;then adjust for speed.
 call adjustplayerposition

 test B_JoystickStatus,128  ;Fire/Keypad centre
 jz notfire
 call MayBeFireMissile
 jmp short fireok
notfire:
 mov ds:FireButtonHeld,0
fireok:

 if TraceCode          ;@
 mov cs:debugword,40Ch ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 jmp MCReturn

;-----

   IF TwoD
MayBeFireMissile proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 cmp ds:FireButtonHeld,0
 je FireMissile
 dec ds:FireButtonHeld
 ret

FireMissile:
 mov ds:FireButtonHeld,4    ;restrict rate of fire

 push si
 call Game_SpecialMissile   ;11th jump
 pop si

 mov es,cs:CS_Acode
 mov ax,es:V1
 mov ds:D4,ax
 cmp ax,0
 jne GoFireMissile          ;sprite number to use non-zero
 ret

GoFireMissile:

;Initiate fire
; mov cl,ds:B_SourceWeapon
; cmp cl,0
; jne WeHaveWeapon
; ret

;WeHaveWeapon:
;Special cases for firing (e.g. to trigger "create monster")
; cmp cl,60                  ;Create monster?
; je FireSpecialMissile
; cmp cl,71                  ;Stick of dynamite?
; je FireSpecialMissile
; cmp cl,73                  ;shield wand?
; je FireSpecialMissile
; cmp cl,65                  ;wand of digging?
; jne NotSpecialMissile
; call FireSpecialMissile    ;digging does a "gosub" to acode
; jmp short NotSpecialMissile ;and then continues with fire

;FireSpecialMissile:
; mov ds:B_SpecialMissile,cl ;Set flag for ACODE to use

; push bx ;A0
; push di ;A1
; push si ;A6

; call Game_SpecialMissile ;11th jump

; pop si ;A6
; pop di ;A1
; pop bx ;A0

; ret

;NotSpecialMissile:

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov si,offset SpriteTable
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 add si,ax

 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl
 add dx,4                   ;overlap allowed for head
 mov ds:D2,0
 mov al,ds:Move_View[si]
 mov byte ptr ds:D2,al

 mov bx,ds:D2
 add bx,bx                  ;2 words per entry
 add bx,bx
 add bx,offset ViewToXYConversionTable

 mov ax,cs:[bx]             ;X speed
 push dx
 mov dx,12                  ;missiles go at 12 pel/step
 mul dx
 mov ds:D2,ax
 mov ax,cs:2[bx]            ;Y speed
 mov dx,12                  ;missiles go at 12 pel/step
 mul dx
 mov ds:D3,ax
 pop dx

 mov es,cs:CS_Acode
 mov ax,es:V1 ;Sprite number 

; mov al,ds:B_CurrentWeapon
; mov byte ptr ds:D6,al
; mov ds:D4,9                ;sprite number for digging missile
; cmp byte ptr ds:D6,1
; je FM1
; mov ds:D4,8                ;sprite for explosive weapon
; cmp byte ptr ds:D6,2
; je FM1
; mov ds:D4,1                ;sprite number of non-explosive missile

;FM1:
 rol ds:Random,1
 mov ax,ds:Random
 mov ds:D6,ax

 cmp ds:D2,0
 je NoRandomizeXSpeed
 cmp ds:D3,0
 je NoRandomizeBoth
; and change to y speed to maintain angles of diagonals

 test ds:D6,1
 jz DecreaseSpeed
;increase speed

 inc ds:D2
 cmp ds:D2,0                ;Must be CMP to set sign flag
 jg IncreaseSpeed1
 sub ds:D2,2
IncreaseSpeed1:
 inc ds:D3
 cmp ds:D3,0                ;Must be CMP to set sign flag
 jg NoRandomizeXspeed
 sub ds:D3,2
 jmp short NoRandomizeYspeed

DecreaseSpeed:
 dec ds:D2
 cmp ds:D2,0                ;Must be CMP to set sign flag
 jg DecreaseSpeed1
 add ds:D2,2
DecreaseSpeed1:
 dec ds:D3
 cmp ds:D3,0                ;Must be CMP to set sign flag
 jg NoRandomizeYspeed
 add ds:D3,2
 jmp short NoRandomizeYSpeed

NoRandomizeBoth:
 inc ds:D2
 test ds:D6,1
 jz NoRandomizeXSpeed
;Decrease X speed
 sub ds:D2,2

NoRandomizeXSpeed:
  cmp ds:D3,0
 je NoRandomizeYSpeed
 test ds:D6,1
 jz NoRandomizeYspeed

DecreaseYSpeed:
 dec ds:D3
 jmp short NoRandomizeYspeed

IncreaseYSpeed:
 inc ds:D3

 NoRandomizeYSpeed:

;CX,DX = Initial X,Y position. D2,D3 are X,Y speed D4 is sprite number

 call SetUpNewSprite

 mov al,ds:B_SourceWeapon
 mov ds:Move_SourceWeapon[bx],al

 if TraceCode          ;@
 mov cs:debugword,40Dh ;@
 endif ;TraceCode      ;@

 ret

MayBeFireMissile endp
   ENDIF ;TwoD

;-----

ReadJoystick:
 mov ds:PlayerDirection,0   ;Set Up missile fire direction player

 test B_JoystickStatus,1    ;Up
 jz NotMoveUp
 or byte ptr PlayerDirection,4
NotMoveUp:

 test B_JoystickStatus,2    ;Down
 jz NotMoveDown
 or byte ptr PlayerDirection,8
NotMoveDown:

 test B_JoystickStatus,4    ;Left
 jz NotMoveRight
 or byte ptr PlayerDirection,1
NotMoveRight:

 test B_JoystickStatus,8    ;Right
 jz NotMoveLeft
 or byte ptr PlayerDirection,2
NotMoveLeft:

 mov al,ds:PlayerDirection
 mov bx,offset DirectionAdjust
 xlat byte ptr cs:[bx] ; mov al,cs:[al+bx]
 mov ds:PlayerDirection,al

stationary:
 ret

;-----

;Set up player direction/speed in it's Move_Structure.

   IF TwoD
adjustplayerposition:
 mov cx,0                   ;Set default player speed to be stationary
 mov dx,0

 test ds:B_JoystickStatus,128
 jz ap01
 jmp short ap05             ;If firing; leave player stationary

;If not firing then set up player to request a move

ap01:
 test byte ptr ds:PlayerDirection,1
 jz ap02                    ;Not trying to go nw/w/sw
 mov cx,-4
ap02:
 test byte ptr ds:PlayerDirection,2
 jz ap03                    ;Not trying to go ne/e/se
 mov cx,4
ap03:
 test byte ptr ds:PlayerDirection,4
 jz ap04                    ;Not trying to go nw/n/ne
 mov dx,-4
ap04:
 test byte ptr ds:PlayerDirection,8
 jz ap05                    ;Not trying to go sw/s/se
 mov dx,4
ap05:

;If not firing; Check if player is trying to collide 
;with wall, and 'cushion' the move if possible.

; cx,dx=speed
 call CheckPlayerMove 
; cx,dx=speed

;Store the allowable move/speed(s)
;This only checks for player/background collision; player/sprite collisions
;use the normal sprite/sprite collision detection.

 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 xchg ch,cl
 mov ds:Move_Xspeed_HiLo[si],cx ;Allowable horizontal-component of move

 xchg dh,dl
 mov ds:Move_Yspeed_HiLo[si],dx ;Allowable vertical-component move

 ret
   ENDIF ;TwoD

MCHandlePlayerInput endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 7
;-------------------------------------

MCMoveAllSprites proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD
 call MoveAllSprites

;Now decide how best to redraw screen.

 if TraceCode          ;@
 mov cs:debugword,40Eh ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

 call AdjustScreenWindow

 if TraceCode          ;@
 mov cs:debugword,40Fh ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 jmp MCReturn

MCMoveAllSprites endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 8
;-------------------------------------

MCDisplayAllSprites proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD

 if TraceCode          ;@
 mov cs:debugword,410h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

 cmp ds:CGA_MustRebuild,0
 jne movebackground
 jmp short redisplay6       ;(No movement of background)

movebackground:

;Re-draw the entire background:
Redisplay1:
 if TraceCode          ;@
 mov cs:debugword,411h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

 call AlignForJump

 if TraceCode          ;@
 mov cs:debugword,412h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

 call RefreshAligned

 if TraceCode          ;@
 mov cs:debugword,413h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

 jmp short allmoved

redisplay6:                 ;Keep the background the same
 if TraceCode          ;@
 mov cs:debugword,414h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

;! cmp cs:CS_ScreenMode,0
;! jne EgaDisplay
;! call CGA_PlaceSprites
;! jmp short allmoved

;!EgaDisplay:
 call RedisplaySprites

allmoved:
;Reset flag for next time. If in the mean time something else happens
;during the next frame build, setting CGA_MustRebuild<>0 will force
;the next frame to be a complete background-rebuild.

 mov ax,seg vars
 mov ds,ax
 assume ds:vars
 mov es,ax ;(ax=seg vars)

 mov ds:CGA_MustRebuild,0

 if TraceCode          ;@
 mov cs:debugword,415h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

   ENDIF ;TwoD

 jmp MCReturn

MCDisplayAllSprites endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 4
;-------------------------------------

MCSpecials proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

   IF TwoD
 if TraceCode          ;@
 mov cs:debugword,416h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@
   ENDIF ;TwoD

 jmp MCReturn

MCSpecials endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 13
;-------------------------------------

MCCalculateMemoryFree proc near

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,cs:CS_FreeParagraphs ;(1 paragraph = 16 bytes)
 rept 10-4                  ;divide by 1024, multiply by 16
 shr ax,1
 endm ;rept

 mov es,cs:CS_Acode
 mov es:V1,ax               ;in 1Kbyte units

 jmp MCReturn

MCCalculateMemoryFree endp

;-----

;!EightLines macro updateline
;!
;! IF TwoD
;! ENDIF ;TwoD
;!
;! mov ax,0B800h ;!** Never used
;! mov es,ax ;!****
;!;! mov es,cs:CS_CGA_Screen2
;! mov si,(96*80)
;! call updateline
;! mov si,2000h+(96*80)
;! call updateline
;! mov si,(97*80)
;! call updateline
;! mov si,2000h+(97*80)
;! call updateline
;! mov si,(98*80)
;! call updateline
;! mov si,2000h+(98*80)
;! call updateline
;! mov si,(99*80)
;! call updateline
;! mov si,2000h+(99*80)
;!updateline:
;!
;! endm ;EightLines

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 31
;-------------------------------------

MCScrollTextLine proc near

 mov es,cs:CS_Acode

;! cmp cs:CS_ScreenMode,0
;! jne st01

;! mov cx,es:V1
;! call st02
;! jmp MCReturn
;!
;!st01:
 mov bx,es:V1
   IF TwoD
 call Pass_Variables
 call EGA2DShiftRectangle
 call Retrieve_Variables
   ELSE ;TwoD
 call cs:AddrShiftRectangle
   ENDIF ;TwoD
 jmp MCReturn

;-----

;!st02:
;! mov ax,seg vars
;! mov ds,ax
;! assume ds:vars
;!
;! mov es,cs:CS_Acode
;! mov cx,es:V1
;! cmp cx,2
;! jne st04
;!
;!;Scroll left by two pixels...
;!
;! EightLines u2              ;Do remaining subroutine for each pixel row.
;! add si,80
;! mov cx,80
;! clc
;! mov dh,0
;!st03:
;! dec si
;! rcl dh,1
;! rcl byte ptr es:[si],1
;! rcl dh,1
;! rcl byte ptr es:[si],1
;! rcl dh,1
;! rcl byte ptr es:[si],1
;! rcl dh,1
;! rcl byte ptr es:[si],1
;! rcl dh,1
;! rcl dh,1
;! rcl dh,1
;! rcl dh,1
;! rcl dh,1
;! loop st03
;! ret
;!
;!st04:
;! cmp cx,4
;! jne st06
;!
;!;Scroll left by one byte (four pixels)...
;!
;! EightLines u4              ;Do remaining subroutine for each pixel row.
;! mov cx,80
;!st05:
;! mov al,es:1[si]
;! mov es:0[si],al
;! inc si
;! loop st05
;! dec si
;! mov byte ptr es:0[si],0
;! ret
;!
;!st06:
;! cmp cx,6
;! je st07
;! ret
;!
;!st07:
;!;Scroll left by six pixels...
;!
;! EightLines u6              ;Do remaining subroutine for each pixel row.
;! add si,80
;! mov cx,80
;! clc
;! dec si
;! dec cx
;! mov al,es:0[si]
;! mov ah,0
;!st08:
;! dec si
;! mov dl,es:0[si]
;! rcl ah,1
;! rcl al,1
;! rcl ah,1
;! rcl al,1
;! rcl ah,1
;! rcl al,1
;! rcl ah,1
;! rcl al,1
;! mov es:0[si],al
;! mov al,dl
;! rcl ah,1
;! rcl ah,1
;! rcl ah,1
;! rcl ah,1
;! rcl ah,1
;! loop st08
;! ret

MCScrollTextLine endp

;! purge EightLines           ;speed up assembly

;Location of Clock interrupt handler...
CS_DriverClock db 0 ;0 - My timer. 0FF - HEADER.BIN

;-----

;...e

code ends

;-----

stacks segment stack 'stack'
stacks ends

;-----

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
