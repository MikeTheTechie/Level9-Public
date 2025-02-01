 page 128,122 ;length,width
;IBM HERO. All collision detection/Sprite sorting/Sprite moving.

;MOVE.ASM

;Copyright (C) 1988,1989 Level 9 Computing

;-----

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
 include common.asm
 include consts.asm
 include structs.asm

;...e

;...sPublics and externals:0:

 public MCFindSprite
 public MCDestroyList20
 public MCDestroyList22
 public MCSetUpNewSprite
 public MCSpecialCheck
 public MCStartBigExplosion

;In MCODE.ASM:
 extrn MCReturn:near

   IF TwoD

 public CheckPlayerMove
 public D2
 public D3
 public D4
 public D5
 public MoveAllSprites
 public SetUpNewSprite
 public SpriteTptr

;In GAME.ASM:
 extrn B_JoystickStatus:byte
 extrn CGA_MustRebuild:byte
 extrn HiLo_PlayerSprite:word
 extrn HiLo_ScreenXblocks:word
 extrn HiLo_ScreenYblocks:word
 extrn HiLo_XposSave:word
 extrn HiLo_YposSave:word
 extrn SpriteTable:byte
 if TraceCode              ;@
 extrn CheckSTaddress:near ;@
 extrn CheckCD:near        ;@
 extrn CheckChain:near     ;@
 extrn DebugWord:word      ;@
 endif ;TraceCode          ;@

;In HUGE.ASM:
 extrn CS_Acode:word
;! extrn CS_ScreenMode:byte
 extrn DumpRegisters:near
 extrn CS_ViewSegment:word

;In MCODE.ASM:
 extrn Game_BGSpecials:near
 extrn Game_DAMSSpecials:near
 extrn Game_FGSpecials:near

;In TABLES.ASM:
 extrn BigExplosiontable:byte
 extrn PlayerSprite:byte
 extrn SpriteDataStructure:byte

   ENDIF ;TwoD

;...e:

;-----

code segment public 'code'

 assume cs:code
   IF TwoD
 assume ds:vars
   ENDIF ;TwoD

;           Either   Signed   Unsigned
;    <=              jle      jbe
;    <               jl       jb/jc
;    =      je/jz
;    <>     jnz/jne
;    >=              jge      jae/jnc
;    >               jg       ja

;-----

   IF TwoD

Push_D0_D7 macro

 push cx ;D0
 push dx ;D1
 mov ax,ds:D2
 push ax
 mov ax,ds:D3
 push ax
 mov ax,ds:D4
 push ax
 mov ax,ds:D5
 push ax
 mov ax,ds:D7
 push ax

 endm

;-----

Pop_D0_D7 macro

 pop ax
 mov ds:D7,ax
 pop ax
 mov ds:D5,ax
 pop ax
 mov ds:D4,ax
 pop ax
 mov ds:D3,ax
 pop ax
 mov ds:D2,ax
 pop dx ;D1
 pop cx ;D0

 endm

;-----

Push_A0_A7 macro

 push bx ;A0
 push di ;A1
 mov ax,ds:A2
 push ax
 mov ax,ds:A3
 push ax
 mov ax,ds:A4
 push ax
 mov ax,ds:A5
 push ax
 push si ;A6

 endm

;-----

Pop_A0_A7 macro

 pop si ;A6
 pop ax
 mov ds:A5,ax
 pop ax
 mov ds:A4,ax
 pop ax
 mov ds:A3,ax
 pop ax
 mov ds:A2,ax
 pop di ;A1
 pop bx ;A0

 endm

;-----

;...sSubroutines:0:

SetUpNewSprite proc near

 if TraceCode         ;@
 mov cs:debugword,704h
 call CheckChain
 mov cs:debugword,705h
 call su01
 mov cs:debugword,706h
 call CheckChain
 mov cs:debugword,707h
 ret

;CX,DX = Initial X,Y position. D2,D3 are X,Y speed D4 is sprite number
;(I.E. which entry in fixed sprite table is to be used)
;Returns BX as pointer to temp sprite table

su01:
 endif ;TraceCode     ;@

 mov bx,ds:SpriteTptr
 cmp ds:Move_InfoPtr[bx],0
 jne su02
 jmp SUNS5 ;JE

su02:
 mov bx,offset SpriteTable

 mov ds:D7,MaxMovingSprites ;max size of table

Suns1:
 cmp ds:Move_InfoPtr[bx],0
 je Suns2                   ;got a blank entry
 add bx,size Move_Structure
 dec ds:D7
 jnz Suns1

 mov ax,0FFFFh              ;return code
 ret                        ;can't set up sprite! (sorry)

Suns2:
 mov ax,ds:D4               ;Sprite number
 mov ds:TempNameStorage,ax  ;(Sprite number)

 push dx
 mov dx,size Perm_Structure ;size of fixed sprite information
 mul dx ;corrupts dx        ;Get offset of sprite structure
 pop dx
 add ax,offset SpriteDataStructure
 mov ds:A3,ax               ;A3 is fixed sprite information

;decide where to put the sprite in the chain
;Items of low priority are displayed first (and therefore
;stored first in the linked list). Items of same
;priority are sorted according to Y position.

 mov di,ds:SpriteTptr
 mov ds:D7,MaxMovingSprites ;max size of table - limit scan

SunsScan0:
 cmp ds:Move_NextPtr[di],0
 jne sa01
 jmp SunsAddAfterCurrent    ;GotNewPosition ;End of linked list

sa01:
;* Priority

;is the new Y position lower on screen than this sprite?
;If so we have found the right place
 push ax
 mov ax,ds:Move_Ypos_HiLo[di]
 xchg ah,al
 cmp dx,ax
 pop ax

 jl SunsInsertSprite

SunsScan1:                  ;keep on scanning
 mov di,ds:Move_NextPtr[di]
 dec ds:D7
 jnz SunsScan0

;should never get here
 call DumpRegisters
 db 0E0h ;generate an 'limit-exceeded'  break point

GotNewPosition:
 mov ds:Move_NextPtr[bx],0  ;Clear the new ptr

SunsInsertSprite:
GotPosition:
;insert a sprite (BX) before (DI)
 mov ax,ds:Move_LastPtr[di]
 mov ds:A2,ax               ;keep address of previous sprite
 mov ds:Move_LastPtr[bx],ax ;point back to previous link
 and ax,ax                  ;test ptr to previous sprite
 jnz Suns3a

;adding a new entry to start of chain
;we've just added because its the first in the chain.

 mov ds:SpriteTptr,bx
 cmp bx,0
 jne Suns3b

 call DumpRegisters
 db 0F3h ;generate an 'Invalid-address'  break point

Suns3a:
 push di
 mov di,ax                  ;SCB before the insertion
 mov ds:Move_NextPtr[di],bx
 pop di

Suns3b:
 mov ds:Move_NextPtr[bx],di
 mov ds:Move_LastPtr[di],bx

Suns3:
 mov ax,ds:A3
 mov ds:Move_InfoPtr[bx],ax ;Sprite data addresses

 if TraceCode     ;@
 call CheckCD     ;@
 endif ;TraceCode ;@

 mov ax,ds:D2
 xchg ah,al
 mov ds:Move_Xspeed_HiLo[bx],ax ;X speed
 mov ax,ds:D3
 xchg ah,al
 mov ds:Move_Yspeed_HiLo[bx],ax ;X speed
 xchg ch,cl
 mov ds:Move_Xpos_HiLo[bx],cx ;x pos
 xchg ch,cl
 xchg dh,dl
 mov ds:Move_Ypos_HiLo[bx],dx ;y pos
 xchg dh,dl

;get base sprite number for view

 mov ax,ds:TempNameStorage
 xchg ah,al
 mov ds:Move_Name_HiLo[bx],ax ;Set up default 'name'
 mov ds:Move_Animation_HiLo[bx],-1 ;insivible

 push di

;! cmp cs:CS_ScreenMode,0
;! je set_cga

;EGA: Store sprite number

 mov ax,ds:Move_Animation_HiLo[bx] ;add current animation offset
 xchg ah,al
 mov di,ax                  ;ax=displayed sprite number
;! jmp short set_both
;!
;!set_cga:
;! xchg ah,al
;! cmp ax,4
;! jb rangeok
;! mov ax,4
;!rangeok:
;! push dx
;! mov dx,SpriteHeight*40     ;Each sprite is stored 20x10 bytes
;! mul dx
;! pop dx
;! mov di,offset PlayerSprite ;calculate offset of sprite set
;! add di,ax                  ;CGA: Store cs:address
;!
;!set_both:
 mov ds:Move_DataPtr[bx],di

 mov di,ds:A3               ;info ptr/CD storage

 if TraceCode     ;@
 mov ax,di        ;@
 call CheckCD     ;@
 endif ;TraceCode ;@

 mov ax,cs:Perm_HitPoint_HiLo[di]
 mov ds:Move_HitPoint_HiLo[bx],ax
 mov ax,cs:Perm_BlowStrength_HiLo[di]
 mov ds:Move_BlowStrength[bx],ax
 pop di

 mov ax,ds:D7               ;Return code
 ret

