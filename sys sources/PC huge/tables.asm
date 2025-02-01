;IBM HERO

;TABLES.ASM

;Copyright (C) 1988 Level 9 Computing

;-----

;...sInclude files:0:

;These include files must be named in MAKE.TXT:
; include common.asm
 include consts.asm
; include structs.asm

;...e

;...sPublics and externals:0:

 public BigExplosionTable
 public DefaultCells
 public NextAddDirTable
 public SpriteDataStructure
 public ViewToXYConversionTable

  IF TwoD
 public ExplodeSprite
 public ExplodeSpriteForm2
 public ExplodeSpriteForm3
 public ExplodeSpriteForm4
 public GarbageSprite
 public GarbageSpriteForm2
 public GarbageSpriteForm3
 public GarbageSpriteForm4
 public MissileSprite
 public MissileSpriteForm2
 public MissileSpriteForm3
 public MissileSpriteForm4
 public MonsterSprite
 public MonsterSpriteForm2
 public MonsterSpriteForm3
 public MonsterSpriteForm4
 public PlayerSprite
 public PlayerSpriteForm2
 public PlayerSpriteForm3
 public PlayerSpriteForm4
  ENDIF ;TwoD

;...e

;-----

code segment public 'code'
 assume cs:code

;-----

;           Either   Signed   Unsigned
;    <=              jle      jbe
;    <               jl       jb/jc
;    =      je/jz
;    <>     jnz/jne
;    >=              jge      jae/jnc
;    >               jg       ja

;-----

;...sTables:0:

BGMaxXTable:
 IF TwoD
;for each background block, record here the max x
;value which should be cd'd with.
;start with block 16...
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15

 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 ENDIF ;TwoD

BGMinYTable:
 IF TwoD
;for each background block, record here the min x
;value which should be cd'd with.
;start with block 16...
 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
 ENDIF ;TwoD

BGMaxYTable:
 IF TwoD
;For each background block, record here the min x
;value which should be cd'd with.
;start with block 16....
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15

 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
 ENDIF ;TwoD

;-----

BigExplosionTable:
 IF TwoD
;Table giving the x,y speeds for the
;elements of a big explosion

;up, right quarter.
 dw 0,-12 ;north
 dw 6,-11
 dw 12,-12
 dw 11,-6

;down, right quarter
 dw 12,0 ;east
 dw 11,6
 dw 12,12
 dw 6,11

;down, left quarter
 dw 0,12 ;south
 dw -6,11
 dw -12,12
 dw -12,6

;down, right quarter
 dw -12,0
 dw -11,-6
 dw -12,-12
 dw -6,-11

 dw 0,0 ;terminates table
 ENDIF ;TwoD

;-----

ViewConversionTable:
 IF TwoD
;Table to convert from joystick status values to view of player to use
 db 0 ; 0000 dummy entry
 db 0 ; 0001 north
 db 4 ; 0010 south
 db 0 ; 0011
 db 6 ; 0100 west
 db 7 ; 0101 northwest
 db 5 ; 0110 southwest
 db 0 ; 0111
 db 2 ; 1000 east
 db 1 ; 1001 east-north
 db 3 ; 1010 east-south
 db 0 ; 1011
 db 0 ; 1100
 db 0 ; 1101
 db 0 ; 1110
 db 0 ; 1111
 ENDIF ;TwoD

;-----

ViewToXYConversionTable:
 IF TwoD
;Table to convert from player view to XY offset (used for
;firing missiles etc.)
 dw 0,-1  ;north
 dw 1,-1  ;ne
 dw 1,0   ;e
 dw 1,1   ;se
 dw 0,1   ;s
 dw -1,1  ;sw
 dw -1,0  ;w
 dw -1,-1 ;nw

;-----

even
 db 0*4 ; -3 sixth attempt
 db 0,0,0
 db 3*4 ; -2 fifth attempt
 db 0,0,0
 db 2*4 ; -1 fourth attempt
 db 0,0,0

 ENDIF ;TwoD

NextAddDirTable:

 IF TwoD

;byte-wise table that, given the current addition to the
;movement direction, gives the new direction
 db 1*4  ; 0 first altered direction
 db 0,0,0
 db -1*4 ; 1 second attempt
 db 0,0,0
 db -2*4 ; 2 third attempt
 db 0,0,0
 db -3*4 ; 3 seventh attempt
 db 0,0,0
 db 0    ; 4 eigth attempt
 db 0,0,0

;-----

even
 db 0*4 ; -3
 db 0,0,0
 db 0*4 ; -2
 db 0,0,0
 db 0*4 ; -1
 db 0,0,0
 ENDIF ;TwoD
NearbyAddDirTable:
 IF TwoD
;byte-wise table that, given the current addition to the
;movement direction, gives the new addition
 db 1*4 ; 0
 db 0,0,0
 db -1*4 ; 1
 db 0,0,0
 db 0*4 ; 2
 db 0,0,0
 db 0*4 ; 3
 db 0,0,0
 db 0*4 ; 4
 db 0,0,0

;-----

DW_HiLo macro p1
 db (p1) / 256
 db (p1) mod 256
 endm ;DW_HiLo
 ENDIF ;TwoD

;-----

 even
SpriteDataStructure:
 IF TwoD
;PlayerSDS
; 0 is left player
 Dw 0 ; animation offset range when stationary ( from current view)
 Dw 0 ; animation range when moving north
 DW_HiLo 8 ; animation range when moving ne
 DW_HiLo 16 ; animation range when moving e
 DW_HiLo 24 ; animation range when moving se
 DW_HiLo 32 ; animation range when moving s
 DW_HiLo 40 ; animation range when moving sw
 DW_HiLo 48 ; animation range when moving w
 DW_HiLo 56 ; animation range when moving nw
 Dw 0 ; roughly change the colour of the player.
 DW_HiLo 256 ; added to above animation ranges when player is throwing
 DW_HiLo 1000 ; initial hit points
 DW_HiLo 30 ; damage done
 db 5
 db 7 ; max animation offset
 db 1 ; player type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 0FDh  ; which collisions are detected?
 db 034h  ; which collisions activate specials?
 db 000h ; does THIS sprite explode on these collisions
 db 00Fh ; is this sprite blocked by these collisions
 db 100 ; 128 ; priority of sprite. 255 appears on top, 0 at bottom
 db 19 ; offset of bottom row used in cd
 db 4 ; number of rows at top of sprite not cd'd

 even
