;IBM ANIMATED ADVENTURES

;STRUCTUR.ASM
 
;Copyright (C) 1988 Level 9 Computing

;-----

;...sInclude files:0:
;These include files must be named in MAKE.TXT:
 include consts.asm

;...e

;...sPublics and externals:0:
public ObjectHandler
public SetupPointers
public SetProtectMark
public NewFindObject
public RangeError

extrn PlotSprite:near
extrn InsertCell:near
extrn InsertRedrawCell:near
extrn RemoveRedrawCell:near
extrn PreloadMark:near
extrn PurgeObject:near

extrn CellTable:word
extrn StructureSegment:word

extrn CellBeginning:word
extrn NumberofCells:word
extrn ErrorStackPointer:word

;...sCGA\47\HERC \45\ extrn PaletteNumber\58\byte:0:
if CGA+HERC
extrn PaletteNumber:byte
endif
;...e

extrn GetKey:near
extrn ReportError:near

;...sSCROLL \45\ extrn ScrollingMode\58\word:0:
if SCROLL

 extrn ScrollingMode:word

endif
;...e

;...sif debugging:0:
if debugging
 extrn PrintDebugLine:near

if StructureNumbers
 extrn PrintDebugWordX:near
endif

endif
;...e

;...e

;-----

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
;******** constants

 NumberStackEntries = 12

 StackLump	= 12

 LastLastReflection = StackLump*2 +0

 LastEndAddress	= StackLump + 10
 LastAddress	= StackLump + 8
 LastHpos	= StackLump + 6
 LastZpos	= StackLump + 4
 LastXpos	= StackLump + 2
 LastReflection	= StackLump + 0

 ThisEndAddress	= 10
 ThisAddress	= 8
 ThisHpos	= 6
 ThisZpos	= 4
 ThisXpos	= 2
 ThisReflection	= 0


;...e

;** Structure Setup
;...sSetupPointers:0:
;*************************************************************************
;*************************************************************************
;********  Structure file setting up

;es - Structure segment

;...sif debugging:0:
if debugging
SetupPointersText db 'Setup Pointers',0dh,0ah,0
endif
;...e

SetupPointers:
 mov bp,cs
 mov ds,bp
 mov StructureSegment,es

;...sif debugging:0:
if debugging
 mov bx,offset SetupPointersText
 call PrintDebugLine
endif
;...e

 mov si,2

 lods word ptr es:[si]	;es:[2]		;XZH address
 xchg ah,al
 mov XZHAddress,ax

 lods word ptr es:[si]	;es:[4]		;XZH object
 xchg ah,al
 mov XZHBeginning,ax
 add si,2

 lods word ptr es:[si]	;es:[8]		;Raster address
 xchg ah,al
 mov RastersAddress,ax

 lods word ptr es:[si]	;es:[10]	;Raster object
 xchg ah,al
 mov RastersBeginning,ax
 add si,2

 lods word ptr es:[si]	;es:[14]	;Animated address
 xchg ah,al
 mov AnimatedAddress,ax

 lods word ptr es:[si]	;es:[16]	;Animated object
 xchg ah,al
 mov AnimatedBeginning,ax
 add si,2

 lods word ptr es:[si]	;es:[20]	;Compressed address
 xchg ah,al
 mov CompressedAddress,ax

 lods word ptr es:[si]	;es:[22]	;Compressed object
 xchg ah,al
 mov CompressedBeginning,ax
 add si,4

 lods word ptr es:[si]	;es:[28]	;Cell object
 xchg ah,al
 mov CellBeginning,ax

 ret

;...e

;** Structure Handler
;...sObjectHandler:0:
;*************************************************************************
;*************************************************************************
;********  ObjectHandler

; ax - object x coord
; bx - object z coord
; cx - object h coord
; dx - object number
; bp - raster object offset
; si - drawflag		-1 - remove redraw object
;			 0 - insert into linked list
;			 1 - plot object as sprite
;			 2 - insert redraw object
;			 3 - mark to preload
;			 4 - SetProtectMark
;			 5 - UnsetProtectMark
;			 6 - PurgeObject
; di - reflectflag	 0 - normal
; 		    08XXXh - reflected
;		      XXXb - palette number (CGA/HERC)
; 
; all registers used