;-----

SunsAddAfterCurrent:
;We found the end of the chain (DI)
;Now add the sprite (BX) at this end of the list
 mov ds:Move_NextPtr[di],bx
 mov ds:Move_LastPtr[bx],di
 mov ds:Move_NextPtr[bx],0
 jmp Suns3

;-----

Suns5:
;first entry only - just calc address and write data block
;size of fixed sprite information
 push dx
 mov ax,size Perm_Structure
 mov dx,ds:D4
 mul dx ;corrupts dx
 pop dx

 mov ds:D4,ax               ;get offset of sprite structure
 add ax,offset SpriteDataStructure
 mov ds:A3,ax

;bx is sprite data
 mov ds:Move_NextPtr[bx],0  ;set up ptr to next entry
 mov ds:Move_LastPtr[bx],0
 jmp Suns3

SetUpNewSprite endp

;-----

DamsSpecials proc near

;SI = control block.
;Now do special cases for particular types of monsters...

 push di
 mov di,ds:A4
 mov cl,cs:Perm_Type[di]
 mov ch,0
 pop di

DamssNotMissile:
 cmp cx,4
 je dn01
 jmp short DamsNotMonster

;make monsters move towards player
dn01:
 mov ds:D4,0                ;will be direction of view

;++++ The next instruction is different in ST machine code....
 ret

DamsNotMonster:
 cmp cx,1
 jne DamsNotPlayer
 ret

DamsNotPlayer:
;animate all monsters (except the player
;which is handled only when it is walking)

 ret

DamsSpecials endp

;-----

CheckForSpriteCollision proc near

 cmp ds:D2,0                ;X speed
 jne CFSC1
 cmp ds:D3,0                ;Y speed
 jne CFSC1
;No movement

;++++ The next instruction is different in ST machine code....
 cmp ds:Move_InfoPtr[si],0
 je CFSC1                   ;Player, always check
 ret

CFSC1:
 jmp short CDWithAllSprites ;call, ret

CheckForSpriteCollision endp

;-----

;On entry D0 CX=new X position
;         D1 DX=new Y position
;         A6 SI=address of control block
;         A4 fixed data block
;Returns  D7 AL=1 if ok to move to this position
;         A0 BX=control block for the sprite we hit.

CDWithAllSprites proc near

;Collision detect with all other sprites...
 push di
 mov di,ds:A4               ;(fixed data block)
 mov al,cs:Perm_Type[di]    ;Get type
 mov byte ptr ds:Sprite2_Type,al ;remains as type throughout
 mov al,cs:Perm_Flags[di]
 pop di
 mov byte ptr ds:D5,al      ;D5 remains set as collision detect flag

 and al,al
 jnz as01
 mov ds:D7,1                ;ok to move
 cmp ds:D7,0
 ret                        ;Don't collision detect with anything

as01:
 mov ds:D7,MaxMovingSprites

 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl

;Search sprites after current one on screen....
 mov bx,si                  ;Initial Value

CDWFore1:
 mov ax,ds:Move_NextPtr[bx]
 and ax,ax
 jnz cf01
 jmp CDWForeEnd

cf01:
 mov bx,ax

;cd sprite (BX) with sprite (SI). check Y positions of the two
;sprites... (ignore head overlap at the present as it will be
;the same for both sprites.)

 mov ax,dx                  ;copy Y pos to temporary
 push bx
 mov bx,ds:Move_Ypos_HiLo[bx]
 xchg bh,bl
 sub ax,bx
 pop bx
 cmp ax,0                   ;Must be CMP to set sign flag
 jg CDWFore3
 neg ax
CDWFore3:
 cmp ax,13                  ;vertical separation between sprites
 jg CDWFore1

;++++ The next 12 instructions are different in ST machine code....
;Check X pos of the two sprites
 mov ax,cx                  ;Copy X pos to temporary
 push bx
 mov bx,ds:Move_Xpos_HiLo[bx]
 xchg bh,bl
 sub ax,bx
 pop bx

 cmp ax,0                   ;Must be CMP to set sign flag
 jg CDWFore2
 neg ax
CDWFore2:
 cmp ax,13
 jg CDWFore1

;Collision!
;Should we take any notice of it?

 mov di,ds:Move_InfoPtr[bx] ;Get permament data block for sprite

 if TraceCode          ;@
 mov cs:debugword,708h ;@
 mov ax,di             ;@
 call CheckCD          ;@
 endif ;TraceCode      ;@

 mov al,cs:Perm_Type[di]
 and al,byte ptr ds:D5      ;Do this collision detect
 jnz CDWForeCollision       ;yes

 mov al,cs:Perm_Flags[di]
 and al,byte ptr ds:Sprite2_Type ;check flags other way round
 jnz CDWForeCollision       ;don't bother
 jmp short CDWFore1

CDWForeCollision:
 Push_D0_D7
 call FGSpecials
 Pop_D0_D7

 cmp ds:D4,0                ;Should we carry on with cd?
 je cf02
 jmp CDWFore1

cf02:
 ret                        ;Fatal collision - no more checking.

;-----

CDWForeEnd:
;search sprites before current one on screen...
 mov bx,si

CDWBack1:
 mov ax,ds:Move_LastPtr[bx]
 and ax,ax
 jnz cb01
 jmp CDWBackEnd

cb01:
 mov bx,ax

;cd sprite (BX) with sprite (SI)
;check Y pos of the two sprites...

 mov ax,dx
 push bx
 mov bx,ds:Move_Ypos_HiLo[bx]
 xchg bh,bl
 sub ax,bx
 pop bx
 cmp ax,0                   ;Must be CMP to set sign flags
 jg CDWBack3
 neg ax
CDWBack3:
 cmp ax,13
 jg CDWBack1

;Check X pos of the two sprites

 mov ax,cx
 push bx
 mov bx,ds:Move_Xpos_HiLo[bx]
 xchg bh,bl
 sub ax,bx
 pop bx
 cmp ax,0                   ;Must be CMP to set sign flags
 jg CDWBack2
 neg ax
CDWBack2:
 cmp ax,13
 jg CDWBack1

;Collision!
;should we take any notice of it?
 mov di,ds:Move_InfoPtr[bx]

 if TraceCode     ;@
 mov ax,di        ;@
 call CheckCD     ;@
 endif ;TraceCode ;@

 mov al,cs:Perm_Type[di]
 and al,byte ptr ds:D5      ;do this collision detect
 jnz CDWBackCollision

 mov al,cs:Perm_Flags[di]
 and al,byte ptr ds:Sprite2_Type ;check for flags other way round...
 jnz CDWBackCollision
 jmp short CDWBack1         ;don't bother...

CDWBackCollision:
 Push_D0_D7
 call FGSpecials
 Pop_D0_D7

 cmp ds:D4,0
 je cb02
 jmp CDWBack1

cb02:
 ret                        ;Fatal collision - no more checking

;-----

CDWBackEnd:
 if TraceCode          ;@
 mov cs:DebugWord,709h ;@
 endif ;TraceCode      ;@

 mov ds:D7,1                ;no collision
 cmp ds:D7,0
 ret

CDWithAllSprites endp

;-----

FGSpecials proc near

 Push_A0_A7

 push di                    ;di=A1

 mov es,cs:CS_Acode
 mov di,offset PCListVector+(20*4) ;table 20

 if TraceCode          ;@
 mov cs:debugword,70Ah ;@
 call CheckSTaddress   ;@
 push si               ;@
 mov si,bx             ;@
 call CheckSTaddress   ;@
 pop si                ;@
 endif ;TraceCode      ;@

 mov ax,si                  ;Table 20 = A6
 stosw ; mov es:[di],ax : add di,2
 mov ax,seg vars
 stosw ; mov es:[di],ax : add di,2

 mov ax,ds:A4               ;Table 21

 if TraceCode     ;@
 push ax          ;@
 call CheckCD     ;@
 pop ax           ;@
 endif ;TraceCode ;@

 stosw ; mov es:[di],ax : add di,2
 mov ax,seg code
 stosw ; mov es:[di],ax : add di,2

 mov ax,bx                  ;Table 22
 stosw ; mov es:[di],ax : add di,2
 mov ax,seg vars
 stosw ; mov es:[di],ax : add di,2

 pop ax                     ;Table 23 = A1
 push ax                    ;A1 = di

 if TraceCode     ;@
 call CheckCD     ;@
 pop ax           ;@
 push ax          ;@
 endif ;TraceCode ;@

 stosw ; mov es:[di],ax : add di,2
 mov ax,seg code
 stosw ; mov es:[di],ax : add di,2

 pop di

 if TraceCode          ;@
 mov cs:debugword,70Bh ;@
 endif ;TraceCode      ;@

 call Game_FGSpecials

 mov es,cs:CS_Acode
 mov ax,es:V1
 mov ds:D4,ax               ;Put return code back into ds:D4

 Pop_A0_A7
 ret

