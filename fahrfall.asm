	nam	fahrfall
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

DATA	equ	$4000		Base address for random storage
LOAD	equ	$4100		Actual load address for binary

STRUCT	equ	0		Dummy origin for declaring structures

TIMVAL	equ	$0112		Extended BASIC's free-running time counter

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

FRMCTIN	equ	$08		Initial value for frame counter

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
PLFALBT	equ	$40		Bit indicating falling/standing player
PLMOVBT	equ	$20		Bit indicating moving/stationary player (L/R)

PLMVMSK	equ	PLMOVBT+PLFALBT	Mask for any current player movement

GMCOLFL	equ	$80		Bit for collision detection in game flags

SCORDLI	equ	$0f		Counter value for scoring delay

JOYLT	equ	$01		Joystick flag definitions
JOYRT	equ	$02
JOYUP	equ	$04
JOYDN	equ	$08
JOYBTN	equ	$10

JOYMSK	equ	JOYLT+JOYRT	Only allow these movements from the joystick

MOVLT	equ	JOYLT		Movement flag definitions
MOVRT	equ	JOYRT
MOVUP	equ	JOYUP
MOVDN	equ	JOYDN

PBTCNTI	equ	64

SQWVBIT	equ	$02

KBROWCC	equ	$08		Row to check for space/left/right keys on CoCo
KBROWDG	equ	$20		Row to check for space/left/right keys on Dragon

	org	STRUCT		Platform info structure declarations
PLTBASE	rmb	2		Current base addresses for drawing platform
PLTDATA	rmb	1		Mask representing platform configuration
PLTCOLR	rmb	4		Color data for drawing platform
PLTSTSZ	equ	*

	org	STRUCT		Hall Of Fame info structure declarations
HOFINIT	rmb	3		Hall Of Fame player initials
HOFSCOR	rmb	SCORLEN		Hall Of Fame score
HOFSTSZ	equ	*

HOFSIZE	set	5		Number of Hall Of Fame entries

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
MOVFLGS	rmb	1		Flags representing movement info

GAMFLGS	rmb	1		Flags representing game status

SCORDLY	rmb	1		Delay counter for scoring

PBUTCNT	rmb	1		Counter for flashing "press button"

PDDEABL	rmb	1		PIA data direction register enable value
PDDDABL	rmb	1		PIA data direction register disable value
PDDSEBL	rmb	1		PIA DDIR sound enable value
PDDSDBL	rmb	1		PIA DDIR sound disable value

SNDHDAT	rmb	1		PIA data value for sound output "high"
SNDLDAT	rmb	1		PIA data value for sound output "low"

KBRWDAT	rmb	1		Data to use when checking for key presses

INPREAD	rmb	2		Function pointer for reading input

HOFDATA	rmb	(HOFSIZE*HOFSTSZ)

	org	LOAD

INIT	equ	*		Basic one-time setup goes here!

	orcc	#$50		Disable IRQ and FIRQ -- seems reasonable!

	lda	#(DATA/256)	Set direct page register
	tfr	a,dp
	setdp	DATA/256	Tell the assembler about the direct page value

	clr	$ffc5		Select SG12 mode

	lda	#$08		Set PIA data value for orange text color set
	ora	$ff22
*	ora	#SQWVBIT	Set PIA data value for sound output "high"
*	sta	SNDHDAT		Store PIA data value for sound output "high"
	anda	#($ff-SQWVBIT)	Set PIA data value for sound output "low"
	sta	SNDHDAT		Actually, default to "high" same as "low" (sound off)
	sta	SNDLDAT		Store PIA data value for sound output "low"
	sta	$ff22

	lda	$ff23
	anda	#$fb
	sta	PDDEABL		Store PIA data direction register enable value
	sta	$ff23
	lda	#SQWVBIT
	ora	$ff22
	sta	PDDSEBL		Store PIA DDIR sound enable value
	sta	$ff22
	anda	#($ff-SQWVBIT)
	sta	PDDSDBL		Store PIA DDIR sound disable value
	lda	$ff23
	ora	#$04
	sta	PDDDABL		Store PIA data direction register disable value
	sta	$ff23

	ldx	#HISCORE	Initialize high score
	lda	#(SCORLEN-1)
	ldb	#$30
INHSCLP	stb	a,x
	deca
	bne	INHSCLP
	stb	a,x

	ldd	TIMVAL		Seed the LFSR data
	std	LFSRDAT

	ldx	#CURSCOR	Initialize current score
	lda	#(SCORLEN-1)
	ldb	#$70
INCSCLP	stb	a,x
	deca
	bne	INCSCLP
	stb	a,x

	ldx	#HOFDFLT	Initialize Hall Of Fame data
	ldy	#HOFDATA
	lda	#(HOFSIZE*HOFSTSZ)
INHOFLP	ldb	,x+
	stb	,y+
	deca
	bne	INHOFLP

RESTART	equ	*		New game starts here!

	lda	#FRMCTIN	Initialize frame sequence counter
	sta	FRAMCNT

	lda	#SCR6CIN	Initialize middle-inner scroll counter
	sta	SCR6CNT

	lda	#BSCLRIN	Seed the bg-scroll color data
	sta	SCRTCOT
	sta	SCRTCMO
	sta	SCRTCMI
	sta	SCRTCIN

	lda	#FLMMSKI	Seed the flame effect data
	sta	FLAMMSK
	lda	#FLMCNTI
	sta	FLAMCNT

	jsr	INTRO		Show intro/title screen

	ldx	#CURSCOR	Re-initialize current score
	lda	#(SCORLEN-1)
	ldb	#$70