;...sif debugging:0:
if debugging
 ObjectHandlerText	db 'Object Handler - ',0
 RemoveRedrawText	db 'Remove & Redraw',0Dh,0Ah,0
 InsertObjectText	db 'Insert Object',0Dh,0Ah,0
 PlotSpriteText		db 'Plot Sprite',0Dh,0Ah,0
 InsertRedrawText	db 'Insert & Redraw',0Dh,0Ah,0
 PreloadMarkText	db 'Preload Mark',0Dh,0Ah,0
 SetProtectMarkText	db 'Set Protect Mark',0Dh,0Ah,0
 UnsetProtectMarkText	db 'Unset Protect Mark',0Dh,0Ah,0
 PurgeObjectText	db 'Purge Object',0Dh,0Ah,0
 NoOperationText	db 'No Operation',0Dh,0Ah,0

if StructureNumbers
 ObjText		db 0Dh,0Ah,0
endif

endif
;...e

ObjectHandler:

;...sif debugging:0:
if debugging
 push ax
 push bx
 push cx
 push dx
 push bp
 push si
 push di

 mov ax,cs
 mov ds,ax
 
 push si
 mov bx,offset ObjectHandlerText
 call PrintDebugLine
 pop si

 mov bx,offset RemoveRedrawText
 cmp si,-1
 je  overdebug
 mov bx,offset InsertObjectText
 cmp si,0
 je  overdebug
 mov bx,offset PlotSpriteText
 cmp si,1
 je  overdebug
 mov bx,offset InsertRedrawText
 cmp si,2
 je  overdebug
 mov bx,offset PreloadMarkText
 cmp si,3
 je  overdebug
 mov bx,offset SetProtectMarkText
 cmp si,4
 je  overdebug
 mov bx,offset UnsetProtectMarkText
 cmp si,5
 je  overdebug
 mov bx,offset PurgeObjectText
 cmp si,6
 je  overdebug
 mov bx,offset NoOperationText

overdebug:
 call PrintDebugline

if StructureNumbers
 mov bp,sp
 mov ax,[bp+12]
 call PrintDebugWordX
 mov ax,[bp+10]
 call PrintDebugWordX
 mov ax,[bp+8]
 call PrintDebugWordX
 mov ax,[bp+6]
 call PrintDebugWordX
 mov ax,[bp+4]
 call PrintDebugWordX
 mov ax,[bp+2]
 call PrintDebugWordX
 mov ax,[bp+0]
 call PrintDebugWordX
 mov bx,offset ObjText
 call PrintDebugLine
endif

 pop di
 pop si
 pop bp
 pop dx
 pop cx
 pop bx
 pop ax
endif
;...e

StructureUnlock:
 cli				;disable interrupts
 cmp byte ptr cs:StructureLock,0
 je  StructureUnLocked
 sti				;enable interrupts
 jmp short StructureUnlock

StructureUnlocked:
 mov byte ptr cs:StructureLock,1
 sti				;enable interrupts

 mov cs:RasterOffset,bp
 mov bp,cs
 mov ds,bp

;...sSCROLL \45\ Coordinate Adjustment:0:
if SCROLL

 cmp ScrollingMode,1
 je  DontAdjustCoordinates

 add ax,16
 sub cx,16

DontAdjustCoordinates:

endif
;...e

 mov XPos,ax			;store input parameters
 mov ZPos,bx
 mov HPos,cx

;...sCGA\47\HERC \45\ Extract Palette Number:0:
if CGA+HERC

 mov ax,di
 and al,03h
 mov cs:PaletteNumber,al

endif
;...e

 and di,08000h			;reflection bit only
 xor dx,di			;modify reflect bit in object

 xor ax,ax
 mov Reflection2,ax		;zero last reflection
 mov Address,ax			;zero address

 inc si				;setup jump table offset
 shl si,1
 cmp si,14			;catch for out of range operation
 ja  BadOperation

 add si,offset OperationList
 mov ax,[si]
 mov Operation,ax


;** setup stack

 mov es,StructureSegment
 mov di,offset StackEnd
 mov ax,dx			;move object into ax

 jmp XZHhandler4

;** Error Return

BadOperation:
 mov byte ptr cs:StructureLock,0

 mov ax,0107h
 call ReportError

 ret

;...e
;...sXZHhandler:0:
;************************************************************************
;************************************************************************
;********  XZH object handler
;si - address of object
;di - stack position
;ds - stack segment for objects
;es - structures segment

XZHStackOverflow:
 mov ax,0108h
 call ReportError
 jmp XZHHandler7


;********  First entry into xzh object