FGSpecials endp

;-----

DestroySprite proc near

;Remove the sprite whose control block is (BX)
 if TraceCode        ;@
 push si             ;@
 mov si,bx           ;@
 call CheckSTaddress ;@
 pop si              ;@
 endif ;TraceCode    ;@

 mov di,ds:Move_LastPtr[bx]
 mov ax,ds:Move_NextPtr[bx] ;ax = ds:A2
 and di,di                  ;first sprite in chain?
 jnz DS1

 mov ds:SpriteTptr,ax       ;ax = ds:A2
 push di
 mov di,ax                  ;ax = ds:A2
 mov ds:Move_LastPtr[di],0  ;new first sprite in chain
 pop di
 jmp short DS2

DS1:
 mov ds:Move_NextPtr[di],ax ;ax = ds:A2
 and ax,ax                  ;last sprite in chain?
 jz DS2

 push bx
 mov bx,ax                  ;ax = ds:A2
 mov ds:Move_LastPtr[bx],di
 pop bx
DS2:
 mov ds:Move_InfoPtr[bx],0  ;remove the pointer to the fixed data
 mov ds:Move_LastPtr[bx],0
 mov ds:Move_NextPtr[bx],0  ;(safety)
 ret

DestroySprite endp

;-----

CheckForBackgroundCollision proc near

;Collision with background?
 if TraceCode          ;@
 mov cs:debugword,70Eh ;@
 endif ;TraceCode      ;@

 push di
 mov di,ds:A4
 mov al,cs:Perm_Height[di]
 pop di
 mov byte ptr ds:Check_Height,al ;offset of bottom row

 xor bx,bx                  ;Offset into map data
 call MapCheck
 jnz cb03                   ;NoBGCollision

;Monsters do not collide, but are 'cushioned' by corners just
;like the player.

 call CleverMapCheck
 jz cb04                    ;Not a monster/Monster blocked from moving.

cb03:
 if TraceCode          ;@
 mov cs:debugword,70Fh ;@
 endif ;TraceCode      ;@

 jmp NoBGCollision          ;(Monster free to move/ Monster cushioned.)

;(Not a monster/Monster blocked from moving.)
cb04:
 push di
 mov di,ds:A4
 mov al,cs:Perm_Flags[di]
 pop di
 mov byte ptr ds:D5,al
 test al,CDwithBG
 jnz cb05
 jmp  NoBGCollision

;Sprite collided with the background - should it actually
;be destroyed, or just be prevented from moving?
cb05:
 push di
 mov di,ds:A4
 mov al,cs:Perm_Destroyed[di]
 pop di
 mov byte ptr ds:D5,al
 test al,CDwithBG
 jnz cb06
 jmp BGNoExplode ;jz

cb06:
 Push_D0_D7
 Push_A0_A7

 if TraceCode          ;@
 mov cs:debugword,710h ;@
 endif ;TraceCode      ;@

 call SpecialMapCheck

 if TraceCode          ;@
 pushf                 ;@
 mov cs:debugword,711h ;@
 popf                  ;@
 endif ;TraceCode      ;@

 jz BGDestroy1

 Pop_A0_A7
 Pop_D0_D7
 if TraceCode          ;@
 mov cs:debugword,712h ;@
 endif ;TraceCode      ;@

 jmp NoBGCollision

BGDestroy1:
 if TraceCode          ;@
 mov cs:debugword,713h ;@
 endif ;TraceCode      ;@

 Pop_A0_A7
 Pop_D0_D7

;Collision with wall - kill the sprite - the explosion
;and any other effects will be handled in the specials code.

 if TraceCode          ;@
 mov cs:debugword,714h ;@
 endif ;TraceCode      ;@

 mov bx,si
 call DestroySprite
 mov ds:Move_InfoPtr[si],1  ;prevent sprite entry being reused yet.

BGNoExplode:
 push di
 mov di,ds:A4
 mov al,cs:Perm_Specials[di]
 pop di
 mov byte ptr ds:D5,al
 test ds:D5,CDwithBg
 jz NoBGSpecials

 if TraceCode          ;@
 mov cs:debugword,715h ;@
 endif ;TraceCode      ;@

 call BGSpecials            ;sometimes create new sprites, so if the sprite

 if TraceCode          ;@
 mov cs:debugword,716h ;@
 endif ;TraceCode      ;@

;had been properly destroyed above, a new replacement for it might
;possibly have been created.

NoBGSpecials:
 mov cx,ds:Move_InfoPtr[si]
 cmp cx,1
 jne NoBGDestroyed
;Sprite was previously marked for destruction

 mov ds:Move_InfoPtr[si],0 ;destroy it properly

NoBGDestroyed:
 push di
 mov di,ds:A4
 mov al,cs:Perm_Blocked[di]
 pop di
 mov byte ptr ds:D5,al
 test ds:D5,CDwithBG
 jz NoBGCollision           ;Not blocked

;Reset co-ords
 mov cx,ds:HiLo_XposSave
 mov ds:Move_Xpos_HiLo[si],cx
 xchg ch,cl
 mov dx,ds:HiLo_YposSave
 mov ds:Move_Ypos_HiLo[si],dx
 xchg dh,dl

 mov ds:D2,0                ;and kill movement
 mov ds:D3,0                ;clear y speed to avoid unnecessary sorting

 if TraceCode          ;@
 mov cs:debugword,717h ;@
 endif ;TraceCode      ;@

 ret

NoBGCollision:
 if TraceCode          ;@
 mov cs:debugword,718h ;@
 endif ;TraceCode      ;@

 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl
 ret

CheckForBackgroundCollision endp

;-----

BGSpecials proc near

 Push_A0_A7

 mov es,cs:CS_Acode
 mov di,offset PCListVector+(20*4) ;table 20

 if TraceCode          ;@
 mov cs:debugword,719h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov ax,si                  ;Table 20 = A6
 stosw ; mov es:[di],ax : add di,2
 mov ax,seg vars
 stosw ; mov es:[di],ax : add di,2

 mov ax,ds:A4               ;Table 21

 if TraceCode     ;@
 push ax          ;@
 call CheckCD     ;@
 pop ax           ;@
 endif ;TraceCode ;@

 stosw ; mov es:[di],ax : add di,2
 mov ax,seg code
 stosw ; mov es:[di],ax : add di,2

 Pop_A0_A7

 call MCBGSpecials

 Push_A0_A7

 if TraceCode          ;@
 mov cs:debugword,71Ah ;@
 endif ;TraceCode      ;@

 call Game_BGSpecials

 Pop_A0_A7
 ret

;-----

MCBGSpecials:
;(si),(A4) has just collided with a chunk of background
 push di
 mov di,ds:A4
 mov al,cs:Perm_Type[di]
 mov byte ptr ds:D5,al
 pop di
 test al,CDwithMissiles
 jnz ms01
 jmp BGNotMissile ;JZ

ms01:
 Push_D0_D7
 Push_A0_A7

 mov ax,Move_Name_HiLo[si]
 xchg ah,al
 mov ds:D4,ax
 cmp ax,9                   ;BG Destructive?
 jne BGExplode1

 mov ds:Move_InfoPtr[si],0  ;Prevent it exploding (again)

;When destroying walls the ST system removes the wall from the
;background map, but leaves the pre-scrolled copies of the
;background as incorrect. Until that cell-wall goes off the
;screen a 'mask' sprite is created to hide the original
;map-background.

;On the slow-PC in CGA mode I force the next screen to be entirely re-built.

;++++ The next three instructions are different in ST machine code....
 cmp CGA_MustRebuild,0
 jne CgaSet
 mov CGA_MustRebuild,1      ;simulate a jump-scroll
CgaSet:

 call BGDestroyWall         ;Display the explosion
 call NoTraceBack
 jmp short BGExplode2

BGExplode1:
 Pop_A0_A7
 Pop_D0_D7

 Push_D0_D7
 Push_A0_A7

 call TraceBack             ;Display the explosion in the most suitable place
BGExplode2:

 Pop_A0_A7
 Pop_D0_D7

BGNotMissile:
 ret

BGSpecials endp