RINSCLP	stb	a,x
	deca
	bne	RINSCLP
	stb	a,x

	jsr	ISTSCRN		Show the pre-game interstitial screen

	jsr	CLRSCRN		Clear the screen to black

	ldd	#PLTBSIN	Initialize platform section base values
	std	PLTFRMS+PLTBASE
	subd	#PLTFRNG
	std	PLTFRMS+PLTSTSZ+PLTBASE
	subd	#PLTFRNG
	std	PLTFRMS+2*PLTSTSZ+PLTBASE

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

	lda	#PLTFMCI	Initialize platform movement counter
	sta	PLTMCNT

	clr	PLEFLGS		Clear player erase flags
	clr	PLDFLGS		Clear player draw flags

	clr	GAMFLGS		Clear game status info

	ldx	#$04cf		Initialize starting player location
	stx	PLREPOS
	stx	PLRDPOS

	lda	#SCORDLI	Initialize scoring delay counter
	sta	SCORDLY

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	jsr	PLYERAS		Erase the player

	ldx	#(PLTFRMS+PLTBASE)
	jsr	PLTERAS		Erase the first platform
	ldx	#(PLTFRMS+PLTSTSZ+PLTBASE)
	jsr	PLTERAS		Erase the second platform
	ldx	#(PLTFRMS+2*PLTSTSZ+PLTBASE)
	jsr	PLTERAS		Erase the third platform

	jsr	SCRLPNT		Paint the bg-scrolls

	ldx	#(PLTFRMS+PLTBASE)
	jsr	PLTDRAW		Draw the first platform
	ldx	#(PLTFRMS+PLTSTSZ+PLTBASE)
	jsr	PLTDRAW		Draw the second platform
	ldx	#(PLTFRMS+2*PLTSTSZ+PLTBASE)
	jsr	PLTDRAW		Draw the third platform

	jsr	PLYDRAW		Draw the player

* Must get here before end of Vblank (~7840 cycles from VSYNC)
	clr	$ffd8		Lo-speed during display

* "Display active" work goes here

	ldx	#HISCORE	Draw the high score
	ldy	#SCNBASE
	lda	#SCORLEN
	jsr	DRWSTR

	ldx	#CURSCOR	Draw the current score
	ldy	#(SCNBASE+SCNWIDT-SCORLEN)
	lda	#SCORLEN
	jsr	DRWSTR

	jsr	DRWFLMS		Draw the flames at the top center of the screen

	jsr	[INPREAD]	Read player inputs, flags returned in B
	stb	JOYFLGS

	andb	#JOYMSK		Mask-off disallowed joystick movements
	stb	MOVFLGS		Store movement flags for later
	beq	SNDDSBL		No movement?  Then disable sound effects

	tst	GAMFLGS		Movement?  Check for platform collision
	bpl	SNDDSBL		If not moving on a platform, disable sound

	lda	#SQWVBIT	Enable sound effects
	ora	SNDHDAT
	sta	SNDHDAT

	bra	SCORCHK

SNDDSBL	lda	#($ff-SQWVBIT)	Disable sound effects
	anda	SNDHDAT
	sta	SNDHDAT

SCORCHK	jsr	CMPSCOR		Compute score

	jsr	COLDTCT		Check for player/platform collisions

	jsr	PLTADV		Advance the platforms

	jsr	MOVCOMP		Compute new player position, returned in X

	cmpx	#(SCNBASE+6*SCNWIDT)	Enforce limits on player vert. pos.
	lblt	GAMEOVR
	cmpx	#(SCNEND+SCNWIDT-PLYRHGT)
	lbge	GAMEOVR

	jsr	LFSRADV		Advance the LFSR

	jsr	FLMFLKR		Bump the flame flicker effect

	dec	FRAMCNT		Bump the frame counter
	bne	CHKUART
	lda	#FRMCTIN
	sta	FRAMCNT

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

	lda	PLDFLGS
	bita	#PLFALBT
	lbne	PDRWFAL
	bita	#PLMOVBT
	lbne	PDRWMOV

PDRWSTA	tst	PLDFLGS
	bmi	PDSTAOD

PDSTAEV	lda	#BFLESH		Draw player on even pixel start
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

PDSTAOD	lda	#BFLESH		Draw player on odd pixel start
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

PDRWMOV	tst	PLDFLGS
	bmi	PDMOVOD

PDMOVEV	lda	#BFLESH		Draw player on even pixel start
	anda	#PXMSK10
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	sta	SCNWIDT,x
	sta	2*SCNWIDT+2,x

	lda	#BSHIRT
	tfr	a,b
	std	-SCNWIDT,x
	std	,x
	anda	#PXMSK10
	tfr	a,b
	sta	2,x
	std	SCNWIDT+1,x
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
	sta	,x
	sta	SCNWIDT,x

	lda	#BSHOES
	sta	2*SCNWIDT,x
	anda	#PXMSK01
	sta	1,x
	eora	#PXMSKXO
	sta	2,x

	rts

PDMOVOD	lda	#BFLESH		Draw player on odd pixel start
	anda	#PXMSK01
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	sta	SCNWIDT+2,x
	sta	2*SCNWIDT,x

	lda	#BSHIRT
	tfr	a,b
	std	-SCNWIDT+1,x
	std	1,x
	anda	#PXMSK01
	tfr	a,b
	sta	,x
	std	SCNWIDT,x
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
	sta	2,x
	sta	SCNWIDT+2,x

	lda	#BSHOES
	sta	2*SCNWIDT+2,x
	anda	#PXMSK01
	sta	,x
	eora	#PXMSKXO
	sta	1,x

	rts

PDRWFAL	tst	PLDFLGS
	bmi	PDFALOD

PDFALEV	lda	#BFLESH		Draw player on even pixel start
	anda	#PXMSK10
	tfr	a,b
	std	-2*SCNWIDT,x
	sta	-2*SCNWIDT+2,x
	sta	-SCNWIDT+1,x

	lda	#BSHIRT
	tfr	a,b
	std	,x
	sta	SCNWIDT+1,x
	anda	#PXMSK01
	sta	SCNWIDT,x
	eora	#PXMSKXO
	tfr	a,b
	sta	-SCNWIDT,x
	sta	-SCNWIDT+2,x
	sta	2,x
	sta	2*SCNWIDT+1,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x

	lda	#BPANTS
	sta	-SCNWIDT+1,x
	anda	#PXMSK10
	sta	-2*SCNWIDT+1,x
	eora	#PXMSKXO
	tfr	a,b
	sta	-SCNWIDT,x
	std	,x
	std	SCNWIDT,x

	lda	#BSHOES
	sta	2*SCNWIDT,x
	anda	#PXMSK01
	sta	2*SCNWIDT+1,x
	eora	#PXMSKXO
	sta	2*SCNWIDT+2,x

	rts