XZHhandler:
 sub di,StackLump		;push stack downwards
 cmp di,offset StackStart
 jb  XZHStackOverflow

 mov ax,es:[si]			;load offset to next object
 xchg ah,al
 add ax,si			;add current address to offset
 dec ax				;decrement for padding byte
 mov [di+ThisEndAddress],ax	;write end address-1 on stack

 xor cx,cx
 mov cl,es:[si+2]		;load x size of this xzh object
 shl cx,1
 shl cx,1
 shl cx,1
 shl cx,1			;width of object in pixels

 add si,4			;jump over offset and size

 cmp si,ax			;check that object is not empty
 jae XZHhandler7		;if empty go back up stack

;********  Alter x coordinate if necessary

 test [di+LastReflection],08000h
 jz  XZHhandler1

 add [di+LastXpos],cx		;add its width - if reflected

XZHhandler1:
 test [di+LastLastReflection],08000h
 jz XZHhandler2

 sub [di+LastXpos],cx		;subtract its width - if reflected before

;********  First and subsequent entries into xzh object

XZHhandler2:
 lods byte ptr es:[si]		;loads new x offset
 cbw
 shl ax,1
 shl ax,1
 mov bx,[di+LastXpos]		;load last xpos

 test [di+LastReflection],08000h
 jnz XZHhandler3

 add bx,ax
 add bx,ax

XZHhandler3:
 sub bx,ax
 mov [di+ThisXpos],bx		;saves new xpos

 lods byte ptr es:[si]		;loads new z offset
 cbw
 shl ax,1
 shl ax,1
 add ax,[di+LastZpos]		;adds last zpos
 mov [di+ThisZpos],ax		;saves new zpos
 
 lods byte ptr es:[si]		;loads new h offset
 cbw
 shl ax,1
 shl ax,1
 add ax,[di+LastHpos]		;adds last hpos
 mov [di+ThisHpos],ax		;saves new hpos

 lods word ptr es:[si]		;loads object number
 xchg ah,al			;catch null object
 xor ax,[di+LastReflection]	;reflects it if necessary

 mov [di+ThisAddress],si	;write this address on stack

;********  Initial entry into system

XZHhandler4:
 mov bp,ax
 and bp,7fffh			;erase top bit for seeking
 jz  XZHhandler6		;jump if null

 and ax,08000h
 mov [di+ThisReflection],ax

;********  Find object and deal with it

 call findobject

;********  Return from object

XZHhandler5:
 mov si,[di+ThisAddress]	;get the address in last object

XZHhandler6:
 or  si,si			;check if any return address
 jz  XZHhandler8
 cmp si,[di+ThisEndAddress]	;compare to see if finished this level
 jb  XZHhandler2		;if not  - process next xzh object in list 

XZHhandler7:
 add di,StackLump		;go back up stack
 cmp di,offset StackEnd
 jne XZHhandler5

XZHhandler8:
 mov byte ptr cs:StructureLock,0
 ret				;leave - all finished

;...e
;...sFindObject:0:
;************************************************************************
;************************************************************************
;********  Find Object in structs file
; bp - object number
; es - structures segment

FindObject:
 mov ax,CellBeginning	;check if cell
 cmp bp,ax
 jb FindObject1
 sub bp,ax		;gives cell number
 jmp ProcessCell

FindObject1:
 mov cx,bp
 xor bx,bx
 mov ax,XZHBeginning	;check if XZH object
 cmp cx,ax
 ja  FindObject2

 mov si,XZHAddress	;get address
 jmp short FindObject6

FindObject2:
 inc bx
 mov dx,RastersBeginning	;check if raster object
 cmp cx,dx
 ja  FindObject3
 sub cx,ax		;adjust object number
 add cx,RasterOffset

 mov si,RastersAddress	;get address
 jmp short FindObject6

FindObject3:
 inc bx
 mov ax,AnimatedBeginning	;check if animation object
 cmp cx,ax
 ja  FindObject4
 sub cx,dx		;adjust object number

 mov si,AnimatedAddress		;get address
 jmp short FindObject6

FindObject4:
 inc bx			;must be a compressed image
 sub cx,ax		;adjust object number

 mov si,CompressedBeginning	;get address
 jmp short FindObject6

FindObject5:
 mov ax,es:[si]		;load offset
 xchg ah,al
 add si,ax		;add offset to current position

FindObject6:
 loop FindObject5

; object found
; si - address of object's data
; bx - object type 0 - xzh, 1 - raster, 2 - animation, 3 - compressed

 or bx,bx
 jne FindObject7
 pop ax			;dump return address
 jmp XZHhandler

FindObject7:
 cmp bx,2
 je  FindObject8
 ja  FindObject9
 jmp ProcessRaster

