; TABLE DEFINITIONS
; Knight Orc
;
; 6/10/86 M.J.Austin
; Copyright (C) 1986 Level 9 Computing
;
; ST observations...
;
; You must start all DEFWs on EVEN boundaries.
; else *subsequent* code seems to be padded to make it even
; (according to the GENST listing, anyway)
; The EVEN directive will insert a padding byte if appropriate
;
 ORG 0
starttables
 dc.l LIST1-starttables ; MOVEABLE OBJECT START
 dc.l $8000 ; OBJECT CURRENT
 dc.l $8000+NUMOBJ ; HI OBJECT CURRENT
 dc.l LIST4-starttables ; scenery table
 dc.l NPCINITIAL-starttables ; npc initial and 'floor pointers'
 dc.l $8000+LIST23SIZE ; 6 - NPC current attributes, stack
 dc.l $8000+LIST236SIZE ; 7 - output buffer,scoretable
 dc.l list8-starttables ; 8 - assorted fixed system tables
 dc.l $8000+LIST23678SIZE ; 9 - input table,object table
 dc.l ENDTABLE-starttables
;---
; CONTAINER POSITONS
ON EQU 1
UNDER EQU 2
BEHIND EQU 3
CARRIED EQU 4
WORN EQU 5
riddenby EQU 6
PREPIN EQU 7
HANGINGFROM EQU 8 ; E.G. TREE
tiedupwith equ 9 ; e.g goat, other people
LIEON EQU 12
SITON EQU 13
fastenedto equ 14
holdingthelid equ 15 ; for strap/chest
;
; additions to high initial position
OBV EQU $80
ita equ 0
itan equ $10 ; starts with a vowel
singularsome equ $20 ; "some cheese is tasy"
he equ $30
she equ $40
pluralsome equ $50 ; "some ropes are strong"
you equ $60
;
NUMOBJ EQU 192
NUMHIOBJ EQU NUMOBJ ; NO. OF OBJECTS WITH A HIGH POSITION
minnpc equ 1
maxnpc equ 39
npctablesize EQU 640 ; (maxnpc+1)*16
npcstacksize equ 512

STACK EQU 50
OUTPUTBUFFER EQU 24
SCORETABLE EQU 98 ;length of score table
OBJTABLE EQU 16 ; number of objects which can be specified on one line
SCRATCH EQU 32 ; GENERAL PURPOSE WS LIST
;
;
LIST23SIZE EQU NUMOBJ+NUMHIOBJ
LIST236SIZE EQU LIST23SIZE+npctablesize+npcstacksize
LIST2367SIZE EQU LIST236SIZE+OUTPUTBUFFER+SCORETABLE
LIST23678SIZE EQU LIST2367SIZE+OBJTABLE
;
;---
LIST1
 dc.b 0,0               ; OBJECT 0
USER EQU 1
 dc.b 0+you,252		; 1 - USER (orc)
 dc.b he,46		; 2 - dragon
mouse equ 3
 dc.b ita,55		; 3 - mouse
 dc.b he+on,perch	; 4 - rainbird
troll equ 5
 dc.b she,238		; 5 - troll
grok equ 6
 dc.b he,5		; 6 - grok
oink equ 7
 dc.b he,4		; 7 - oink
brainz equ 8
 dc.b he,2		; 8 - brainz
 DC.B he,159		; 9 - druid
 dc.b he,31		; 10 - monk
 dc.b he,33		; 11 - vampire
jailor equ 12
 dc.b he,28		; 12 - jailor
 dc.b pluralsome,1	; 13 - humans who appear on balcony
 dc.b he,11		; 14 - custodian
 dc.b she,26		; 15 - valkyrie - starts in holding pen
 dc.b she,179		; 16 - brunhilde
 dc.b he,168		; 17 - sam
 dc.b he,152		; 18 - heathcliffe
 dc.b he,158		; 19 - herne
 dc.b he,235		; 20 - erik
 dc.b he,228		; 21 - prophet
 dc.b he,195		; 22 - wizard
 dc.b he,198		; 23 - john
 dc.b he,179		; 24 - liquidizer
 dc.b he,116		; 25 - thud
 dc.b she,117		; 26 - susan
 dc.b she,122		; 27 - amazon grace
 dc.b she,136		; 28 - lady of shallot
 dc.b she,194		; 29 - dame luck