PDFALOD	lda	#BFLESH		Draw player on odd pixel start
	anda	#PXMSK01
	tfr	a,b
	std	-2*SCNWIDT,x
	sta	-2*SCNWIDT+2,x
	sta	-SCNWIDT+1,x

	lda	#BSHIRT
	tfr	a,b
	std	1,x
	sta	SCNWIDT+1,x
	anda	#PXMSK10
	sta	SCNWIDT+2,x
	eora	#PXMSKXO
	tfr	a,b
	sta	-SCNWIDT,x
	sta	-SCNWIDT+2,x
	sta	,x
	sta	2*SCNWIDT+1,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x

	lda	#BPANTS
	sta	-SCNWIDT+1,x
	anda	#PXMSK01
	sta	-2*SCNWIDT+1,x
	eora	#PXMSKXO
	tfr	a,b
	sta	-SCNWIDT+2,x
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

	leax	3*SCNWIDT,x

	lda	PLEFLGS
	bita	#PLFALBT
	lbne	PERAFAL
	bita	#PLMOVBT
	bne	PERAMOV

PERASTA	tst	PLEFLGS
	bmi	PESTAOD

PESTAEV	ldd	#WBLACK		Erase player from even pixel start
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

	rts

PESTAOD	ldd	#WBLACK		Erase player from odd pixel start
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

	rts

PERAMOV	tst	PLEFLGS
	bmi	PEMOVOD

PEMOVEV	ldd	#WBLACK		Erase player from even pixel start
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	std	-SCNWIDT,x
	std	,x
	sta	2,x
	std	SCNWIDT,x
	sta	SCNWIDT+2,x
	std	2*SCNWIDT+1,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x
	std	-2*SCNWIDT,x
	std	-SCNWIDT,x
	std	,x
	sta	2,x
	sta	SCNWIDT,x
	sta	2*SCNWIDT,x

	rts

PEMOVOD	ldd	#WBLACK		Erase player from odd pixel start
	sta	-3*SCNWIDT+1,x
	sta	-2*SCNWIDT+1,x
	std	-SCNWIDT+1,x
	std	,x
	sta	2,x
	std	SCNWIDT,x
	sta	SCNWIDT+2,x
	std	2*SCNWIDT,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x
	std	-2*SCNWIDT+1,x
	std	-SCNWIDT+1,x
	std	,x
	sta	2,x
	sta	SCNWIDT+2,x
	sta	2*SCNWIDT+2,x

	rts

PERAFAL	tst	PLEFLGS
	bmi	PEFALOD

PEFALEV	ldd	#WBLACK		Erase player from even pixel start
	std	-2*SCNWIDT,x
	sta	-2*SCNWIDT+2,x
	std	-SCNWIDT,x
	sta	-SCNWIDT+2,x
	std	,x
	sta	2,x
	std	SCNWIDT,x
	sta	2*SCNWIDT+1,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x
	sta	-2*SCNWIDT+1,x
	std	-SCNWIDT,x
	std	,x
	std	SCNWIDT,x
	std	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x

	rts

PEFALOD	ldd	#WBLACK		Erase player from odd pixel start
	std	-2*SCNWIDT,x
	sta	-2*SCNWIDT+2,x
	std	-SCNWIDT,x
	sta	-SCNWIDT+2,x
	std	,x
	sta	2,x
	std	SCNWIDT+1,x
	sta	2*SCNWIDT+1,x
	sta	3*SCNWIDT+1,x

	leax	6*SCNWIDT,x
	sta	-2*SCNWIDT+1,x
	std	-SCNWIDT+1,x
	std	1,x
	std	SCNWIDT+1,x
	std	2*SCNWIDT,x
	sta	2*SCNWIDT+2,x

	rts


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

	lda	SNDHDAT		Bump the 30 Hz square wave generator
	sta	$ff22

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

SCROUT1	lda	SNDLDAT		Bump the 30 Hz square wave generator
	sta	$ff22

	lda	SCRCCOT		Retrieve last outer scroll current color data
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

	lda	SNDLDAT		Enable square wave sound output
	sta	$ff22
	lda	PDDEABL
	sta	$ff23
	lda	PDDSEBL
	sta	$ff22
	lda	PDDDABL
	sta	$ff23

	bra	SCRMOLP

SCRMO1	ldx	#(SCNBASE+SCNQRTR)	Paint 2nd qtr...
	ldy	#(SCNBASE+SCNHALF)
	bra	SCRMOCM

SCRMO2	ldx	#(SCNBASE+SCNHALF)	Paint 3rd qtr...
	ldy	#(SCNBASE+SCN3QTR)

	lda	SNDLDAT		Disable square wave sound output
	sta	$ff22
	lda	PDDEABL
	sta	$ff23
	lda	PDDSDBL
	sta	$ff22
	lda	PDDDABL
	sta	$ff23

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
* Advance the platforms
*	A,B get clobbered
*
PLTADV	dec	PLTMCNT		Countdown until next platform movement
	bne	PLTADVX

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
	bra	PLTFNSH				Jump over PLTBSTO here...

PLTBSTO	std	PLTFRMS+2*PLTSTSZ+PLTBASE

PLTFNSH	tst	GAMFLGS		Player/platform collision?
	bpl	PLTCLCK
	lda	#MOVUP		Advance the player with the platform
	ora	MOVFLGS
	sta	MOVFLGS

PLTCLCK	jsr	COLDTCT		Platform moved, check for new collisions

PLTADVX	rts

*
* Compute new player position
*	A,B get clobbered
*	X returns new player position
*
MOVCOMP	tst	GAMFLGS		Check for player/platform collision
	bmi	MOVCMP1

	lda	#MOVDN		Force downward move if not on platform
	ora	MOVFLGS
	sta	MOVFLGS

MOVCMP1	lda	MOVFLGS		Check for movement
	beq	MOVSKIP		Skip if movement flags are not set

	ldx	PLRDPOS		Schedule a player erase at current position
	stx	PLREPOS
	ldb	PLDFLGS		Make sure correct erase routine is used
	stb	PLEFLGS

	andb	#($ff-PLMVMSK)	Temporarily indicate that player is stationary
	stb	PLDFLGS	

	bita	#MOVLT
	beq	MOVRGHT

	eorb	#PLODDBT	Switch odd/even draw flag status
	orb	#PLMOVBT	Indicate player is moving l/r
	stb	PLDFLGS
	bmi	MOVLADJ		Always can move left from odd

	bra	MOVEUP

