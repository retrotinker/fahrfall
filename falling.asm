	nam	falling
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

LOAD	equ	$1c00		Actual load address for binary

SCNBASE	equ	$0400
SCNSIZE	equ	$0c00
SCNWIDE	equ	32
SCNLINS	equ	96

BBLACK	equ	$80
WBLACK	equ	$8080

SSCLRIN	equ	$b58a		Initial value for side scroll effect

	org	LOAD

INIT	clr	$ffc5		Select SG12 mode

	ldx	#SCNBASE	Clear screen
	ldd	#WBLACK

CLSLOOP	std	,x++
	cmpx	#(SCNBASE+SCNSIZE)
	bne	CLSLOOP

	clr	>FRAMCNT	Initialize frame sequence counter

	ldd	#SSCLRIN	 Seed the side-scroll color data
	std	>SCRNXTO
	std	>SCRNXTM
	std	>SCRNXTI

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	* Paint the side scrolls
	ldx	#$SCNBASE
SCRLOOP	ldd	SCNWIDE,x
	std	,x
	std	(SCNWIDE-2),x
	leax	SCNWIDE,x
	cmpx	#(SCNBASE+SCNSIZE-SCNWIDE)
	bne	SCRLOOP
	ldd	>SCRNXTO
	std	,x

	* Move the platforms

	* Move the player

	* Draw the score

* Must get here before end of Vblank (~7840 cycles from VSYNC)
	clr	$ffd8		Lo-speed during display

* "Display active" work goes here

	ldx	#>SCRNXTO	Advance the outer side-scroll color data
	jsr	>SSCDADV

	lda	>FRAMCNT
	bne	SKPINR

	* Paint the inner side scrolls
	ldx	#$SCNBASE
SCRLPI	ldd	(SCNWIDE+4),x
	std	4,x
	std	(SCNWIDE-6),x
	leax	SCNWIDE,x
	cmpx	#(SCNBASE+SCNSIZE-SCNWIDE)
	bne	SCRLPI
	ldd	>SCRNXTI
	std	4,x

	ldx	#>SCRNXTI	Advance the inner side-scroll color data
	jsr	>SSCDADV

	lda	>FRAMCNT
SKPINR	bita	#$01
	bne	NXTFRM

	* Paint the middle side scrolls
	ldx	#$SCNBASE
SCRLPM	ldd	(SCNWIDE+2),x
	std	2,x
	std	(SCNWIDE-4),x
	leax	SCNWIDE,x
	cmpx	#(SCNBASE+SCNSIZE-SCNWIDE)
	bne	SCRLPM
	ldd	>SCRNXTM
	std	2,x

	ldx	#>SCRNXTM	Advance the middle side-scroll color data
	jsr	>SSCDADV

	lda	>FRAMCNT
NXTFRM	inca
	anda	#$03
	sta	>FRAMCNT

* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

VLOOP	jmp	VSYNC

SSCDADV	lda     ,x		Advance the side-scroll color data
	tfr     a,b		No ldd above, B gets clobbered anyway
	adda    #$30
	ora     #$80
	eora    #$0f
	std     ,x
	rts

* Data storage goes here for now, may need a different org later...
FRAMCNT	rmb	1

SCRNXTO	rmb	2
SCRNXTM	rmb	2
SCRNXTI	rmb	2

	end	INIT