;
; npc who can't talk...
 dc.b pluralsome,1		; 30 - ants - must start at locn 1
 dc.b ita,130		; 31 - frog
 dc.b ita,188		; 32 - ghost
 dc.b ita,1		; 33 - eye
 dc.b ita,1		; 34 - fireball
 dc.b ita,1		; 35 - 
 dc.b 0,1               ; 36 - 
 dc.b 0,1               ; 37
 dc.b 0,1               ; 38
 dc.b 0,1               ; 39
; weapons...
 dc.b carried,brainz	; 40 club
 dc.b 0,2	     	; 41 kitchen knife
 dc.b prepin,scabbard	; 42 dagger
 dc.b 0,0		; 43 sword (summoned by sword spell)
 dc.b 0,0		; 44
 dc.b 0,0               ; 45
 dc.b 0,0		; 46
 dc.b 0,0               ; 47
 dc.b 0,0               ; 48
 dc.b 0,0               ; 49
; randomly positioned treasure...
 dc.b 0,151              ;50 gold bar
 dc.b 0,160              ;51 silver coin
 dc.b 0,170              ;52 golden chalice
 dc.b 0,180              ;53 silver chain
 dc.b 0,191               ;54
 dc.b 0,120               ;55
 dc.b 0,130               ;56
 dc.b 0,140               ;57
 dc.b 0,205               ;58
 dc.b 0,210               ;59
 dc.b 0,220               ;60
 dc.b 0,235               ;61
 dc.b 0,0               ;62
 dc.b 0,0               ;63
 dc.b 0,0               ;64
 dc.b 0,0		;65 gold brick - starts in well bucket
 dc.b 0,0		;66 gold comb
 dc.b 0,0		;67 - no object
 dc.b 0,0		;68 gold leaf
 dc.b 0,0		;69 gold standard
 dc.b 0,252		;70 gold apple - in royal tree
 dc.b 0,0               ;71
 dc.b 0,0               ;72 - no object
 dc.b 0,0               ;73
 dc.b 0,0               ;74
 dc.b 0,0               ;75
 dc.b 0,0               ;76
 dc.b 0,0               ;77
 dc.b 0,0               ;78
 dc.b 0,0               ;79
 dc.b 0,0               ;80
 dc.b 0,0		;81
 dc.b 0,0		;82
 dc.b 0,0		;83
 dc.b 0,0		;84
 dc.b 0,0		;85
 dc.b 0,0		;86
 dc.b 0,0		;87
 dc.b 0,0		;88
 dc.b 0,0		;89
 dc.b 0,0		;90 cloak
 dc.b 0,0		;91
 dc.b 0,0		;92
 dc.b 0,0               ;93
 dc.b 0,0               ;94
helmet equ 95
 dc.b worn,oink		;95 - helmet
 dc.b 0,0               ;96 - gloves
 dc.b 0,0               ;97 - shield
 dc.b singularsome,29               ;98 - rusty armour
 dc.b 0,0		;99
ratpie equ 100
 dc.b on,tray		;100 - rat pie
tray equ 101
 dc.b 0,2		; 101 - tray
 dc.b 0,28		; 102 - ball and chain - starts jail room.
 dc.b 0,239		; 103 - driftwood
 dc.b 0,0 ;55		; 104 - glittering card
scabbard equ 105
 dc.b 0,29		; 105 - scabbard
 dc.b 0,24		; 106 - button in acid
 dc.b pluralsome,31		; 107 - scrolls
sack equ 108
 dc.b 0,2		; 108 - sack
 dc.b 0,21		; 109 - wallet
 dc.b 0,0		; 110 - ring
 dc.b 0,33		; 111 - half-coin
 dc.b 0,186		; 112 - garlic
