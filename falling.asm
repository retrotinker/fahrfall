	nam	falling
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

LOAD	equ	$1c00		Actual load address for binary

SCNBASE	equ	$0400
SCNSIZE	equ	$0c00
SCNWIDE	equ	32
SCNLINS	equ	96
SCNQRTR	equ	SCNWIDE*SCNLINS/4
SCNHALF	equ	SCNQRTR*2

SCORLEN	equ	6

BBLACK	equ	$80
WBLACK	equ	$8080

SSCLRIN	equ	$b5		Initial value for side-scroll effect

	org	LOAD

INIT	clr	$ffc5		Select SG12 mode

	ldx	#SCNBASE	Clear screen
	ldd	#WBLACK

CLSLOOP	std	,x++
	cmpx	#(SCNBASE+SCNSIZE)
	bne	CLSLOOP

	clr	>FRAMCNT	Initialize frame sequence counter

	lda	#SSCLRIN	Seed the side-scroll color data
	sta	>SCRDATO
	sta	>SCRDATM
	sta	>SCRDATI

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	* Paint the outer side-scrolls
	lda	>SCRDATO	Retrieve last outer scroll top color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	>SCRDATO	Store current outer scroll top color data

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

	* Move the platforms

	* Move the player

* Must get here before end of Vblank (~7840 cycles from VSYNC)
	clr	$ffd8		Lo-speed during display

* "Display active" work goes here

	lda	>FRAMCNT	Paint half of the middle side-scrolls
	anda	#$01
	bne	SCRMID2

SCRMID1	lda	>SCRDATM	Retrieve last middle scroll top color data
	sta	>SCRCURM	Store current middle scroll starting color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	>SCRDATM	Store current middle scroll top color data

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

SCRMIDX	lda	>FRAMCNT	Paint a quarter of the inner side-scrolls
	lsla
	ldy	#SCRINRB
	jmp	a,y

SCRINRB	bra	SCRINR1
	bra	SCRINR2
	bra	SCRINR3
	bra	SCRINR4

SCRINR1	lda	>SCRDATI	Retrieve last inner scroll top color data
	sta	>SCRCURI	Store current inner scroll starting color data
	tfr     a,b
	adda    #$30
	ora     #$80
	eora    #$0f
	sta	>SCRDATI	Store current inner scroll top color data

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

SCRINRX	lda	>FRAMCNT
	inca
	anda	#$03
	sta	>FRAMCNT

	* Draw the score (Is this worth doing every frame?)
	ldx	#HISCORE
	ldy	#SCNBASE
	lda	#SCORLEN
	jsr	>DRWSTR

	ldx	#CURSCOR
	ldy	#(SCNBASE+SCNWIDE-SCORLEN)
	lda	#SCORLEN
	jsr	>DRWSTR

* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

* End of main game loop
VLOOP	jmp	VSYNC

* Paint the middle side-scrolls
SCRMID	lda	>SCRCURM
SCRMDLP	tfr     a,b		No ldd above, B gets clobbered anyway
	adda    #$30
	ora     #$80
	eora    #$0f
	std	2,x
	std	(SCNWIDE-4),x
	leax	SCNWIDE,x
	cmpx	2,s
	bne	SCRMDLP
	sta	>SCRCURM
	rts

* Paint the inner side-scrolls
SCRINR	lda	>SCRCURI
SCRINLP	tfr     a,b		No ldd above, B gets clobbered anyway
	adda    #$30
	ora     #$80
	eora    #$0f
	std	4,x
	std	(SCNWIDE-6),x
	leax	SCNWIDE,x
	cmpx	2,s
	bne	SCRINLP
	sta	>SCRCURI
	rts

* Draw a normal text string on the SG12 display
* 	X points to the source
*	Y points to the dest
*	A holds the length of the string
*	B gets clobbered
*	Do not pass-in a zero length!

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

* Data storage goes here for now, may need a different org later...
FRAMCNT	rmb	1

SCRDATO	rmb	1
SCRDATM	rmb	1
SCRDATI	rmb	1
SCRCURM	rmb	1
SCRCURI	rmb	1

CURSCOR	fcb	$70,$70,$70,$70,$70,$70
HISCORE	fcb	$30,$30,$30,$30,$30,$30

	end	INIT
