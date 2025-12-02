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
 dc.l $8000+LIST23SIZE ; 6 - NPC current attributes, spell time,stack
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
singularsome equ $20 ; "some cheese is tasty"
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
 dc.b 0+you,13 ; 1 - USER (orc)
orchunter equ 2
 dc.b he,0		; 2 - mounted orc hunter
 dc.b he,3		; 3 - black knight
SAM EQU 2
 dc.b he,60		; 4 - sam
kris equ 5	
 dc.b she,67		; 5 - kris
thor equ 6
 dc.b he,70		; 6 - thor
 dc.b he,75		; 7 - the evil high priest
 dc.b he,80		; 8 - cleric
 DC.B he,8		; 9 - innkeeper - starts in pub
 dc.b he,40		; 10 - fergus
rapunzel equ 11
 dc.b she,25		; 11 - rapunzel
hermit equ 12
 dc.b he,6		; 12 - hermit
greenknight equ 13
 dc.b obv+he,lawnpos	; 13- green knight
 dc.b he,0		; 14 - knight in shining armour
 dc.b she,26		; 15 - valkyrie - starts in holding pen
 dc.b he,0		; 16 -
 dc.b he,fairgroundpos	; 17 - Denzyl
 dc.b he,85		; 18
 dc.b he,100		; 19
 dc.b he,110		; 20
 dc.b he,120		; 21
 dc.b he,130		; 22
 dc.b he,140		; 23
 dc.b he,150		; 24
 dc.b she,160		; 25
 dc.b she,170		; 26
 dc.b she,180		; 27
 dc.b she,190		; 28
 dc.b she,200		; 29
;
; npc who can't talk...
goat equ 30
 dc.b 0,clearingpos	; 30 goat
 dc.b ita,gibbetpos	; 31 wight
ghost equ 32
 dc.b ita,gibbetpos	; 32 ghost
 dc.b ita+riddenby,orchunter ; 33 horse
greenknighthorse equ 34
 dc.b ita+riddenby,greenknight	; 34 green knight's horse
userhorse equ 35
 dc.b ita+riddenby,user	;35 - user's horse at start
 dc.b he,13              ;36 - huge knight at start
 dc.b 0,0               ;37
 dc.b 0,0               ;38
 dc.b 0,0               ;39
 dc.b carried,thor     ;40 sword
 dc.b carried,kris     ;41 dagger
 dc.b carried,sam       ;42 poignard
 dc.b 0,29		;43 bent knife
axe equ 44
 dc.b carried,greenknight ;44 axe
 dc.b carried,0               ;45 - lance used at start
spear equ 46
 dc.b under,bar         ;46 - spear
 dc.b 0,0               ;47
 dc.b 0,0               ;48
 dc.b 0,0               ;49
; randomly positioned treasure...
 dc.b 0,50              ;50 gold bar
 dc.b 0,60              ;51 silver coin
 dc.b 0,70              ;52 golden chalice
 dc.b 0,80              ;53 silver chain
 dc.b 0,90               ;54
 dc.b 0,100               ;55
 dc.b 0,110               ;56
 dc.b 0,120               ;57
 dc.b 0,130               ;58
 dc.b 0,140               ;59
 dc.b 0,150               ;60
 dc.b 0,160               ;61
 dc.b 0,0               ;62
 dc.b 0,0               ;63
 dc.b 0,0               ;64
 dc.b prepin,bucket		;65 gold brick - starts in well bucket
 dc.b 0,120		;66 gold comb
 dc.b carried,ghost	;67 gold ghost
goldleaf equ 68
 dc.b prepin,trophycabinet	;68 gold leaf
 dc.b prepin,chest	;69 gold standard
 dc.b 0,7		;70 gold apple - in royal tree
 dc.b 0,0               ;71
 dc.b 0,0               ;72
 dc.b 0,0               ;73
 dc.b 0,0               ;74
 dc.b 0,0               ;75
 dc.b 0,0               ;76
 dc.b 0,0               ;77
 dc.b fastenedto,user	;78 - rope at start
 dc.b 0,0               ;79
 dc.b 0,0               ;80
 dc.b 0,19              ;81 - well rope
 dc.b carried,orchunter ; 82 - lassoo
 dc.b worn,hermit       ;83 hermit's belt
 dc.b pluralsome+carried,greenknight	;84 reins
 dc.b fastenedto,gibbet          ;85 noose
