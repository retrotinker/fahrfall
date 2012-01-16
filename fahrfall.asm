	nam	fahrfall
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

DATA	equ	$0300		Base address for random storage
LOAD	equ	$1c00		Actual load address for binary

STRUCT	equ	0		Dummy origin for declaring structures

SCNBASE	equ	$0400		Base address for screen memory
SCNSIZE	equ	$0c00		Size of screen memory
SCNEND	equ	SCNBASE+SCNSIZE	End of screen memory
SCNWIDT	equ	32		Width of screen in bytes
SCNLINS	equ	96		Height of screen in lines
SCNQRTR	equ	SCNWIDT*SCNLINS/4
SCNHALF	equ	SCNQRTR*2
SCN3QTR	equ	SCNHALF+SCNQRTR
SCNEIGT	equ	SCNWIDT*SCNLINS/8
SCN3EGT	equ	SCNQRTR+SCNEIGT
SCN5EGT	equ	SCNHALF+SCNEIGT
SCN7EGT	equ	SCN3QTR+SCNEIGT
SCNSIXH	equ	SCNWIDT*SCNLINS/6
SCN2SXH	equ	SCNSIXH*2
SCN4SXH	equ	SCNHALF+SCNSIXH
SCN5SXH	equ	SCNHALF+SCNSIXH*2

TIMVAL	equ	$0112		Extended BASIC's free-running time counter

SCORLEN	equ	6		Number of digits in score display

SCR6CIN	equ	6+1		Initial value for middle-inner scroll counter

FLAMLEN	equ	SCNWIDT-SCORLEN*2	Width of flames in bytes
FLAMHGT	equ	6			Height of flames in lines
FLAMSIZ	equ	FLAMHGT*SCNWIDT 	Size of flame/score area

FLMMSKI	equ	$40		Initial mask value for flame effect
FLMCNTI	equ	$03		Initial count value for flame effect
FLMCTRG	equ	$03		Range mask of flame count values
FLMCTMN	equ	$01		Minimum flame count value

BBLACK	equ	$80		Single byte color code for black
WBLACK	equ	$8080		Double byte color code for black

BYELOW	equ	$9f		Color code for two yellow pixels
BBLUE	equ	$af		Color code for two blue pixels
BRED	equ	$bf		Color code for two red pixels
BMGNTA	equ	$ef		Color code for two magenta pixels

BFLESH	equ	BYELOW		Color code for two "flesh"-colored pixels
BSHIRT	equ	BRED		Color code for two shirt-colored pixels
BPANTS	equ	BBLUE		Color code for two pants-colored pixels
BSHOES	equ	BMGNTA		Color code for two shoe-colored pixels

PXMSK01	equ	$f5		Mask for "01" pixel pattern
PXMSK10	equ	$fa		Mask for "10" pixel pattern
PXMSKXO	equ	$0f		XOR mask to reverse single-pixel patterns

BSCLRIN	equ	$b5		Initial value for bg-scroll effect

FRMCTIN	equ	$08		Initial value for frame count values

NUMPLTF	set	3

PLTFTOP	equ	SCNBASE-SCNWIDT	Top of highest platform animation section
PLTFRNG	equ	SCNSIZE/NUMPLTF	Size of each platform animation section

PLTBSIN	equ	SCNEND-SCNWIDT	Initial value for base of bottom platform
PLTFMCI	equ	$03		Default count value for platform movement

PLTFCTI	equ	$cfcf		Initial top row color pattern for platforms
PLTFCBI	equ	$cfcf		Initial bottom row color pattern for platforms

PLTDFLT	equ	$3c		Default substitue for "sweeper" platforms

PLYRHGT	equ	12*SCNWIDT	Player object height in terms of screen size

PLODDBT	equ	$80		Bit for switching even/odd player drawing

GMCOLBT	equ	$80		Bit for collision detection in game flags

	org	STRUCT		Platform info structure declarations
PLTBASE	rmb	2		Current base addresses for drawing platform
PLTDATA	rmb	1		Mask representing platform configuration
PLTCOLR	rmb	4		Color data for drawing platform
PLTSTSZ	equ	*

JOYLT	equ	$01
JOYRT	equ	$02
JOYUP	equ	$04
JOYDN	equ	$08
JOYBTN	equ	$10

JOYMOV	equ	JOYLT+JOYRT+JOYUP+JOYDN

	org	DATA

FRAMCNT	rmb	1		Rolling frame sequence counter

SCRTCOT	rmb	1		Color data for bg-scroll effect
SCRTCMO	rmb	1			"
SCRTCMI	rmb	1			"
SCRTCIN	rmb	1			"
SCRCCOT	rmb	1			"
SCRCCMO	rmb	1			"
SCRCCMI	rmb	1			"
SCRCCIN	rmb	1			"