; 1 is missile
 DW_HiLo 112 ;stationary ( from current view)
 DW_HiLo 112 ;north
 DW_HiLo 112 ;ne
 DW_HiLo 112 ;e
 DW_HiLo 112 ;se
 DW_HiLo 112 ;s
 DW_HiLo 112 ;sw
 DW_HiLo 112 ;w
 DW_HiLo 112 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 20 ; damage done
 db 0 ; continuous blows
 db 7 ; max animation offset
 db 2 ; missile type
 db 12  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 0CCh  ; collision detect?
 db 0CCh  ; specials?
 db 0CCh ; destroyed?
 db 000h ; blocked?
 db 120 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 2 is  an animated skull monster
 dw 0 ;stationary ( from current view)
 DW_HiLo 99 ;north
 DW_HiLo 99 ;ne
 DW_HiLo 99 ;e
 DW_HiLo 99 ;se
 DW_HiLo 99 ;s
 DW_HiLo 99 ;sw
 DW_HiLo 99 ;w
 DW_HiLo 99 ;nw
 DW_HiLo 3 ; *200 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 2 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 3 is  an explosion effect
 dw 0 ;stationary ( from current view)
 DW_HiLo 88 ;north
 DW_HiLo 88 ;ne
 DW_HiLo 88 ;e
 DW_HiLo 88 ;se
 DW_HiLo 88 ;s
 DW_HiLo 88 ;sw
 DW_HiLo 88 ;w
 DW_HiLo 88 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; blows per second
 db 8 ; max animation offset
 db 0 ; no type - will not cd with anything
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 000h  ; collision detect?
 db 000h  ; specials?
 db 000h  ; destroyed?
 db 00Fh ; blocked?
 db 105 ; priority
 db 15 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 4 is  an animated skull monster for space invaders
 dw 0 ;stationary ( from current view)
 DW_HiLo 96 ;north
 DW_HiLo 96 ;ne
 DW_HiLo 96 ;e
 DW_HiLo 96 ;se
 DW_HiLo 96 ;s
 DW_HiLo 96 ;sw
 DW_HiLo 96 ;w
 DW_HiLo 96 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 2 ; max animation offset
 db 084h ; monster type, but not auto-moving, hence bit 7 set
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 002h  ; collision detect?
 db 000h  ; specials?
 db 002h ; destroyed?
 db 000h ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 5 is missile for space invaders to fire
 DW_HiLo 64 ;stationary ( from current view)
 DW_HiLo 64 ;north
 DW_HiLo 64 ;ne
 DW_HiLo 64 ;e
 DW_HiLo 64 ;se
 DW_HiLo 64 ;s
 DW_HiLo 64 ;sw
 DW_HiLo 64 ;w
 DW_HiLo 64 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 25 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 040h ; si missile type
 db 12  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 001h ; destroyed?
 db 000h ; blocked?
 db 120 ; priority
 db 11 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 6 is missile to fire at space invaders
 DW_HiLo 64 ;stationary ( from current view)
 DW_HiLo 64 ;north
 DW_HiLo 64 ;ne
 DW_HiLo 64 ;e
 DW_HiLo 64 ;se
 DW_HiLo 64 ;s
 DW_HiLo 64 ;sw
 DW_HiLo 64 ;w
 DW_HiLo 64 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 002h ; missile type
 db 12  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 0C4h  ; collision detect?
 db 000h  ; specials?
 db 0C4h ; destroyed?
 db 000h ; blocked?
 db 120 ; priority
 db 11 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 7 is  a Rainbird monster
 dw 0 ;stationary ( from current view)
 DW_HiLo 104 ;north
 DW_HiLo 104 ;ne
 DW_HiLo 104 ;e
 DW_HiLo 104 ;se
 DW_HiLo 104 ;s
 DW_HiLo 104 ;sw
 DW_HiLo 104 ;w
 DW_HiLo 104 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Fh ; blocked?
 db 100 ; priority
 db 15 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 8 is the explosive missile fired by the player
 DW_HiLo 64 ;stationary ( from current view)
 DW_HiLo 64 ;north
 DW_HiLo 64 ;ne
 DW_HiLo 64 ;e
 DW_HiLo 64 ;se
 DW_HiLo 64 ;s
 DW_HiLo 64 ;sw
 DW_HiLo 64 ;w
 DW_HiLo 64 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 50 ; damage done
 db 0 ; continuous blows
 db 7 ; max animation offset
 db 022h ; 002h=missile type, 020h=explosive missile
 db 12  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 0CCh  ; collision detect?
 db 0CCh  ; specials?
 db 0CCh ; destroyed?
 db 000h ; blocked?
 db 120 ; priority
 db 11 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 9 is digging missile.
 DW_HiLo 112 ;stationary ( from current view)
 DW_HiLo 112 ;north
 DW_HiLo 112 ;ne
 DW_HiLo 112 ;e
 DW_HiLo 112 ;se
 DW_HiLo 112 ;s
 DW_HiLo 112 ;sw
 DW_HiLo 112 ;w
 DW_HiLo 112 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 2 ; missile type
 db 12  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 0C8h  ; collision detect?
 db 0C8h  ; specials?
 db 0C8h ; destroyed?
 db 000h ; blocked?
 db 120 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 10 is bottle
 DW_HiLo 122 ;stationary ( from current view)
 DW_HiLo 122 ;north
 DW_HiLo 122 ;ne
 DW_HiLo 122 ;e
 DW_HiLo 122 ;se
 DW_HiLo 122 ;s
 DW_HiLo 122 ;sw
 DW_HiLo 122 ;w
 DW_HiLo 122 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 11 is invisible object
 DW_HiLo -1 ;stationary ( from current view)
 DW_HiLo -1 ;north
 DW_HiLo -1 ;ne
 DW_HiLo -1 ;e
 DW_HiLo -1 ;se
 DW_HiLo -1 ;s
 DW_HiLo -1 ;sw
 DW_HiLo -1 ;w
 DW_HiLo -1 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 020h ; trap type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 000h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 15 ; offset of bottom row - used by rough cd
 db 0 ; head overlap

 even