halyard equ 86
 dc.b fastenedto,flagpole	;86 halyard
 dc.b holdingthelid,chest	;87 - strap
washingline equ 88
 dc.b 0,7               ; washing line
tether equ 89
 dc.b tiedupwith,goat	; tether
 dc.b 0,29		;90 cloak - in garbage heap
robes equ 91
 dc.b pluralsome+worn,hermit	; hermit's robes
 dc.b 0,0 ;hangingfrom,washingline ; 92 - green clothes
 dc.b 0,0               ;
 dc.b 0,0               ;
 dc.b 0,0               ;
 dc.b 0,0               ;
 dc.b 0,0               ;
 dc.b 0,0               ;
 dc.b 0,0               ;
 dc.b 0,10		; 100 -cask
 dc.b 0,0		; 101
 dc.b 0,0		; glass of beer
 dc.b itan,8		; empty glass
bucket equ 104
 dc.b 0,19		; bucket
mat equ 105
 dc.b 0,wellpos		; welcome mat
 dc.b fastenedto,drawbridge ; 106 - note
chest equ 107
 dc.b 0,2		; 107 - great chest
;; flag equ 108
 dc.b 0,0 ; >> fastenedto,halyard ; flag
 dc.b under,mat		; key
horsehead equ 110
 dc.b 0,0		;110 - horse's head
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		;
 dc.b 0,0		; 120
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 130
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 139 - EYES
 dc.b 0,0		; 140
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
bar equ 150
 dc.b 0,8		; 150 - bar
 dc.b 0,9		; 151 - bar
drawbridge equ 152
 dc.b 0,castlepos	; 152 - drawbridge
 dc.b itan,2		; 153 - ominous black door
 dc.b 0,wellpos		; 154 - well roller
 dc.b 0,15		; 155 - garbage heap
trophycabinet equ 156
 dc.b 0,6		; 156 trophy cabinet
flagpole equ 157
 dc.b 0,fairgroundpos	; 157 - flagpole
 dc.b obv+pluralsome,crossroadspos ; 158 two posts
 dc.b 0,0		; 
 dc.b 0,0		; 160
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 
 dc.b 0,0		; 170 eyes
 dc.b 0,25		; 171 hair
 dc.b 0,18		; 172 ring seen from viaduct
 dc.b on,castle		; 173 ivy
 dc.b 0,towerpos	; 174 thorn hedge
 dc.b 0,29		; 175 - garbage heap
 dc.b 0,18		; 176 - orc's head (rock!)
 dc.b 0,0		; 177
 dc.b 0,0		; 178
 dc.b 0,0		; 179
gibbetpos equ 230 ; 214
gibbet equ 180
 dc.b 0,gibbetpos	; 180 gibbet
castlepos equ 88 ; 38
castle equ 181
 dc.b 0,castlepos	; 181 castle
clearingpos equ 60
 dc.b 0,clearingpos	; 182 clearing
crossroadspos equ 200 ; 95
 dc.b 0,crossroadspos	; 183 crossroads
fairgroundpos equ 58 ; 56
 dc.b 0,fairgroundpos	; 184 fairground
lawnpos equ 70
 dc.b 0,lawnpos		; 185 lawn
cavepos equ 90 ; 80
 dc.b 0,cavepos		; 186 cave
oakpos equ 212 ; 85
 dc.b 0,oakpos		; 187 royal tree
towerpos equ  229 ; 90
 dc.b 0,towerpos	; 188 tower
viaductpos equ 40
 dc.b 0,viaductpos	; 189 viaduct
wellpos equ 215 ; 110
 dc.b 0,wellpos		; 190 well
 dc.b 0,viaductpos+2	; 191 Mount Olympus gate
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
; table giving scenery types for forest
alder equ 0*16
beech equ 1*16
blackthorn equ 2*16
cedar equ 3*16
elder equ 4*16
elm equ $50
hawthorn equ $60
hazel equ $70
holly equ $80
hornbeam equ $90
juniper equ $a0
larch equ $b0
oak equ $c0
pine equ $d0
rowan equ $e0
whitebeam equ $f0

