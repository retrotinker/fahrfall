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

BSCLRIN	equ	$b5		Initial value for bg-scroll effect

FRMCTRG	equ	$07		Range mask of frame count values

NUMPLTF	set	3

PLTFTOP	equ	SCNBASE-SCNWIDT	Top of highest platform animation section
PLTFRNG	equ	SCNSIZE/NUMPLTF	Size of each platform animation section

PLTBSIN	equ	SCNEND-SCNWIDT	Initial value for base of bottom platform
PLTFMCI	equ	$05		Default count value for platform movement

PLTFCTI	equ	$cfcf		Initial top row color pattern for platforms
PLTFCBI	equ	$cfcf		Initial bottom row color pattern for platforms

	org	STRUCT		Platform info structure declarations
PLTBASE	rmb	2		Current base addresses for drawing platform
PLTDATA	rmb	1		Mask representing platform configuration
PLTCOLR	rmb	4		Color data for drawing platform
PLTSTSZ	equ	*

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

	org	LOAD

INIT	lda	#(DATA/256)	Set direct page register
	tfr	a,dp
	setdp	DATA/256	Tell the assembler about the direct page value

	clr	$ffc5		Select SG12 mode

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

	lda	LFSRDAT+1	Apply LFSR to platform data
	sta	PLTFRMS+PLTDATA
	clr	PLTFRMS+PLTSTSZ+PLTDATA
	clr	PLTFRMS+2*PLTSTSZ+PLTDATA

* Main game loop is from here to VLOOP
VSYNC	lda	$ff03		Wait for Vsync
	bpl	VSYNC
	lda	$ff02

	clr	$ffd9		Hi-speed during Vblank

* Vblank work goes here

	* Erase the player

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
	bne	PLTADV

	lda	#FLMMSKI	Cycle the flame effect data
	eora	FLAMMSK
	sta	FLAMMSK

	lda	LFSRDAT		Grab part of the LFSR value
	anda	#FLMCTRG	Limit the range of the values
	adda	#FLMCTMN	Enforce a minimum value
	sta	FLAMCNT

PLTADV	dec	PLTMCNT		Countdown until next platform movement
	bne	CHKUART

	lda	#PLTFMCI	Reset platform movement counter
	sta	PLTMCNT

	ldd	PLTFRMS+PLTBASE	Decrement platform base values
	subd	#SCNWIDT
	std	PLTFRMS+PLTBASE
	subd	#PLTFRNG
	std	PLTFRMS+PLTSTSZ+PLTBASE
	subd	#PLTFRNG

	cmpd	#PLTFTOP	Check for top of platform movement
	bge	PLTBSTO

	lda	PLTFRMS+PLTSTSZ+PLTDATA		Shift platform data values
	sta	PLTFRMS+2*PLTSTSZ+PLTDATA
	lda	PLTFRMS+PLTDATA
	sta	PLTFRMS+PLTSTSZ+PLTDATA
	lda	LFSRDAT+1			Apply LFSR to platform data
	sta	PLTFRMS+PLTDATA
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
	ldd	#(PLTBSIN-SCNWIDT)		Reset first platform base pointer
	std	PLTFRMS+PLTBASE
	ldd	#(PLTBSIN-PLTFRNG-SCNWIDT)	Reset second platform base pointer
	std	PLTFRMS+PLTSTSZ+PLTBASE
	ldd	#(PLTBSIN-2*PLTFRNG-SCNWIDT)	Reset third platform base pointer

PLTBSTO	std	PLTFRMS+2*PLTSTSZ+PLTBASE

* Check for user break (development only)
CHKUART	lda	$ff69		Check for serial port activity
	bita	#$08
	beq	VLOOP
	lda	$ff68
	jmp	[$fffe]		Re-enter monitor

* End of main game loop
VLOOP	jmp	VSYNC

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

PLTDRW0	lsr	,s
	bcc	PLTDRW1
	std	,x
	std	$02,x
	sty	$20,x
	sty	$22,x
PLTDRW1	lsr	,s
	bcc	PLTDRW2
	std	$04,x
	std	$06,x
	sty	$24,x
	sty	$26,x
PLTDRW2	lsr	,s
	bcc	PLTDRW3
	std	$08,x
	std	$0a,x
	sty	$28,x
	sty	$2a,x
PLTDRW3	lsr	,s
	bcc	PLTDRW4
	std	$0c,x
	std	$0e,x
	sty	$2c,x
	sty	$2e,x
PLTDRW4	lsr	,s
	bcc	PLTDRW5
	std	$10,x
	std	$12,x
	sty	$30,x
	sty	$32,x
PLTDRW5	lsr	,s
	bcc	PLTDRW6
	std	$14,x
	std	$16,x
	sty	$34,x
	sty	$36,x
PLTDRW6	lsr	,s
	bcc	PLTDRW7
	std	$18,x
	std	$1a,x
	sty	$38,x
	sty	$3a,x
PLTDRW7	lsr	,s
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

PLTERA0	lsr	,s
	bcc	PLTERA1
	std	,x
	std	$02,x
PLTERA1	lsr	,s
	bcc	PLTERA2
	std	$04,x
	std	$06,x
PLTERA2	lsr	,s
	bcc	PLTERA3
	std	$08,x
	std	$0a,x
PLTERA3	lsr	,s
	bcc	PLTERA4
	std	$0c,x
	std	$0e,x
PLTERA4	lsr	,s
	bcc	PLTERA5
	std	$10,x
	std	$12,x
PLTERA5	lsr	,s
	bcc	PLTERA6
	std	$14,x
	std	$16,x
PLTERA6	lsr	,s
	bcc	PLTERA7
	std	$18,x
	std	$1a,x
PLTERA7	lsr	,s
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
	anda	#$07
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