FindObject8:
 jmp FoundAnimation

FindObject9:
 jmp FoundCompressed

FoundAnimation:
FoundCompressed:
 ret

;...e
;...sProcessRaster:0:
;************************************************************************
;************************************************************************
;********  Process a raster block
; si - raster address
; di - stack address

ProcessRaster:
 xor cx,cx
 mov cl,es:[si+2]		;load x size in cells
 shl cx,1
 shl cx,1
 shl cx,1
 shl cx,1			;pixel width of raster

 test [di+LastReflection],08000h
 jz  ProcessRaster1

 sub [di+ThisXpos],cx		;move reference to left side of object

ProcessRaster1:
 test [di+ThisReflection],08000h
 jnz ProcessRaster2

 xor ax,ax			;going right - non reversed
 mov RasterStart,ax
 mov RasterEnd,cx
 mov RasterCount,ax
 mov word ptr RasterDirection,16

 jmp short ProcessRaster3

ProcessRaster2:
 mov ax,-16			;going left - reversed
 add cx,ax			;add width
 mov RasterStart,cx
 mov RasterEnd,ax
 mov RasterCount,cx
 mov RasterDirection,ax

ProcessRaster3:
 mov ax,es:[si]			;load offset to next object
 xchg ah,al
 add ax,si			;add address to offset

 add si,4			;jump over four bytes

 cmp si,ax			;check that object is empty
 je  ProcessRaster7		;if empty go back up stack

 mov RasterEndAddress,ax	;write end address on stack

ProcessRaster4:
 lods word ptr es:[si]		;loads new object number
 xchg ah,al
 mov RasterAddress,si		;save raster address

 mov dx,ax			;object number			
 and dx,07FFFh			;erase top bit
 jz  ProcessRaster5		;check to see if object zero

 and ax,08000h
 xor ax,[di+ThisReflection]	;overall reflection status

 sub dx,CellBeginning		;cell offset subtracted
 jz  ProcessRaster5		;check to see if cell zero

 or  dx,ax			;add reflection bit back

 mov ax,[di+ThisXpos]
 add ax,RasterCount
 mov bx,[di+ThisZpos]
 mov cx,[di+ThisHpos]

 push di

 call word ptr operation

 pop di

 mov ax,cs
 mov ds,ax
 mov es,StructureSegment

 mov si,RasterAddress

ProcessRaster5:
 cmp RasterEndAddress,si
 je  ProcessRaster7

 mov ax,RasterCount
 add ax,RasterDirection
 cmp ax,RasterEnd
 jne ProcessRaster6

 sub word ptr [di+ThisHpos],16
 mov ax,RasterStart

ProcessRaster6:
 mov RasterCount,ax
 jmp ProcessRaster4

ProcessRaster7:
 ret

;...e
;...sProcessCell:0:
;**********************************************************************
;**********************************************************************
;********  ProcessCell
; bp - cell number (range 0 upwards)

ProcessCell:
 push di
 mov ax,[di+ThisXpos]
 test [di+LastReflection],08000h
 jz  ProcessCell1
 sub ax,16			;move reference to left side of object

ProcessCell1:
 mov bx,[di+ThisZpos]
 mov cx,[di+ThisHpos]
 mov dx,bp
 or  dx,[di+ThisReflection]
 
 and bp,07FFFh
 jz  ProcessCell2		;catch cell zero
 
 call word ptr operation
 
ProcessCell2:
 pop di
 mov ax,cs
 mov ds,ax
 mov es,StructureSegment

 ret

;...e

;** NewFindObject
;...sNewFindObject:0:
;************************************************************************
;************************************************************************
;********  Find Object in structs file and return address
; ax - object number
; bx - address (returned)

NewFindObject:
 mov cx,cs
 mov ds,cx
 mov cx,ax

 mov ax,CellBeginning	;check if cell
 cmp cx,ax
 jb NewFindObject1
 xor bx,bx		;invalid number
 ret

NewFindObject1:
 mov ax,XZHBeginning	;check if XZH object
 cmp cx,ax
 ja  NewFindObject2

 mov bx,XZHAddress	;get address
 jmp short NewFindObject5

NewFindObject2:
 mov dx,RastersBeginning	;check if raster object
 cmp cx,dx
 ja  NewFindObject3
 sub cx,ax		;adjust object number
 add cx,RasterOffset

 mov bx,RastersAddress	;get address
 jmp short NewFindObject5