clump equ 0
coppice equ 1
deadwoods equ 2
edgewoods equ 3
forest equ 4
ghostwood equ 5
glade equ 6
grove equ 7
heartwood equ 8
scrubland equ 9
spinney equ 10
tangle equ 11
thicket equ 12
underbrush equ 13
wildwood equ 14
woodland equ 15

 DC.B OAK+THICKET
 DC.B OAK+UNDERBRUSH
 DC.B OAK+WILDWOOD
 DC.B OAK+WOODLAND
 DC.B PINE+THICKET
 DC.B PINE+UNDERBRUSH
 DC.B PINE+WILDWOOD
 DC.B PINE+WOODLAND
 DC.B ROWAN+THICKET
 DC.B ROWAN+UNDERBRUSH
 DC.B ROWAN+WILDWOOD
 DC.B ROWAN+WOODLAND
 DC.B WHITEBEAM+THICKET
 DC.B WHITEBEAM+UNDERBRUSH
 DC.B WHITEBEAM+WILDWOOD
 DC.B WHITEBEAM+WOODLAND
 DC.B OAK+HEARTWOOD
 DC.B OAK+SCRUBLAND
 DC.B OAK+SPINNEY
 DC.B OAK+TANGLE
 DC.B PINE+HEARTWOOD
 DC.B PINE+SCRUBLAND
 DC.B PINE+SPINNEY
 DC.B PINE+TANGLE
 DC.B ROWAN+HEARTWOOD
 DC.B ROWAN+SCRUBLAND
 DC.B ROWAN+SPINNEY
 DC.B ROWAN+TANGLE
 DC.B WHITEBEAM+HEARTWOOD
 DC.B WHITEBEAM+SCRUBLAND
 DC.B WHITEBEAM+SPINNEY
 DC.B WHITEBEAM+TANGLE
 DC.B OAK+FOREST
 DC.B OAK+GHOSTWOOD
 DC.B OAK+GLADE
 DC.B OAK+GROVE
 DC.B PINE+FOREST
 DC.B PINE+GHOSTWOOD
 DC.B PINE+GLADE
 DC.B PINE+GROVE
 DC.B ROWAN+FOREST
 DC.B ROWAN+GHOSTWOOD
 DC.B ROWAN+GLADE
 DC.B ROWAN+GROVE
 DC.B WHITEBEAM+FOREST
 DC.B WHITEBEAM+GHOSTWOOD
 DC.B WHITEBEAM+GLADE
 DC.B WHITEBEAM+GROVE
 DC.B OAK+CLUMP
 DC.B OAK+COPPICE
 DC.B OAK+DEADWOODS
 DC.B OAK+EDGEWOODS
 DC.B PINE+CLUMP
 DC.B PINE+COPPICE
 DC.B PINE+DEADWOODS
 DC.B PINE+EDGEWOODS
 DC.B ROWAN+CLUMP
 DC.B ROWAN+COPPICE
 DC.B ROWAN+DEADWOODS
 DC.B ROWAN+EDGEWOODS
 DC.B WHITEBEAM+CLUMP
 DC.B WHITEBEAM+COPPICE
 DC.B WHITEBEAM+DEADWOODS
 DC.B WHITEBEAM+EDGEWOODS
 DC.B HOLLY+THICKET
 DC.B HOLLY+UNDERBRUSH
 DC.B HOLLY+WILDWOOD
 DC.B HOLLY+WOODLAND
 DC.B HORNBEAM+THICKET
 DC.B HORNBEAM+UNDERBRUSH
 DC.B HORNBEAM+WILDWOOD
 DC.B HORNBEAM+WOODLAND
 DC.B JUNIPER+THICKET
 DC.B JUNIPER+UNDERBRUSH
 DC.B JUNIPER+WILDWOOD
 DC.B JUNIPER+WOODLAND
 DC.B LARCH+THICKET
 DC.B LARCH+UNDERBRUSH
 DC.B LARCH+WILDWOOD
 DC.B LARCH+WOODLAND
 DC.B HOLLY+HEARTWOOD
 DC.B HOLLY+SCRUBLAND
 DC.B HOLLY+SPINNEY
 DC.B HOLLY+TANGLE
 DC.B HORNBEAM+HEARTWOOD
 DC.B HORNBEAM+SCRUBLAND
 DC.B HORNBEAM+SPINNEY
 DC.B HORNBEAM+TANGLE
 DC.B JUNIPER+HEARTWOOD
 DC.B JUNIPER+SCRUBLAND
 DC.B JUNIPER+SPINNEY
 DC.B JUNIPER+TANGLE
 DC.B LARCH+HEARTWOOD
 DC.B LARCH+SCRUBLAND
 DC.B LARCH+SPINNEY
 DC.B LARCH+TANGLE
 DC.B HOLLY+FOREST
 DC.B HOLLY+GHOSTWOOD
 DC.B HOLLY+GLADE
 DC.B HOLLY+GROVE
 DC.B HORNBEAM+FOREST
 DC.B HORNBEAM+GHOSTWOOD
 DC.B HORNBEAM+GLADE
 DC.B HORNBEAM+GROVE
 DC.B JUNIPER+FOREST
 DC.B JUNIPER+GHOSTWOOD
 DC.B JUNIPER+GLADE
 DC.B JUNIPER+GROVE
 DC.B LARCH+FOREST
 DC.B LARCH+GHOSTWOOD
 DC.B LARCH+GLADE
 DC.B LARCH+GROVE
 DC.B HOLLY+CLUMP
 DC.B HOLLY+COPPICE
 DC.B HOLLY+DEADWOODS
 DC.B HOLLY+EDGEWOODS
 DC.B HORNBEAM+CLUMP
 DC.B HORNBEAM+COPPICE
 DC.B HORNBEAM+DEADWOODS
 DC.B HORNBEAM+EDGEWOODS
 DC.B JUNIPER+CLUMP
 DC.B JUNIPER+COPPICE
 DC.B JUNIPER+DEADWOODS
 DC.B JUNIPER+EDGEWOODS
 DC.B LARCH+CLUMP
 DC.B LARCH+COPPICE
 DC.B LARCH+DEADWOODS
 DC.B LARCH+EDGEWOODS
 DC.B ELDER+THICKET
 DC.B ELDER+UNDERBRUSH
 DC.B ELDER+WILDWOOD
 DC.B ELDER+WOODLAND
 DC.B ELM+THICKET
 DC.B ELM+UNDERBRUSH
 DC.B ELM+WILDWOOD
 DC.B ELM+WOODLAND
 DC.B HAWTHORN+THICKET
 DC.B HAWTHORN+UNDERBRUSH
 DC.B HAWTHORN+WILDWOOD
 DC.B HAWTHORN+WOODLAND
 DC.B HAZEL+THICKET
 DC.B HAZEL+UNDERBRUSH
 DC.B HAZEL+WILDWOOD
 DC.B HAZEL+WOODLAND
 DC.B ELDER+HEARTWOOD
 DC.B ELDER+SCRUBLAND
 DC.B ELDER+SPINNEY
 DC.B ELDER+TANGLE
 DC.B ELM+HEARTWOOD
 DC.B ELM+SCRUBLAND
 DC.B ELM+SPINNEY
 DC.B ELM+TANGLE
 DC.B HAWTHORN+HEARTWOOD
 DC.B HAWTHORN+SCRUBLAND
 DC.B HAWTHORN+SPINNEY
 DC.B HAWTHORN+TANGLE
 DC.B HAZEL+HEARTWOOD
 DC.B HAZEL+SCRUBLAND
 DC.B HAZEL+SPINNEY
 DC.B HAZEL+TANGLE
 DC.B ELDER+FOREST
 DC.B ELDER+GHOSTWOOD
 DC.B ELDER+GLADE
 DC.B ELDER+GROVE
 DC.B ELM+FOREST
 DC.B ELM+GHOSTWOOD
 DC.B ELM+GLADE
 DC.B ELM+GROVE
 DC.B HAWTHORN+FOREST
 DC.B HAWTHORN+GHOSTWOOD
 DC.B HAWTHORN+GLADE
 DC.B HAWTHORN+GROVE
 DC.B HAZEL+FOREST
 DC.B HAZEL+GHOSTWOOD
 DC.B HAZEL+GLADE
 DC.B HAZEL+GROVE
 DC.B ELDER+CLUMP
 DC.B ELDER+COPPICE
 DC.B ELDER+DEADWOODS
 DC.B ELDER+EDGEWOODS
 DC.B ELM+CLUMP
 DC.B ELM+COPPICE
 DC.B ELM+DEADWOODS
 DC.B ELM+EDGEWOODS
 DC.B HAWTHORN+CLUMP
 DC.B HAWTHORN+COPPICE
 DC.B HAWTHORN+DEADWOODS
 DC.B HAWTHORN+EDGEWOODS
 DC.B HAZEL+CLUMP
 DC.B HAZEL+COPPICE
 DC.B HAZEL+DEADWOODS
 DC.B HAZEL+EDGEWOODS
 DC.B ALDER+THICKET
 DC.B ALDER+UNDERBRUSH
 DC.B ALDER+WILDWOOD
 DC.B ALDER+WOODLAND
 DC.B BEECH+THICKET
 DC.B BEECH+UNDERBRUSH
 DC.B BEECH+WILDWOOD
 DC.B BEECH+WOODLAND
 DC.B BLACKTHORN+THICKET
 DC.B BLACKTHORN+UNDERBRUSH
 DC.B BLACKTHORN+WILDWOOD
 DC.B BLACKTHORN+WOODLAND
 DC.B CEDAR+THICKET
 DC.B CEDAR+UNDERBRUSH
 DC.B CEDAR+WILDWOOD
 DC.B CEDAR+WOODLAND
 DC.B ALDER+HEARTWOOD
 DC.B ALDER+SCRUBLAND
 DC.B ALDER+SPINNEY
 DC.B ALDER+TANGLE
 DC.B BEECH+HEARTWOOD
 DC.B BEECH+SCRUBLAND
 DC.B BEECH+SPINNEY
 DC.B BEECH+TANGLE
 DC.B BLACKTHORN+HEARTWOOD
 DC.B BLACKTHORN+SCRUBLAND
 DC.B BLACKTHORN+SPINNEY
 DC.B BLACKTHORN+TANGLE
 DC.B CEDAR+HEARTWOOD
 DC.B CEDAR+SCRUBLAND
 DC.B CEDAR+SPINNEY
 DC.B CEDAR+TANGLE
 DC.B ALDER+FOREST
 DC.B ALDER+GHOSTWOOD
 DC.B ALDER+GLADE
 DC.B ALDER+GROVE
 DC.B BEECH+FOREST
 DC.B BEECH+GHOSTWOOD
 DC.B BEECH+GLADE
 DC.B BEECH+GROVE
 DC.B BLACKTHORN+FOREST
 DC.B BLACKTHORN+GHOSTWOOD
 DC.B BLACKTHORN+GLADE
 DC.B BLACKTHORN+GROVE
 DC.B CEDAR+FOREST
 DC.B CEDAR+GHOSTWOOD
 DC.B CEDAR+GLADE
 DC.B CEDAR+GROVE