MOVLADJ	tfr	x,d		Enforce limits on player horizontal position
	lda	MOVFLGS
	bitb	#$1f
	beq	MOVLSTP

	leax	-1,x
	bra	MOVEUP

MOVLSTP	ldb	#PLODDBT	Reset odd drawing status on left edge of screen
	orb	PLDFLGS
	stb	PLDFLGS
	bra	MOVEUP

MOVRGHT	bita	#MOVRT
	beq	MOVEUP

	eorb	#PLODDBT	Switch odd/even draw flag status
	orb	#PLMOVBT	Indicate player is moving l/r
	stb	PLDFLGS
	bpl	MOVRADJ		Always can move right from even

	bra	MOVEUP

MOVRADJ	tfr	x,d		Enforce limits on player horizontal position
	lda	MOVFLGS
	andb	#$1f
	cmpb	#$1d
	beq	MOVRSTP

	leax	1,x
	bra	MOVEUP

MOVRSTP	ldb	#($ff-PLODDBT)	Reset even drawing status on right edge of screen
	andb	PLDFLGS
	stb	PLDFLGS

MOVEUP	bita	#MOVUP
	beq	MOVDOWN

	leax	-SCNWIDT,x
	bra	MOVCMPX

MOVDOWN	bita	#MOVDN
	beq	MOVCMPX

	leax	SCNWIDT,x

	ldb	#PLFALBT	Indicate that the player is falling
	orb	PLDFLGS
	stb	PLDFLGS

MOVCMPX	stx	PLRDPOS		Update player position
	rts

MOVSKIP	ldx	PLRDPOS		Reload current player draw position
	stx	PLREPOS
	ldb	PLDFLGS		Make sure correct erase routine is used
	stb	PLEFLGS

	ldb	#($ff-PLMVMSK)	Indicate that player is stationary
	andb	PLDFLGS
	stb	PLDFLGS

	rts

*
* Compute the score
*
CMPSCOR	dec	SCORDLY		Decrement score delay counter
	bne	CMPSCRX		Not expired, so exit
	lda	#SCORDLI
	sta	SCORDLY		Restore delay counter

	lda	#SCORLEN	Start from LSB end
	ldx	#(CURSCOR-1)	Point X at current score
CMPSLP1	ldb	a,x		Increment current digit
	incb
	cmpb	#$7a
	blt	CMPSCR1		Value less than encoding for "9", we are done
	ldb	#$70		Otherwise, reset to encoding for "0"
	stb	a,x
	deca
	bne	CMPSLP1		Then increment the next digit
CMPSCR1	stb	a,x		Store 

	clra			Start from MSB end
	ldy	#(HISCORE-1)	Point Y at high score
CMPSLP2	inca
	ldb	a,x		Load digit from current score
	andb	#$bf		Convert to format for high score
	cmpb	a,y		Compare this digit to same one in high score

	blt	CMPSCRX		If lesser, no high score update
	bgt	CMPSCR2		If higher, record new high score

	cmpa	#SCORLEN	Out of digits?
	blt	CMPSLP2		No, compare next set of digits

CMPSCR2	lda	#SCORLEN
CMPSLP3	ldb	a,x		Load current score digit
	andb	#$bf		Convert to format for high score
	stb	a,y		Store high score digit
	deca
	bne	CMPSLP3

CMPSCRX	rts

*
* Game Over
*
GAMEOVR	lda	SNDHDAT		Set the sound output
	sta	$ff22
	lda	PDDEABL		Enable square wave sound output
	sta	$ff23
	lda	PDDSEBL
	sta	$ff22
	lda	PDDDABL
	sta	$ff23

	tst	$ff00		Clear Hsync interrupt signal
	lda	#$0f		Setup line counter for game over sound effect
	ldb	#$5a
	pshs	a,b

GMOVRLP	lda	$ff01		Wait for Hsync
	bpl	GMOVRLP
	tst	$ff00

	jsr	LFSRADV		Advance the LFSR

	lda	LFSRDAT
	anda	#SQWVBIT
	ora	SNDLDAT
	sta	$ff22
	puls	a,b
	decb
	bne	GMOVCNT
	deca
	beq	GMOVOUT
GMOVCNT	pshs	a,b
	bne	GMOVRLP

GMOVOUT	lda	SNDLDAT		Clear the sound output
	sta	$ff22

	jmp	RESTART

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

COLDPOS	lda	#GMCOLFL	Set collision flag
	ora	GAMFLGS
	sta	GAMFLGS
	rts

COLDNEG	lda	#($ff-GMCOLFL)	Clear collision flag
	anda	GAMFLGS
	sta	GAMFLGS
	rts

*
* Intro screen loop is from here to ILOOP
*
INTRO	jsr	CLRSCRN		Clear the screen to black

	lda	#PBTCNTI	Initialize counter for "press button" message
	sta	PBUTCNT

ISYNC	lda	$ff03		Wait for Vsync
	bpl	ISYNC
	lda	$ff02

*	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here
	jsr	INTRPNT

* Must get here before end of Vblank (~7840 cycles from VSYNC)
*	clr	$ffd8		Lo-speed during display

	ldx	#HISCORE	Draw the high score
	ldy	#SCNBASE
	lda	#SCORLEN
	jsr	DRWSTR

	ldx	#CURSCOR	Draw the current score
	ldy	#(SCNBASE+SCNWIDT-SCORLEN)
	lda	#SCORLEN
	jsr	DRWSTR

	jsr	DRWFLMS		Draw the flames at the top center of the screen

	ldx	#CPYSTR1	Display the copyright info
	ldy	#(SCNBASE+60*SCNWIDT+5)
	lda	#CPYS1LN
	jsr	DRWSTR

	ldx	#CPYSTR2
	ldy	#(SCNBASE+66*SCNWIDT+9)
	lda	#CPYS2LN
	jsr	DRWSTR

	jsr	LFSRADV		Advance the LFSR

	jsr	PUSHBTN		Check for input
	bcs	INTREXT		Exit intro if carry set

	jsr	FLMFLKR		Bump the flame flicker effect

	dec	FRAMCNT		Bump the frame counter
	bne	CHKURT2
	lda	#FRMCTIN
	sta	FRAMCNT

* Check for user break (development only)
CHKURT2	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	ILOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

ILOOP	bra	ISYNC

INTREXT	rts