NewFindObject3:
 mov ax,AnimatedBeginning	;check if animation object
 cmp cx,ax
 ja  NewFindObject4
 sub cx,dx		;adjust object number

 mov bx,AnimatedAddress		;get address
 jmp short NewFindObject5

NewFindObject4:
 sub cx,ax		;adjust object number

 mov bx,CompressedBeginning	;get address

NewFindObject5:
 mov ds,StructureSegment
 jmp short NewFindObject7

NewFindObject6:
 mov ax,ds:[bx]		;load offset
 xchg ah,al
 add bx,ax		;add offset to current position

NewFindObject7:
 loop NewFindObject6

 ret

;...e

;** Protection Setting
;...sSetProtectMark:0:
;*************************************************************************
;*************************************************************************
;********  Set Protect Mark
;dx - cell number

SetProtectMark:
 mov bp,cs
 mov ds,bp

 and dx,07FFFh		;remove reversal bit

 mov ErrorStackpointer,sp

 cmp dx,NumberofCells
 jae RangeError

 mov es,CellTable
 mov di,dx		;cell number * 4
 shl di,1
 shl di,1

 or es:[di+2],08000h

 ret

;...e
;...sUnsetProtectMark:0:
;*************************************************************************
;*************************************************************************
;********  Unset Protect Mark
;dx - cell number

UnsetProtectMark:
 mov bp,cs
 mov ds,bp

 and dx,07FFFh		;remove reversal bit

 mov ErrorStackpointer,sp

 cmp dx,NumberofCells
 jae RangeError

 mov es,CellTable
 mov di,dx		;cell number * 4
 shl di,1
 shl di,1

 and es:[di+2],07FFFh

 ret

;...e

;** Range Error
;...sRangeError:0:
;************************************************************************
;************************************************************************
;*******  Range error

RangeError:
 mov ax,0103h
 call ReportError

ife discdebugging
 mov sp,cs:ErrorStackPointer
 ret
endif

;...sif discdebugging:0:
if discdebugging
 mov ax,2
 int 10h

 mov ax,cs
 mov ds,ax
 mov bx,offset RangeErrorText
 call printline
 call Getkey	;continue or terminate
 mov sp,cs:ErrorStackPointer
 ret

RangeErrorText:
 db 'Cell out of range!',0

;********  prints line of text
; bx - address start

printline:
 mov al,ds:[bx]     ;get character
 or al,al
 jnz printline2
 ret
printline2:
 call printchar
 inc bx
 jmp short printline

;********  print character
; al - character number

printchar:
 push bx
 mov bx,00007h
 mov ah,00Eh
 int 10h
 pop bx
 ret

endif
;...e


;...e

;** Tables
;...sOperationList:0:
;**********************************************************************
;**********************************************************************
;******** Operation List
; drawflag	(1)	 0 - insert into linked list
; incremented	(2)	 1 - plot object as sprite
;		(3)      2 - insert and redraw object in linked list
;		(4)	 3 - mark to preload
;		(5)	 4 - Set Protection Mark
;		(6)	 5 - Unset Protection Mark
;		(7)	 6 - Purge Object
;		(0)	-1 - remove and redraw object in linked list

even

OperationList:
 dw offset RemoveRedrawCell
 dw offset InsertCell
 dw offset PlotSprite
 dw offset InsertRedrawCell
 dw offset PreLoadMark
 dw offset SetProtectMark
 dw offset UnsetProtectMark
 dw offset PurgeObject

;...e

;** Variables
;...sVariables:0:
;***************************************************************************
;***************************************************************************
;********  Variables

 even

 Operation	dw 0
 object		dw 0
 drawflag	dw 0
 Rasteroffset   dw 0

;** stack start

 StackStart	db NumberStackEntries*StackLump	dup (0)
 StackEnd:

 Reflection	dw 0
 XPos		dw 0
 Zpos		dw 0
 Hpos		dw 0
 Address	dw 0
 EndAddress	dw 0

 Reflection2	dw 0

;** stack end

 RasterAddress		dw 0
 RasterEndAddress	dw 0

 RasterStart		dw 0
 RasterEnd		dw 0
 RasterCount		dw 0
 RasterDirection	dw 0

;** structure addresses etc

 XZHBeginning		dw 0
 XZHAddress		dw 0
 RastersBeginning	dw 0
 RastersAddress		dw 0
 AnimatedBeginning	dw 0
 AnimatedAddress	dw 0
 CompressedBeginning	dw 0
 CompressedAddress	dw 0

;** multitasking stuff

 StructureLock		db 0

;...e

;...e

code ends

;-----

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################