;---
;
list8
 dc.w 0,0,0,0 ; pointers to other list 8 contents
;;
;;---
;; gives a table of verb/noun handlers
;;
;; The entries for each verb start with:
;;  Verb number.b
;;  Offset of next handler.b
;;  (low bound for match with noun1).b
;;  (high bound for match with noun1).b
;; There is then a set of noun/message/handler entries:-
;;   (low bound for match with noun2).b
;;   (high bound for match with noun2).b
;;   Message number.b
;;   code handler number.b
;; The end of the verb table is indicated by a zero
;; instead of a verb number
;nullobject equ 255
;anything equ 254
;matchwith equ 253
;;
;minweapon equ 40
;maxweapon equ 43
;; verb handler codes...
;handlenormally equ 0
;processed equ 1
;cancelinput equ 2
;SkipOnError equ 3
;
;hello
; dc.b 38,attack-hello,0,255
;  dc.b 0,255,7,processed ; hello there
;
;attack
; dc.b 40,attack2-attack,USER,USER ; attack with or without weapon
;  dc.b 0,255,1,processed ; don't attack yourself!
;
;attack2
;listen
; dc.b 41,search-listen,0,255
;  dc.b 0,255,3,processed ; don't hear anything interesting
;
;search
;; search object=examine object (handled in acode)
; dc.b 42,smell-search,nullobject,nullobject
;  dc.b nullobject,nullobject,4,processed ; find nothing special
;
;smell
; dc.b 44,smell2-smell,USER,USER
;  dc.b 0,255,6,processed ; you smell wonderful
;
;smell2
; dc.b 44,yes-smell2,0,255
;  dc.b 0,255,4,processed ; smell nothing interesting
;
;yes
; dc.b 55,no-yes,0,255
;  dc.b 0,255,10,processed ; you sound very positive
;
;no
; dc.b 56,weather-no,0,255
;  dc.b 0,255,9,processed ; you sound very negative
;
;weather
; dc.b 60,treasure-weather,0,255
;  dc.b 0,255,17,SkipOnError ; nice, isn't it
;
;treasure
; dc.b 61,want-treasure,0,255
;  dc.b 0,255,14,SkipOnError ; yes please!
;
;want
; dc.b 64,what-want,0,255
;  dc.b 0,255,18,SkipOnError
;
;what
; dc.b 65,whynot-what,0,255
;  dc.b 0,255,19,SkipOnError
;
;whynot
; dc.b 66,why-whynot,255,255
;  dc.b 0,255,8,processed
;
;why
; dc.b 66,where-why,0,255
;  dc.b 0,255,19,SkipOnError
;
;where
; dc.b 67,how-where,0,255
;  dc.b 0,255,19,SkipOnError
;
;how
; dc.b 68,whether-how,0,255
;  dc.b 0,255,19,SkipOnError
;
;whether
; dc.b 69,rudeword-whether,0,255
;  dc.b 0,255,19,SkipOnError
;
;rudeword
; dc.b 70,rude2-rudeword,minnpc,maxnpc
;  dc.b 0,255,24,cancelinput ; rudeword npc
;
;rude2
; dc.b 70,rudeend-rude2,0,255
;  dc.b 0,255,2,cancelinput
;
;rudeend
;intelligence
; dc.b 71,life-intelligence,0,255
;  dc.b 0,255,12,SkipOnError
;
;life
; dc.b 72,royalties-life,0,255
;  dc.b 0,255,13,SkipOnError
;
;royalties
; dc.b 74,to-royalties,0,255
;  dc.b 0,255,15,SkipOnError
;
;to
;; be or not to be
; dc.b 75,death-to,251,251
;  dc.b 0,255,16,SkipOnError
;
;death
; dc.b 76,goodbye-death,0,255
;  dc.b 0,255,20,SkipOnError
;
;goodbye
; dc.b 77,sorry-goodbye,0,255
;  dc.b 0,255,21,SkipOnError
;
;sorry
; dc.b 78,scream-sorry,0,255
;  dc.b 0,255,22,SkipOnError
;
;scream
; dc.b 79,cut-scream,0,255
;  dc.b 0,255,23,SkipOnError
;
;cut
;phew
; dc.b 85,phewend-phew,0,255
;  dc.b 0,255,11,skiponerror
;
;phewend
;dir
; dc.b 86,dirend-dir,0,255
;  dc.b 0,255,25,skiponerror
;
;dirend 
; dc.b 0 ; end of table

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

 dc.b FRIENDLY,80,20,100,0,0,0,0         ; 1 USER
 dc.w defaultmale ; standard singing
 dc.b 0,0,0,0,0,0

 dc.b friendly,50,80,200,20,255,0,255      ; 2 orchunter
 dc.w 3750
 dc.b 4,0,0,0,0,0

 dc.b user,100,255,200,0,255,0,0      ; 3 black knight
 dc.w defaultmale ; standard singing-
 dc.b 4,0,0,0,0,0

 dc.b friendly,100,80,150,150,80,20,100     ; 4 synonym
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,30,200,200,0,150,100       ; 5 kris
 dc.w defaultfemale ; standard singing-
 dc.b 3,0,0,0,0,0

 dc.b friendly,200,255,200,40,150,150,100       ; 6 thor
 dc.w defaultmale ; standard singing-
 dc.b 3,0,0,0,0,0

 dc.b friendly,50,30,200,255,0,0,220      ; 7 priest
 dc.w defaultmale ; standard si
 dc.b 2,0,0,0,0,0

 dc.b friendly,100,30,200,200,40,20,220      ; 8 cleric
 dc.w defaultmale ; standard si
 dc.b 4,0,0,0,0,0

 dc.b friendly,150,20,200,30,0,20,254      ; 9 innkeeper
 dc.w defaultmale ; standard s
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,100,200,20,80,20,220      ; 10 fergus
 dc.w defaultmale ; standard s
 dc.b 6,0,0,0,0,0

 dc.b friendly,100,80,200,0,0,0,0      ; 11 rapunzel
 dc.w defaultfemale ; standard s
 dc.b 7,0,0,0,0,0

 dc.b friendly,100,80,200,0,80,20,255      ; 12 hermit
 dc.w 3756 ; hermit gold-singing messages
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,20,80,0,255      ; 13 green knight
 dc.w defaultmale ; standard s
 dc.b 6,0,0,0,0,0

 dc.b friendly,100,80,240,200,80,20,0      ; 14 knight
 dc.w defaultmale ; standard singing-
 dc.b 7,0,0,0,0,0