;-----

;Using a weapon that destroys walls

BGDestroyWall proc near

 call MissileTrace

; CX,DX is approx position of explosion

 mov ax,ds:HiLo_ScreenYblocks
 xchg ah,al
 rept CellHeightBIts
 add ax,ax
 endm ;rept
 cmp dx,ax                  ;off the map!
 jae BGNoWallToDestroy

 mov ax,ds:HiLo_ScreenXblocks
 xchg ah,al
 rept CellWidthBits
 add ax,ax
 endm ;rept
 cmp cx,ax                  ;off the map!
 jae BGNoWallToDestroy

 push cx
 push dx
;Now CX,DX is position on grid
;calculate the position in the map

 rept CellWidthBits-1       ;Divide by 16 and multiply by 2.
 shr cx,1
 endm ;rept
 and cx,0FFFEh

 add dx,CellHeight/2

 rept CellHeightBits
 shr dx,1
 endm ;rept

 mov ax,HiLo_ScreenXblocks
 xchg ah,al
 add ax,ax                  ;MapWidth in words
 mul dx ;corrupts dx

 mov bx,cx
 add bx,ax                  ;Get es:bx address in map
 mov es,cs:CS_ViewSegment

 pop dx
 pop cx

;es:[bx] is now the square containing the left half of the explosion.

;+ At this point the ST system has some complex code to decide how much
;+ of the sprite overlaps the left & right cells/tiles; to decide which wall
;+ cell to demolish. 

;I found that one of the cells will be a floor tile and the other cell is 
;a wall tile. I demolish the wall tile.

 mov ax,es:[bx]
 xchg ah,al
 cmp ax,16                  ;Left cell  a floor tile?
 jb RightTrace
 mov word ptr es:[bx],0
 jmp short BGNoWallToDestroy

RightTrace:
 mov ax,cx                  ;X-pos
 and ax,CellWidth-1 ;0Fh
 cmp ax,0
 je BGNoWallToDestroy       ;exactly cell-aligned/ No right-cell overlap

 mov ax,es:2[bx]            ;Right square
 xchg ah,al
 cmp ax,16                  ;Right cell a floor tile?
 jb BGNoWallToDestroy
 mov word ptr es:2[bx],0

;+ ST version sets up 'mask' sprite here.

;When destroying walls the ST system removes the wall from the
;background map, but leaves the pre-scrolled copies of the
;background as incorrect. Until that cell-wall goes off the
;screen a 'mask' sprite is created to hide the original
;map-background.

BGNoWallToDestroy:

 ret

BGDestroyWall endp

;-----

MissileTrace proc near

 mov ds:Trace_Distance,24   ;maximum trace-back distance

 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl

 mov ax,ds:Move_Xspeed_HiLo[si]
 xchg ah,al
 mov ds:D2,ax
 mov ax,ds:Move_Yspeed_HiLo[si]
 xchg ah,al
 mov ds:D3,ax

;Now reduce speed until it is less than 4

MissileTraceBack1:
 cmp ds:D2,0
 je MissileTraceBack2
 jg MissileTraceBack2a
 mov ds:D2,0FFFFh
 jmp short MissileTraceBack2

MissileTraceBack2a:
 mov ds:D2,1

MissileTraceBack2:
 cmp ds:D3,0
 je MissileTraceBack3
 jg MissileTraceBack3a
 mov ds:D3,0FFFFh
 jmp short MissileTraceBack3

MissileTraceBack3a:
 mov ds:D3,1

MissileTraceBack3:
;keep retreating until we're clear of the wall...

 push cx ;D0
 push dx ;D1

 push di
 mov di,ds:A4
 mov al,cs:Perm_Height[di]
 pop di
 mov byte ptr ds:Check_Height,al
 xor bx,bx                  ;Layout pointer
 call MapCheck

 pop dx ;D1
 pop cx ;D0

 jnz NoMissileTraceBack0    ;are clear of wall

 sub cx,ds:D2               ;move back a little way
 sub dx,ds:D3

 dec ds:Trace_Distance
 cmp ds:Trace_Distance,0
 jge MissileTraceBack3

;couldn't get clear - just leave explosion at point of contact

NoMissileTraceBack0:
;Now advance onto the wall
 mov ax,ds:D2
 shl ax,1
 shl ax,1
 shl ax,1
 mov ds:D2,ax
 mov ax,ds:D3
 shl ax,1
 shl ax,1
 shl ax,1
 mov ds:D3,ax

 add cx,ds:D2
 add dx,ds:D3
 jmp short NoMissileTraceBack1

NoMissileTraceBack:
 xchg ch,cl
 mov ds:Move_Xpos_HiLo[si],cx
 xchg ch,cl
 xchg dh,dl
 mov ds:Move_Xpos_HiLo[si],dx
 xchg dh,dl

NoMissileTraceBack1:
 ret

MissileTrace endp

;-----

TraceBack proc near

 call MissileTrace
 jmp short NoTraceBack1

NoTraceBack:
 xchg ch,cl
 mov ds:Move_Xpos_HiLo[si],cx
 xchg ch,cl
 xchg dh,dl
 mov ds:Move_Xpos_HiLo[si],dx
 xchg dh,dl

NoTraceBack1:
 push di
 mov di,ds:A4
 mov al,cs:Perm_Type[si]
 pop di

 cmp al,22h                 ;* What ???
 je TraceBackStartBigExplosion

 mov ds:D2,0                ;Clear speed
 mov ds:D3,0
 mov ds:D4,3                ;Explosion sprite
 call SetUpNewSprite

 if TraceCode          ;@
 mov cs:debugword,71Bh ;@
 endif ;TraceCode      ;@

 cmp ax,0                   ;Must be CMP to set sign flag
 jl NTBRet
 mov ds:Move_LifeCtr[bx],8  ;Self-destructs after 8 steps
NTBRet:
 ret

;-----

TraceBackStartBigExplosion:
 sub cx,ds:D2               ;Move back a bit
 sub dx,ds:D3
 jmp StartBigExplosion

TraceBack endp

;-----

MoveAllSprites proc near

 if TraceCode          ;@
 mov cs:debugword,71Ch ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

;move the sprites in the moving sprite table
 mov si,offset SpriteTable  ;si remains as the pointer to the sprite table
 mov bx,offset DamsLoopCounter
 mov ds:DamsLoopCounter,MaxMovingSprites+1

Dams1:
 cmp ds:Move_InfoPtr[si],0  ;Entry unused/Sprite number = zero?
 jne ma01
 jmp DamsNextSprite ;JZ

ma01:
 mov ax,ds:A5
 push ax
 push si ;(A6)

 push di                    ;Setup list 20 to point to current Move_Structure
 mov es,cs:CS_Acode
 mov di,offset PCListVector+(20*4) ;table 20

 if TraceCode          ;@
 mov cs:debugword,71Dh ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov ax,si
 stosw ; mov es:[di],ax : add di,2
 mov ax,seg vars
 stosw ; mov es:[di],ax : add di,2

 mov ax,ds:Move_InfoPtr[si] ;Address of Collision Data

 if TraceCode     ;@
 push ax          ;@
 call CheckCD     ;@
 pop ax           ;@
 endif ;TraceCode ;@

 stosw ; mov es:[di],ax : add di,2
 mov ax,seg code           ;Setup list 21 for current CD (collision data)
 stosw ; mov es:[di],ax : add di,2
 pop di

 if TraceCode          ;@
 mov cs:debugword,71Eh ;@
 endif ;TraceCode      ;@

 call Game_DAMSSpecials

 if TraceCode          ;@
 mov cs:debugword,71Fh ;@
 endif ;TraceCode      ;@

 pop si ;(A6)
 pop ax
 mov ds:A5,ax

 mov es,cs:CS_Acode
 mov ax,es:V1
 cmp ax,0                   ;Must be CMP to set sign-flag
 jge ma02
 jmp DAMSNextSprite         ;Signed 'JL'
ma02:
 je DamsSkipSpecials

 mov ax,ds:Move_InfoPtr[si] ;Address of sprite structure
 mov ds:A4,ax
 mov ax,ds:Move_Xspeed_HiLo[si]
 xchg ah,al
 mov ds:D2,ax               ;x speed
 mov ax,ds:Move_Yspeed_HiLo[si]
 xchg ah,al
 mov ds:D3,ax               ;y speed

 if TraceCode          ;@
 mov cs:debugword,720h ;@
 endif ;TraceCode      ;@

 call DamsSpecials          ;SI = control block

 cmp word ptr Move_InfoPtr[si],0
 jne DamsNotDestroyed
 jmp DamsNextSprite

