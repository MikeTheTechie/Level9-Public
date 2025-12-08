
* a sample GEM program supplied with DevpacST version 2

* Source code Copyright (C) 1988 HiSoft. All rights reserved.
* No part of this source may be reproduced, transmitted,
* transcribed, or stored in a retrieval system, or translated
* in any form or by any means without the prior written
* permission of HiSoft.

* HiSoft makes no representations or warranties with respect
* to the contents hereof and specifically disclaims any
* implied warranties or merchantability or fitness for any
* particular purpose.

* feel free to use any or all of the object code

* if you find any bugs in the GEMINC file, please tell us.
* we cannot guarantee that this program itself is free of bugs!!

* If you cannot assemble this exactly as supplied, tell us.
* If the object doesn't run after you have made any changes,
* please do not tell us, as you're on your own once you
* start messing with it!

* this is mainly to show the calling sequence for GEM
* from assembler - the program itself doesn't do much

* last changed:21.3.88

	opt x+				dump long labels for debugging

* the important include file
	bra	main			shouldn't execute it

	include	geminc.s

* the program proper
main	do_start			set up stack and memory
	bsr initvdipars			and the VDI arrays
	bsr initgempars			and the AES arrays
	gem APPL_INIT
	move.w d0,ap_id(a6)		store the application id

	gem	GRAF_HANDLE
	move.w	int_out(a6),d2		Desktop VDI handle

* start by opening a virtual workstation
	move.l #$00010001,d0
	move.l d0,intin(a6)		most parameters are 1
	move.l d0,intin+4(a6)
	move.l d0,intin+8(a6)
	move.l d0,intin+12(a6)
	move.l d0,intin+16(a6)
	move.w #2,intin+20(a6)		use the RC system
	clr.w	contrl+2(a6)
	move.w	#11,contrl+6(a6)
	move.w	d2,contrl+12(a6)
	vdi V_OPNVWK			open one
	move.w contrl+12(a6),d0		the handle
	move.w d0,ws_handle(a6)		save it

* set the mouse to an arrow
	clr.w int_in(a6)		arrow please
	clr.l addr_in(a6)
	gem GRAF_MOUSE

* we want to open a window, so find the size of the workstation
	clr.w int_in(a6)		the desktop handle
	move.w #4,int_in+2(a6)		work area wanted
	gem WIND_GET			get the size

* the type of the window
wtype	equ %000000101111		title, close, full, move, size

* the size lies in int_out(1..4), so calculate the window size
	move.w #1,int_in(a6)		work area wanted
	move.w #wtype,int_in+2(a6)	full feature window
	movem.w int_out+2(a6),d0-d3
	movem.w d0-d3,int_in+4(a6)	the size
	gem WIND_CALC

* now get its offsets
	move.w int_out+2(a6),xstart(a6)
	move.w int_out+4(a6),ystart(a6)
	move.w int_out+6(a6),xwidth(a6)
	move.w int_out+8(a6),ywidth(a6)

* and create the window
	move.w #wtype,int_in(a6)	full feature
	movem.w int_out+2(a6),d0-d3
	movem.w d0-d3,int_in+2(a6)	the size
	gem WIND_CREATE			create it
	move.w d0,w_handle(a6)		save the handle

* now set its title
	move.w d0,int_in(a6)
	move.w #2,int_in+2(a6)		title string
	lea windowname(pc),a0
	move.l a0,int_in+4(a6)		the address
	gem WIND_SET

* now actually show it by opening
	move.w w_handle(a6),int_in(a6)
	movem.w xstart(a6),d0-d3
	add.w #10,d0			x start
	add.w #10,d1			y start
	sub.w #20,d2			width
	sub.w #20,d3			height
	movem.w d0-d3,int_in+2(a6)	the size
	gem WIND_OPEN			open it
	bsr recalcwindow
	bsr setupmode

* the main loop of the application
* the only interesting events are messages
waitforevent
	lea messagebuf(a6),a0
	move.l a0,addr_in(a6)
	gem EVNT_MESAG			get the message
	lea messagebuf(a6),a0
	move.w (a0),d0			message type
	cmp.w #20,d0
	beq updateit			if Redraw
	cmp.w #22,d0
	beq quit			if Close button
	cmp.w #23,d0
	beq fullit			if Full button
	cmp.w #27,d0
	beq sizeit			if re-size required
	cmp.w #28,d0
	beq moveit			if window moved

* nothing I'm interested in so try again
	bra waitforevent

* move the window around the screen
moveit	move.w 6(a0),d0
	cmp.w w_handle(a6),d0
	bne waitforevent		if not my window then don't
changedwindow
	move.w d0,int_in(a6)
	move.w #5,int_in+2(a6)
	move.w 8(a0),int_in+4(a6)	new x pos
	move.w 10(a0),int_in+6(a6)	new y pos
	move.w 12(a0),d0
	cmp.w #40,d0
	bcc.s widok
	moveq #40,d0			cant be too narrow
widok	move.w d0,int_in+8(a6)		width
	move.w 14(a0),d0
	cmp.w #50,d0
	bcc.s hiteok
	moveq #50,d0			cant be too thin either
hiteok	move.w d0,int_in+10(a6)		height
	gem WIND_SET			move it
	movem.w xwidth(a6),d4-d5	old size
	bsr recalcwindow
	cmp.w xwidth(a6),d4
	bcs waitforevent
	cmp.w ywidth(a6),d5
	bcs waitforevent
	bne.s forceupdate
	cmp.w xwidth(a6),d4
	beq waitforevent		not if exactly the same