; valkyrie must have zero timidity and zero agression
 dc.b friendly,255,40,250,0,50,0,255        ; 15 valkyrie
 dc.w defaultfemale ; standard singing-
 dc.b 2,0,0,0,0,0

 dc.b friendly,40,10,40,50,20,10,0      ; 16 
 dc.w defaultmale ; standard singing-
 dc.b 8,0,0,0,0,0

 dc.b friendly,100,1,10,0,0,20,255    ; 17 - Denzyl
 dc.w defaultmale ; standard singing-
 dc.b 1,0,0,0,0,0 ; denzyl is high-priority (at least for 68000 versions)

 dc.b friendly,60,10,40,0,40,60,0        ; 18 
 dc.w defaultmale ; standard singing-
 dc.b 10,0,0,0,0,0

 dc.b friendly,0,40,200,100,60,0,0      ; 19 
 dc.w defaultmale ; standard singing-
 dc.b 16,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 20
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 21
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 22
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 23
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 24
 dc.w defaultmale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 25
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 26
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 27
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 28
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,100,80,200,200,80,20,100     ; 29
 dc.w defaultfemale ; standard singing-
 dc.b 5,0,0,0,0,0

 dc.b friendly,90,2,20,0,0,240,0          ; 30 goat
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0
;
 dc.b friendly,90,2,20,0,0,240,0          ; 31 wight
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0
;
 dc.b friendly,90,2,20,0,0,240,0          ; 32 ghost
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0
;
 dc.b friendly,90,2,20,0,0,240,0          ; 33 horse
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0

 dc.b friendly,90,2,20,0,0,240,0          ; 34
 dc.w defaultanimal ; standard singing-
 dc.b 16,0,0,0,0,0


 dc.b friendly,0,2,200,0,0,240,0          ; 35 user's horse at start
 dc.w defaultanimal ; standard singing-
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
in equ 11
out equ 12
cross equ 13
climb equ 14
jump equ 15

 dc.b 0 ; room 0 (not used)
 dc.b 0 ; room 1 (not used)
 dc.b south ; 2 - courtyard
 dc.b south ; 3 - base of keep
 dc.b down ; 4 - staircase
 dc.b down ; 5 - keep roof
 dc.b out ; 6 - hermit's cave
 dc.b out ; 7 - royal oak
 dc.b west ; 8 - public bar
 dc.b west ; 9 - saloon bar
 dc.b up ; 10 - cellar
 dc.b 3 ; 11 - market
 dc.b 0 ; 12 - 
 dc.b 3 ; 13 - stable
 dc.b 1 ; 14 - jousting field
 dc.b 7 ; 15 - trampled field
 dc.b 1 ; 16 - grandstand
 dc.b 0 ; 17 - tower
 dc.b north ; 18 - viaduct
 dc.b up ; 19 - well
 dc.b south ; 20 - on drawbridge
 dc.b west ; 21 - east end of forest road
 dc.b south ; 22 - north end of forest road
 dc.b east ; 23 - west end of forest road
 dc.b 0 ; 24 - non-existent
 dc.b south ; 25 - base of tower
 dc.b north ; 26 ; lab
 dc.b west ; 27 ; cupboard in lab
 dc.b north ; 28 - Mt Olympus holding tank
 dc.b out ; 29 - garbage heap