SCR6CNT	rmb	1		Frame counter for "every 6th frame" scroll

CURSCOR	rmb	SCORLEN		Display storage for current score
HISCORE	rmb	SCORLEN		Display storage for high score

FLAMMSK	rmb	1		Current mask value for flame effect
FLAMCNT	rmb	1		Current count of frames until next flicker

LFSRDAT	rmb	2

PLTMCNT	rmb	1		Countdown until next platform movement
PLTNCLR	rmb	4		Color patterns for next platform
PLTFRMS	rmb	3*PLTSTSZ	Platform info data structures

PLREPOS	rmb	2		Player screen erase position
PLRDPOS	rmb	2		Player screen draw position

PLEFLGS	rmb	1		Flags for erasing player object
PLDFLGS	rmb	1		Flags for drawing player object

JOYFLGS	rmb	1		Flags representing joystick info

GAMFLGS	rmb	1		Flags representing game status

	org	LOAD

INIT	lda	#(DATA/256)	Set direct page register
	tfr	a,dp
	setdp	DATA/256	Tell the assembler about the direct page value

	clr	$ffc5		Select SG12 mode

	lda	#$08		Select orange text color set
	ora	$ff22
	sta	$ff22

	ldx	#SCNBASE	Clear screen
	ldd	#WBLACK

CLSLOOP	std	,x++
	cmpx	#SCNEND
	bne	CLSLOOP

	ldx	#HISCORE	Initialize high score
	lda	#(SCORLEN-1)
	ldb	#$30
INHSCLP	stb	a,x
	deca
	bne	INHSCLP
	stb	a,x

	ldx	#CURSCOR	Initialize current score
	lda	#(SCORLEN-1)
	ldb	#$70
INCSCLP	stb	a,x
	deca
	bne	INCSCLP
	stb	a,x

	lda	#SCR6CIN	Initialize middle-inner scroll counter
	sta	SCR6CNT

	lda	#FRMCTIN	Initialize frame sequence counter
	sta	FRAMCNT

	lda	#BSCLRIN	Seed the bg-scroll color data
	sta	SCRTCOT
	sta	SCRTCMO
	sta	SCRTCMI
	sta	SCRTCIN

	lda	#FLMMSKI	Seed the flame effect data
	sta	FLAMMSK
	lda	#FLMCNTI
	sta	FLAMCNT

*	ldd	TIMVAL		Seed the LFSR data
*	std	LFSRDAT

	ldd	#PLTBSIN	Initialize platform section base values
	std	PLTFRMS+PLTBASE
	subd	#PLTFRNG
	std	PLTFRMS+PLTSTSZ+PLTBASE
	subd	#PLTFRNG
	std	PLTFRMS+2*PLTSTSZ+PLTBASE

	lda	#PLTFMCI	Initialize platform movement counter
	sta	PLTMCNT

	ldd	#PLTFCTI	Initialize platform color values
	std	PLTFRMS+PLTCOLR
	std	PLTFRMS+PLTSTSZ+PLTCOLR
	std	PLTFRMS+2*PLTSTSZ+PLTCOLR
	std	PLTNCLR
	ldd	#PLTFCBI
	std	PLTFRMS+PLTCOLR+2
	std	PLTFRMS+PLTSTSZ+PLTCOLR+2
	std	PLTFRMS+2*PLTSTSZ+PLTCOLR+2
	std	PLTNCLR+2

	lda	LFSRDAT		Apply LFSR to platform data
	eora	LFSRDAT+1
	beq	PLTDFLI		Use default if zero
	cmpa	#$ff		Check for "sweepers"
	bne	PLTDINI
PLTDFLI	lda	#PLTDFLT	Substitute default platform data
PLTDINI	sta	PLTFRMS+PLTDATA
	clr	PLTFRMS+PLTSTSZ+PLTDATA
	clr	PLTFRMS+2*PLTSTSZ+PLTDATA

	clr	PLEFLGS		Clear player erase flags
	clr	PLDFLGS		Clear player draw flags

	clr	GAMFLGS		Clear game status info

	ldx	#$04cf		Dummy player location initialization
	stx	PLREPOS
	stx	PLRDPOS

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	jsr	>PLYERAS	Erase the player

	ldx	#(PLTFRMS+PLTBASE)
	jsr	>PLTERAS	Erase the first platform
	ldx	#(PLTFRMS+PLTSTSZ+PLTBASE)
	jsr	>PLTERAS	Erase the second platform
	ldx	#(PLTFRMS+2*PLTSTSZ+PLTBASE)
	jsr	>PLTERAS	Erase the third platform

	jsr	>SCRLPNT	Paint the bg-scrolls

	ldx	#(PLTFRMS+PLTBASE)
	jsr	>PLTDRAW	Draw the first platform
	ldx	#(PLTFRMS+PLTSTSZ+PLTBASE)
	jsr	>PLTDRAW	Draw the second platform
	ldx	#(PLTFRMS+2*PLTSTSZ+PLTBASE)
	jsr	>PLTDRAW	Draw the third platform

	jsr	>PLYDRAW	Draw the player