; 12 is missile for space invaders to fire
 DW_HiLo 64 ;stationary ( from current view)
 DW_HiLo 64 ;north
 DW_HiLo 64 ;ne
 DW_HiLo 64 ;e
 DW_HiLo 64 ;se
 DW_HiLo 64 ;s
 DW_HiLo 64 ;sw
 DW_HiLo 64 ;w
 DW_HiLo 64 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 100 ; initial hit points
 DW_HiLo 25 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 044h ; monster missile type
 db 12  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Bh  ; collision detect?
 db 00Bh  ; specials?
 db 00Bh ; destroyed?
 db 000h ; blocked?
 db 120 ; priority
 db 11 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 13 is  an explosion effect
 dw 0 ;stationary ( from current view)
 DW_HiLo 80 ;north
 DW_HiLo 80 ;ne
 DW_HiLo 80 ;e
 DW_HiLo 80 ;se
 DW_HiLo 80 ;s
 DW_HiLo 80 ;sw
 DW_HiLo 80 ;w
 DW_HiLo 80 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; blows per second
 db 8 ; max animation offset
 db 0 ; no type - will not cd with anything
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 000h  ; collision detect?
 db 000h  ; specials?
 db 000h  ; destroyed?
 db 000h ; blocked?
 db 105 ; priority
 db 15 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 14 is NEW bottle
 DW_HiLo 122 ;stationary ( from current view)
 DW_HiLo 122 ;north
 DW_HiLo 122 ;ne
 DW_HiLo 122 ;e
 DW_HiLo 122 ;se
 DW_HiLo 122 ;s
 DW_HiLo 122 ;sw
 DW_HiLo 122 ;w
 DW_HiLo 122 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 15 is sword
 DW_HiLo 123 ;stationary ( from current view)
 DW_HiLo 123 ;north
 DW_HiLo 123 ;ne
 DW_HiLo 123 ;e
 DW_HiLo 123 ;se
 DW_HiLo 123 ;s
 DW_HiLo 123 ;sw
 DW_HiLo 123 ;w
 DW_HiLo 123 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 16 is armour
 DW_HiLo 124 ;stationary ( from current view)
 DW_HiLo 124 ;north
 DW_HiLo 124 ;ne
 DW_HiLo 124 ;e
 DW_HiLo 124 ;se
 DW_HiLo 124 ;s
 DW_HiLo 124 ;sw
 DW_HiLo 124 ;w
 DW_HiLo 124 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 17 is ring
 DW_HiLo 125 ;stationary ( from current view)
 DW_HiLo 125 ;north
 DW_HiLo 125 ;ne
 DW_HiLo 125 ;e
 DW_HiLo 125 ;se
 DW_HiLo 125 ;s
 DW_HiLo 125 ;sw
 DW_HiLo 125 ;w
 DW_HiLo 125 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 18 is wand
 DW_HiLo 126 ;stationary ( from current view)
 DW_HiLo 126 ;north
 DW_HiLo 126 ;ne
 DW_HiLo 126 ;e
 DW_HiLo 126 ;se
 DW_HiLo 126 ;s
 DW_HiLo 126 ;sw
 DW_HiLo 126 ;w
 DW_HiLo 126 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 19 is scroll
 DW_HiLo 127 ;stationary ( from current view)
 DW_HiLo 127 ;north
 DW_HiLo 127 ;ne
 DW_HiLo 127 ;e
 DW_HiLo 127 ;se
 DW_HiLo 127 ;s
 DW_HiLo 127 ;sw
 DW_HiLo 127 ;w
 DW_HiLo 127 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 20 is pot of gold
 DW_HiLo 106 ;stationary ( from current view)
 DW_HiLo 106 ;north
 DW_HiLo 106 ;ne
 DW_HiLo 106 ;e
 DW_HiLo 106 ;se
 DW_HiLo 106 ;s
 DW_HiLo 106 ;sw
 DW_HiLo 106 ;w
 DW_HiLo 106 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 21 is club
 DW_HiLo 108 ;stationary ( from current view)
 DW_HiLo 108 ;north
 DW_HiLo 108 ;ne
 DW_HiLo 108 ;e
 DW_HiLo 108 ;se
 DW_HiLo 108 ;s
 DW_HiLo 108 ;sw
 DW_HiLo 108 ;w
 DW_HiLo 108 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 dw 0 ; initial hit points
 dw 0 ; damage done
 db 0 ; continuous blows
 db 0 ; max animation offset
 db 010h ; object type
 db 0  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 001h  ; collision detect?
 db 000h  ; specials?
 db 000h ; destroyed?
 db 000h ; blocked?
 db 0	 ; priority
 db 12 ; offset of bottom row - used by rough cd
 db 4 ; head overlap

 even
; 22 is  a floating eye monster
 dw 0 ;stationary ( from current view)
EyeGraphic equ 128
 DW_HiLo EyeGraphic ;north
 DW_HiLo EyeGraphic ;ne
 DW_HiLo EyeGraphic ;e
 DW_HiLo EyeGraphic ;se
 DW_HiLo EyeGraphic ;s
 DW_HiLo EyeGraphic ;sw
 DW_HiLo EyeGraphic ;w
 DW_HiLo EyeGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 009h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 23 is  an acide blob
 dw 0 ;stationary ( from current view)
AcidGraphic equ 136
 DW_HiLo AcidGraphic ;north
 DW_HiLo AcidGraphic ;ne
 DW_HiLo AcidGraphic ;e
 DW_HiLo AcidGraphic ;se
 DW_HiLo AcidGraphic ;s
 DW_HiLo AcidGraphic ;sw
 DW_HiLo AcidGraphic ;w
 DW_HiLo AcidGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 3 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 24 is a jelly
 dw 0 ;stationary ( from current view)
JellyGraphic equ 140
 DW_HiLo JellyGraphic ;north
 DW_HiLo JellyGraphic ;ne
 DW_HiLo JellyGraphic ;e
 DW_HiLo JellyGraphic ;se
 DW_HiLo JellyGraphic ;s
 DW_HiLo JellyGraphic ;sw
 DW_HiLo JellyGraphic ;w
 DW_HiLo JellyGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 3 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 25 is a fog cloud
 dw 0 ;stationary ( from current view)
FogGraphic equ 144
 DW_HiLo FogGraphic ;north
 DW_HiLo FogGraphic ;ne
 DW_HiLo FogGraphic ;e
 DW_HiLo FogGraphic ;se
 DW_HiLo FogGraphic ;s
 DW_HiLo FogGraphic ;sw
 DW_HiLo FogGraphic ;w
 DW_HiLo FogGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 3 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 26 is a ghost
 dw 0 ;stationary ( from current view)
GhostGraphic equ 148
 DW_HiLo GhostGraphic ;north
 DW_HiLo GhostGraphic ;ne
 DW_HiLo GhostGraphic ;e
 DW_HiLo GhostGraphic ;se
 DW_HiLo GhostGraphic ;s
 DW_HiLo GhostGraphic ;sw
 DW_HiLo GhostGraphic ;w
 DW_HiLo GhostGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 3 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 27 is a will'o wisp
 dw 0 ;stationary ( from current view)
WispGraphic equ 152
 DW_HiLo WispGraphic ;north
 DW_HiLo WispGraphic ;ne
 DW_HiLo WispGraphic ;e
 DW_HiLo WispGraphic ;se
 DW_HiLo WispGraphic ;s
 DW_HiLo WispGraphic ;sw
 DW_HiLo WispGraphic ;w
 DW_HiLo WispGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 28 is a ghoul
 dw 0 ;stationary ( from current view)
GhoulGraphic equ 160
 DW_HiLo GhoulGraphic ;north
 DW_HiLo GhoulGraphic ;ne
 DW_HiLo GhoulGraphic ;e
 DW_HiLo GhoulGraphic ;se
 DW_HiLo GhoulGraphic ;s
 DW_HiLo GhoulGraphic ;sw
 DW_HiLo GhoulGraphic ;w
 DW_HiLo GhoulGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 3 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 29 is a spider
 dw 0 ;stationary ( from current view)