bones equ 113
 dc.b pluralsome,49		; 113 - bones
map equ 114
 dc.b carried,grok	; 114 - map
 dc.b 0,27		; 115 - recruiter
 dc.b 0,0		; 116 - apple
 dc.b 0,186		; 117 - small marrow
 dc.b 0,0		; 118 - large marrow
 dc.b 0,46		; 119 - scale
 dc.b on,anthill	; 120 - amber
 dc.b 0,0		; 121 - pebble
note equ 122
 dc.b fastenedto,sheddoor ; 122 - note on shed door
rope equ 123
 dc.b 0,238		; 123 - rope on bridge
 dc.b 0,26		; 124 - door in heaven
 dc.b itan,10		; 125 - inspection hatch near end
 dc.b prepin,kiosk	; 126 - opening in kiosk
 dc.b itan,240		; 127 - inscription near start - glow spell
opendrawbridge equ 128
 dc.b 0,0		; 128 - open drawbridge
 dc.b 0,36		; 129 - tomb
 dc.b under,bed		; 130 - mouse hole
bed equ 131
 dc.b 0,52		; 131 - bed
 dc.b 0,0		; 132 - crack
 dc.b 0,0		; 133 - crevice
 dc.b worn,user		; 134 - visor
 dc.b 0,0		; 135 - battery compartment (not in part 2)
 dc.b 0,11		; 136 - fire sensor
 dc.b 0,46		; 137 - heap of loot
perch equ 138
 dc.b obv,159		; 138 - perch
plaque equ 139
 dc.b 0,131		; 139 - plaque
 dc.b 0,22		; 140 - wooden plaque
anthill equ 141
 dc.b itan,159		; 141 - ant hill
 dc.b 0,221		; 142 - gravestone
 dc.b prepin,142	; 143 - hole in gravestone
grate equ 144
 dc.b obv,54		; 144 - grate
 dc.b 0,186		; 145 - apple tree
kiosk equ 146
 dc.b 0,9		; 146 - kiosk
 dc.b 0,186		; 147 - statue
pedestal equ 148
 dc.b 0,159		; 148 - pedestal
 dc.b on,pedestal	; 149 - mysterious book

; invisible objects... (150..)
 dc.b singularsome,42		; 150 - faint writing in dark maze
sheddoor equ 151
 dc.b 0,32		; 151 - shed door
fire equ 152
 dc.b prepin,grate	; 152 - fire
 dc.b pluralsome,150		; 153 - ropes holding drawbridge
closeddrawbridge equ 154
 dc.b 0,150		; 154 - drawbridge itself
 dc.b pluralsome,238		; 155 - bolts
 dc.b ita,238		; 156 - troll door
 dc.b 0,10		; 157 - red line
; spells start in room 1 when not known by user
spellunknown equ 1
 dc.b 0,spellunknown	; 158 spell
 dc.b 0,spellunknown	; 159 spell
 dc.b 0,spellunknown	; 160 spell
 dc.b 0,spellunknown	; 161 spell
 dc.b 0,spellunknown	; 162 spell
 dc.b 0,spellunknown	; 163 spell
 dc.b 0,spellunknown	; 164 spell
 dc.b 0,spellunknown	; 165 spell
 dc.b 0,spellunknown	; 166 spell
 dc.b 0,spellunknown	; 167 spell
 dc.b 0,spellunknown	; 168 spell
 dc.b 0,spellunknown	; 169 spell
 dc.b 0,spellunknown	; 170 spell
 dc.b 0,spellunknown	; 171 spell
 dc.b 0,spellunknown	; 172 spell
 dc.b 0,spellunknown	; 173 spell
 dc.b 0,spellunknown	; 174 spell
 dc.b 0,spellunknown	; 175 spell
 dc.b 0,spellunknown	; 176 spell
 dc.b 0,spellunknown	; 177 spell
 dc.b 0,spellunknown	; 178 spell
 dc.b 0,spellunknown	; 179
 dc.b 0,240		; 180 orc lair entrance
 dc.b 0,131		; 181 mud
 dc.b 0,238		; 182 west bridge