;---
 even
racetracks
; sequences of commands which actors obey
; each is referred to by a 16-bit offset from the start of list5
; the initial sequences are contained in this table at the start..
 dc.w 0 ; player 0
 dc.w 0 ; 1 user
 dc.w 0 ; 2 orchunter
 dc.w 0 ; 3
 dc.w 0 ; 4 sam, lord of light
 dc.w 0 ; 5 kris
 dc.w 0 ; 6 thor
 dc.w 0 ; 7 priest
 dc.w 0 ; 8 cleric
 dc.w innkeepertrack-list5 ; 9 innkeeper
 dc.w 0 ; 10 fergus
 dc.w 0 ; 11 rapunzel
 dc.w 0 ; 12 hermit
 dc.w greenknightracetrack-list5 ; 13 green knight
 dc.w 0 ; 14 knight
 dc.w 0 ; 15 valkyrie
 dc.w 0 ; 16
 dc.w 0 ; 17 - Denzyl
 dc.w 0 ; 18
 dc.w 0 ; 19
 dc.w 0 ; 20 goat
 dc.w 0 ; 21 wight
 dc.w 0 ; 22 ghost
 dc.w 0 ; 23 horse
 dc.w 0 ; 24
 dc.w 0 ; 25
 dc.w 0 ; 26
 dc.w 0 ; 27
 dc.w 0 ; 28
 dc.w 0 ; 29
 dc.w 0 ; 30
 dc.w 0 ; 31
 dc.w 0 ; 32
 dc.w 0 ; 33
 dc.w 0 ; 34
 dc.w 0 ; 35
 dc.w 0 ; 36
 dc.w 0 ; 37
 dc.w 0 ; 38
 dc.w 0 ; 39
 dc.w gkrt2-list5 ; 40 - green knight pushing off dead horse
 dc.w hermitracetrack-list5 ; 41 used when you give something to hermit
 dc.w hermitstunnedtrack-list5 ; 42 used when hermit is stunned
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
cask equ 100
ride equ 135
people equ 237
everything equ 234
nullobject equ 255

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
innkeepertrack
 dc.b go,0,8,nullobject ; go public bar
 dc.b returnobject,0,spear,nullobject
 dc.b examine,0,spear,nullobject
 dc.b racetrackgosub,0
  dc.w servecustomers-list5 ; hums a little tune etc.
 dc.b go,0,9,nullobject ; go saloon bar
 dc.b racetrackgosub,0
  dc.w servecustomers-list5 ; hums a little tune etc.
 dc.b go,0,10,0 ; go cellar
 dc.b returnobject,0,cask,nullobject
 dc.b examine,0,cask,nullobject
 dc.b racetrackgoto,0
  dc.w innkeepertrack-list5