SpiderGraphic equ 164
 DW_HiLo SpiderGraphic ;north
 DW_HiLo SpiderGraphic ;ne
 DW_HiLo SpiderGraphic ;e
 DW_HiLo SpiderGraphic ;se
 DW_HiLo SpiderGraphic ;s
 DW_HiLo SpiderGraphic ;sw
 DW_HiLo SpiderGraphic ;w
 DW_HiLo SpiderGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 2 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 30 is a leprecaun
 dw 0 ;stationary ( from current view)
 DW_HiLo 168 ;north
 DW_HiLo 172 ;ne
 DW_HiLo 176 ;e
 DW_HiLo 180 ;se
 DW_HiLo 184 ;s
 DW_HiLo 188 ;sw
 DW_HiLo 192 ;w
 DW_HiLo 196 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 3 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 31 is a gorgon
 dw 0 ;stationary ( from current view)
 DW_HiLo 288 ;north
 DW_HiLo 296 ;ne
 DW_HiLo 304 ;e
 DW_HiLo 312 ;se
 DW_HiLo 320 ;s
 DW_HiLo 328 ;sw
 DW_HiLo 336 ;w
 DW_HiLo 344 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 32 is a minotaur
 dw 0 ;stationary ( from current view)
 DW_HiLo 320 ;north
 DW_HiLo 324 ;ne
 DW_HiLo 328 ;e
 DW_HiLo 332 ;se
 DW_HiLo 336 ;s
 DW_HiLo 340 ;sw
 DW_HiLo 344 ;w
 DW_HiLo 348 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 33 is a mummy
 dw 0 ;stationary ( from current view)
 DW_HiLo 352 ;north
 DW_HiLo 356 ;ne
 DW_HiLo 360 ;e
 DW_HiLo 364 ;se
 DW_HiLo 368 ;s
 DW_HiLo 372 ;sw
 DW_HiLo 376 ;w
 DW_HiLo 380 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 ; max animation offset
 db 4 ; monster type
 db 4  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 34 is a balrog
 dw 0 ;stationary ( from current view)
 DW_HiLo 416 ;north
 DW_HiLo 420 ;ne
 DW_HiLo 424 ;e
 DW_HiLo 428 ;se
 DW_HiLo 432 ;s
 DW_HiLo 436 ;sw
 DW_HiLo 440 ;w
 DW_HiLo 444 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 ; 3 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 35 is a demon
 dw 0 ;stationary ( from current view)
 DW_HiLo 448 ;north
 DW_HiLo 452 ;ne
 DW_HiLo 456 ;e
 DW_HiLo 460 ;se
 DW_HiLo 464 ;s
 DW_HiLo 468 ;sw
 DW_HiLo 472 ;w
 DW_HiLo 476 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 ; 3 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 36 is a skeleton
 dw 0 ;stationary ( from current view)
 DW_HiLo 480 ;north
 DW_HiLo 484 ;ne
 DW_HiLo 488 ;e
 DW_HiLo 492 ;se
 DW_HiLo 496 ;s
 DW_HiLo 500 ;sw
 DW_HiLo 504 ;w
 DW_HiLo 508 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 ; 3 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 37 is a nymph
 dw 0 ;stationary ( from current view)
 DW_HiLo 544 ;north
 DW_HiLo 548 ;ne
 DW_HiLo 552 ;e
 DW_HiLo 556 ;se
 DW_HiLo 560 ;s
 DW_HiLo 564 ;sw
 DW_HiLo 568 ;w
 DW_HiLo 572 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 *3 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 38 is a vampire
 dw 0 ;stationary ( from current view)
 DW_HiLo 576 ;north
 DW_HiLo 580 ;ne
 DW_HiLo 584 ;e
 DW_HiLo 588 ;se
 DW_HiLo 592 ;s
 DW_HiLo 596 ;sw
 DW_HiLo 600 ;w
 DW_HiLo 604 ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 0 *3 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 39 is killer bee
 dw 0 ;stationary ( from current view)
BeeGraphic equ 608
 DW_HiLo BeeGraphic ;north
 DW_HiLo BeeGraphic ;ne
 DW_HiLo BeeGraphic ;e
 DW_HiLo BeeGraphic ;se
 DW_HiLo BeeGraphic ;s
 DW_HiLo BeeGraphic ;sw
 DW_HiLo BeeGraphic ;w
 DW_HiLo BeeGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 40 is a snake
 dw 0 ;stationary ( from current view)
SnakeGraphic equ 616
 DW_HiLo SnakeGraphic ;north
 DW_HiLo SnakeGraphic ;ne
 DW_HiLo SnakeGraphic ;e
 DW_HiLo SnakeGraphic ;se
 DW_HiLo SnakeGraphic ;s
 DW_HiLo SnakeGraphic ;sw
 DW_HiLo SnakeGraphic ;w
 DW_HiLo SnakeGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap

 even
; 41 is a freezing sphere
 dw 0 ;stationary ( from current view)
SphereGraphic equ 624
 DW_HiLo SphereGraphic ;north
 DW_HiLo SphereGraphic ;ne
 DW_HiLo SphereGraphic ;e
 DW_HiLo SphereGraphic ;se
 DW_HiLo SphereGraphic ;s
 DW_HiLo SphereGraphic ;sw
 DW_HiLo SphereGraphic ;w
 DW_HiLo SphereGraphic ;nw
 dw 0 ; fight offset
 dw 0 ; throw offset
 DW_HiLo 50 ; initial hit points
 DW_HiLo 5 ; damage done
 db 10 ; roughly one blow per second
 db 7 ; max animation offset
 db 4 ; monster type
 db 1  ; speed of movement (pels)
 db 0  ; number of null moves per real move
 db 00Dh  ; collision detect?
 db 001h  ; specials?
 db 000h ; destroyed?
 db 00Dh ; blocked?
 db 100 ; priority
 db 19 ; offset of bottom row - used in cd
 db 4 ; head overlap
 ENDIF ;TwoD

;-----

;Each line of these sprite is stored as a transparency mask (two bits per
;pixel 00=display sprite, 11=display background) and the pixel mask (two
;bits per pixel ,transparent pixels are 00.)

;The pixels are always stored byte-aligned, so when the sprite on the screen
;is not byte-aligned 1,2 or 3 blank pixels are added to the left and leftright
;margins, so the sprite always needs to be stored as 12 pixels wide.

; ......XXXX......
; ....XXXXXXXX....
; ...XXXXXXXXXX...
; ....XXXXXXXX....
; ......XXXX......
; .....XXXXXX.....
; ....XXXXXXXX....
; ....XXXXXXXX....
; ...XXXXXXXXXX...
; ...XXXXXXXXXX...
; ...XXXXXXXXXX...
; ...XXXXXXXXXX...
; ...XXXXXXXXXX...
; ..XXXXXXXXXXXX..
; ..XXXXXXXXXXXX..
; ..XXXXXXXXXXXX..

 IF TwoD

