;IBM HERO. Contants required by Interpreter.

;COMMON.ASM

;Copyright (C) 1987,1988,1989 Level 9 Computing

;-----

;Gamedata segment contains:
;  0,1      IP for return to acode
;  2,3      Acode INT segment
;  4,5      Table 0. Address of start
;  6,7      Table 0. Segment paragraph
;  8-35     addresses of lists 1 thru 9
;  36-141   addresses of lists 10 thru 31
;  142      RET instruction
;  143      RETF instruction
;  144-2191 Vars and temp lists
;  2192+    Gamedata (includes acode and permanent tables)

PCListVector= 4
PCretf      = 142
PCvarsoffset= 144

;-----

workspacesize = 3700 ;2560 ;03000h ;Variables+temp lists
numvar equ 256

startsavearea equ PCvarsoffset
SizeRunTimeSystem equ PCvarsoffset+workspacesize

;Acode variables used to interface to machine-code subroutines.
V1=startsavearea+2
V2=startsavearea+4
V3=startsavearea+6
V4=startsavearea+8
V5=startsavearea+10
V6=startsavearea+12
V7=startsavearea+14

;-----

kbdbufsize = 64 ;Keyboard buffer during 'PRESS ANY KEY'

cpnrst = 13 ;Reset disk system
cpnof  = 15 ;Open File
cpncf  = 16 ;Close File
cpnrs  = 20 ;Read Sequential

;-----