*
* Paint display data for introduction
*	Y points at output destination
*	A,B get clobbered
*
* INTPDT1 and INTPDT2 are alternate entry points for narrower data fields.
*
INTPDAT	anda	#$f0		Separate color info
	ldb	#$c0		Translate pixel mask info
	andb	5,s
	lsrb
	lsrb
	lsrb
	lsrb
	stb	4,s
	ora	4,s
	lsrb
	lsrb
	stb	4,s
	ora	4,s
	anda	6,s
	sta	,y		Store first byte

INTPDT1	anda	#$f0		Separate color info
	ldb	#$30		Translate pixel mask info
	andb	5,s
	lsrb
	lsrb
	stb	4,s
	ora	4,s
	lsrb
	lsrb
	stb	4,s
	ora	4,s
	anda	6,s
	sta	1,y		Store second byte

INTPDT2	anda	#$f0		Separate color info
	ldb	#$0c		Translate pixel mask info
	andb	5,s
	stb	4,s
	ora	4,s
	lsrb
	lsrb
	stb	4,s
	ora	4,s
	anda	6,s
	sta	2,y		Store third byte

	anda	#$f0		Separate color info
	ldb	#$03		Translate pixel mask info
	andb	5,s
	stb	4,s
	ora	4,s
	lslb
	lslb
	stb	4,s
	ora	4,s
	anda	6,s
	sta	3,y		Store fourth byte

	rts

*
* Paint the intro-scroll effects
*	X,Y,A,B get clobbered
*
INTRPNT	lda	FRAMCNT
	bita	#$01
	bne	INTOUT1

	lda	SCRTCOT		Retrieve last outer scroll top color data
	adda    #$30
	ora     #$80
	eora	#$0f
	sta	SCRTCOT		Store current outer scroll top color data
	ldx	#(SCNBASE+16*SCNWIDT)
	ldy	#(SCNBASE+32*SCNWIDT)
	pshs	y
	ldy	#INOTDAT

	bra	INTOTWK

INTOUT1	lda	SCRCCOT		Retrieve last outer scroll current color data
	ldx	#(SCNBASE+32*SCNWIDT)
	ldy	#(SCNBASE+48*SCNWIDT)
	pshs	y
	ldy	#(INOTDAT+16)

INTOTWK	leas	-3,s		Allocate extra stack space
	tfr	a,b
	orb	#$f0
	stb	2,s

INTOTLP	ldb	#$0f		XOR pixel data mask
	eorb	2,s
	stb	2,s

	ldb	,y+		Operate on data for first letter
	stb	1,s

	pshs	y
	leay	,x
	jsr	INTPDT2

	ldy	,s
	ldb	31,y		Operate on data for eighth letter
	stb	3,s

	leay	(SCNWIDT-6),x
	jsr	INTPDT2
	puls	y

	adda    #$30		Advance the color data
	ora     #$80
	leax	SCNWIDT,x
	cmpx	3,s
	blt	INTOTLP
	ldb	SCRTCOT
	andb	#$0f
	stb	2,s
	ora	2,s
	sta	SCRCCOT
	leas	5,s		Release all stack space

	lda	FRAMCNT		Compute the branch
	anda	#$03
	lsla
	ldy	#INTMOBT
	jmp	a,y

INTMOBT	bra	INTMO0		Odd jump ordering due to init of down counter 
	bra	INTMO3
	bra	INTMO2
	bra	INTMO1

INTMO0	lda	SCRTCMO		Retrieve last outer-mid scroll top color data
	adda    #$30
	ora     #$80
	eora	#$0f
	sta	SCRTCMO		Store current outer-mid scroll top color data

	ldx	#(SCNBASE+16*SCNWIDT)	Paint 1st qtr...
	ldy	#(SCNBASE+24*SCNWIDT)
	pshs	y
	ldy	#INMODAT

	bra	INTMOWK

INTMO1	ldx	#(SCNBASE+24*SCNWIDT)	Paint 2nd qtr...
	ldy	#(SCNBASE+32*SCNWIDT)
	pshs	y
	ldy	#(INMODAT+8)
	bra	INTMOCM

INTMO2	ldx	#(SCNBASE+32*SCNWIDT)	Paint 3rd qtr...
	ldy	#(SCNBASE+40*SCNWIDT)
	pshs	y
	ldy	#(INMODAT+16)
	bra	INTMOCM

INTMO3	ldx	#(SCNBASE+40*SCNWIDT)	Paint 4th qtr...
	ldy	#(SCNBASE+48*SCNWIDT)
	pshs	y
	ldy	#(INMODAT+24)

INTMOCM	lda	SCRCCMO

INTMOWK	leas	-3,s		Allocate extra stack space
	tfr	a,b
	orb	#$f0
	stb	2,s

INTMOLP	ldb	#$0f		XOR pixel data mask
	eorb	2,s
	stb	2,s

	ldb	,y+		Operate on data for second letter
	stb	1,s

	pshs	y
	leay	3,x
	jsr	INTPDT1

	ldy	,s
	ldb	31,y		Operate on data for seventh letter
	stb	3,s

	leay	(SCNWIDT-8),x
	jsr	INTPDT1
	puls	y

	adda    #$30		Advance the color data
	ora     #$80
	leax	SCNWIDT,x
	cmpx	3,s
	blt	INTMOLP
	ldb	SCRTCMO
	andb	#$0f
	stb	2,s
	ora	2,s
	sta	SCRCCMO
	leas	5,s		Release all stack space

	lda	SCR6CNT		Bump this scroll's counter...
	deca
	bne	INTMICB
	lda	#SCR6CIN	Reinit the counter
	sta	SCR6CNT
	deca

INTMICB	sta	SCR6CNT
	lsla			Compute the branch
	ldy	#(INTMIBT-2)	Offset for 1-based count values
	jmp	a,y

INTMIBT	bra	INTMI5
	bra	INTMI4
	bra	INTMI3
	bra	INTMI2
	bra	INTMI1
	bra	INTMI0

INTMI0	lda	SCRTCMI		Retrieve last inner-mid scroll top color data
	adda    #$30
	ora     #$80
	eora	#$0f
	sta	SCRTCMI		Store current inner-mid scroll top color data

	ldx	#(SCNBASE+16*SCNWIDT)	Paint 1st 6th...
	ldy	#(SCNBASE+20*SCNWIDT)
	pshs	y
	ldy	#INMIDAT

	bra	INTMIWK