PlayerSprite: ;Data for Sprite 0 
 db 0FFh,0C0h,003h,0FFh,0FFh
 db 000h,00Fh,0F0h,000h,000h

 db 0FCh,000h,000h,03Fh,0FFh
 db 000h,0FFh,0FFh,000h,000h

 db 0F0h,000h,000h,00Fh,0FFh
 db 003h,0FFh,0FFh,0C0h,000h

 db 0FCh,000h,000h,03Fh,0FFh
 db 000h,0FFh,0FFh,000h,000h

 db 0FFh,0C0h,003h,0FFh,0FFh
 db 000h,00Fh,0F0h,000h,000h

 db 0FFh,000h,000h,0FFh,0FFh
 db 000h,03Fh,0FCh,000h,000h

 db 0FCh,000h,000h,03Fh,0FFh
 db 000h,0FFh,0FFh,000h,000h

 db 0FCh,000h,000h,03Fh,0FFh
 db 000h,0FFh,0FFh,000h,000h

 db 0F0h,000h,000h,00Fh,0FFh
 db 003h,0FFh,0FFh,0C0h,000h

 db 0F0h,000h,000h,00Fh,0FFh
 db 003h,0FFh,0FFh,0C0h,000h

 db 0F0h,000h,000h,00Fh,0FFh
 db 003h,0FFh,0FFh,0C0h,000h

 db 0F0h,000h,000h,00Fh,0FFh
 db 003h,0FFh,0FFh,0C0h,000h

 db 0F0h,000h,000h,00Fh,0FFh
 db 003h,0FFh,0FFh,0C0h,000h

 db 0F0h,000h,000h,00Fh,0FFh
 db 00Fh,0FFh,0FFh,0F0h,000h

 db 0C0h,000h,000h,003h,0FFh
 db 00Fh,0FFh,0FFh,0F0h,000h

 db 0C0h,000h,000h,003h,0FFh
 db 00Fh,0FFh,0FFh,0F0h,000h

SpriteLength = ((this byte) - PlayerSprite)

PlayerSpriteForm2 db SpriteLength dup(0)
PlayerSpriteForm3 db SpriteLength dup(0)
PlayerSpriteForm4 db SpriteLength dup(0)

 ENDIF ;TwoD

;-----

; ................
; .......XX.......
; ......XXXX......
; .....XXXXXX.....
; ....XXXXXXXX....
; ...XXXXXXXXXX...
; ...XXXXXXXXXX...
; ....XXXXXXXX....
; .....XXXXXX.....
; ......XXXX......
; .......XX.......
; ................

 IF TwoD

MissileSprite: ;Data for sprite 2
 db 0FFh,0FCh,03Fh,0FFh,0FFh ;line 1
 db 000h,000h,000h,000h,000h

 db 0FFh,0F0h,00Fh,0FFh,0FFh ;line 2
 db 000h,002h,080h,000h,000h

 db 0FFh,0C0h,003h,0FFh,0FFh ;line 3
 db 000h,00Ah,0A0h,000h,000h

 db 0FFh,000h,000h,0FFh,0FFh ;line 4
 db 000h,02Ah,0A8h,000h,000h

 db 0FCh,000h,000h,03Fh,0FFh ;line 5
 db 000h,0AAh,0AAh,000h,000h

 db 0F0h,000h,000h,00Fh,0FFh ;line 6
 db 002h,0AAh,0AAh,080h,000h

 db 0F0h,000h,000h,00Fh,0FFh ;line 7
 db 002h,0AAh,0AAh,080h,000h

 db 0FCh,000h,000h,03Fh,0FFh ;line 8
 db 000h,0AAh,0AAh,000h,000h

 db 0FFh,000h,000h,0FFh,0FFh ;line 9
 db 000h,02Ah,0A8h,000h,000h

 db 0FFh,0C0h,003h,0FFh,0FFh ;line 10
 db 000h,00Ah,0A0h,000h,000h

 db 0FFh,0F0h,00Fh,0FFh,0FFh ;line 11
 db 000h,002h,080h,000h,000h

 db 0FFh,0FCh,03Fh,0FFh,0FFh ;line 12
 db 000h,000h,000h,000h,000h

 db 0FFh,0FFh,0FFh,0FFh,0FFh ;line 13
 db 000h,000h,000h,000h,000h

 db 0FFh,0FFh,0FFh,0FFh,0FFh ;line 14
 db 000h,000h,000h,000h,000h

 db 0FFh,0FFh,0FFh,0FFh,0FFh ;line 15
 db 000h,000h,000h,000h,000h

 db 0FFh,0FFh,0FFh,0FFh,0FFh ;line 16
 db 000h,000h,000h,000h,000h

MissileSpriteForm2 db SpriteLength dup(0)
MissileSpriteForm3 db SpriteLength dup(0)
MissileSpriteForm4 db SpriteLength dup(0)

 ENDIF ;TwoD

;-----

; ................
; .......XX.......
; .....XXXXXX.....
; ...XXXXXXXXXX...
; ..XXXXXXXXXXXX..
; ..XXXXXXXXXXXX..
; .XXXXXXXXXXXXXX.
; .XXXXXXXXXXXXXX.
; .XXXXXXXXXXXXXX.
; .XXXXXXXXXXXXXX.
; ..XXXXXXXXXXXX..
; ..XXXXXXXXXXXX..
; ...XXXXXXXXXX...
; .....XXXXXX.....
; .......XX.......
; ................

 IF TwoD

MonsterSprite: ;Data for sprite 1
 db 0FFh,0F0h,00Fh,0FFh,0FFh ;Plotting mask (top line)
 db 000h,000h,000h,000h,000h

 db 0FFh,0C0h,003h,0FFh,0FFh ;top of circle
 db 000h,003h,0C0h,000h,000h

 db 0FCh,000h,000h,03Fh,0FFh ;line 3
 db 000h,03Fh,0FCh,000h,000h

 db 0F0h,000h,000h,00Fh,0FFh ;line 4
 db 003h,0FFh,0FFh,0C0h,000h

 db 0C0h,000h,000h,003h,0FFh ;line 5
 db 00Fh,0FFh,0FFh,0F0h,000h

 db 0C0h,000h,000h,003h,0FFh ;line 6
 db 00Fh,0FFh,0FFh,0F0h,000h

 db 000h,000h,000h,000h,0FFh ;line 7
 db 03Fh,0FFh,0FFh,0FCh,000h

 db 000h,000h,000h,000h,0FFh ;line 8
 db 03Fh,0FFh,0FFh,0FCh,000h

 db 000h,000h,000h,000h,0FFh ;line 9
 db 03Fh,0FFh,0FFh,0FCh,000h

 db 000h,000h,000h,000h,0FFh ;line 10
 db 03Fh,0FFh,0FFh,0FCh,000h

 db 0C0h,000h,000h,003h,0FFh ;line 11
 db 00Fh,0FFh,0FFh,0F0h,000h

 db 0C0h,000h,000h,003h,0FFh ;line 12
 db 00Fh,0FFh,0FFh,0F0h,000h

 db 0F0h,000h,000h,00Fh,0FFh ;line 13
 db 003h,0FFh,0FFh,0C0h,000h

 db 0FCh,000h,000h,03Fh,0FFh ;line 14
 db 000h,03Fh,0FCh,000h,000h
 
 db 0FFh,0C0h,003h,0FFh,0FFh ;bottom of circle
 db 000h,003h,0C0h,000h,000h

 db 0FFh,0F0h,00Fh,0FFh,0FFh ;line 16
 db 000h,000h,000h,000h,000h

