	nam	falling
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

DATA	equ	$0300		Base address for random storage
LOAD	equ	$1c00		Actual load address for binary

SCNBASE	equ	$0400		Base address for screen memory
SCNSIZE	equ	$0c00		Size of screen memory
SCNWIDT	equ	32		Width of screen in bytes
SCNLINS	equ	96		Height of screen in lines
SCNQRTR	equ	SCNWIDT*SCNLINS/4
SCNHALF	equ	SCNQRTR*2
SCN3QTR	equ	SCNHALF+SCNQRTR
SCNEIGT	equ	SCNWIDT*SCNLINS/8
SCN3EGT	equ	SCNQRTR+SCNEIGT
SCN5EGT	equ	SCNHALF+SCNEIGT
SCN7EGT	equ	SCN3QTR+SCNEIGT
SCNSIXT	equ	SCNWIDT*SCNLINS/16
SCN3SXT	equ	SCNEIGT+SCNSIXT
SCN5SXT	equ	SCNQRTR+SCNSIXT
SCN7SXT	equ	SCN3EGT+SCNSIXT
SCN9SXT	equ	SCNHALF+SCNSIXT
SCNBSXT	equ	SCN5EGT+SCNSIXT
SCNDSXT	equ	SCN3QTR+SCNSIXT
SCNFSXT	equ	SCN7EGT+SCNSIXT

TIMVAL	equ	$0112		Extended BASIC's free-running time counter

SCORLEN	equ	6		Number of digits in score display

FLAMLEN	equ	SCNWIDT-SCORLEN*2	Width of flames in bytes
FLAMHGT	equ	6			Height of flames in lines
FLAMSIZ	equ	FLAMHGT*SCNWIDT 	Size of flame/score area

BBLACK	equ	$80		Single byte color code for black
WBLACK	equ	$8080		Double byte color code for black

BYELOW	equ	$9f		Color code for two yellow pixels

BSCLRIN	equ	$b5		Initial value for bg-scroll effect
FLMMSKI	equ	$40		Initial mask value for flame effect
FLMCNTI	equ	$03		Initial count value for flame effect
FLMCTRG	equ	$03		Range mask of flame count values
FLMCTMN	equ	$01		Minimum flame count value

FRMCTRG	equ	$0f		Range mask of frame count values

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

CURSCOR	rmb	SCORLEN		Display storage for current score
HISCORE	rmb	SCORLEN		Display storage for high score

FLAMMSK	rmb	1		Current mask value for flame effect
FLAMCNT	rmb	1		Current count of frames until next flicker

LFSRDAT	rmb	2

	org	LOAD

INIT	lda	#(DATA/256)	Set direct page register
	tfr	a,dp
	setdp	DATA/256

	clr	$ffc5		Select SG12 mode

	ldx	#SCNBASE	Clear screen
	ldd	#WBLACK

CLSLOOP	std	,x++
	cmpx	#(SCNBASE+SCNSIZE)
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

	clr	FRAMCNT		Initialize frame sequence counter

	lda	#BSCLRIN	Seed the bg-scroll color data
	sta	SCRTCOT
	sta	SCRTCMO
	sta	SCRTCMI
	sta	SCRTCIN

	lda	#FLMMSKI	Seed the flame effect data
	sta	FLAMMSK
	lda	#FLMCNTI
	sta	FLAMCNT

	ldd	TIMVAL		Seed the LFSR data
	std	LFSRDAT

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	* Erase the player

	* Erase the platforms(?)

	jsr	>SCRLPNT	Paint the bg-scrolls

	* Draw the platforms

	* Draw the player

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

	* Read the controls

	* Compute movement

	* Detect collisions

	* Compute score

	lda	FRAMCNT		Bump the frame counter
	inca
	anda	#FRMCTRG
	sta	FRAMCNT

	jsr	LFSRADV		Advance the LFSR

	dec	FLAMCNT		Countdown until next flame flicker
	bne	CHKUART

	lda	#FLMMSKI	Cycle the flame effect data
	eora	FLAMMSK
	sta	FLAMMSK

	lda	LFSRDAT		Grab part of the LFSR value
	anda	#FLMCTRG	Limit the range of the values
	adda	#FLMCTMN	Enforce a minimum value
	sta	FLAMCNT

* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

* End of main game loop
VLOOP	jmp	VSYNC

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
	ldy	#(SCNBASE+SCNSIZE)
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

SCRMOBT	bra	SCRMO0
	bra	SCRMO1
	bra	SCRMO2
	bra	SCRMO3

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
	ldy	#(SCNBASE+SCNSIZE)

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

	lda	FRAMCNT		Compute the branch
	anda	#$07
	lsla
	ldy	#SCRMIBT
	jmp	a,y

SCRMIBT	bra	SCRMI0
	bra	SCRMI1
	bra	SCRMI2
	bra	SCRMI3
	bra	SCRMI4
	bra	SCRMI5
	bra	SCRMI6
	bra	SCRMI7

SCRMI0	lda	SCRTCMI		Retrieve last inner-mid scroll top color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRTCMI		Store current inner-mid scroll top color data

	ldx	#SCNBASE		Paint 1st 8th...
	ldy	#(SCNBASE+SCNEIGT)
	pshs	y
	bra	SCRMILP

