	nam	falling
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

DATA	equ	$0300		Base address for random storage
LOAD	equ	$1c00		Actual load address for binary

SCNBASE	equ	$0400		Base address for screen memory
SCNSIZE	equ	$0c00		Size of screen memory
SCNWIDE	equ	32		Width of screen in bytes
SCNLINS	equ	96		Height of screen in lines
SCNQRTR	equ	SCNWIDE*SCNLINS/4
SCNHALF	equ	SCNQRTR*2

SCORLEN	equ	6		Number of digits in score display
SPIKLEN	equ	20		Width of spikes in bytes
SPIKHGT	equ	6		Height of spikes in lines

BBLACK	equ	$80		Single byte color code for black
WBLACK	equ	$8080		Double byte color code for black

SSCLRIN	equ	$b5		Initial value for side-scroll effect

	org	DATA
	setdp	DATA / 256

FRAMCNT	rmb	1		Rolling frame sequence counter

SCRDATO	rmb	1		Color data for side-scroll effect
SCRDATM	rmb	1			"
SCRDATI	rmb	1			"
SCRCURM	rmb	1			"
SCRCURI	rmb	1			"

CURSCOR	rmb	SCORLEN		Display storage for current score
HISCORE	rmb	SCORLEN		Display storage for high score

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
	sta	SCRDATO
	sta	SCRDATM
	sta	SCRDATI

	jsr	>DRWSPKS	Draw the spikes at the top center of the screen

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	jsr	>SCRLPNT	Paint the outer side-scrolls

	* Draw the platforms

	* Draw the player

	* Draw the score (Is this worth doing every frame?)
	ldx	#HISCORE
	ldy	#SCNBASE
	lda	#SCORLEN
	jsr	>DRWSTR

	ldx	#CURSCOR
	ldy	#(SCNBASE+SCNWIDE-SCORLEN)
	lda	#SCORLEN
	jsr	>DRWSTR

* Must get here before end of Vblank (~7840 cycles from VSYNC)
	clr	$ffd8		Lo-speed during display

* "Display active" work goes here

	* Read the controls

	* Compute movement

	* Compute score

	lda	FRAMCNT		Bump the frame counter
	inca
	anda	#$03
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
* Paint the middle side-scrolls
*	X points at the start of the side-scroll bar section
*	2,S points at end of the side-scroll bar section
*	A,B get clobbered
*
SCRMID	lda	SCRCURM
SCRMDLP	tfr     a,b		No ldd above, B gets clobbered anyway
	adda    #$30
	ora     #$80
	eora    #$0f
	std	2,x
	std	(SCNWIDE-4),x
	leax	SCNWIDE,x
	cmpx	2,s
	bne	SCRMDLP
	sta	SCRCURM
	rts

*
* Paint the inner side-scrolls
*	X points at the start of the side-scroll bar section
*	2,S points at end of the side-scroll bar section
*	A,B get clobbered
*
SCRINR	lda	SCRCURI
SCRINLP	tfr     a,b		No ldd above, B gets clobbered anyway
	adda    #$30
	ora     #$80
	eora    #$0f
	std	4,x
	std	(SCNWIDE-6),x
	leax	SCNWIDE,x
	cmpx	2,s
	bne	SCRINLP
	sta	SCRCURI
	rts

*
* Paint the side-scroll effects
*
SCRLPNT	lda	FRAMCNT

	lda	SCRDATO		Retrieve last outer scroll top color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRDATO		Store current outer scroll top color data

	ldx	#(SCNBASE+6*SCNWIDE)
SCRLOOP	std	,x
	std	(SCNWIDE-2),x
	tfr     a,b		Advance outer scroll color data
	adda    #$30
	ora     #$80
	eora    #$0f
	leax	SCNWIDE,x
	cmpx	#(SCNBASE+SCNSIZE-SCNWIDE)
	bne	SCRLOOP
	std	,x
	std	(SCNWIDE-2),x

	lda	FRAMCNT		Paint half of the middle side-scrolls
	anda	#$01
	bne	SCRMID2

SCRMID1	lda	SCRDATM		Retrieve last middle scroll top color data
	sta	SCRCURM		Store current middle scroll starting color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRDATM		Store current middle scroll top color data

	ldx	#SCNBASE	Paint the 1st half of the middle side-scroll
	ldx	#(SCNBASE+6*SCNWIDE)
	ldd	#(SCNBASE+SCNHALF)
	pshs	d
	jsr	>SCRMID
	leas	2,s
	bra	SCRMIDX