MonsterSpriteForm2 db SpriteLength dup(0)
MonsterSpriteForm3 db SpriteLength dup(0)
MonsterSpriteForm4 db SpriteLength dup(0)

 ENDIF ;TwoD

;-----

; ................
; ................
; ................
; .....X.XX.X.....
; ...X...XX...X...
; ....X.XXXX.X....
; ..X....XX....X..
; ..XXXXXXXXXXXX..
; ..XXXXXXXXXXXX..
; ..X....XX....X..
; ....X.XXXX.X....
; ...X...XX...X...
; .....X.XX.X.....
; ................
; ................
; ................

 IF TwoD

ExplodeSprite: ;Data for sprite 3
 rept 3
 db 0FFh,0FFh,0FFh,0FFh,0FFh ;Line 1..3
 db 000h,000h,000h,000h,000h
 endm ;rept 3

 db 0FFh,000h,000h,0FFh,0FFh ;line 4
 db 000h,022h,088h,000h,000h

 db 0F0h,000h,000h,00Fh,0FFh ;line 5
 db 002h,002h,080h,080h,000h

 db 0FCh,000h,000h,03Fh,0FFh ;line 6
 db 000h,08Ah,0A2h,000h,000h

 db 0C0h,000h,000h,003h,0FFh ;line 7
 db 008h,002h,080h,020h,000h

 db 0C0h,000h,000h,003h,0FFh ;line 8
 db 00Ah,0AFh,0FAh,0A0h,000h

 db 0C0h,000h,000h,003h,0FFh ;line 9
 db 00Ah,0AFh,0FAh,0A0h,000h

 db 0C0h,000h,000h,003h,0FFh ;line 10
 db 008h,002h,080h,020h,000h

 db 0FCh,000h,000h,03Fh,0FFh ;line 11
 db 000h,08Ah,0A2h,000h,000h

 db 0F0h,000h,000h,00Fh,0FFh ;line 12
 db 002h,002h,080h,080h,000h

 db 0FFh,000h,000h,0FFh,0FFh ;line 13
 db 000h,022h,088h,000h,000h

 rept 3
 db 0FFh,0FFh,0FFh,0FFh,0FFh ;Line 14..16
 db 000h,000h,000h,000h,000h
 endm ;rept 3

ExplodeSpriteForm2 db SpriteLength dup(0)
ExplodeSpriteForm3 db SpriteLength dup(0)
ExplodeSpriteForm4 db SpriteLength dup(0)

 ENDIF ;TwoD

;-----

; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; XXXXXXXXXXXXXXXX
; ................

 IF TwoD

GarbageSprite: ;Data for sprite 4
 db 000h,000h,000h,000h,0FFh
 db 055h,055h,055h,055h,000h
 rept 7
 db 03Ch,0F3h,0CFh,03Ch,0FFh
 db 041h,004h,010h,041h,000h
 db 03Fh,0FFh,0FFh,0FCh,0FFh
 db 040h,000h,000h,001h,000h
 endm ;rept

 db 000h,000h,000h,000h,0FFh
 db 055h,055h,055h,055h,000h

GarbageSpriteForm2 db SpriteLength dup(0)
GarbageSpriteForm3 db SpriteLength dup(0)
GarbageSpriteForm4 db SpriteLength dup(0)

 ENDIF ;TwoD

;-----

;These cells, and all code which accesses them, SHOULD be a different segment.

 even

DefaultCells:
 IF TwoD
;Cell 0.
 dw 0,0    ;0  .... ....
 dw 0,03Ch ;4  .... .XX.
 dw 0,0C3h ;8  .... X..X
 dw 0,0C3h ;12 .... X..X
 dw 0,03Ch ;16 .... .XX.
 dw 0,0    ;20 .... ....
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58

;Cell 1.
 dw 0AA2Ah,0AAAAh ;0  .... ....
 dw 0AA2Ah,0A6AAh ;4  .... ..X.
 dw 0AA2Ah,096AAh ;8  .... .XX.
 dw 0AA2Ah,0A6AAh ;12 .... ..X.
 dw 0AA2Ah,095AAh ;16 .... .XXX
 dw 0AA2Ah,0AAAAh ;20 .... ....
 dw 0AA2Ah,0AAAAh ;24 .... ....
 dw 0AA2Ah,0AAAAh ;28 .... ....
 dw 0AA2Ah,0AAAAh ;32 .... ....
 dw 0AA2Ah,0AAAAh ;36 .... ....
 dw 0AA2Ah,0AAAAh ;40 .... ....
 dw 0AA2Ah,0AAAAh ;44 .... ....
 dw 0AA2Ah,0AAAAh ;48 .... ....
 dw 0AA2Ah,0AAAAh ;52 .... ....
 dw 0AA2Ah,0AAAAh ;56 .... ....
 dw 0,0           ;58 .... ....

;Cell 2.
 dw 0AA2Ah,0AAAAh ;0  .... .... 
 dw 0AA2Ah,056AAh ;4  .... XXX. 1010 0101 0110
 dw 0AA2Ah,0A9A9h ;8  ...X ...X 1001 1010 1001
 dw 0AA2Ah,096AAh ;12 .... .XX. 1010 1001 0110
 dw 0AA2Ah,055AAh ;16 .... XXXX 1010 0101 0101
 dw 0AA2Ah,0AAAAh ;20 .... ....
 dw 0AA2Ah,0AAAAh ;24 .... ....
 dw 0AA2Ah,0AAAAh ;28 .... ....
 dw 0AA2Ah,0AAAAh ;32 .... ....
 dw 0AA2Ah,0AAAAh ;36 .... ....
 dw 0AA2Ah,0AAAAh ;40 .... ....
 dw 0AA2Ah,0AAAAh ;44 .... ....
 dw 0AA2Ah,0AAAAh ;48 .... ....
 dw 0AA2Ah,0AAAAh ;52 .... ....
 dw 0AA2Ah,0AAAAh ;56 .... ....
 dw 0,0           ;58 .... ....

;Cell 3.
 dw 0AA2Ah,0AAAAh ;0  .... ....
 dw 0AA2Ah,056AAh ;4  .... XXX. 0101 0110
 dw 0AA2Ah,0A9AAh ;8  .... ...X 1010 1001
 dw 0AA2Ah,096AAh ;12 .... .XX. 1001 0110
 dw 0AA2Ah,0A9AAh ;16 .... ...X 1010 1001
 dw 0AA2Ah,056AAh ;20 .... XXX. 0101 0110
 dw 0AA2Ah,0AAAAh ;24 .... ....
 dw 0AA2Ah,0AAAAh ;28 .... ....
 dw 0AA2Ah,0AAAAh ;32 .... ....
 dw 0AA2Ah,0AAAAh ;36 .... ....
 dw 0AA2Ah,0AAAAh ;40 .... ....
 dw 0AA2Ah,0AAAAh ;44 .... ....
 dw 0AA2Ah,0AAAAh ;48 .... ....
 dw 0AA2Ah,0AAAAh ;52 .... ....
 dw 0AA2Ah,0AAAAh ;56 .... ....
 dw 0,0           ;58 .... ....

