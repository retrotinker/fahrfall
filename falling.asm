	nam	falling
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

LOAD	equ	$1c00		Actual load address for binary

SCNBASE	equ	$0400
SCNSIZE	equ	$0c00

BBLACK	equ	$80
WBLACK	equ	$8080

	org	LOAD

INIT	clr	$ffc5		Select SG12 mode

	ldx	#SCNBASE	Clear screen
	ldd	#WBLACK

CLSLOOP	std	,x++
	cmpx	#(SCNBASE+SCNSIZE)
	bne	CLSLOOP

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	* Paint the side scrolls

	* Move the platforms

	* Move the player

	* Draw the score

* Must get here before end of Vblank (~7840 cycles from VSYNC)
	clr	$ffd8		Lo-speed during display

* "Display active" work goes here

* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

VLOOP	jmp	VSYNC

	end	INIT