INTMI1	ldx	#(SCNBASE+20*SCNWIDT)	Paint 2nd 6th...
	ldy	#(SCNBASE+26*SCNWIDT)
	pshs	y
	ldy	#(INMIDAT+4)
	bra	INTMICM

INTMI2	ldx	#(SCNBASE+26*SCNWIDT)	Paint 3rd 6th...
	ldy	#(SCNBASE+32*SCNWIDT)
	pshs	y
	ldy	#(INMIDAT+10)
	bra	INTMICM

INTMI3	ldx	#(SCNBASE+32*SCNWIDT)	Paint 4th 6th...
	ldy	#(SCNBASE+38*SCNWIDT)
	pshs	y
	ldy	#(INMIDAT+16)
	bra	INTMICM

INTMI4	ldx	#(SCNBASE+38*SCNWIDT)	Paint 5th 6th...
	ldy	#(SCNBASE+44*SCNWIDT)
	pshs	y
	ldy	#(INMIDAT+22)
	bra	INTMICM

INTMI5	ldx	#(SCNBASE+44*SCNWIDT)	Paint 6th 6th...
	ldy	#(SCNBASE+48*SCNWIDT)
	pshs	y
	ldy	#(INMIDAT+28)

INTMICM	lda	SCRCCMI

INTMIWK	leas	-3,s		Allocate extra stack space
	tfr	a,b
	orb	#$f0
	stb	2,s

INTMILP	ldb	#$0f		XOR pixel data mask
	eorb	2,s
	stb	2,s

	ldb	,y+		Operate on data for third letter
	stb	1,s

	pshs	y
	leay	7,x
	jsr	INTPDAT

	ldy	,s
	ldb	31,y		Operate on data for sixth letter
	stb	3,s

	leay	(SCNWIDT-11),x
	jsr	INTPDAT
	puls	y

	adda    #$30		Advance the color data
	ora     #$80
	leax	SCNWIDT,x
	cmpx	3,s
	blt	INTMILP
	ldb	SCRTCMI
	andb	#$0f
	stb	2,s
	ora	2,s
	sta	SCRCCMI
	leas	5,s		Release all stack space

	lda	FRAMCNT		Compute the branch
	anda	#$07
	lsla
	ldy	#INTINBT
	jmp	a,y

INTINBT	bra	INTIN0		Odd jump ordering due to init of down counter 
	bra	INTIN7
	bra	INTIN6
	bra	INTIN5
	bra	INTIN4
	bra	INTIN3
	bra	INTIN2
	bra	INTIN1

INTIN0	lda	SCRTCIN		Retrieve last inner scroll top color data
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRTCIN		Store current inner scroll top color data

	ldx	#(SCNBASE+16*SCNWIDT)	Paint 1st 8th...
	ldy	#(SCNBASE+20*SCNWIDT)
	pshs	y
	ldy	#ININDAT

	bra	INTINWK

INTIN1	ldx	#(SCNBASE+20*SCNWIDT)	Paint 2nd 8th...
	ldy	#(SCNBASE+24*SCNWIDT)
	pshs	y
	ldy	#(ININDAT+4)
	bra	INTINCM

INTIN2	ldx	#(SCNBASE+24*SCNWIDT)	Paint 3rd 8th...
	ldy	#(SCNBASE+28*SCNWIDT)
	pshs	y
	ldy	#(ININDAT+8)
	bra	INTINCM

INTIN3	ldx	#(SCNBASE+28*SCNWIDT)	Paint 4th 8th...
	ldy	#(SCNBASE+32*SCNWIDT)
	pshs	y
	ldy	#(ININDAT+12)
	bra	INTINCM

INTIN4	ldx	#(SCNBASE+32*SCNWIDT)	Paint 5th 8th...
	ldy	#(SCNBASE+36*SCNWIDT)
	pshs	y
	ldy	#(ININDAT+16)
	bra	INTINCM

INTIN5	ldx	#(SCNBASE+36*SCNWIDT)	Paint 6th 8th...
	ldy	#(SCNBASE+40*SCNWIDT)
	pshs	y
	ldy	#(ININDAT+20)
	bra	INTINCM

INTIN6	ldx	#(SCNBASE+40*SCNWIDT)	Paint 7th 8th...
	ldy	#(SCNBASE+44*SCNWIDT)
	pshs	y
	ldy	#(ININDAT+24)
	bra	INTINCM

INTIN7	ldx	#(SCNBASE+44*SCNWIDT)	Paint 8th 8th...
	ldy	#(SCNBASE+48*SCNWIDT)
	pshs	y
	ldy	#(ININDAT+28)

INTINCM	lda	SCRCCIN

INTINWK	leas	-3,s		Allocate extra stack space
	tfr	a,b
	orb	#$f0
	stb	2,s

INTINLP	ldb	#$0f		XOR pixel data mask
	eorb	2,s
	stb	2,s

	ldb	,y+		Operate on data for fourth letter
	stb	1,s

	pshs	y
	leay	12,x
	jsr	INTPDAT

	ldy	,s
	ldb	31,y		Operate on data for fifth letter
	stb	3,s

	leay	(SCNWIDT-15),x
	jsr	INTPDAT
	puls	y

	adda    #$30		Advance the color data
	ora     #$80
	leax	SCNWIDT,x
	cmpx	3,s
	blt	INTINLP
	ldb	SCRTCIN
	andb	#$0f
	stb	2,s
	ora	2,s
	sta	SCRCCIN
	leas	5,s		Release all stack space

	rts

*
* Interstitial screen is from here to ISTLOOP
*
ISTSCRN	jsr	CLRSCRN

	ldx	#HISCORE	Draw the high score
	ldy	#SCNBASE
	lda	#SCORLEN
	jsr	DRWSTR

	ldx	#CURSCOR	Draw the current score
	ldy	#(SCNBASE+SCNWIDT-SCORLEN)
	lda	#SCORLEN
	jsr	DRWSTR

	ldx	#ISTSTR1	Display the pre-game message
	ldy	#(SCNBASE+42*SCNWIDT+6)
	lda	#ISTS1LN
	jsr	DRWSTR

	ldx	#ISTSTR2
	ldy	#(SCNBASE+48*SCNWIDT+10)
	lda	#ISTS2LN
	jsr	DRWSTR

	lda	#$c0
	pshs	a