SCRMI1	ldx	#(SCNBASE+SCNEIGT)	Paint 2nd 8th...
	ldy	#(SCNBASE+SCNQRTR)
	bra	SCRMICM

SCRMI2	ldx	#(SCNBASE+SCNQRTR)	Paint 3rd 8th...
	ldy	#(SCNBASE+SCN3EGT)
	bra	SCRMICM

SCRMI3	ldx	#(SCNBASE+SCN3EGT)	Paint 4th 8th...
	ldy	#(SCNBASE+SCNHALF)
	bra	SCRMICM

SCRMI4	ldx	#(SCNBASE+SCNHALF)	Paint 5th 8th...
	ldy	#(SCNBASE+SCN5EGT)
	bra	SCRMICM

SCRMI5	ldx	#(SCNBASE+SCN5EGT)	Paint 6th 8th...
	ldy	#(SCNBASE+SCN3QTR)
	bra	SCRMICM

SCRMI6	ldx	#(SCNBASE+SCN3QTR)	Paint 7th 8th...
	ldy	#(SCNBASE+SCN7EGT)
	bra	SCRMICM

SCRMI7	ldx	#(SCNBASE+SCN7EGT)	Paint 8th 8th...
	ldy	#(SCNBASE+SCNSIZE)

SCRMICM	lda	SCRCCMI
	tfr     a,b		Recreate B half of the color data
	eorb    #$0f
	pshs	y

SCRMILP	std	9,x
	sta	8,x
	std	(SCNWIDT-11),x
	stb	(SCNWIDT-9),x
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
	anda	#$0f
	cmpa	#$08
	bge	SCRIBR2
	lsla
	ldy	#SCRINBT
	jmp	a,y

SCRINBT	bra	SCRIN0
	bra	SCRIN1
	bra	SCRIN2
	bra	SCRIN3
	bra	SCRIN4
	bra	SCRIN5
	bra	SCRIN6
	bra	SCRIN7

SCRIN0	lda	SCRTCIN		Retrieve last inner scroll top color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRTCIN		Store current inner scroll top color data

	ldx	#SCNBASE		Paint 1st 16th...
	ldy	#(SCNBASE+SCNSIXT)
	pshs	y
	lbra	SCRINLP

SCRIN1	ldx	#(SCNBASE+SCNSIXT)	Paint 2nd 16th...
	ldy	#(SCNBASE+SCNEIGT)
	lbra	SCRINCM

SCRIN2	ldx	#(SCNBASE+SCNEIGT)	Paint 3rd 16th...
	ldy	#(SCNBASE+SCN3SXT)
	lbra	SCRINCM

SCRIN3	ldx	#(SCNBASE+SCN3SXT)	Paint 4th 16th...
	ldy	#(SCNBASE+SCNQRTR)
	lbra	SCRINCM

SCRIN4	ldx	#(SCNBASE+SCNQRTR)	Paint 5th 16th...
	ldy	#(SCNBASE+SCN5SXT)
	bra	SCRINCM

SCRIN5	ldx	#(SCNBASE+SCN5SXT)	Paint 6th 16th...
	ldy	#(SCNBASE+SCN3EGT)
	bra	SCRINCM

SCRIN6	ldx	#(SCNBASE+SCN3EGT)	Paint 7th 16th...
	ldy	#(SCNBASE+SCN7SXT)
	bra	SCRINCM

SCRIN7	ldx	#(SCNBASE+SCN7SXT)	Paint 8th 16th...
	ldy	#(SCNBASE+SCNHALF)
	bra	SCRINCM

SCRIBR2	ldy	#SCRIBT2
	anda	#$07
	lsla
	jmp	a,y

SCRIBT2	bra	SCRIN8
	bra	SCRIN9
	bra	SCRINA
	bra	SCRINB
	bra	SCRINC
	bra	SCRIND
	bra	SCRINE
	bra	SCRINF

SCRIN8	ldx	#(SCNBASE+SCNHALF)	Paint 9th 16th...
	ldy	#(SCNBASE+SCN9SXT)
	bra	SCRINCM

SCRIN9	ldx	#(SCNBASE+SCN9SXT)	Paint 10th 16th...
	ldy	#(SCNBASE+SCN5EGT)
	bra	SCRINCM

SCRINA	ldx	#(SCNBASE+SCN5EGT)	Paint 11th 16th...
	ldy	#(SCNBASE+SCNBSXT)
	bra	SCRINCM

SCRINB	ldx	#(SCNBASE+SCNBSXT)	Paint 12th 16th...
	ldy	#(SCNBASE+SCN3QTR)
	bra	SCRINCM

SCRINC	ldx	#(SCNBASE+SCN3QTR)	Paint 13th 16th...
	ldy	#(SCNBASE+SCNDSXT)
	bra	SCRINCM

SCRIND	ldx	#(SCNBASE+SCNDSXT)	Paint 14th 16th...
	ldy	#(SCNBASE+SCN7EGT)
	bra	SCRINCM

SCRINE	ldx	#(SCNBASE+SCN7EGT)	Paint 15th 16th...
	ldy	#(SCNBASE+SCNFSXT)
	bra	SCRINCM

SCRINF	ldx	#(SCNBASE+SCNFSXT)	Paint 16th 16th...
	ldy	#(SCNBASE+SCNSIZE)

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

	end	INIT