;Cell 4.
 dw 0AA2Ah,0AAAAh ;0  .... ....
 dw 0AA2Ah,0A6AAh ;4  .... ..X. 1010 0110
 dw 0AA2Ah,096AAh ;8  .... .XX. 1001 0110
 dw 0AA2Ah,055AAh ;12 .... XXXX 0101 0101
 dw 0AA2Ah,0A6AAh ;16 .... ..X. 1010 0110
 dw 0AA2Ah,0AAAAh ;20 .... ....
 dw 0AA2Ah,0AAAAh ;24 .... ....
 dw 0AA2Ah,0AAAAh ;28 .... ....
 dw 0AA2Ah,0AAAAh ;32 .... ....
 dw 0AA2Ah,0AAAAh ;36 .... ....
 dw 0AA2Ah,0AAAAh ;40 .... ....
 dw 0AA2Ah,0AAAAh ;44 .... ....
 dw 0AA2Ah,0AAAAh ;48 .... ....
 dw 0AA2Ah,0AAAAh ;52 .... ....
 dw 0AA2Ah,0AAAAh ;56 .... ....
 dw 0,0           ;58 .... ....

;Cell 5.
 dw 0AA2Ah,0AAAAh ;0  .... ....
 dw 0AA2Ah,055AAh ;4  .... XXXX 0101 0101
 dw 0AA2Ah,06AAAh ;8  .... X... 0110 1010
 dw 0AA2Ah,056AAh ;12 .... XXX. 0101 0110
 dw 0AA2Ah,0A9AAh ;16 .... ...X 1010 1001
 dw 0AA2Ah,056AAh ;20 .... XXX. 0101 0110
 dw 0AA2Ah,0AAAAh ;24 .... ....
 dw 0AA2Ah,0AAAAh ;28 .... ....
 dw 0AA2Ah,0AAAAh ;32 .... ....
 dw 0AA2Ah,0AAAAh ;36 .... ....
 dw 0AA2Ah,0AAAAh ;40 .... ....
 dw 0AA2Ah,0AAAAh ;44 .... ....
 dw 0AA2Ah,0AAAAh ;48 .... ....
 dw 0AA2Ah,0AAAAh ;52 .... ....
 dw 0AA2Ah,0AAAAh ;56 .... ....
 dw 0,0           ;58 .... ....

;Cell 6.
 dw 0,0    ;0  .... ....
 dw 0,00Ch ;4  .... ..X.
 dw 0,030h ;8  .... .X..
 dw 0,0FCh ;12 .... XXX.
 dw 0,0C3h ;16 .... X..X
 dw 0,03Ch ;20 .... .XX.
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 7.
 dw 0,0    ;0  .... ....
 dw 0,0FFh ;4  .... XXXX
 dw 0,003h ;8  .... ...X
 dw 0,03Fh ;12 .... .XXX
 dw 0,00Ch ;16 .... ..X.
 dw 0,030h ;20 .... .X..
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 8.
 dw 0,0    ;0  .... ....
 dw 0,03Ch ;4  .... .XX.
 dw 0,0C3h ;8  .... X..X
 dw 0,03Ch ;12 .... .XX.
 dw 0,0C3h ;16  .... X..X
 dw 0,03Ch ;20 .... .XX.
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 9.
 dw 0,0    ;0  .... ....
 dw 0,03Ch ;4  .... .XX.
 dw 0,0C3h ;8  .... X..X
 dw 0,03Fh ;12 .... .XXX
 dw 0,00Ch ;16 .... ..X.
 dw 0,030h ;20 .... .X..
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 0A.
 dw 0,0    ;0  .... ....
 dw 0,03Ch ;4  .... .XX.
 dw 0,0C3h ;8  .... X..X
 dw 0,0FFh ;12 .... XXXX
 dw 0,0C3h ;16 .... X..X
 dw 0,0C3h ;20 .... X..X
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 0B.
 dw 0,0    ;0  .... ....
 dw 0,0FCh ;4  .... XXX.
 dw 0,0C3h ;8  .... X..X
 dw 0,0FCh ;12 .... XXX.
 dw 0,0C3h ;16 .... X..X
 dw 0,0FCh ;20 .... XXX.
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 0C.
 dw 0,0    ;0  .... ....
 dw 0,03Ch ;4  .... .XX.
 dw 0,0C0h ;8  .... X...
 dw 0,0C0h ;12 .... X...
 dw 0,03Ch ;16 .... .XX.
 dw 0,0    ;20 .... ....
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 0D.
 dw 0,0    ;0  .... ....
 dw 0,0FCh ;4  .... XXX.
 dw 0,0C3h ;8  .... X..X
 dw 0,0C3h ;12 .... X..X
 dw 0,0FCh ;16 .... XXX.
 dw 0,0    ;20 .... ....
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 0E.
 dw 0,0    ;0  .... ....
 dw 0,0FFh ;4  .... XXXX
 dw 0,0C0h ;8  .... X...
 dw 0,0FCh ;12 .... XXX.
 dw 0,0C0h ;16 .... X...
 dw 0,0FFh ;20 .... XXXX
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 0F.
 dw 0,0    ;0 .... ....
 dw 0,0FFh ;4  .... XXXX
 dw 0,0C0h ;8  .... X...
 dw 0,0FCh ;12 .... XXX.
 dw 0,0C0h ;16 .... X...
 dw 0,0    ;20 .... X...
 dw 0,0    ;24 .... ....
 dw 0,0    ;28 .... ....
 dw 0,0    ;32 .... ....
 dw 0,0    ;36 .... ....
 dw 0,0    ;40 .... ....
 dw 0,0    ;44 .... ....
 dw 0,0    ;48 .... ....
 dw 0,0    ;52 .... ....
 dw 0,0    ;56 .... ....
 dw 0,0    ;58 .... ....

;Cell 10.
 dw 0,0       ;0  .... ....
 dw 030h,03Ch ;4  .X.. .XX.
 dw 0F0h,0C3h ;8  XX.. X..X
 dw 030h,0C3h ;12 .X.. X..X
 dw 0FCh,03Ch ;16 XXX. .XX.
 dw 0,0       ;20 .... ....
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 11.
 dw 05515h,05555h  ;0  ........
 dw 05515h,05565h  ;4  .X......
 dw 05515h,065A5h  ;8  XX...X..
 dw 05515h,0A565h  ;12 .X..XX..
 dw 05515h,065A9h  ;16 XXX..X..
 dw 05515h,0A955h  ;20 ....XXX.
 dw 05515h,05555h  ;24 ........
 dw 05515h,05555h  ;28 ........
 dw 05515h,05555h  ;32 ........
 dw 05515h,05555h  ;36 ........
 dw 05515h,05555h  ;40 ........
 dw 05515h,05555h  ;44 ........
 dw 05515h,05555h  ;48 ........
 dw 05515h,05555h  ;52 ........
 dw 05515h,05555h  ;56 ........
 dw 0,0            ;58 ........