ISTSYNC	lda	$ff03		Wait for Vsync
	bpl	ISTSYNC
	lda	$ff02

	jsr	DRWFLMS		Draw the flames at the top center of the screen

	jsr	LFSRADV		Advance the LFSR

	jsr	FLMFLKR		Bump the flame flicker effect

	dec	,s
	beq	ISTEXIT

ISTLOOP	bra	ISTSYNC

ISTEXIT	leas	1,s
	rts

*
* "Hall Of Fame" screen is from here to HOFLOOP
*
HOFSCRN	jsr	CLRSCRN

	lda	#PBTCNTI	Initialize counter for "press button" message
	sta	PBUTCNT

	ldx	#HISCORE	Draw the high score
	ldy	#SCNBASE
	lda	#SCORLEN
	jsr	DRWSTR

	ldx	#CURSCOR	Draw the current score
	ldy	#(SCNBASE+SCNWIDT-SCORLEN)
	lda	#SCORLEN
	jsr	DRWSTR

	ldx	#FHRFSTR	Display the "Fahrfall" header
	ldy	#(SCNBASE+12*SCNWIDT+11)
	lda	#FRFSTLN
	jsr	DRWSTR

	ldx	#HOFSTRN	Display the "Hall Of Fame" header
	ldy	#(SCNBASE+18*SCNWIDT+9)
	lda	#HOFSTLN
	jsr	DRWSTR

	ldx	#HOFDATA	Draw the Hall Of Fame scores
	ldy	#(SCNBASE+30*SCNWIDT+11)
	lda	#HOFSIZE
	pshs	a,x,y

HOFSCLP	lda	#3		Set size for initials string
	jsr	DRWSTR

	ldx	1,s		Reset for score data
	leax	3,x

	ldy	3,s		Reset for score position
	leay	4,y
	lda	#SCORLEN	Set size for score string
	jsr	DRWSTR

	ldx	1,s		Advance data pointer for next entry
	leax	HOFSTSZ,x
	stx	1,s

	ldy	3,s		Advance position pointer for next entry
	leay	6*SCNWIDT,y
	leay	6*SCNWIDT,y
	sty	3,s

	dec	,s		Check for end of data
	bne	HOFSCLP

	leas	5,s		Clean-up stack

HOFSYNC	lda	$ff03		Wait for Vsync
	bpl	HOFSYNC
	lda	$ff02

	jsr	DRWFLMS		Draw the flames at the top center of the screen

	jsr	LFSRADV		Advance the LFSR

	jsr	PUSHBTN		Check for input
	bcs	HOFEXIT		Exit "Hall Of Fame" if carry set

	jsr	FLMFLKR		Bump the flame flicker effect

* Check for user break (development only)
CHKURT3	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	HOFLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

HOFLOOP	bra	HOFSYNC

HOFEXIT
	rts

*
* Display "PUSH BUTTON" message and check for input
*
*	A,B,X,Y get clobbered
*
*	On retun, carry set indicates button pushed
*
PUSHBTN	lda	#(PBTCNTI/2)	Display "press button" message
	bita	PBUTCNT
	beq	PBUTINV

	ldx	#PBTSTR1
	ldy	#(SCNBASE+90*SCNWIDT+9)
	lda	#PBTS1LN
	jsr	DRWSTR

	bra	PBCTDEC

PBUTINV	ldx	#PBTSTR2
	ldy	#(SCNBASE+90*SCNWIDT+9)
	lda	#PBTS2LN
	jsr	DRWSTR

PBCTDEC	dec	PBUTCNT
	bne	PBJOYCK

	lda	#PBTCNTI	Initialize counter for "press button" message
	sta	PBUTCNT

PBJOYCK	jsr	JOYREAD		Read joystick, flags returned in B
	andb	#JOYBTN		Only check for button press
	beq	PBKEYCK		No joystick button, check keyboard

	ldx	#JOYREAD	Point INPREAD at JOYREAD
	stx	INPREAD

	bra	PBEXTCS		Indicate positive result

PBKEYCK	lda	#KBROWCC	Select CoCo keyboard
	sta	KBRWDAT
	jsr	KEYBDRD		Read the keyboard, flags returned in B
	andb	#JOYBTN		Only check for button press
	bne	PBKYSET		Spacebar hit, select keyboard and exit intro

PBKYCK2	lda	#KBROWDG	Select Dragon keyboard
	sta	KBRWDAT
	jsr	KEYBDRD		Read the keyboard, flags returned in B
	andb	#JOYBTN		Only check for button press
	beq	PBEXTCC		No spacebar, finish the loop

PBKYSET	ldx	#KEYBDRD	Point INPREAD at KEYBDRD
	stx	INPREAD

PBEXTCS	orcc	#$01		Return positive result
	rts

PBEXTCC	andcc	#$fe		Return negative result
	rts

*
* Advance the flame flicker effect
*	A gets clobbered
*
FLMFLKR	dec	FLAMCNT		Countdown until next flame flicker
	bne	FLMFLKX

	lda	#FLMMSKI	Cycle the flame effect data
	eora	FLAMMSK
	sta	FLAMMSK

	lda	LFSRDAT		Grab part of the LFSR value
	anda	#FLMCTRG	Limit the range of the values
	adda	#FLMCTMN	Enforce a minimum value
	sta	FLAMCNT

FLMFLKX	rts

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
* Read the joystick
*	A gets clobbered
*	B returns flags representing joystick state
*
JOYREAD	clr	JOYFLGS		Clear the old joystick flag values
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
	bpl	JYREADX

JOYRDDN	orb	#JOYDN		Joystick points down
	bra	JYREADX

JOYRDUP	orb	#JOYUP		Joystick points up

JYREADX	rts

*
* Keyboard read routine
*	B holds pending JOYFLGS value
*	A gets clobbered
*
*	-- Use JOYFLGS to record keyboard results
*	-- Be smart enough to handle the Dragon keyboard too?
*
KEYBDRD	lda	#$7f
	bsr	KEYBHLP
	bne	KEYBDR1

	orb	#JOYBTN

KEYBDR1	lda	#$bf
	bsr	KEYBHLP
	bne	KEYBDR2

	orb	#JOYRT