servecustomers
 dc.b racetrackmessage,0
  dc.w 3900 ; polishes the bar
 dc.b wait,0,nullobject,nullobject ; to allow him to serve customers
 dc.b racetrackreturn,0,0,0

greenknightracetrack
 dc.b go,0,lawnpos,nullobject
 dc.b waitforperson,0,user,nullobject

 dc.b returnobject,0,axe,nullobject
 dc.b racetrackmessage,0
  dc.w 2536 ; chalenges you

 dc.b wait,nullobject,nullobject,nullobject ; to allow user to attack
 dc.b wait,nullobject,nullobject,nullobject
 dc.b racetrackmessage,0
  dc.w 2537 ; what are you waiting for?
 dc.b wait,nullobject,nullobject,nullobject
gkkilluser
 dc.b attack,ipwith,user,axe ; kill people with axe - gets axe if necessary
 dc.b racetrackgoto,nullobject
  dc.w greenknightracetrack-list5

gkrt2
; green knight racetrack when you behead his horse
 dc.b racetrackmessage,0
  dc.w 2540

 dc.b wait,nullobject,nullobject,nullobject

 dc.b racetrackmessage,0
  dc.w 2541
 dc.b wait,nullobject,nullobject,nullobject

 dc.b racetrackmessage,0
  dc.w 2542 ; gets up