* Must get here before end of Vblank (~7840 cycles from VSYNC)
	clr	$ffd8		Lo-speed during display

* "Display active" work goes here

	ldx	#HISCORE	Draw the high score
	ldy	#SCNBASE
	lda	#SCORLEN
	jsr	>DRWSTR

	ldx	#CURSCOR	Draw the current score
	ldy	#(SCNBASE+SCNWIDT-SCORLEN)
	lda	#SCORLEN
	jsr	>DRWSTR

	jsr	>DRWFLMS	Draw the flames at the top center of the screen

	clr	JOYFLGS		Clear the old joystick flag values
	clrb
	lda	$ff00		Read from the PIA connected to the joystick buttons
	bita	#$02		Test for left joystick button press
	bne	JOYRDRL
	ldb	#JOYBTN

JOYRDRL	lda	#$34		Read the right/left axis of the left joystick
	sta	$ff01
	lda	#$3c
	sta	$ff03

	lda	#$65		Test for low value on axis
	sta	$ff20
	lda	$ff00
	bpl	JOYRDLT
	lda	#$98		Test for high value on axis
	sta	$ff20
	lda	$ff00
	bpl	JOYRDUD

JOYRDRT	orb	#JOYRT		Joystick points right
	bra	JOYRDUD

JOYRDLT	orb	#JOYLT		Joystick points left

JOYRDUD	lda	#$3c		Read the up/down axis of the left joystick
	sta	$ff01

	lda	#$65		Test for low value on axis
	sta	$ff20
	lda	$ff00
	bpl	JOYRDUP
	lda	#$98		Test for high value on axis
	sta	$ff20
	lda	$ff00
	bpl	JOYDONE

JOYRDDN	orb	#JOYDN		Joystick points down
	bra	JOYDONE

JOYRDUP	
*	orb	#JOYUP		Joystick points up

JOYDONE	stb	JOYFLGS
	jsr	KEYBDRD		Read the keyboard (?)

	* Compute score

CHKCOLS	jsr	COLDTCT		Check for player/platform collisions

PLTADV	dec	PLTMCNT		Countdown until next platform movement
	bne	MOVCOMP

	lda	#PLTFMCI	Reset platform movement counter
	sta	PLTMCNT

	ldd	PLTFRMS+PLTBASE	Decrement platform base values
	subd	#SCNWIDT
	std	PLTFRMS+PLTBASE
	subd	#PLTFRNG
	std	PLTFRMS+PLTSTSZ+PLTBASE
	subd	#PLTFRNG

	cmpd	#PLTFTOP	Check for top of platform movement
	bgt	PLTBSTO

	lda	PLTFRMS+PLTSTSZ+PLTDATA		Shift platform data values
	sta	PLTFRMS+2*PLTSTSZ+PLTDATA
	lda	PLTFRMS+PLTDATA
	sta	PLTFRMS+PLTSTSZ+PLTDATA
	lda	LFSRDAT				Apply LFSR to platform data
	eora	LFSRDAT+1
	beq	PLTDFLS				Use default if zero
	cmpa	#$ff				Check for "sweepers"
	bne	PLTDSTO
PLTDFLS	lda	#PLTDFLT	Substitute default platform data
PLTDSTO	sta	PLTFRMS+PLTDATA

	ldd	PLTFRMS+PLTSTSZ+PLTCOLR		Shift the color values too
	std	PLTFRMS+2*PLTSTSZ+PLTCOLR
	ldd	PLTFRMS+PLTSTSZ+PLTCOLR+2
	std	PLTFRMS+2*PLTSTSZ+PLTCOLR+2
	ldd	PLTFRMS+PLTCOLR
	std	PLTFRMS+PLTSTSZ+PLTCOLR
	ldd	PLTFRMS+PLTCOLR+2
	std	PLTFRMS+PLTSTSZ+PLTCOLR+2
	ldd	PLTNCLR
	std	PLTFRMS+PLTCOLR
	ldd	PLTNCLR+2
	std	PLTFRMS+PLTCOLR+2
	ldd	#PLTBSIN		Reset first platform base pointer
	std	PLTFRMS+PLTBASE
	ldd	#(PLTBSIN-PLTFRNG)	Reset second platform base pointer
	std	PLTFRMS+PLTSTSZ+PLTBASE
	ldd	#(PLTBSIN-2*PLTFRNG)	Reset third platform base pointer

	tst	GAMFLGS		Player/platform collision already?
	bmi	PLTBSTO		No need to check for a new one
	std	PLTFRMS+2*PLTSTSZ+PLTBASE	Replicate PLTBSTO action here...
	jsr	COLDTBP		Special check for new player/platform collision
	bra	PLTADVF				Jump over PLTBSTO here...