DamsSkipSpecials:
 if TraceCode          ;@
 mov cs:debugword,721h ;@
 endif ;TraceCode      ;@

 mov ax,ds:Move_InfoPtr[si] ;Address of sprite structure
 mov ds:A4,ax
 mov ax,ds:Move_Xspeed_HiLo[si]
 xchg ah,al
 mov ds:D2,ax               ;x speed
 mov ax,ds:Move_Yspeed_HiLo[si]
 xchg ah,al
 mov ds:D3,ax               ;y speed

DamsNotDestroyed:
 if TraceCode          ;@
 mov cs:debugword,722h ;@
 endif ;TraceCode      ;@

 mov cl,byte ptr ds:Move_LifeCtr[si]
 and cl,cl
 jz DamsNotLimited
 dec cl
 mov byte ptr ds:Move_LifeCtr[si],cl
 and cl,cl
 jnz DamsNotLimited
 
;end of life, self destruct
SelfDestruct:
 if TraceCode          ;@
 mov cs:debugword,723h ;@
 endif ;TraceCode      ;@

 mov bx,si
 call DestroySprite

 jmp DamsNextSprite

SelfDestruct2:
 jmp short SelfDestruct

DamsNotLimited:
;calc address of sprite data

 if TraceCode          ;@
 mov cs:debugword,724h ;@
 endif ;TraceCode      ;@

;! cmp cs:CS_ScreenMode,0
;! je dl01                    ;2D?

 mov ax,ds:Move_Animation_HiLo[si] ;add current animation offset
 xchg ah,al
 mov Move_DataPtr[si],ax    ;ax=displayed sprite number

;!dl01:
 if TraceCode          ;@
 mov cs:debugword,725h ;@
 endif ;TraceCode      ;@

;load co-ordinates and move sprite
 mov cx,ds:Move_Xpos_HiLo[si] ;x pos
 mov ds:HiLo_XposSave,cx
 xchg ch,cl
 add cx,ds:D2               ;Move horizontally
 xchg ch,cl
 mov ds:Move_Xpos_HiLo[si],cx
 xchg ch,cl

 mov dx,ds:Move_Ypos_HiLo[si] ;y pos
 mov ds:HiLo_YposSave,dx
 xchg dh,dl
 cmp dx,0                   ;Must be CMP to set sign-flag.
 jl SelfDestruct2           ;prevent missiles wrapping round.
 add dx,ds:D3               ;Move vertically
 xchg dh,dl
 mov ds:Move_Ypos_HiLo[si],dx
 xchg dh,dl

 mov ax,ds:HiLo_ScreenXblocks
 xchg ah,al
 rept CellWidthBits
 add ax,ax
 endm ;rept
 cmp cx,ax                  ;off the map!
 jae dn02 ;(unsigned)

 mov ax,ds:HiLo_ScreenYblocks
 xchg ah,al
 rept CellHeightBits
 add ax,ax
 endm ;rept
 cmp dx,ax                  ;off the map!
 jb dn03
dn02:
 if TraceCode          ;@
 mov cs:debugword,726h ;@
 endif ;TraceCode      ;@

 mov bx,si
 call DestroySprite
 jmp short DamsNextSprite

dn03:
 call CheckForBackgroundCollision

 cmp ds:Move_InfoPtr[si],0
 je DamsNextSprite

 call CheckForSpriteCollision

 cmp ds:Move_InfoPtr[si],0
 je DamsNextSprite

 mov ax,ds:Move_Yspeed_HiLo[si]
 xchg ah,al
 mov ds:D3,ax               ;y speed

;++++ The next instruction is different in ST machine code....
 call SortSpriteChain

 if TraceCode          ;@
 mov cs:debugword,727h ;@
 call CheckChain       ;@
 endif ;TraceCode      ;@

DamsNextSprite:
 if TraceCode          ;@
 mov cs:debugword,728h ;@
 endif ;TraceCode      ;@

 add si,size Move_Structure
 dec ds:DamsLoopCounter
 jz dn04
 jmp Dams1                  ;limit length of loop

;All sprites moved
dn04:
 if TraceCode          ;@
 mov cs:debugword,729h ;@
 endif ;TraceCode      ;@

 ret

MoveAllSprites endp

;-----

SortSpriteChain proc near

 mov ds:SortLimit,0
 push bx
 push si
 push di
 push cx
 push dx

ss01:
 mov si,ds:SpriteTptr
ss02:
 and si,si                  ;No moving sprites (really?)
 jz ss09
 mov ax,ds:Move_NextPtr[si]
 and ax,ax
 jz ss09                    ;Only one sprite control block in chain

;Compare SCBs Y-order
 mov bx,ax
 mov ax,ds:Move_Ypos_HiLo[si] ;si=Nearest to start of chain (spriteTptr)
 xchg ah,al
;bx=Nearest to end of chain
 push bx
 mov bx,ds:Move_Ypos_HiLo[bx]
 xchg bh,bl
 cmp ax,bx
 pop bx

 jle ss07

;Blocks (si),(bx) not sorted, so swap them

;Move ptr from previous SCB/SpriteTpts from si to bx.
 mov di,ds:Move_LastPtr[si]
 and di,di
 jnz ss03
 mov ds:SpriteTptr,bx
 jmp short ss04
ss03:
 mov ds:Move_NextPtr[di],bx
ss04:

;Move ptr from next SCB (if not at end) from bx to si
 mov di,ds:Move_NextPtr[bx]
 and di,di
 jz ss05
 mov ds:Move_LastPtr[di],si
ss05:

;Swap forward-ptrs
 mov ax,ds:Move_NextPtr[bx]
 mov ds:Move_NextPtr[si],ax
 mov ds:Move_NextPtr[bx],si

;Swap backward-ptrs
 mov ax,ds:Move_LastPtr[si]
 mov ds:Move_LastPtr[si],bx
 mov ds:Move_LastPtr[bx],ax
 inc ds:SortLimit
 cmp ds:SortLimit,0
 jne ss06
 call DumpRegisters
 db 0E1h ;generate an 'limit-exceeded'  break point

;Having swapped (si),(bx) this may be because (bx) is
;mis-positioned, so compare (bx) and its new predecessor.

ss06:
 mov ax,ds:Move_LastPtr[bx]
 and ax,ax
 jz ss01                    ;No-predeccsor, so re-check entire chain
 mov si,ax
 jmp short ss02

ss07:
 mov si,bx                  ;Check next two SCBs
 jmp short ss02

ss09:                       ;Chain sorted...
 pop dx
 pop cx
 pop di
 pop si
 pop bx
 ret

SortSpriteChain endp

;-----

StartBigExplosion proc near

 mov bx,offset BigExplosiontable
SBELoop:
 mov ax,ds:[bx]
 add bx,2
 mov ds:D2,ax
 and ax,ax
 jnz SBE1
 mov ax,ds:[bx]
 add bx,2
 mov ds:D3,ax
 and ax,ax
 jnz SBE2
 ret                        ;end of table

SBE1:
 mov ax,ds:[bx]
 add bx,2
 mov ds:D3,ax

SBE2:
 Push_D0_D7
 Push_A0_A7

 mov ds:D4,1                ;ordinary non-explosive missile
 call SetUpNewSprite
 
 if TraceCode          ;@
 mov cs:debugword,72Ah ;@
 endif ;TraceCode      ;@

 cmp ax,0
 jl SBE3                    ;couldn't set up new sprite
 mov ds:Move_LifeCtr[bx],3  ;self-destructs adter 8 steps
SBE3:

 Pop_A0_A7
 Pop_D0_D7
 jmp SBELoop

StartBigExplosion endp

 purge Push_D0_D7           ;speed up assembly
 purge Pop_D0_D7            ;speed up assembly
 purge Push_A0_A7           ;speed up assembly
 purge Pop_A0_A7            ;speed up assembly

;-----

CleverMapCheck proc near

;called from automove
;Make it fast guys...
;check if sprite (SI) can move to (CX,DX) at speed D2,D3
;           is D2 really the X speed here?
;surely it is corrupted by MapCheck

 push di
 mov di,ds:A4
 mov al,cs:Perm_Type[di]
 pop di
 mov byte ptr ds:Sprite2_Type,al
 cmp al,4
 jne MCNoChance             ;not a monster

 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl

;the monster was blocked by a collision with the map.
;if it was trying to go diagonally, try just going in each of the
;orthogonal directions:
 cmp ds:D2,0
 je MCNoChance
 cmp ds:D3,0
 je MCNoChance

 push cx
 push dx

 sub cx,ds:D2               ;remove horizontal move
 push di
 mov di,ds:A4
 mov al,cs:Perm_Height[di]
 pop di
 mov byte ptr ds:Check_Height,al ;height

 xor bx,bx                  ;Map layout pointer
 call MapCheck

 pop dx
 pop cx

 jnz MCVertOk

 push cx
 push dx
 sub dx,ds:D3               ;remove vertical total
 push di
 mov di,ds:A4
 mov al,cs:Perm_Height[di]
 pop di
 mov byte ptr ds:Check_Height,al ;height

 xor bx,bx                  ;Map layout
 call MapCheck

 pop dx
 pop cx
 jnz MCHorizOk