house equ 183
 dc.b 0,187		; 183 house
 dc.b 0,159		; 184 clearing
 dc.b 0,221		; 185 graveyard
 dc.b 0,186		; 186 garden
 dc.b 0,0		; 187 
 dc.b 0,150		; 188 castle entrance
 dc.b 0,252		; 189 - gate
 dc.b 0,121		; 190 entrance-way
 dc.b 0,0		; 191 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 200 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 

;---
ENDOBJECTS
terraintable
LIST4
; table giving scenery types on grassy plain grid
m equ 112 ; minsynthroom
plain equ m+0
marsh equ m+1
forest equ m+2
river equ m+3
riverhousewest equ m+4
eastbank equ m+5
westbank equ m+6
roadew equ m+7
roadns equ m+8
junctionne equ m+9
junctionnw equ m+10
junctionse equ m+11
junctionsw equ m+12
mountaine equ m+13
mountainn equ m+14
housee equ m+15
houses equ m+16
housen equ m+17
castlew equ m+18
castles equ m+19

 dc.b 25,35,30,castlew,plain,marsh,marsh,marsh,plain,plain,plain,plain
 dc.b 28,24,31,castlew,plain,marsh,marsh,marsh,plain,plain,plain,plain
 dc.b 29,23,22,castlew,plain,marsh,marsh,marsh,plain,forest,forest,forest
 dc.b castles,roadns,castles,plain,westbank,river,eastbank,plain
  dc.b plain,forest,forest,forest
 dc.b plain,roadns,plain,plain,westbank,river,eastbank,plain
  dc.b plain,forest,forest,forest
 dc.b plain,junctionse,junctionnw,plain,westbank,river,eastbank
  dc.b plain,plain,plain,plain,plain
 dc.b 32,plain,roadns,53,52,riverhousewest,eastbank
  dc.b plain,plain,plain,plain,plain
 dc.b 33,plain,roadns,54,51,riverhousewest,eastbank
  dc.b plain,mountainn,mountainn,mountainn,mountainn
 dc.b 36,plain,roadns,49,50,riverhousewest,eastbank
  dc.b mountaine,40,41,42,46
 dc.b plain,plain,junctionse,junctionnw,westbank,river,eastbank
  dc.b mountaine,39,43,44,45
 dc.b plain,plain,plain,junctionse,roadew,river,roadew,mountaine
  dc.b 38,37,48,47
 dc.b plain,plain,plain,plain,westbank,21,eastbank,plain,5,4,3,2
;---
;
list8
 dc.w spelltable-list8,0,0,0 ; pointers to other list 8 contents

spelltable
 dc.w coldspell-list8
 dc.w deathspell-list8
 dc.w lightningspell-list8
 dc.w knivesspell-list8
 dc.w fireballspell-list8
 dc.w swordspell-list8
 dc.w slowspell-list8
 dc.w flyspell-list8
 dc.w jumpspell-list8
 dc.w teleportspell-list8
 dc.w glowspell-list8
 dc.w eyespell-list8
 dc.w locatespell-list8
 dc.w detectspell-list8
 dc.w empathyspell-list8
 dc.w curespell-list8
 dc.w exorcisespell-list8
 dc.w growspell-list8
 dc.w charismaspell-list8
 dc.w shieldspell-list8
 dc.w wizardspell-list8

coldspell
 dc.b 0
deathspell
 dc.b 0
lightningspell
 dc.b 0
knivesspell
 dc.b 0
fireballspell
 dc.b 0
swordspell
 dc.b 0
slowspell
 dc.b mouse,30
 dc.b 0
flyspell
 dc.b 0
jumpspell
 dc.b 0
teleportspell
 dc.b 0
glowspell
 dc.b 0
eyespell
 dc.b 0
locatespell
 dc.b 0
detectspell
 dc.b 0