; dc.b returnobject,0,greenknighthorse,nullobject

 dc.b take,0,horsehead,nullobject

 dc.b racetrackmessage,0
  dc.w 2543 ; repairs horse + remounts
 dc.b ride,nullobject,greenknighthorse,nullobject

 dc.b examine,ipwith,axe,axe ; must be held because mentioned in noun2!

 dc.b go,0,lawnpos,nullobject

 dc.b racetrackgoto,0
  dc.w greenknightracetrack-list5 ; reset gk
;-
hermitracetrack
; racetrack for hermit putting stuff into trophy cabinet
 dc.b racetrackmessage,0
  dc.w 2548 ; hermit turns away

 dc.b put,ipin,everything,trophycabinet

 dc.b racetrackmessage,0
  dc.w 2549 ; hermit turns back

 dc.b racetrackreturn,0 ; finish up
  dc.w hermitracetrack-list5
;---
hermitstunnedtrack
 dc.b waitforperiod,0,5,nullobject
 dc.b racetrackmessage,0
  dc.w 2550 ; hermit wakes up
 dc.b returnobject,0,robes,nullobject
 dc.b returnobject,0,goldleaf,nullobject
 dc.b racetrackgoto,0
  dc.w hermitracetrack-list5
;---
reversaltable
; part of list5
; gives reverse directions for directions
 dc.b 0,4,6,7,1,8,2,3,5 ; compass directions
 dc.b 10,9,12,11,13,14,15
ENDTABLE
;---
     