MCNoChance:
 xor ax,ax                  ;Set zero flag
 ret

MCOk:
 mov ax,1
 and ax,ax                  ;Set NZ
 ret

MCHorizOk:
 sub dx,ds:D3               ;no vertical move
 xchg dh,dl
 mov ds:Move_Ypos_HiLo[si],dx
 xchg dh,dl
 mov ax,1
 and ax,ax                  ;Set NZ
 ret

MCVertOk:
 sub cx,ds:D2               ;undo horiz move
 xchg ch,cl
 mov ds:Move_Xpos_HiLo[si],cx
 xchg ch,cl
 mov ax,1
 and ax,ax                  ;Set NZ
 ret

CleverMapCheck endp

;-----

; (int) result = BitCheck ( Sprite1 , Sprite2 )
;         D0                 SI/A4     BX/DI

SpecialCheck proc near

;TruExit, collision has occurred!

 xor cx,cx                  ;set the return register to TRUE
 ret

SpecialCheck endp

;-----

SpecialMapCheck proc near

;we belive there is a collision between the sprite (si)
;and the background at 0(BX+Check_Height) or 2(BX,Check_Height)

 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl
 push di
 mov di,ds:A4
 mov al,cs:Perm_Height[di]
 pop di
 mov byte ptr ds:Check_Height,al ;offset of bottom row of pels
 call MapCheck

;and get address of sprite data...

 mov ds:A3,offset PlayerSprite
;Now A3 = pointer to sprite data.
;We want the transparency mask, which is the fifth word for each
;line of 16 pels.

;Get the co-ordinates.
 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl
 mov ds:D3,0
 push di
 mov di,ds:A4
 xor ah,ah
 mov al,cs:Perm_HeadOverlap[di] ;Player
 pop di
 mov byte ptr ds:D3,al
 add dx,ax
 and cx,CellWidth-1         ;get relative positions
 and dx,CellHeight-1        ;from x and y grid.

 if TraceCode          ;@
 mov cs:debugword,72Bh ;@
 endif ;TraceCode      ;@

;we will do two loops which will check for collisions
;The first loop checks the upper two 16x16 blocks
;The second loop checks the lower two 16x16 blocks

;For each loop, bits set in D3 correspond
;to bits in the sprite which must be transparent (i.e. 1) in
;the sprite transparency mask.

 mov ds:D4,0                ;Start loop at top of sprite
                            ;(but ignore the head overlap)
 push di
 mov di,ds:A4
 mov al,cs:Perm_HeadOverlap[di]
 pop di
 mov byte ptr ds:D4,al

 if TraceCode          ;@
 mov cs:debugword,72Ch ;@
 endif ;TraceCode      ;@

;and work out how many lines there are within the current map
;square. (Note that dx,the y offset within the square, gives the
;start of the area to cd with. The head overlap has already been
;taken off)
 mov ds:D5,CellHeight
 sub ds:D5,dx
 mov ax,ds:D4
 add ds:D5,ax               ;and add on to the starting row.
 mov ds:Quadrant_Height,0   ;check upper two map squares to start with

SMCLoop:
 if TraceCode          ;@
 mov cs:debugword,72Dh ;@
 endif ;TraceCode      ;@

 mov ax,ds:D4
 push ax
 mov ax,ds:D5
 push ax

 if TraceCode          ;@
 mov cs:debugword,72Eh ;@
 endif ;TraceCode      ;@

;For blocks 16-31 inclusive, reduce the height of
;the blocks to allow diagonal fire.
 mov ds:D7,0FFFFh           ;full width block
 push di
 mov di,ds:Quadrant_Height
 mov ax,ds:[di+bx]
 pop di

 if TraceCode          ;@
 mov cs:debugword,72Fh ;@
 endif ;TraceCode      ;@

 cmp ax,010h
 jb SMCReduce1             ;left block isn't reduces height
 cmp ax,020h
 jb SMCReduce2             ;left block IS reduced height
SMCReduce1:
 if TraceCode          ;@
 mov cs:debugword,730h ;@
 endif ;TraceCode      ;@

 push di
 mov di,ds:Quadrant_Height
 cmp word ptr ds:2[di+bx],010h
 pop di
 jb SMCReduce3             ;left block isn't reduced height

 cmp ax,020h               ;(cmp ds:0[di+bx],020h)
 jae SMCReduce3            ;Left block isn't reduced height

SMCReduce2:
 if TraceCode          ;@
 mov cs:debugword,731h ;@
 endif ;TraceCode      ;@

;reduce the height of the block
 mov ds:D7,01FF8h           ;mask - reduce width of block
 sub ds:D5,4                ;reduce the end point
 cmp ds:D5,0
 jl SMCMayBeAnother
 mov ax,ds:D5
 cmp ds:D4,ax
 jge SMCMayBeAnother        ;end point now before start point

SMCReduce3:
 if TraceCode          ;@
 mov cs:debugword,732h ;@
 endif ;TraceCode      ;@

;Have we gone too far?
 push di
 mov di,ds:A4
 mov cl,cs:Perm_Height[di]
 pop di
 cmp byte ptr ds:D5,cl
 jle SMCHeightOk
;Have we gone much too far? - in which case we terminate
 cmp byte ptr ds:D4,cl      ;is the start past the height of the sprite
 jg SMCPopNotOnWall
 mov ds:byte ptr D5,cl      ;limit end counter to height of sprite.

SMCHeightOk:
 push dx
 mov ax,ds:D4
 mov dx,010h
 mul dx ;corrupts dx
 mov ds:D4,ax               ;calculate the byte offset

 mov ax,ds:D5
 mov dx,010h
 mul dx ;corrupts dx
 mov ds:D5,ax
 pop dx

 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 and cx,CellWidth-1
 call CheckSomeLines
 jz SMCCollision            ;got a collision

SMCMayBeAnother:
 if TraceCode          ;@
 mov cs:debugword,734h ;@
 endif ;TraceCode      ;@

 pop ax
 mov ds:D5,ax
 pop ax
 mov ds:D4,ax

 mov ax,ds:HiLo_ScreenXblocks
 add ax,ax                 ;Mapwidth in words
 add ds:Quadrant_Height,ax ;check lower two map squares

 inc ds:D5                 ;increment end pos - it has already been checked.
 mov ax,ds:D5
 mov ds:D4,ax              ;old end pos becomes new start pos
 add ds:D5,CellHeight      ;increase end position for check
 jmp SMCLoop

SMCCollision:
 if TraceCode          ;@
 mov cs:debugword,735h ;@
 endif ;TraceCode      ;@

 pop ax
 mov ds:D5,ax
 pop ax
 mov ds:D4,ax
 jmp OnWall

;-----

SMCPopNotOnWall:
 pop ax
 mov ds:D5,ax
 pop ax
 mov ds:D4,ax
 jmp NotOnWall

SpecialMapCheck endp

;-----

CheckSomeLines proc near

;D4 is the loop counter - giving index
;into the sprite data table.
;D5 is the end of loop value.

;first calculate the bit mask corresponding to
;the top left 16x16 block
 mov ds:D3,0                ;zero mask

 mov es,cs:CS_ViewSegment
;cd with upper left block?
 push di
 mov di,ds:Quadrant_Height
 mov es,cs:CS_ViewSegment
 mov ax,es:0[di+bx]
 xchg ah,al
 cmp ax,MaxWalkableBlock
 pop di
 jb CSL1                    ;Walkable block

 mov ax,ds:D7
 mov ds:D3,ax               ;mask - either full width or reduced width
;introduce CX zeros into the mask. These zeros correspond
;to the amount of the sprite on the RHS that overlaps the
;next map square along.
;CX=D0
 shl ds:D3,cl               ;shift mask along by amout corresponding to X offset
CSL1:

 mov es,cs:CS_ViewSegment
;cd with upper right block?
 push di
 mov di,ds:Quadrant_Height
 mov ax,es:2[di+bx]
 xchg ah,al
 cmp ax,MaxWalkableBlock
 pop di
 jb CSL2                    ;walkable block

;introduce CX 1s into the mask. These 1's correspond
;to the amount of the sprite on the RHS that overlaps the next
;map square along.

;D7 is already the unshifted mask for the block - either 0FF0 or FFFF