empathyspell
 dc.b closeddrawbridge,31
 dc.b opendrawbridge,31
 dc.b house,32
 dc.b 0
curespell
 dc.b 0
exorcisespell
 dc.b 0
growspell
 dc.b 0
charismaspell
 dc.b 0
shieldspell
 dc.b 0
wizardspell
 dc.b 0
;---
 even ; absolutely essential!
NPCINITIAL
list5
; first we have a dummy entry for npc 0
; this is used as some pointers to the *other*
; things which are used in this list
; (the equivalent of this area in list6 is used for temp workspace)
;
 dc.w floorpointers-npcinitial
 dc.w racetracks-npcinitial
 dc.w reversaltable-npcinitial
 dc.b 0,0,0,0,0,0,0,0,0,0  ; remainder of dummy entry
;
; for each character, have the following info:
; initial enemy, 0 if none
; dodge (min 0, max 255)
; maximum damage done by it (approx 0..40 at present)
; initial hit points
; GREED (min 0, max 254)
; AGRESSION (min 0, max 254)
; timidity (min 0, max 254)
; obedience (0 to 254) (likelihood to obey orders or racetrack)
; (word): standard gold-singing group
; patience (no. of moves npc will wait between activations) 10
; try not to have too many npcs with same patience - 
; it causes bursts of activities which is BAD NEWS!
; dunno 11
; dunno 12
; dunno 13
; dunno 14
; dunno 15

; For greed agression, timidity, obediance, there
; is a special case - if one of the values is 255, then
; the npc will always choose that one, if it is possible
; This is particularly useful for slaves etc.
; Note that npcs will still respond to attacks etc. - 
; anything which sets the 'attention flag'

FRIENDLY EQU 0
; now the npc tables themselves...
defaultmale equ 3753 ; normal singing-of gold table
defaultfemale equ 3759
defaultanimal equ 3762
; npc 0 has dummy entry used as pointers above

 dc.b FRIENDLY,0,20,100,0,0,0,0         ; 1 USER
 dc.w defaultmale ; standard singing
 dc.b 0,0,0,0,0,0

 dc.b friendly,255,255,255,255,0,0,255      ; 2 dragon
 dc.w 3767
 dc.b 4,0,0,0,0,0

 dc.b friendly,255,80,200,0,80,40,200      ; 3 mouse (greed=0)
 dc.w 3772
 dc.b 4,0,0,0,0,0

 dc.b friendly,100,80,200,0,0,0,200     ; 4 rainbird (greed must=0)
 dc.w 2886
 dc.b 3,0,0,0,0,0

 dc.b friendly,100,30,200,200,0,150,200       ; 5 troll
 dc.w 3782
 dc.b 1,0,0,0,0,0

 dc.b friendly,200,255,50,40,10,10,50       ; 6 grok
 dc.w 2706 ; want some food messages
 dc.b 3,0,0,0,0,0

 dc.b friendly,50,30,200,55,50,0,180      ; 7 oink
 dc.w defaultmale ; standard si
 dc.b 4,0,0,0,0,0 ; must be less active than grok

 dc.b friendly,100,30,50,50,40,20,180      ; 8 brainz
 dc.w defaultmale ; standard si
 dc.b 16,0,0,0,0,0 ; can be totally passive

 dc.b friendly,150,20,200,30,0,20,254      ; 9 druid
 dc.w defaultmale ; standard s
 dc.b 6,0,0,0,0,0

 dc.b friendly,100,100,200,20,80,20,220      ; 10 
 dc.w defaultmale ; standard s
 dc.b 6,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100      ; 11 vampire
 dc.w defaultfemale ; standard s
 dc.b 7,0,0,0,0,0

 dc.b friendly,100,80,200,0,80,20,255      ; 12 
 dc.w defaultmale ; hermit gold-singing messages
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,20,80,0,255      ; 13 humans on balcony
 dc.w 2654 ; standard s
 dc.b 6,0,0,0,0,0

 dc.b friendly,250,250,240,0,0,0,255      ; 14 - custodian
 dc.w defaultmale ; standard singing-
 dc.b 3,0,0,0,0,0