PLTBSTO	std	PLTFRMS+2*PLTSTSZ+PLTBASE

PLTADVF	tst	GAMFLGS		Player/platform collision?
	bpl	PLADVDN
	lda	#JOYUP		Advance the player with the platform
	ora	JOYFLGS
	sta	JOYFLGS

PLADVDN	jsr	COLDTCT		Platform moved, check for new collisions

MOVCOMP	
	tst	GAMFLGS
	bmi	MOVCMP2

	lda	#JOYDN
	ora	JOYFLGS
	sta	JOYFLGS
MOVCMP2

	lda	JOYFLGS		Compute movement
	bita	#JOYMOV
	beq	MOVSKIP

	tst	GAMFLGS		If on a platform, disable down movement
	bpl	MOVCMP1

	lda	#($ff-JOYDN)
	anda	JOYFLGS
	sta	JOYFLGS

MOVCMP1	ldx	PLRDPOS		Schedule a player erase at current position
	stx	PLREPOS
	ldb	PLDFLGS		Make sure correct erase routine is used
	stb	PLEFLGS

	bita	#JOYLT
	beq	MOVRT

	eorb	#PLODDBT	Switch odd/even draw flag status
	stb	PLDFLGS
	bmi	MOVLADJ		Always can move left from odd

	bra	MOVUP

MOVLADJ	tfr	x,d		Enforce limits on player horizontal position
	lda	JOYFLGS
	bitb	#$1f
	beq	MOVLSTP

	leax	-1,x
	bra	MOVUP

MOVLSTP	ldb	#($ff-PLODDBT)	Set even drawing status on left edge of screen
	andb	PLDFLGS
	stb	PLDFLGS
	bra	MOVUP

MOVRT	bita	#JOYRT
	beq	MOVUP

	eorb	#PLODDBT	Switch odd/even draw flag status
	stb	PLDFLGS
	bpl	MOVRADJ		Always can move right from even

	bra	MOVUP

MOVRADJ	tfr	x,d		Enforce limits on player horizontal position
	lda	JOYFLGS
	andb	#$1f
	cmpb	#$1d
	beq	MOVRSTP

	leax	1,x
	bra	MOVUP

MOVRSTP	ldb	#PLODDBT	Set odd drawing status on right edge of screen
	orb	PLDFLGS
	stb	PLDFLGS

MOVUP	bita	#JOYUP
	beq	MOVDN

	cmpx	#(SCNBASE+7*SCNWIDT)	Enforce limits on player vert. pos.
	lblt	GAMEOVR

	leax	-SCNWIDT,x

	bra	MOVFIN

MOVDN	bita	#JOYDN
	beq	MOVFIN

	cmpx	#(SCNEND-PLYRHGT)	Enforce limits on player vert. pos.
	lbge	GAMEOVR

	leax	SCNWIDT,x

MOVFIN	stx	PLRDPOS		Update player position

MOVSKIP	equ	*

LFSRBMP	jsr	LFSRADV		Advance the LFSR

	dec	FLAMCNT		Countdown until next flame flicker
	bne	FRMCBMP

	lda	#FLMMSKI	Cycle the flame effect data
	eora	FLAMMSK
	sta	FLAMMSK

	lda	LFSRDAT		Grab part of the LFSR value
	anda	#FLMCTRG	Limit the range of the values
	adda	#FLMCTMN	Enforce a minimum value
	sta	FLAMCNT

FRMCBMP	dec	FRAMCNT		Bump the frame counter
	bne	FRMCBDN
	lda	#FRMCTIN
	sta	FRAMCNT
FRMCBDN	equ	*

* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

* End of main game loop
VLOOP	jmp	VSYNC

*
* Draw the player
*	X,A,B get clobbered
*
PLYDRAW	ldx	PLRDPOS
	leax	3*SCNWIDT,x

	tst	PLDFLGS
	bmi	PDRWODD

PDRWEVN	lda	#BFLESH		Draw player on even pixel start
	anda	#PXMSK10
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	sta	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x

	lda	#BSHIRT
	tfr	a,b
	sta	-SCNWIDT+1,x
	std	,x
	anda	#PXMSK01
	sta	-SCNWIDT,x
	eora	#PXMSKXO
	tfr	a,b
	sta	2,x
	std	SCNWIDT,x
	sta	SCNWIDT+2,x
	sta	2*SCNWIDT+1,x

	leax	6*SCNWIDT,x

	lda	#BPANTS
	sta	-2*SCNWIDT+1,x
	anda	#PXMSK10
	sta	-3*SCNWIDT+1,x
	eora	#PXMSKXO
	tfr	a,b
	sta	-2*SCNWIDT,x
	std	-SCNWIDT,x
	std	,x
	std	SCNWIDT,x

	lda	#BSHOES
	sta	2*SCNWIDT,x
	anda	#PXMSK01
	sta	2*SCNWIDT+1,x
	eora	#PXMSKXO
	sta	2*SCNWIDT+2,x

	rts