SCRMID2	ldx	#(SCNBASE+SCNHALF)	Paint the 2nd half...
	ldd	#(SCNBASE+SCNSIZE)
	pshs	d
	jsr	>SCRMID
	leas	2,s

SCRMIDX	lda	FRAMCNT		Paint a quarter of the inner side-scrolls
	lsla
	ldy	#SCRINRB
	jmp	a,y

SCRINRB	bra	SCRINR1
	bra	SCRINR2
	bra	SCRINR3
	bra	SCRINR4

SCRINR1	lda	SCRDATI		Retrieve last inner scroll top color data
	sta	SCRCURI		Store current inner scroll starting color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	SCRDATI		Store current inner scroll top color data

	ldx	#SCNBASE	Paint the 1st quarter of the inner side-scroll
	ldx	#(SCNBASE+6*SCNWIDE)
	ldd	#(SCNBASE+SCNQRTR)
	bra	SCRINRJ

SCRINR2	ldx	#(SCNBASE+SCNQRTR)	Paint the 2nd quarter...
	ldd	#(SCNBASE+2*SCNQRTR)
	bra	SCRINRJ

SCRINR3	ldx	#(SCNBASE+2*SCNQRTR)	Paint the 3rd quarter...
	ldd	#(SCNBASE+3*SCNQRTR)

SCRINRJ	pshs	d
	jsr	>SCRINR
	leas	2,s
	bra	SCRINRX

SCRINR4	ldx	#(SCNBASE+3*SCNQRTR)	Paint the 4th quarter...
	ldd	#(SCNBASE+SCNSIZE)
	pshs	d
	jsr	>SCRINR
	leas	2,s

SCRINRX	rts

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
	stb	SCNWIDE,y
	stb	2*SCNWIDE,y
	stb	3*SCNWIDE,y
	stb	4*SCNWIDE,y
	stb	5*SCNWIDE,y

	deca			More characters?
	beq	DRWSTRX
	leax	1,x
	leay	1,y
	bra	DRWSTR

DRWSTRX	rts

*
* Draw the spikes in the top center of the screen
*	X,Y,A,B get clobbered
*
DRWSPKS	ldx	#(SPIKES-1)		A offset will always be >= 1
	ldy	#(SCNBASE+SCORLEN-1)
	lda	#SPIKHGT
	pshs	a
	lda	#SPIKLEN
DRWSPLP	ldb	a,x
	stb	a,y
	deca
	bne	DRWSPLP
	leax	SPIKLEN,x
	leay	SCNWIDE,y
	dec	,s
	beq	DRWSPKX
	lda	#SPIKLEN
	bra	DRWSPLP
DRWSPKX	leas	1,s
	rts

SPIKES	fcb	$ff,$bf,$bf,$ff,$bf,$bf,$bf,$bf,$ff,$bf
	fcb	$bf,$ff,$bf,$bf,$bf,$bf,$bf,$ff,$bf,$ff
	fcb	$bf,$bf,$ff,$bf,$bf,$bf,$ff,$bf,$bf,$bf
	fcb	$ff,$bf,$bf,$bf,$ff,$bf,$bf,$bf,$ff,$bf
	fcb	$f5,$bf,$ba,$ff,$ba,$bf,$fa,$bf,$ba,$ff
	fcb	$bf,$b5,$ff,$b5,$bf,$f5,$bf,$b5,$ff,$fa
	fcb	$b5,$ff,$ba,$ff,$ba,$ff,$ba,$ff,$ba,$ff
	fcb	$bf,$f5,$bf,$f5,$bf,$f5,$bf,$f5,$bf,$fa
	fcb	$f0,$f5,$b0,$f5,$f0,$b5,$f0,$f5,$b0,$f5
	fcb	$fa,$b0,$fa,$f0,$ba,$f0,$fa,$b0,$fa,$f0
	fcb	$f0,$f5,$f0,$f5,$f0,$f5,$f0,$f5,$f0,$f5
	fcb	$fa,$f0,$fa,$f0,$fa,$f0,$fa,$f0,$fa,$f0

	end	INIT