; valkyrie must have zero timidity and zero agression
 dc.b friendly,255,40,250,0,50,0,255        ; 15 valkyrie
 dc.w defaultfemale ; standard singing-
 dc.b 2,0,0,0,0,0

 dc.b friendly,40,10,40,50,20,10,180      ; 16 
 dc.w defaultmale ; standard singing-
 dc.b 8,0,0,0,0,0

 dc.b friendly,100,1,10,0,0,20,180    ; 17 
 dc.w defaultmale ; standard singing-
 dc.b 2,0,0,0,0,0

 dc.b friendly,60,10,40,0,40,60,180        ; 18 
 dc.w defaultmale ; standard singing-
 dc.b 10,0,0,0,0,0

 dc.b friendly,0,40,200,100,60,0,180      ; 19 
 dc.w defaultmale ; standard singing-
 dc.b 16,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 20
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 21
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 22
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 23
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 24
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 25
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 26
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 27
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 28
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,180     ; 29
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,90,2,20,0,0,240,0          ; 30 ants
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0
;
 dc.b friendly,90,2,20,0,0,240,220          ; 31 frog
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0
;
 dc.b friendly,90,2,20,0,0,240,255          ; 32 ghost
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0
;
 dc.b user,0,0,100,0,0,0,255          ; 33 - eye
 dc.w 2984
 dc.b 4,0,0,0,0,0

 dc.b user,0,0,100,0,0,0,255          ; 34 - fireball
 dc.w 2989 ; gold-singing stuff
 dc.b 4,0,0,0,0,0


 dc.b friendly,0,2,200,0,0,0,0          ; 35 user's horse at start
 dc.w defaultanimal
 dc.b 16,0,0,0,0,0

 dc.b friendly,255,2,200,0,0,240,0          ; 36 -  huge knight
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0

 dc.b friendly,90,2,20,0,0,240,0          ; 37
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0

 dc.b friendly,90,2,20,0,0,240,0          ; 38
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0

 dc.b friendly,90,2,20,0,0,240,0          ; 39
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0
;---
floorpointers
; part of list5
; now 'floor pointers'
; there is one bye pair for each static room - the
; first byte gives the direction to go inwards
; and the second byte gives direction for going outwards
; (i.e. towards the synthesised grid)
;
; ** BIG WARNING **
; all shapes must be simply connected. i.e. given a pair of rooms,
; you must be able to trace a path between them using only the
; OUT paths of one OR the other.
; This is because of the way the follow and GO code works.
north equ 1
ne equ 2
east equ 3
se equ 5
south equ 4
sw equ 6
west equ 7
nw equ 8
up equ 9
down equ 10
verbin equ 11
out equ 12
cross equ 13
climb equ 14
jump equ 15

 dc.b 0 ; room 0 (not used)
 dc.b 0 ; room 1 (not used)
 dc.b down ; 2 - kitchen
 dc.b west ; 3 - landing
 dc.b south ; 4 - junction in mountain
 dc.b east ; 5 - hq
 dc.b west ; 6 - 
 dc.b south ; 7 - 
 dc.b 0 ; 8 - 
 dc.b east ; 9 - foyer
 dc.b east ; 10 - corridor
 dc.b north ; 11 - wide road
 dc.b sw ; 12 - west of turnstile
 dc.b se ; 13 - east of turnstile
 dc.b north ; 14 - glade in forest
 dc.b north ; 15 - 
 dc.b east ; 16 - 
 dc.b south ; 17 - 
 dc.b west ; 18 - 
 dc.b 0 ; 19 - 
 dc.b south ; 20 - 
 dc.b south ; 21 - 
 dc.b south ; 22 - office in castle
 dc.b north ; 23 - drawbridge
 dc.b north ; 24 - courtyard in castle
 dc.b east ; 25 - steps in castle
 dc.b south ; 26 ; heaven
 dc.b west ; 27 ; castle
 dc.b south ; 28 - dungeon
 dc.b south ; 29 - armoury
 dc.b west ; 30 - corridor
 dc.b south ; 31 - library
 dc.b east ; 32 - shed
 dc.b north ; 33 - barrow
 dc.b 0 ; 34
 dc.b north ; 35 - plain hall in castle
 dc.b north ; 36 - south graveyard
 dc.b west ; 37 - junction
 dc.b west ; 38 - juunction
 dc.b north ; 39 - maze
 dc.b north ; 40 - maze
 dc.b west ; 41 - maze
 dc.b west ; 42 - dark room
 dc.b north ; 43 - corridor
 dc.b west ; 44 - corridor
 dc.b west ; 45 - corridor
 dc.b north ; 46 - dragon room
 dc.b north ; 47 - dead end north of dragon
 dc.b 0 ; 48 - dark room (no exits)
 dc.b east ; 49 - secret room in house
 dc.b south ; 50 - bedroom
 dc.b down ; 51 - stairs
 dc.b north ; 52 - bedroom
 dc.b west ; 53 - porch
 dc.b south ; 54 - hall
 dc.b out ; 55 - mouse hole