PDRWODD	lda	#BFLESH		Draw player on odd pixel start
	anda	#PXMSK01
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	sta	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x

	lda	#BSHIRT
	tfr	a,b
	sta	-SCNWIDT+1,x
	std	1,x
	anda	#PXMSK10
	sta	-SCNWIDT+2,x
	eora	#PXMSKXO
	tfr	a,b
	sta	,x
	std	SCNWIDT,x
	sta	SCNWIDT+2,x
	sta	2*SCNWIDT+1,x

	leax	6*SCNWIDT,x

	lda	#BPANTS
	sta	-2*SCNWIDT+1,x
	anda	#PXMSK01
	sta	-3*SCNWIDT+1,x
	eora	#PXMSKXO
	tfr	a,b
	sta	-2*SCNWIDT+2,x
	std	-SCNWIDT+1,x
	std	1,x
	std	SCNWIDT+1,x

	lda	#BSHOES
	sta	2*SCNWIDT+2,x
	anda	#PXMSK01
	sta	2*SCNWIDT,x
	eora	#PXMSKXO
	sta	2*SCNWIDT+1,x

	rts

*
* Erase the player
*	X,A,B get clobbered
*
PLYERAS	ldx	PLREPOS
	beq	PLYERSX

	leax	3*SCNWIDT,x

	tst	PLEFLGS
	bmi	PERAODD

PERAEVN	ldd	#WBLACK		Erase player from even pixel start
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	std	-SCNWIDT,x
	std	,x
	sta	2,x
	std	SCNWIDT,x
	sta	SCNWIDT+2,x
	std	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x
	std	-2*SCNWIDT,x
	std	-SCNWIDT,x
	std	,x
	std	SCNWIDT,x
	std	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x

	clr	PLREPOS		Don't erase again until next move!
	clr	PLREPOS+1

	rts

PERAODD	ldd	#WBLACK		Erase player from odd pixel start
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	std	-SCNWIDT+1,x
	std	,x
	sta	2,x
	std	SCNWIDT,x
	sta	SCNWIDT+2,x
	std	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x
	std	-2*SCNWIDT+1,x
	std	-SCNWIDT+1,x
	std	1,x
	std	SCNWIDT+1,x
	std	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x

	clr	PLREPOS		Don't erase again until next move!
	clr	PLREPOS+1

PLYERSX	rts

*
* Draw the platforms
*	X points to the platform structure
*	X,Y,A,B get clobbered
*
PLTDRAW	lda	PLTDATA,x
	pshs	a
	ldd	PLTCOLR,x
	ldy	PLTCOLR+2,x
	leax	[PLTBASE,x]

PLTDRW0	lsl	,s
	bcc	PLTDRW1
	std	,x
	std	$02,x
	sty	$20,x
	sty	$22,x
PLTDRW1	lsl	,s
	bcc	PLTDRW2
	std	$04,x
	std	$06,x
	sty	$24,x
	sty	$26,x
PLTDRW2	lsl	,s
	bcc	PLTDRW3
	std	$08,x
	std	$0a,x
	sty	$28,x
	sty	$2a,x
PLTDRW3	lsl	,s
	bcc	PLTDRW4
	std	$0c,x
	std	$0e,x
	sty	$2c,x
	sty	$2e,x
PLTDRW4	lsl	,s
	bcc	PLTDRW5
	std	$10,x
	std	$12,x
	sty	$30,x
	sty	$32,x
PLTDRW5	lsl	,s
	bcc	PLTDRW6
	std	$14,x
	std	$16,x
	sty	$34,x
	sty	$36,x
PLTDRW6	lsl	,s
	bcc	PLTDRW7
	std	$18,x
	std	$1a,x
	sty	$38,x
	sty	$3a,x
PLTDRW7	lsl	,s
	bcc	PLTDRW8
	std	$1c,x
	std	$1e,x
	sty	$3c,x
	sty	$3e,x

PLTDRW8	leas	1,s
	rts

*
* Erase the platforms
*	X points to the platform structure
*	X,Y,A,B get clobbered
*
PLTERAS	lda	#PLTFMCI	Check for platform movement
	cmpa	PLTMCNT
	bne	PLTERAX		Skip erase if no movement

	lda	PLTDATA,x
	pshs	a
	leax	[PLTBASE,x]
	leax	(2*SCNWIDT),x
	ldd	#WBLACK