;CX=D0
 push cx                    ;Preserve, used for loop count (number of bits to shift)
 push bx
 xor ch,ch
 mov bx,ds:D7
 xor ax,ax                  ;New mask to create (originally high word of D7)
CLS1a:
 jcxz CLS1b
 rcl bx,1                   ;Shift top bit to carry
 rcl ax,1                   ;And save bit to new mask
 dec cx
 jmp short CLS1a

CLS1b:
 pop bx
 pop cx

 or ds:D3,ax                ;and bring back the ones into the main mask

CSL2:
;Now D3 is the mask.
;Let's check the data!
;Go between 0[A3,D4] and 0[A3,D5]

CSLLoop:
 push di
 push bx
 mov di,ds:A3
 mov bx,ds:D4
 mov ax,ds:0[di+bx]
 pop bx
 pop di
 not ax
 and ax,ds:D3               ;mask out irrelevant bits
 jnz SMCOnWall
 add ds:D4,10h
 mov ax,ds:D5
 cmp ds:D4,ax
 jle CSLLoop
 jmp NotOnWall

SMCOnWall:
 jmp OnWall

CheckSomeLines endp

;-----

CheckPlayerMove proc near

;see if player can move by offset X=ds:D4 Y=ds:Speed_Y
;and make any move possible

 mov ds:Speed_X,cx          ;destination X
 mov ds:Speed_Y,dx          ;destination Y
 call cpm
 mov cx,ds:Speed_X
 mov dx,ds:Speed_Y
 ret

cpm:
 mov si,offset SpriteTable
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 add si,ax                  ;si=Player Sprite

;Quicker than: mov ds:A4,ds:Move_InfoPtr[si]
 mov ds:A4,offset SpriteDataStructure

 push bx
 mov bh,0
 mov bl,ds:B_JoyStickStatus
 and bl,0Fh
 jz NoViewChange            ;No joystick

 mov al,byte ptr cs:ViewConversion[bx]
 mov Move_View[si],al

NoViewChange:
 pop bx
 
 mov ds:Move_Xspeed_HiLo[si],0
 mov ds:Move_Yspeed_HiLo[si],0
 mov cx,ds:Move_Xpos_HiLo[si]
 xchg ch,cl
 add cx,ds:Speed_X          ;destination X pos
 mov dx,ds:Move_Ypos_HiLo[si]
 xchg dh,dl
 add dx,ds:Speed_Y          ;destination Y pos

 mov al,cs:SpriteDataStructure.Perm_Height
 mov byte ptr ds:Check_Height,al

;Check top left:
 call MapCheck

 jz cp01                    ;covering background
 ret                        ;Make move. Return ds:Speed_X = Xspeed
                            ;and ds:Speed_Y = Yspeed.

;not possible - was player trying to go diagonally?
cp01:
 cmp ds:Speed_X,0           ;Xspeed
 jne cp02
 jmp MayBeCushionVertically
cp02:

 cmp ds:Speed_Y,0           ;Yspeed
 jne cp03
 jmp short MayBeCushionHorizontally

;diagonal - so is movement possible in one
;of the orthogonal directions? X only?

cp03:
 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,736h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov cx,Move_Xpos_HiLo[si]
 xchg ch,cl
 add cx,ds:Speed_X
 mov dx,Move_Ypos_HiLo[si]
 xchg dh,dl
 pop si

 mov al,cs:SpriteDataStructure.Perm_Height
 mov byte ptr ds:Check_Height,al

;Check top right:
 call MapCheck

 jz CPMNotHorizontal        ;covering background
 mov ds:Speed_Y,0

;Make move. Return ds:Speed_X = Xspeed.
 ret

CPMNotHorizontal:
;y only
 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,737h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov cx,Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,Move_Ypos_HiLo[si]
 xchg dh,dl
 pop si
 add dx,ds:Speed_Y

 mov al,cs:SpriteDataStructure.Perm_Height
 mov byte ptr ds:Check_Height,al

;Check bottom left:
 call MapCheck

 jz CPMNotVertical          ;covering background
 mov ds:Speed_X,0

;Make move. Return ds:Speed_Y = Yspeed.
 ret

CPMNotVertical:
CPMCantMove:
 mov ds:Speed_X,0
 mov ds:Speed_Y,0
 ret

MayBeCushionHorizontally:
;trying to move horizontally - try cushioning
 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,738h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov cx,Move_Xpos_HiLo[si]
 xchg ch,cl
 add cx,ds:Speed_X
 mov dx,Move_Ypos_HiLo[si]
 xchg dh,dl
 pop si
 add dx,20-CellHeight       ;because player sprite is 20 high
 and dx,CellHeight-1
 cmp dx,10
 jg NoCushionUp

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,739h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov dx,Move_Ypos_HiLo[si]
 xchg dh,dl
 pop si
 sub dx,4                   ;move up one step

 push dx ;D1

 mov al,cs:SpriteDataStructure.Perm_Height
 mov byte ptr ds:Check_Height,al

;Check bottom right:
 call MapCheck

 pop dx ;D1

 and cx,cx
 jz CPMCantMove             ;covering background

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,73Ah ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 xchg dh,dl
 mov Move_Ypos_HiLo[si],dx
 xchg dh,dl
 pop si
 jmp CPMCantMove

NoCushionUp:
 cmp dx,12
 jl NoCushionDown

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,73Bh ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov dx,Move_Ypos_HiLo[si]
 xchg dh,dl
 pop si
 add dx,4

 push dx

 mov al,cs:SpriteDataStructure.Perm_Height
 mov byte ptr ds:Check_Height,al

 call MapCheck

 pop dx

 and cx,cx
 jnz cp04
 jmp CPMCantMove            ;covering background

cp04:
 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,73Ch ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov dx,Move_Ypos_HiLo[si]
 xchg dh,dl
 pop si

NoCushionDown:
 jmp CPMCantMove           ;can't move as requested - give up

MayBeCushionVertically:
;trying to move vertically - try cushioning

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,73Dh ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov cx,Move_Xpos_HiLo[si]
 xchg ch,cl
 mov dx,Move_Ypos_HiLo[si]
 xchg dh,dl
 pop si
 add dx,ds:Speed_Y

 and cx,CellWidth-1
 cmp cx,6
 jg NoCushionLeft

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,73Eh ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov cx,Move_Xpos_HiLo[si]
 xchg ch,cl
 pop si
 and cx,-CellWidth

 push cx

 mov al,cs:SpriteDataStructure.Perm_Height
 mov byte ptr ds:Check_Height,al

 call MapCheck

 pop ax                     ;Actually x co-ordinate
 mov ds:D3,ax

 and cx,cx
 jz NoCushionDown           ;CPMCantMove

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,73Fh ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov ax,ds:D3
 xchg ah,al
 mov Move_Xpos_HiLo[si],ax
 pop si
 jmp CPMCantMove

NoCushionLeft:
 cmp cx,12
 jl NoCushionRight

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,740h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov cx,Move_Xpos_HiLo[si]
 xchg ch,cl
 pop si

 and cx,-CellWidth
 add cx,CellWidth

 push cx ;D0

 mov al,cs:SpriteDataStructure.Perm_Height
 mov byte ptr ds:Check_Height,al

 call MapCheck

 pop ax                     ;Actually X coord
 mov ds:D3,ax

 and cx,cx
 jz NoCushionRight          ;CPMCantMove

 push si
 mov ax,ds:HiLo_PlayerSprite
 xchg ah,al
 mov si,ax
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,741h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 mov ax,ds:D3
 xchg ah,al
 mov Move_Xpos_HiLo[si],ax
 pop si

NoCushionRight:
 jmp CPMCantMove            ;can't move as requested - give up

CPMMakeMove:
;make move (surprise surprise)
;Return D4=xspeed and d5=yspeed
 ret

CheckPlayerMove endp

ViewConversion:
 db 0,0,4,0,6,7,5,0,2,1,3,0,0,0,0,0

;-----

;A routine which will determine whether a 16x16 sprite is
;occupying a part of the map which is defined to be a wall.
;If it is TRUE will be returned, otherwise FALSE.
;
;    (int) return = MapCheck( Xpos , Ypos , Height-1 , Map );
;           TempX            TempX  TempY     BX       A0
;
;Return value TRUE is on a wall pettern, FALSE if not.
;Returns (di) 2(di) 100(di) and 102(A0) as the relevant
;entires in the map layout