;---
 even
racetracks
; sequences of commands which actors obey
; each is referred to by a 16-bit offset from the start of list5
; the initial sequences are contained in this table at the start..
 dc.w 0 ; 0
 dc.w 0 ; 1 - user
 dc.w dragonracetrack-list5 ; 2 dragon
 dc.w 0 ; 3 mouse
 dc.w rainbirdracetrack-list5 ; 4 rainbird
 dc.w 0 ; 5 troll
 dc.w grokracetrack-list5 ; 6 grok
 dc.w oinkracetrack-list5 ; 7 oink
 dc.w 0 ; 8 brainz
 dc.w druidracetrack-list5 ; 9 druid
 dc.w 0 ; 10 
 dc.w 0 ; 11 vampire
 dc.w 0 ; 12
 dc.w 0 ; 13
 dc.w custodianracetrack-list5 ; 14 - custodian
 dc.w 0 ; 15 valkyrie
 dc.w 0 ; 16
 dc.w 0 ; 17
 dc.w 0 ; 18
 dc.w 0 ; 19
 dc.w 0 ; 20
 dc.w 0 ; 21
 dc.w 0 ; 22
 dc.w 0 ; 23
 dc.w 0 ; 24
 dc.w 0 ; 25
 dc.w 0 ; 26
 dc.w 0 ; 27
 dc.w 0 ; 28
 dc.w 0 ; 29
 dc.w 0 ; 30
 dc.w frogracetrack-list5 ; 31 - frog
 dc.w ghostracetrack-list5 ; 32 - ghost
 dc.w 0 ; 33
 dc.w 0 ; 34
 dc.w 0 ; 35
 dc.w 0 ; 36
 dc.w 0 ; 37
 dc.w 0 ; 38
 dc.w 0 ; 39
 dc.w 0 ; 40
 dc.w 0 ; 41
 dc.w 0 ; 42
;
; each of the race track entries has a 4-byte entry:
; VERB PREP NOUN1 NOUN2
ipin equ 7
ipwith equ 16

attack equ 40
go equ 96 ;58 ; go to room noun1 (=setupgo)
wait equ 92
examine equ 100
take equ 105
give equ 111
eat equ 123
kill equ 93
waitforperson equ 89
waituntiltime equ 90
waitforperiod equ 91
put equ 108
returnobject equ 136
racetracksay equ 250
racetrackmessage equ 251
racetrackgosub equ 253
racetrackgoto equ 254
racetrackreturn equ 255
light equ 115
ride equ 135
people equ 237
everything equ 234
nullobject equ 255