PLTERA0	lsl	,s
	bcc	PLTERA1
	std	,x
	std	$02,x
PLTERA1	lsl	,s
	bcc	PLTERA2
	std	$04,x
	std	$06,x
PLTERA2	lsl	,s
	bcc	PLTERA3
	std	$08,x
	std	$0a,x
PLTERA3	lsl	,s
	bcc	PLTERA4
	std	$0c,x
	std	$0e,x
PLTERA4	lsl	,s
	bcc	PLTERA5
	std	$10,x
	std	$12,x
PLTERA5	lsl	,s
	bcc	PLTERA6
	std	$14,x
	std	$16,x
PLTERA6	lsl	,s
	bcc	PLTERA7
	std	$18,x
	std	$1a,x
PLTERA7	lsl	,s
	bcc	PLTERA8
	std	$1c,x
	std	$1e,x

PLTERA8	leas	1,s

PLTERAX	rts

*
* Paint the bg-scroll effects
*	X,Y,A,B get clobbered
*
SCRLPNT	lda	FRAMCNT
	bita	#$01
	bne	SCROUT1

	lda	SCRTCOT		Retrieve last outer scroll top color data
	tfr     a,b		Advance the color data
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRTCOT		Store current outer scroll top color data
	ldx	#SCNBASE
	ldy	#(SCNBASE+SCNHALF)
	pshs	y

	bra	SCROTLP

SCROUT1	lda	SCRCCOT		Retrieve last outer scroll current color data
	tfr     a,b		Recreate B half of the color data
	subb    #$30
	orb     #$80
	eorb    #$0f
	ldx	#(SCNBASE+SCNHALF)
	ldy	#SCNEND
	pshs	y

SCROTLP	sta	0,x
	eora    #$0f
	sta	(SCNWIDT-1),x
	adda    #$30		Advance the color data
	ora     #$80
	leax	SCNWIDT,x
	cmpx	,s
	blt	SCROTLP
	leas	2,s
	sta	SCRCCOT

	lda	FRAMCNT		Compute the branch
	anda	#$03
	lsla
	ldy	#SCRMOBT
	jmp	a,y

SCRMOBT	bra	SCRMO0		Odd jump ordering due to init of down counter 
	bra	SCRMO3
	bra	SCRMO2
	bra	SCRMO1

SCRMO0	lda	SCRTCMO		Retrieve last outer-mid scroll top color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRTCMO		Store current outer-mid scroll top color data

	ldx	#SCNBASE		Paint 1st qtr...
	ldy	#(SCNBASE+SCNQRTR)
	pshs	y
	bra	SCRMOLP

SCRMO1	ldx	#(SCNBASE+SCNQRTR)	Paint 2nd qtr...
	ldy	#(SCNBASE+SCNHALF)
	bra	SCRMOCM

SCRMO2	ldx	#(SCNBASE+SCNHALF)	Paint 3rd qtr...
	ldy	#(SCNBASE+SCN3QTR)
	bra	SCRMOCM

SCRMO3	ldx	#(SCNBASE+SCN3QTR)	Paint 4th qtr...
	ldy	#SCNEND

SCRMOCM	ldb	SCRCCMO
	tfr     b,a		Recreate A half of the color data
	eora    #$0f
	pshs	y

SCRMOLP	std	3,x
	std	(SCNWIDT-5),x
	addb    #$30		Advance the color data
	orb     #$80
	tfr     b,a
	eorb    #$0f
	leax	SCNWIDT,x
	cmpx	,s
	blt	SCRMOLP
	leas	2,s
	stb	SCRCCMO

	lda	SCR6CNT		Bump this scroll's counter...
	deca
	bne	SCRMICB
	lda	#SCR6CIN	Reinit the counter
	sta	SCR6CNT
	deca

SCRMICB	sta	SCR6CNT
	lsla			Compute the branch
	ldy	#(SCRMIBT-2)	Offset for 1-based count values
	jmp	a,y

SCRMIBT	bra	SCRMI5
	bra	SCRMI4
	bra	SCRMI3
	bra	SCRMI2
	bra	SCRMI1
	bra	SCRMI0

SCRMI0	lda	SCRTCMI		Retrieve last inner-mid scroll top color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRTCMI		Store current inner-mid scroll top color data

	ldx	#SCNBASE		Paint 1st 6th...
	ldy	#(SCNBASE+SCNSIXH)
	pshs	y
	bra	SCRMILP

SCRMI1	ldx	#(SCNBASE+SCNSIXH)	Paint 2nd 6th...
	ldy	#(SCNBASE+SCN2SXH)
	bra	SCRMICM

SCRMI2	ldx	#(SCNBASE+SCN2SXH)	Paint 3rd 6th...
	ldy	#(SCNBASE+SCNHALF)
	bra	SCRMICM

