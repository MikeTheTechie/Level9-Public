;IBM hero

;STRUCTS.ASM

;25/MAY/88

;------

;Structure is read by acode, hence is defined as the ST version:

Perm_Structure struc

Perm_StaticAnimation   dw 0 ;(0) When stationary (from current view)

Perm_Moving_HiLo       dw 0 ;when moving when moving north
                       dw 0 ;when moving  ne
                       dw 0 ;when moving e
                       dw 0 ;when moving se
                       dw 0 ;when moving s
                       dw 0 ;when moving sw
                       dw 0 ;when moving w
                       dw 0 ;(16) when moving nw

;FightAnimate
                       dw 0 ;change colour during hand-to-hand combat
;(this is the actual offset in bytes)

;ThrowAnimate
                       dw 256 ;(20) when launching/throwing

Perm_HitPoint_HiLo     dw 0

Perm_BlowStrength_HiLo dw 0 ;damage done

;TimeBetweenBlows
                       db 0 ;26
 
;MaxAnimation
                       db 0

Perm_Type              db 0 ;(28) 1 bit, defined by collision detect flags

;Speed
                       db 0 ;Speed of movement

;>NullMove
                       db 0 ;Number of null moves per real move

Perm_Flags             db 0 ;(31) which collisions are detected
Perm_Specials          db 0 ;(32) which collisions activate specials
Perm_Destroyed         db 0 ;(33) does THIS sprite explode on these collisions

Perm_Blocked           db 0 ;(34) blocked by these collisions

;Priority
                       db 0 ;(35) priority of sprite

Perm_Height            db 0 ;(36) offset of bottom row used in cd

Perm_HeadOverlap       db 0 ;(37) number of rows at top not in cd.
;38 bytes

Perm_Structure ends

;-----

;Bit assignments for use in type offset, and
;the various cd fields below
CDwithMissiles        equ 2
CDwithBG              equ 8

;-----

;TemporarySpriteData
 
Move_Structure struc

Move_InfoPtr        dw 0 ;0
                    dw 0 ;2

Move_Xspeed_HiLo    dw 0 ;4
Move_Yspeed_HiLo    dw 0 ;6

Move_Xpos_HiLo      dw 0 ;8
Move_Ypos_HiLo      dw 0 ;10

;Pointer to currently displayed bit pattern
Move_DataPtr        dw 0 ;12
                    dw 0 ;14

;Pointer to next entry in sprite table
Move_NextPtr        dw 0 ;16
                    dw 0 ;18

;Pointer to previous entry in sprite table
Move_LastPtr        dw 0 ;20
                    dw 0 ;22

;Sprite number/Child number etc. for expansion.
Move_Name_HiLo      dw 0 ;24

;Hit points remaining for the monster
Move_HitPoint_HiLo  dw 0 ;26

;number of hit points of damage done by blows
Move_BlowStrength   dw 0 ;28

;Move_TimeToNextBlow
                    db 0 ;30

Move_View           db 0 ;31

;Move_Stage
                    db 0 ;32

;Move_NullMovesMade
                    db 0 ;33

;Move_OnScreen
                    db 0 ;34

;Move_Distance
                    db 0 ;35

;When zero sprite self destructs
Move_LifeCtr        db 0 ;36
                    db 0 ;37

Move_Animation_HiLo dw 0 ;38 ;adds to view when sprite trying to unblock itself

                    dw 0   ;40 Wealth
Move_SourceWeapon   db 0   ;42
                    db 0   ;43 Magic
                    db 0   ;44 Cursed
                    db 0   ;45 SlowCounter
                    db 0   ;46 RunAway
                    db 0   ;47 Not used
;(48 bytes)

Move_Structure ends

;-------------------------------------------------------------------------------