KEYBDR2	lda	#$df
	bsr	KEYBHLP
	bne	KEYBDRX

	orb	#JOYLT

KEYBDRX	rts

KEYBHLP	sta	$ff02
	lda	$ff00
	anda	KBRWDAT
	rts

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
* Clear the screen
*	X,A,B get clobbered
*
CLRSCRN	ldx	#SCNBASE	Clear screen
	ldd	#WBLACK

CLSLOOP	std	,x++
	cmpx	#SCNEND
	bne	CLSLOOP

	rts

*
* Flame effect graphics data
*
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

*
* Player/platform collision detection data
*
PLTCMSK fcb	$80,$80,$c0,$c0,$40,$40,$60,$60
	fcb	$20,$20,$30,$30,$10,$10,$18,$18
	fcb	$08,$08,$0c,$0c,$04,$04,$06,$06
	fcb	$02,$02,$03,$03,$01,$01,$01,$01

*
* Data used for "FAHRFALL" on title screen
*
INOTDAT	fcb	$fe,$fe,$fe,$fe,$f8,$f8,$f8,$f8
	fcb	$f8,$f8,$f8,$f8,$fc,$fc,$fc,$fc
	fcb	$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
	fcb	$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
	fcb	$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
	fcb	$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
	fcb	$f8,$f8,$f8,$f8,$f8,$f8,$f8,$f8
	fcb	$f8,$f8,$f8,$f8,$fe,$fe,$fe,$fe

INMODAT	fcb	$cc,$de,$de,$de,$d2,$d2,$d2,$d2
	fcb	$d2,$d2,$d2,$d2,$de,$de,$de,$de
	fcb	$d2,$d2,$d2,$d2,$d2,$d2,$d2,$d2
	fcb	$d2,$d2,$d2,$d2,$d2,$d2,$d2,$d2
	fcb	$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
	fcb	$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
	fcb	$f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0
	fcb	$f0,$f0,$f0,$f0,$fc,$fc,$fc,$fc

INMIDAT	fcb	$63,$63,$63,$63,$63,$63,$63,$63
	fcb	$63,$63,$63,$63,$7f,$7f,$7f,$7f
	fcb	$63,$63,$63,$63,$63,$63,$63,$63
	fcb	$63,$63,$63,$63,$63,$63,$63,$63
	fcb	$30,$78,$fc,$fc,$84,$84,$84,$84
	fcb	$84,$84,$84,$84,$fc,$fc,$fc,$fc
	fcb	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc
	fcb	$cc,$cc,$cc,$cc,$cc,$cc,$cc,$cc

ININDAT	fcb	$fc,$fe,$ff,$ff,$c7,$c3,$c3,$c3
	fcb	$c3,$c3,$c3,$c7,$ff,$ff,$fe,$fc
	fcb	$d8,$d8,$d8,$d8,$cc,$cc,$cc,$cc
	fcb	$c6,$c6,$c6,$c6,$c3,$c3,$c3,$c3
	fcb	$fc,$fc,$fc,$fc,$c0,$c0,$c0,$c0
	fcb	$c0,$c0,$c0,$c0,$f8,$f8,$f8,$f8
	fcb	$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0
	fcb	$c0,$c0,$c0,$c0,$c0,$c0,$c0,$c0

*
* Data for "COPYRIGHT 2012"
*
CPYSTR1	fcb	$60,$43,$4f,$50,$59,$52,$49,$47
	fcb	$48,$54,$60,$72,$70,$71,$72,$60
CPYS1ND	equ	*
CPYS1LN	equ	(CPYS1ND-CPYSTR1)

*
* Data for "JOHN W. LINVILLE"
*
CPYSTR2	fcb	$60,$4a,$4f,$48,$4e,$60,$57,$6e
	fcb	$60,$4c,$49,$4e,$56,$49,$4c,$4c
	fcb	$45,$60
CPYS2ND	equ	*
CPYS2LN	equ	(CPYS2ND-CPYSTR2)

*
* Data for "PRESS BUTTON"
*
PBTSTR1	fcb	$60,$50,$52,$45,$53,$53,$60,$42
	fcb	$55,$54,$54,$4f,$4e,$60
PBTS1ND	equ	*
PBTS1LN	equ	(PBTS1ND-PBTSTR1)
PBTSTR2	fcb	$20,$10,$12,$05,$13,$13,$20,$02
	fcb	$15,$14,$14,$0f,$0e,$20
PBTS2ND	equ	*
PBTS2LN	equ	(PBTS2ND-PBTSTR2)

*
* Data for "TO SLEEP, PERCHANCE TO DREAM..."
*
ISTSTR1	fcb	$60,$54,$4f,$60,$53,$4c,$45,$45
	fcb	$50,$6c,$60,$50,$45,$52,$43,$48
	fcb	$41,$4e,$43,$45,$60
ISTS1ND	equ	*
ISTS1LN	equ	(ISTS1ND-ISTSTR1)
ISTSTR2	fcb	$60,$54,$4f,$60,$44,$52,$45,$41
	fcb	$4d,$6e,$6e,$6e,$60
ISTS2ND	equ	*
ISTS2LN	equ	(ISTS2ND-ISTSTR2)

*
* Data for "FAHRFALL"
*
FHRFSTR	fcb	$60,$46,$41,$48,$52,$46,$41,$4c
	fcb	$4c,$60
FRFSTND	equ	*
FRFSTLN	equ	(FRFSTND-FHRFSTR)

*
* Data for "HALL OF FAME"
*
HOFSTRN	fcb	$20,$08,$01,$0c,$0c,$20,$0f,$06
	fcb	$20,$06,$01,$0d,$05,$20
HOFSTND	equ	*
HOFSTLN	equ	(HOFSTND-HOFSTRN)

*
* Data for initial Hall Of Fame
*
HOFDFLT	fcb	$4b,$4d,$4c
	fcb	$30,$30,$31,$32,$38,$32
	fcb	$40,$40,$40
	fcb	$30,$30,$31,$30,$30,$30
	fcb	$40,$40,$40
	fcb	$30,$30,$30,$37,$35,$30
	fcb	$40,$40,$40
	fcb	$30,$30,$30,$35,$30,$30
	fcb	$40,$40,$40
	fcb	$30,$30,$30,$32,$35,$30

	end	INIT