* if the new size is smaller in both dimensions than the old size
* then an update event will not be posted, so the re-draw will
* have to be done manually
forceupdate
	bsr drawwindow			draw it
	bra waitforevent		and carry on

* re-size the window
sizeit	move.w 6(a0),d0
	cmp.w w_handle(a6),d0
	bne waitforevent		if not my window
	bra.s changedwindow

* there's an update
updateit
	move.w 6(a0),d0
	cmp.w w_handle(a6),d0
	bne waitforevent		if not my window
* there are two ways of doing updates:
* (a) to support overlapping windows
* this takes a lot of code, and is very slow and tricky
* (b) to ignore the possibility of overlapping windows
* this takes little code and is easy
* Here method (b) is used! (method (a) is described in the
* window chapter of the DR GEM manual, and used in EdST)

* start by clipping the rectangle
	movem.w 8(a0),d0-d3		the rectangle
	add.w d0,d2
	add.w d1,d3
	movem.w d0-d3,ptsin(a6)
	move.w #2,contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	st intin(a6)			clipping on
	vdi VS_CLIP			clip it
	bsr drawwindow			draw the window
	bra waitforevent

* the full button has been clicked
* this puts up an alert box
fullit
	move.w #1,int_in(a6)		default=1st button
	lea myalert(pc),a0
	move.l a0,addr_in(a6)		the alert definition
	gem FORM_ALERT
	bra waitforevent

* to go away various things have to be tidied up
* starting with closing the window
quit	move.w w_handle(a6),int_in(a6)
	gem WIND_CLOSE			close it
	gem WIND_DELETE			and delete it
* then closing the virtual workstation
	clr.w contrl+2(a6)
	clr.w contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	vdi V_CLSVWK			close it
	gem APPL_EXIT			tell GEM I've finished
* now quit to the desktop
	clr.w -(a7)			status code
	move.w #$4c,-(a7)		P_TERM
	trap #1				and go away

* calculate the work area of the window
recalcwindow
	move.w w_handle(a6),int_in(a6)
	move.w #4,int_in+2(a6)		work area required
	gem WIND_GET
	movem.w int_out+2(a6),d0-d3
	movem.w d0-d3,xstart(a6)
	rts

* this draws the picture in the window
* which is an oval on top of a rectangle

* before drawing anywhere you have to hide the mouse
drawwindow
	clr.l contrl+2(a6)
	move.w ws_handle(a6),contrl+12(a6)
	vdi V_HIDE_C			hide the mouse
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w #2,intin(a6)		pattern please
	vdi VSF_INTERIOR
	move.w #2,contrl+2(a6)
	clr.w contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	movem.w xstart(a6),d0-d3
	add.w d0,d2
	subq.w #1,d2
	add.w d1,d3
	subq.w #1,d3
	movem.w d0-d3,ptsin(a6)		the rectangle
	vdi VR_RECFL			filled rectangle
* the oval has to be drawn in the user defined pattern
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w #4,intin(a6)
	vdi VSF_INTERIOR		set fill style
	move.w #2,contrl+2(a6)
	clr.w contrl+6(a6)
	move.w #5,contrl+10(a6)
	move.w ws_handle(a6),contrl+12(a6)
	movem.w xstart(a6),d0-d3
	asr.w #1,d2			half width
	asr.w #1,d3			half height
	add.w d2,d0			x centre
	add.w d3,d1			y centre
	movem.w d0-d3,ptsin(a6)
	vdi V_GDP			GDP ellipse
* we have finished drawing so get the mouse back
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	clr.w intin(a6)
	vdi V_SHOW_C			show the mouse
	rts

* this prepares the drawing mode etc
setupmode
	clr.w contrl+2(a6)
	move.w #16,contrl+6(a6)
	move.w ws_handle(a6),contrl+12(a6)
	move.w #%0000100101000000,intin(a6)
	move.w #%0000100101000000,intin+2(a6)
	move.w #%0000111101000000,intin+4(a6)
	move.w #%0000100101000000,intin+6(a6)
	move.w #%0000100101000000,intin+8(a6)
	move.w #%0000000000000000,intin+10(a6)
	move.w #%0110010011011100,intin+12(a6)
	move.w #%1000101010001000,intin+14(a6)
	move.w #%1100101011001000,intin+16(a6)
	move.w #%0010101010001000,intin+18(a6)
	move.w #%1100010010001000,intin+20(a6)
	clr.l intin+22(a6)
	clr.l intin+26(a6)
	clr.w intin+30(a6)
	vdi VSF_UDPAT			set user defined fill style
	clr.w contrl+2(a6)
	move.w #1,contrl+6(a6)
	move.w #1,intin(a6)
	vdi VSF_COLOR			use colour/color 1
	rts

* all C strings must end in a null
windowname dc.b ' An Example GEM Program by HiSoft ',0

myalert dc.b "[1][This is written in 68000|assembler using HiSoft's|"
	dc.b 'DevpacST development system][ OK ]',0

* global constants, referenced off A6

* these have to remain together
xstart	rs.w 1
ystart	rs.w 1
xwidth	rs.w 1
ywidth	rs.w 1

w_handle	rs.w 1
ws_handle	rs.w 1
ap_id		rs.w 1
messagebuf	rs.b 16

	rs.l	100			stack space
mystack	rs.w	1			(stacks go backwards)

datalength	rs.w 0			this is the total required

* data lies in the BSS section
	section	BSS

	ds.b	datalength