MapCheck proc near

 mov ds:D5,0
 push di
 mov di,ds:A4
 xor ah,ah
 mov al,cs:Perm_HeadOverlap[di]
 mov ds:D5,ax
 pop di

 mov ax,ds:D5
 add dx,ax                  ;Increase Y pos to allow for overlap
 sub ds:Check_Height,ax     ;Reduce height by same

 mov ds:D5,dx               ;Copy Y pos into D5
 and dx,CellHeight-1        ;Get RelYpos
 add dx,ds:Check_Height     ;Add the height to Rel Y pos

 rept CellWidthBits
 shr ds:D5,1                ;Divide Y pos by CellHeight
 endm ;rept

 mov ax,HiLo_ScreenXblocks
 xchg ah,al
 add ax,ax                  ;MapWidth in words
 mov ds:Check_Height,ax

 push dx
 mov ax,HiLo_ScreenXblocks
 xchg ah,al
 add ax,ax                  ;MapWidth in words

 mov dx,ds:D5
 mul dx ;corrupts dx
 mov ds:D5,ax               ;Get the Y displacement
 pop dx

 mov bx,ds:D5               ;Get the Y displacement

 mov ds:D5,cx               ;Copy X pos to D5

 and cx,15                  ;Get RelXpos

 rept CellWidthBits-1
 shr ds:D5,1
 endm ;rept

;But *2 because map entries map entries are word sized
 and ds:D5,0FFFEh
 add bx,ds:D5               ;Add X pos to Map Pointer

;The actual test
MapCheckA0D5:
;Check (a0) 2(a0) 0(a0,Check_Height) 2(a0,Check_Height) 
;for blocks less than ds:D5

 mov es,cs:CS_ViewSegment
 mov ax,es:0[bx]
 xchg ah,al
 cmp ax,MaxWalkableBlock
 jae OnWallClearHeight

 and cx,cx                  ;Is Rel X pos = 0 ?
 jz L1

;Sprite spills over into next 16x16 along - so check for collision with
;that.

 mov ax,es:2[bx]
 xchg ah,al
 cmp ax,MaxWalkableBlock
 jae OnWallClearHeight

L1:
 cmp dx,16                  ;Does the sprite extend down onto the next row of
 jl NotOnWall               ;blocks.  No - so no collision

;(ds:Check_Height here is twice MapWidth)
 push di
 mov di,ds:Check_Height
 mov ax,es:[bx+di]
 xchg ah,al
 cmp ax,MaxWalkableBlock
 pop di
 jae OnWall
 and cx,cx                  ;Is Rel X pos = 0 ?
 jz NotOnWall               ; Yes - Branch

 push di
 mov di,ds:Check_Height
 mov ax,es:2[bx+di]
 xchg ah,al
 cmp ax,MaxWalkableBlock
 pop di
 jb NotOnWall
 jmp short OnWall

OnWallClearHeight:
 mov ds:Check_Height,0

OnWall:
 xor cx,cx
 and cx,cx                  ;Set return to false
 ret
 
NotOnWall:
 mov cx,1
 and cx,cx                  ;Set return to true
 ret

MapCheck endp

   ENDIF ;TwoD

;...e

;-----

;...sAcode Subroutines:

MCFindSprite proc near

   IF TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov es,cs:CS_Acode
;Return the next sprite in the sprite block having name V1
;Start search from offset V2, and return V2 as new offset
;only used by Acode.
 mov ax,es:V1
 xchg ah,al                 ;Convert to Hi-Lo
 mov si,es:V2
 add si,offset SpriteTable

 if TraceCode          ;@
 mov cs:debugword,700h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

MCFS1:
 cmp ds:Move_Name_HiLo[si],ax
 je MCFSFound
 mov si,ds:Move_NextPtr[si]
 and si,si
 jnz MCFS1

;Not Found
 mov word ptr es:V2,-1      ;Error code
 jmp MCReturn

MCFSFound:
 if TraceCode          ;@
 mov cs:debugword,701h ;@
 call CheckSTaddress   ;@
 endif ;TraceCode      ;@

 sub si,offset SpriteTable
 mov es:V2,si

   ENDIF ;TwoD

 jmp MCReturn

MCFindSprite endp

;-----

MCSetUpNewSprite proc near

   IF TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,ds:A3
 push ax
 mov ax,ds:A4
 push ax
 mov ax,ds:A5
 push ax
 push si

 mov es,cs:CS_Acode
;V1 - D0 - X pos
;V2 - D1 - Y pos
;V3 - D2 - X speed
;V4 - D3 - Y speed
;V5 - D4 - Sprite Name/Number

 mov cx,es:V1               ;X pos
 mov dx,es:V2               ;Y pos
 mov ax,es:V3
 mov ds:D2,ax               ;X speed
 mov ax,es:V4
 mov ds:D3,ax               ;Y speed
 mov ax,es:V5
 mov ds:D4,ax               ;Sprite number

 call SetUpNewSprite
 mov ds:D7,ax               ;Return code

 if TraceCode          ;@
 mov cs:debugword,702h ;@
 endif ;TraceCode      ;@

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 pop si
 pop ax
 mov ds:A5,ax
 pop ax
 mov ds:A4,ax
 pop ax
 mov ds:A3,ax

 if TraceCode          ;@
 push si               ;@
 mov si,bx             ;@
 call CheckSTaddress   ;@
 mov cs:debugword,703h ;@
 pop si                ;@
 endif ;TraceCode      ;@

 mov es,cs:CS_Acode
 sub bx,offset SpriteTable
 mov es:V6,bx               ;Return offset to start of spritetable
 mov ax,ds:D7
 mov es:V7,ax               ;Return negative in V7 if couldn't set up sprite

   ENDIF ;TwoD

 jmp MCReturn

MCSetUpNewSprite endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 17
;-------------------------------------

MCDestroyList20 proc near

   IF TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,ds:A5
 push ax

 mov es,cs:CS_Acode
 mov di,offset PCListVector+(20*4) ;table 20
 mov bx,es:[di]

 if TraceCode          ;@
 mov cs:debugword,70Ch ;@
 call DestroySprite    ;@
 endif ;TraceCode      ;@

 pop ax
 mov ds:A5,ax

   ENDIF ;TwoD

 jmp MCReturn

MCDestroyList20 endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 18
;-------------------------------------

MCDestroyList22 proc near

   IF TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,ds:A5
 push ax

 mov es,cs:CS_Acode
 mov di,offset PCListVector+(22*4) ;table 22
 mov bx,es:[di]

 if TraceCode          ;@
 mov cs:debugword,70Dh ;@
 endif ;TraceCode      ;@

 call DestroySprite

 pop ax
 mov ds:A5,ax

   ENDIF ;TwoD

 jmp MCReturn

MCDestroyList22 endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 30
;-------------------------------------

MCStartBigExplosion proc near

   IF TwoD
   
 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov es,cs:CS_Acode
 mov cx,es:V1 ;Xpos
 mov dx,es:V2 ;Ypos
 
 call StartBigExplosion

   ENDIF ;TwoD

 jmp MCReturn

MCStartBigExplosion endp

;-------------------------------------
;Call only from compiled-machine code.
;Subroutine number 29
;-------------------------------------

MCSpecialCheck proc near

   IF TwoD

 mov ax,seg vars
 mov ds,ax
 assume ds:vars

 mov ax,ds:A3
 push ax
 mov ax,ds:A4
 push ax
 mov ax,ds:A5
 push ax
 push si

 mov es,cs:CS_Acode
 mov si,offset PCListVector+(20*4) ;table 20
 mov bx,es:[si]             ;bx=A0 Sprite 1/moving sprite
 mov di,ds:Move_InfoPtr[bx] ;di=A1 data ptr

 mov si,offset PCListVector+(22*4) ;table 22
 mov si,es:[si]             ;si=A6 Sprite 2/fixed sprite
 mov ax,ds:Move_InfoPtr[si] ;A4 data ptr
 mov ds:A4,ax

 call SpecialCheck

 pop si
 pop ax
 mov ds:A5,ax
 pop ax
 mov ds:A4,ax
 pop ax
 mov ds:A3,ax

 mov es,cs:CS_Acode
 mov es:V1,cx

   ENDIF ;TwoD

 jmp MCReturn

MCSpecialCheck endp

;...e

code ends

;-----

;...sVariables:0:

   IF TwoD

vars segment word public 'data'

 even
TempX dw 0                  ;destination X/Y after move
TempY dw 0

DamsLoopCounter dw 0

SpriteTptr dw 0

TempNameStorage dw 0

Speed_X dw 0
Speed_Y dw 0

;Were D6 is ST version...
Check_Height dw 0
Quadrant_Height dw 0
Sprite2_Type dw 0
Trace_Distance dw 0

;A1 = di
A2 dw 0
A3 dw 0
A4 dw 0
A5 dw 0
D2 dw 0
D3 dw 0
D4 dw 0
D5 dw 0
D7 dw 0

SpriteDataPtr dw 0

SortLimit db 0

vars ends

 ENDIF ;TwoD

;...e

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