;Cell 12.
 dw 0,0       ;0  .... ....
 dw 0C0h,0FCh ;4  X... XXX.
 dw 0C3h,001h ;8  X..X ...X
 dw 0C0h,03Ch ;12 X... .XX.
 dw 0C0h,0FFh ;16 X... XXXX
 dw 0,0       ;20 .... ....
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 13.
 dw 0,0       ;0  .... ....
 dw 030h,0FCh ;4  .X.. XXX.
 dw 0F0h,001h ;8  XX.. ...X
 dw 030h,03Ch ;12 .X.. .XX.
 dw 0FCh,001h ;16 XXX. ...X
 dw 000h,0FCh ;20 .... XXX.
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 14.
 dw 0,0       ;0  .... ....
 dw 030h,00Ch ;4  .X.. ..X.
 dw 0F0h,03Ch ;8  XX.. .XX.
 dw 030h,0FFh ;12 .X.. XXXX
 dw 0FCh,00Ch ;16 XXX. ..X.
 dw 0,0       ;20 .... ....
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 15.
 dw 0,0       ;0  .... ....
 dw 0C0h,0FFh ;4  .X.. XXXX
 dw 0F0h,0C0h ;8  XX.. X...
 dw 030h,0FCh ;12  .X.. XXX.
 dw 030h,003h ;16 .X.. ...X
 dw 0FCh,0FCh ;20 XXX.. XX.
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 16.
 dw 0,0       ;0  .... ....
 dw 0C0h,00Ch ;4  .X.. ..X.
 dw 0F0h,030h ;8  XX.. .X..
 dw 0C0h,0FCh ;12 .X.. XXX.
 dw 0FCh,0C3h ;16 XXX. X..X
 dw 000h,03Ch ;20 .... .XX.
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 17.
 dw 0,0       ;0  .... ....
 dw 0C0h,0FFh ;4  .X.. XXXX
 dw 0F0h,003h ;8  XX.. ...X
 dw 0C0h,03Fh ;12 .X.. .XXX
 dw 0FCh,00Ch ;16 XXX. ..X.
 dw 0FCh,030h ;20 .... .X..
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 18.
 dw 0,0       ;0  .... ....
 dw 0C0h,03Ch ;4  .X.. .XX.
 dw 0F0h,0C3h ;8  XX... X..X
 dw 0C0h,03Ch ;12 .X.. .XX.
 dw 0FCh,0C3h ;16 XXX. X..X
 dw 000h,03Ch ;20 .... .XX.
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 19.
 dw 0,0       ;0  .... ....
 dw 0C0h,03Ch ;4  .X.. .XX.
 dw 0F0h,0C3h ;8  XX.. X..X
 dw 0C0h,03Fh ;12 .X.. .XXX
 dw 0FCh,00Ch ;16 XXX. ..X.
 dw 000h,030h ;20 .... .X..
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 1A.
 dw 0,0       ;0  .... ....
 dw 0C0h,03Ch ;4  .X.. .XX.
 dw 0F0h,0C3h ;8  XX.. X..X
 dw 0C0h,0FFh ;12 .X.. XXXX
 dw 0FCh,0C3h ;16 XXX. X..X
 dw 000h,0C3h ;20 .... X..X
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 1B.
 dw 0,0       ;0  .... ....
 dw 0C0h,0FCh ;4  .X.. XXX.
 dw 0F0h,0C3h ;8  XX.. X..X
 dw 0C0h,0FCh ;12 .X.. XXX.
 dw 0FCh,0C3h ;16 XXX. X..X
 dw 000h,0FCh ;20 .... XXX.
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 1C.
 dw 0,0       ;0  .... ....
 dw 0C0h,03Ch ;4  .X.. .XX.
 dw 0F0h,0C0h ;8  XX.. X...
 dw 0C0h,0C0h ;12 .X.. X...
 dw 0FCh,03Ch ;16 XXX. .XX.
 dw 0,0       ;20 .... ....
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 1D.
 dw 0,0       ;0  .... ....
 dw 0C0h,0FCh ;4  .X.. XXX.
 dw 0F0h,0C3h ;8  XX.. X..X
 dw 0C0h,0C3h ;12 .X.. X..X
 dw 0FCh,0FCh ;16 XXX. XXX.
 dw 0,0       ;20 .... ....
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 1E.
 dw 0,0       ;0  .... ....
 dw 0C0h,0FFh ;4  .X.. XXXX
 dw 0F0h,0C0h ;8  XX.. X...
 dw 0C0h,0FCh ;12 .X.. XXX.
 dw 0FCh,0C0h ;16 XXX. X...
 dw 000h,0FFh ;20 .... XXXX
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 1F.
 dw 0,0       ;0  .... ....
 dw 0C0h,0FFh ;4  .X.. XXXX
 dw 0F0h,0C0h ;8  XX.. X...
 dw 0C0h,0FCh ;12  .X.. XXX.
 dw 0FCh,0C0h ;16 XXX. X...
 dw 000h,0C0h ;20 .... X...
 dw 0,0       ;24 .... ....
 dw 0,0       ;28 .... ....
 dw 0,0       ;32 .... ....
 dw 0,0       ;36 .... ....
 dw 0,0       ;40 .... ....
 dw 0,0       ;44 .... ....
 dw 0,0       ;48 .... ....
 dw 0,0       ;52 .... ....
 dw 0,0       ;56 .... ....
 dw 0,0       ;58 .... ....

;Cell 20.
 dw 01111h,0      ;0  .... ....
 dw 04404h,00028h ;4  .XX.. ....
 dw 01111h,02882h ;8  X..X .XX.
 dw 04404h,08208h ;12 ..X. X..X
 dw 01111h,082AAh ;16 XXXX X..X
 dw 04404h,02800h ;20 .... .XX.
 dw 01111h,0      ;24 .... ....
 dw 04404h,04444h ;28 .... ....
 dw 01111h,01111h ;32 .... ....
 dw 04404h,04444h ;36 .... ....
 dw 01111h,01111h ;40 .... ....
 dw 04404h,04444h ;44 .... ....
 dw 01111h,01111h ;48 .... ....
 dw 04404h,04444h ;52 .... ....
 dw 01111h,01111h ;56 .... ....
 dw 0,0           ;58 .... ....
 ENDIF ;TwoD

junksprite:
 IF TwoD
 dw 01111h,01111h ;3-255 - 'Cross hatch'
 dw 04404h,04444h
 dw 01111h,01111h
 dw 04404h,04444h
 dw 01111h,01111h
 dw 04404h,04444h
 dw 01111h,01111h
 dw 04404h,04444h
 dw 01111h,01111h
 dw 04404h,04444h
 dw 01111h,01111h
 dw 04404h,04444h
 dw 01111h,01111h
 dw 04404h,04444h
 dw 01111h,01111h
 dw 00000h,00000h
 ENDIF ;TwoD

;-----

code ends

;...e

 end

###########################################################################
############################### END OF FILE ###############################
###########################################################################