; prepositions...
to equ 202
; note that:
;
; NOUN1 will always be searched for if not accessible
; to the verb (using the usual accessability rules)
;
; NOUN2 will normally be searched for using the same rules.
; There are situations where this is awkward - so if the
; preposition is WITH, then NOUN2 must be carried (or it will
; be searched for by the npc).
;
custodianracetrack
; must NOT try to return any fixed objects
; (but can examine them, of course)
 dc.b examine,0,plaque,nullobject
 dc.b examine,0,note,nullobject
 dc.b returnobject,0,note,nullobject
 dc.b go,0,54,nullobject
 dc.b light,0,nullobject,nullobject
 dc.b racetrackgoto,0
  dc.w custodianracetrack-list5
;---
grokracetrack
 dc.b go,0,5,nullobject ; go to headquarters cave
 dc.b wait,0,nullobject,nullobject
 dc.b examine,0,map,nullobject
 dc.b wait,0,nullobject,nullobject
 dc.b returnobject,0,map,nullobject
 dc.b racetrackgoto,0
  dc.w grokracetrack-list5
;---
oinkracetrack
 dc.b go,0,5,nullobject ; visit grok!
 dc.b go,0,42,nullobject ; visit dark room
 dc.b go,0,47,nullobject ; go to cupboard
 dc.b eat,0,ratpie,nullobject
 dc.b returnobject,0,helmet,nullobject
 dc.b racetrackgoto,0
  dc.w oinkracetrack-list5
;---
rainbirdracetrack
; executed at start of game, and when rainbird killed
 dc.b go,0,159,nullobject ; go to clearing
 dc.b racetrackreturn,0,nullobject,nullobject ; kill racetrack

;---
dragonracetrack
; executed at start of game, and when dragon killed
 dc.b go,0,46,nullobject ; go to clearing
 dc.b racetrackreturn,0,nullobject,nullobject ; kill racetrack
;---
druidracetrack
 dc.b go,0,170,nullobject ; go forest locn 1
 dc.b wait,0,nullobject,nullobject
 dc.b racetrackmessage,0
  dc.w 2789

 dc.b go,0,172,nullobject ; go forest locn 2
 dc.b wait,0,nullobject,nullobject
 dc.b racetrackmessage,0
  dc.w 2790

 dc.b go,0,159,nullobject ; go lake
 dc.b racetrackmessage,0
  dc.w 2791 ; touches water of lake
 dc.b wait,0,nullobject,nullobject
 dc.b racetrackgoto,0
  dc.w druidracetrack-list5
;---
frogracetrack
 dc.b go,0,142,nullobject
 dc.b racetrackmessage,0
  dc.w 2820 ; croaks

 dc.b go,0,132,nullobject
 dc.b racetrackmessage,0
  dc.w 2821 ; croaks

 dc.b go,0,118,nullobject
 dc.b racetrackmessage,0
  dc.w 2822 ; croaks

 dc.b racetrackgoto,0
  dc.w frogracetrack-list5
;---
ghostracetrack
 dc.b go,0,36,nullobject ; go grave

 dc.b go,0,50,nullobject ; go to bedroom

 dc.b racetrackmessage,0
  dc.w 2798 ; they go through a secret door
 dc.b go,0,49,nullobject

 dc.b returnobject,0,bones,nullobject
 dc.b examine,0,bones,nullobject
 dc.b racetrackgoto,0
  dc.w ghostracetrack-list5
;---
;dragonracetrack
; dc.b waitforperson,0,user,nullobject
; dc.b racetrackmessage,0
;  dc.w 2875 ; taunts message
; dc.b wait,0,nullobject,nullobject
;
; dc.b racetrackmessage,0
;  dc.w 2876 ; taunts message
; dc.b wait,0,nullobject,nullobject
;
; dc.b racetrackmessage,0
;  dc.w 2877 ; taunts message (kills anyone present)
; dc.b wait,0,nullobject,nullobject
;
; dc.b go,0,37,nullobject
; dc.b go,0,46,nullobject
; dc.b racetrackgoto,0
;  dc.w dragonracetrack-list5
;---
reversaltable
; part of list5
; gives reverse directions for directions
 dc.b 0,4,6,7,1,8,2,3,5 ; compass directions
 dc.b 10,9,12,11,13,14,15

ENDTABLE
;---
