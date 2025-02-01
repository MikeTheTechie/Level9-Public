;IBM HERO. Contants required by HERO system

;CONSTS.ASM

;24/DEC/88

;------

DosKeyboard     = 0 ;True/False. Disables interrupt system to allow 'symdeb'
TraceCode       = 1 ;True/False. Enable self-checking/crash-assist code.

Production      = 1 ;True/False. Use correct palette
TwoD            = 0 ;True/False. Reserved for ADEPT
Scroll          = 1 ;with scrolling DRIVER.BIN

CellWidthBits   = 4 ;Size of background elements
CellHeightBits  = 4

MapWidth        = 50
MapHeight       = 50

SpriteWidthBits = 4 ;Size of each sprite
SpriteHeight    = 16

;-----

;Manifest constants. Not expected to be changed in future...

CellWidth         = 1 SHL CellWidthBits
CellHeight        = 1 SHL CellHeightBits

SpriteWidth       = 1 SHL SpriteWidthBits

DisplayAreaHeight = 12*CellHeight
DisplayAreaWidth  = 16*CellWidth

HorizontalMargin  = 4*CellHeight
VerticalMargin    = 3*CellHeight

InitialManX       = CellWidth*2
InitialManY       = CellHeight*5

Width5            = (SpriteWidth+7)/4

maxmovingsprites  = 75
maxwalkableblock  = 16

CharStackMax         = 200*4
MultiTaskStackSize   = 2048

;!CGA_NumberOfCells    = 21h
NumberofCells        = 800
NumberofSprites      = 800
Heapsize             = 100

;-----