SCRMI3	ldx	#(SCNBASE+SCNHALF)	Paint 4th 6th...
	ldy	#(SCNBASE+SCN4SXH)
	bra	SCRMICM

SCRMI4	ldx	#(SCNBASE+SCN4SXH)	Paint 5th 6th...
	ldy	#(SCNBASE+SCN5SXH)
	bra	SCRMICM

SCRMI5	ldx	#(SCNBASE+SCN5SXH)	Paint 6th 6th...
	ldy	#SCNEND

SCRMICM	lda	SCRCCMI
	tfr     a,b		Recreate B half of the color data
	eorb    #$0f
	pshs	y

SCRMILP	std	8,x
	sta	10,x
	stb	(SCNWIDT-11),x
	std	(SCNWIDT-10),x
	adda    #$30		Advance the color data
	ora     #$80
	tfr     a,b
	eora    #$0f
	leax	SCNWIDT,x
	cmpx	,s
	blt	SCRMILP
	leas	2,s
	sta	SCRCCMI

	lda	FRAMCNT		Compute the branch
	anda	#$07
	lsla
	ldy	#SCRINBT
	jmp	a,y

SCRINBT	bra	SCRIN0		Odd jump ordering due to init of down counter 
	bra	SCRIN7
	bra	SCRIN6
	bra	SCRIN5
	bra	SCRIN4
	bra	SCRIN3
	bra	SCRIN2
	bra	SCRIN1

SCRIN0	lda	SCRTCIN		Retrieve last inner scroll top color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRTCIN		Store current inner scroll top color data

	ldx	#SCNBASE		Paint 1st 8th...
	ldy	#(SCNBASE+SCNEIGT)
	pshs	y
	bra	SCRINLP

SCRIN1	ldx	#(SCNBASE+SCNEIGT)	Paint 2nd 8th...
	ldy	#(SCNBASE+SCNQRTR)
	bra	SCRINCM

SCRIN2	ldx	#(SCNBASE+SCNQRTR)	Paint 3rd 8th...
	ldy	#(SCNBASE+SCN3EGT)
	bra	SCRINCM

SCRIN3	ldx	#(SCNBASE+SCN3EGT)	Paint 4th 8th...
	ldy	#(SCNBASE+SCNHALF)
	bra	SCRINCM

SCRIN4	ldx	#(SCNBASE+SCNHALF)	Paint 5th 8th...
	ldy	#(SCNBASE+SCN5EGT)
	bra	SCRINCM

SCRIN5	ldx	#(SCNBASE+SCN5EGT)	Paint 6th 8th...
	ldy	#(SCNBASE+SCN3QTR)
	bra	SCRINCM

SCRIN6	ldx	#(SCNBASE+SCN3QTR)	Paint 7th 8th...
	ldy	#(SCNBASE+SCN7EGT)
	bra	SCRINCM

SCRIN7	ldx	#(SCNBASE+SCN7EGT)	Paint 8th 8th...
	ldy	#SCNEND

SCRINCM	lda	SCRCCIN
	tfr     a,b		Recreate B half of the color data
	eorb    #$0f
	pshs	y

SCRINLP	std	14,x
	std	(SCNWIDT-16),x
	adda    #$30	Advance the color data
	ora     #$80
	tfr     a,b
	eora    #$0f
	leax	SCNWIDT,x
	cmpx	,s
	blt	SCRINLP
	leas	2,s
	sta	SCRCCIN

	rts

*
* Advance the LFSR value
*	A,B get clobbered
*
* 	Wikipedia article on LFSR cites this polynomial for a maximal 16-bit LFSR:
*
*		x16 + x14 + x13 + x11 + 1
*
*	http://en.wikipedia.org/wiki/Linear_feedback_shift_register
*
LFSRADV	lda	LFSRDAT		Get MSB of LFSR data
	eora	#$04		Capture x11 of LFSR polynomial
	lsla
	lsla
	eora	LFSRDAT		Capture X13 of LFSR polynomial
	lsla
	eora	LFSRDAT		Capture X14 of LFSR polynomial
	lsla
	lsla
	eora	LFSRDAT		Capture X16 of LFSR polynomial
	lsla			Move result to Carry bit of CC
	ldd	LFSRDAT		Get all of LFSR data
	rolb			Shift through 16 bits of LFSR
	rola
	std	LFSRDAT		Store the result
	rts

*
* Implement a keyboard read routine here
*	-- Use JOYFLGS to record keyboard results
*	-- Be smart enough to handle the Dragon keyboard too?
*
KEYBDRD	rts

