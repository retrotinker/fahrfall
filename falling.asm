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

SCORLEN	equ	8		Number of digits in score display

FLAMLEN	equ	SCNWIDT-SCORLEN*2	Width of flames in bytes
FLAMHGT	equ	6			Height of flames in lines
FLAMSIZ	equ	FLAMHGT*SCNWIDT 	Size of flame/score area

BBLACK	equ	$80		Single byte color code for black
WBLACK	equ	$8080		Double byte color code for black

SSCLRIN	equ	$b5		Initial value for side-scroll effect
FLMXRIN	equ	$40

	org	DATA
	setdp	DATA / 256

FRAMCNT	rmb	1		Rolling frame sequence counter

SCRTCOT	rmb	1		Color data for side-scroll effect
SCRTCMO	rmb	1			"
SCRTCMI	rmb	1			"
SCRTCIN	rmb	1			"
SCRCCOT	rmb	1			"
SCRCCMO	rmb	1			"
SCRCCMI	rmb	1			"
SCRCCIN	rmb	1			"

CURSCOR	rmb	SCORLEN		Display storage for current score
HISCORE	rmb	SCORLEN		Display storage for high score

FLAMXOR	rmb	1		Current XOR value for flame effect

	org	LOAD

INIT	clr	$ffc5		Select SG12 mode

	ldx	#SCNBASE	Clear screen
	ldd	#WBLACK

CLSLOOP	std	,x++
	cmpx	#(SCNBASE+SCNSIZE)
	bne	CLSLOOP

	ldx	#CURSCOR
	lda	#(SCORLEN-1)
	ldb	#$70
INCSCLP	stb	a,x
	deca
	bne	INCSCLP
	stb	a,x

	ldx	#HISCORE
	lda	#(SCORLEN-1)
	ldb	#$30
INHSCLP	stb	a,x
	deca
	bne	INHSCLP
	stb	a,x

	clr	FRAMCNT		Initialize frame sequence counter

	lda	#SSCLRIN	Seed the side-scroll color data
	sta	SCRTCOT
	sta	SCRTCMO
	sta	SCRTCMI
	sta	SCRTCIN

	lda	#FLMXRIN	Seed the flame effect data
	sta	FLAMXOR

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	jsr	>SCRLPNT	Paint the outer side-scrolls

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

	* Compute score

	lda	FRAMCNT		Bump the frame counter
	inca
	anda	#$0f
	bne	FCSTOR

	ldb	#FLMXRIN		Cycle the flame effect data
	eorb	FLAMXOR
	stb	FLAMXOR

FCSTOR	sta	FRAMCNT

* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

* End of main game loop
VLOOP	jmp	VSYNC

*
* Paint the side-scroll effects
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

SCROTLP	std	,x
	std	(SCNWIDT-2),x
	tfr     a,b		Advance the color data
	adda    #$30
	ora     #$80
	eora    #$0f
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

SCRMOCM	lda	SCRCCMO
	tfr     a,b		Recreate B half of the color data
	subb    #$30
	orb     #$80
	eorb    #$0f
	pshs	y

SCRMOLP	std	2,x
	std	(SCNWIDT-4),x
	tfr     a,b		Advance the color data
	adda    #$30
	ora     #$80
	eora    #$0f
	leax	SCNWIDT,x
	cmpx	,s
	blt	SCRMOLP
	leas	2,s
	sta	SCRCCMO

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
	subb    #$30
	orb     #$80
	eorb    #$0f
	pshs	y

SCRMILP	std	4,x
	std	(SCNWIDT-6),x
	tfr     a,b		Advance the color data
	adda    #$30
	ora     #$80
	eora    #$0f
	leax	SCNWIDT,x
	cmpx	,s
	blt	SCRMILP
	leas	2,s
	sta	SCRCCMI

	lda	FRAMCNT		Compute the branch
	anda	#$0f
	cmpa	#$0c
	lbge	SCRINB2
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
	bra	SCRIN8
	bra	SCRIN9
	bra	SCRINA
	bra	SCRINB

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
	bra	SCRINCM

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

SCRINB2	ldy	#SCRINT2
	anda	#$03
	lsla
	jmp	a,y

SCRINT2	bra	SCRINC
	bra	SCRIND
	bra	SCRINE
	bra	SCRINF

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
	subb    #$30
	orb     #$80
	eorb    #$0f
	pshs	y

SCRINLP	std	6,x
	std	(SCNWIDT-8),x
	tfr     a,b		Advance the color data
	adda    #$30
	ora     #$80
	eora    #$0f
	leax	SCNWIDT,x
	cmpx	,s
	blt	SCRINLP
	leas	2,s
	sta	SCRCCIN

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
DRWSPLP	ldb	a,x
	eorb	FLAMXOR
	stb	a,y
	deca
	bne	DRWSPLP
	leax	FLAMLEN,x
	leay	SCNWIDT,y
	dec	,s
	beq	DRWFLMX
	lda	#FLAMLEN
	bra	DRWSPLP
DRWFLMX	leas	1,s
	rts

FLAMES	fcb	$bf,$ff,$bf,$bf,$bf,$bf,$ff,$bf
	fcb	$bf,$ff,$bf,$bf,$bf,$bf,$bf,$ff
	fcb	$ff,$bf,$bf,$bf,$ff,$bf,$bf,$bf
	fcb	$ff,$bf,$bf,$bf,$ff,$bf,$bf,$bf
	fcb	$b5,$ff,$ba,$bf,$ff,$bf,$ba,$ff
	fcb	$bf,$b5,$ff,$bf,$bf,$f5,$bf,$ba
	fcb	$b0,$ff,$b0,$ff,$ba,$ff,$ba,$f5
	fcb	$ba,$f5,$bf,$f5,$bf,$f0,$bf,$f0
	fcb	$b0,$f5,$f0,$b5,$fa,$f5,$b0,$f5
	fcb	$fa,$b0,$fa,$f5,$ba,$f0,$fa,$b0
	fcb	$f0,$f5,$f0,$f5,$f0,$f5,$f0,$f0
	fcb	$fa,$f0,$fa,$f0,$fa,$f0,$fa,$f0

	end	INIT