*
* Draw a normal text string on the SG12 display
* 	X points to the source
*	Y points to the dest
*	A holds the length of the string
*	B gets clobbered
*	Do not pass-in a zero length!
*
DRWSTR	ldb	,x
	stb	,y
	stb	SCNWIDT,y
	stb	2*SCNWIDT,y
	stb	3*SCNWIDT,y
	stb	4*SCNWIDT,y
	stb	5*SCNWIDT,y

	deca			More characters?
	beq	DRWSTRX
	leax	1,x
	leay	1,y
	bra	DRWSTR

DRWSTRX	rts

*
* Draw the flames in the top center of the screen
*	X,Y,A,B get clobbered
*
DRWFLMS	ldx	#(FLAMES-1)		A offset will always be >= 1
	ldy	#(SCNBASE+SCORLEN-1)
	lda	#FLAMHGT
	pshs	a
	lda	#FLAMLEN
DRWFMLP	ldb	a,x
	cmpb	#BYELOW
	beq	DRWSKOR
	orb	FLAMMSK
DRWSKOR	stb	a,y
	deca
	bne	DRWFMLP
	leax	FLAMLEN,x
	leay	SCNWIDT,y
	dec	,s
	beq	DRWFLMX
	lda	#FLAMLEN
	bra	DRWFMLP
DRWFLMX	leas	1,s
	rts

*
* Collision detection for new bottom platform
*	X,A,B get clobbered
*
*	This is a special collision detection entry point for the
*	case of a new bottom platform.
*
COLDTBP	ldd	PLRDPOS
	addd	#(PLYRHGT-SCNWIDT)
	andb	#$e0
	ldx	#PLTCMSK
	bra	COLDTP0

*
* Collision detection -- check for player/platform collisions
*	X,A,B get clobbered
*
*	Both COLDPOS and COLDNEG have rts instructions
*
*	Note: platform movement uses special entry point COLDTBP
*
COLDTCT	ldd	PLRDPOS
	addd	#PLYRHGT
	andb	#$e0
	ldx	#PLTCMSK

COLDTP2	cmpd	PLTFRMS+2*PLTSTSZ+PLTBASE
	bne	COLDTP1
	ldb	PLRDPOS+1
	andb	#$1f
	ldb	b,x
	bitb	PLTFRMS+2*PLTSTSZ+PLTDATA
	beq	COLDNEG

	bra	COLDPOS

COLDTP1	cmpd	PLTFRMS+PLTSTSZ+PLTBASE
	bne	COLDTP0
	ldb	PLRDPOS+1
	andb	#$1f
	ldb	b,x
	bitb	PLTFRMS+PLTSTSZ+PLTDATA
	beq	COLDNEG

	bra	COLDPOS

COLDTP0	cmpd	PLTFRMS+PLTBASE
	bne	COLDNEG
	ldb	PLRDPOS+1
	andb	#$1f
	ldb	b,x
	bitb	PLTFRMS+PLTDATA
	beq	COLDNEG

COLDPOS	lda	#GMCOLBT	Set collision flag
	ora	GAMFLGS
	sta	GAMFLGS
	rts

COLDNEG	lda	#$7f		Clear collision flag
	anda	GAMFLGS
	sta	GAMFLGS
	rts

*
* Game Over
*
GAMEOVR	jmp	INIT

FLAMES	fcb	$bf,$ff,$9f,$ff,$ff,$ff,$9f,$9f,$ff,$ff
	fcb	$ff,$ff,$9f,$9f,$ff,$ff,$ff,$9f,$ff,$bf
	fcb	$bf,$ff,$ff,$ff,$bf,$ff,$ff,$ff,$ff,$bf
	fcb	$bf,$ff,$ff,$ff,$ff,$bf,$ff,$ff,$ff,$bf
	fcb	$b5,$bf,$ff,$bf,$bf,$bf,$ff,$ff,$ba,$bf
	fcb	$bf,$b5,$ff,$bf,$bf,$b5,$ff,$ff,$bf,$ba
	fcb	$b0,$bf,$bf,$bf,$ba,$bf,$ba,$bf,$ba,$b5
	fcb	$ba,$b5,$bf,$b5,$bf,$b0,$bf,$bf,$bf,$b0
	fcb	$b0,$b5,$ba,$b5,$ba,$b5,$ba,$b5,$b0,$b5
	fcb	$ba,$b0,$ba,$b5,$ba,$b0,$ba,$b5,$ba,$b0
	fcb	$b0,$b5,$b0,$b5,$b0,$b5,$b0,$b5,$b0,$b0
	fcb	$ba,$b0,$ba,$b0,$ba,$b0,$ba,$b0,$ba,$b0

PLTCMSK fcb	$80,$80,$c0,$c0,$40,$40,$60,$60
	fcb	$20,$20,$30,$30,$10,$10,$18,$18
	fcb	$08,$08,$0c,$0c,$04,$04,$06,$06
	fcb	$02,$02,$03,$03,$01,$01,$01,$01

	end	INIT
