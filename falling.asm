	nam	falling
	ttl	Game inspired by "Man Goes Down" and/or "Downfall"

LOAD	equ	$1c00		Actual load address for binary

	org	LOAD

INIT	clr	$ffc5

	ldx	#$0400
	ldd	#$8080

INILOOP	std	,x++
	cmpx	#$1000
	bne	INILOOP

*	ldd	#$efef
*	std	$0a06
*	std	$0a26
*	std	$0a18
*	std	$0a38

	lda	#$8a
	sta	>COUNT

START	ldx	#$0fcc

	jsr	>CANDY

SYNC	lda	$ff03
	bpl	SYNC
	lda	$ff02

* start at bottom of screen
	ldd	#$9faf
	std	32,x
	std	34,x
	std	36,x
	std	38,x
	
	jsr	>CANDY

SYNC1	lda	$ff03
	bpl	SYNC1
	lda	$ff02

	jsr	>CANDY

* delay for 30fps simulation
SYNC130	lda	$ff03
	bpl	SYNC130
	lda	$ff02

	jsr	>CANDY

* delay for 20fps simulation
SYNC120	lda	$ff03
	bpl	SYNC120
	lda	$ff02

	ldd	#$9faf
	std	,x
	std	2,x
	std	4,x
	std	6,x

	ldd	#$af9f
	std	32,x
	std	34,x
	std	36,x
	std	38,x

LOOP	clr	$ffd9	hi-speed for redraw

	leax	-32,x

	ldd	#$9faf
	std	,x
	std	2,x
	std	4,x
	std	6,x

	ldd	#$af9f
	std	32,x
	std	34,x
	std	36,x
	std	38,x

	ldd	#$8080

	std	64,x
	std	66,x
	std	68,x
	std	70,x

	clr	$ffd8	lo-speed for display

	jsr	>CANDY

SYNC2	lda	$ff03
	bpl	SYNC2
	lda	$ff02

	jsr	>CANDY

* delay for 30fps simulation
SYNC230	lda	$ff03
	bpl	SYNC230
	lda	$ff02

	jsr	>CANDY

* delay for 20fps simulation
SYNC220	lda	$ff03
	bpl	SYNC220
	lda	$ff02

	cmpx	#$040c
	bne	LOOP

* erase last two lines at top of screen
	ldd	#$af9f
	std	,x
	std	2,x
	std	4,x
	std	6,x
	ldd	#$8080
	std	32,x
	std	34,x
	std	36,x
	std	38,x

	jsr	>CANDY

SYNC3	lda	$ff03
	bpl	SYNC3
	lda	$ff02

	jsr	>CANDY

* delay for 30fps simulation
SYNC330	lda	$ff03
	bpl	SYNC330
	lda	$ff02

	jsr	>CANDY

* delay for 20fps simulation
SYNC320	lda	$ff03
	bpl	SYNC320
	lda	$ff02

	ldd	#$8080
	std	,x
	std	2,x
	std	4,x
	std	6,x

CHKUART	lda	$ff69
	bita	#$08
	beq	RESTART
	lda	$ff68
	jmp	[$fffe]

RESTART	jmp	START

CANDY	ldd	#$0400
	tfr	d,y
	lda	>COUNT
	tfr	a,b
	adda	#$30
	ora	#$80
	eora	#$0f
	sta	>COUNT

FLOOP	std	,y
	std	$1e,y

	tfr	a,b
	adda	#$30
	ora	#$80
	eora	#$0f
	leay	$20,y

	cmpy	#$1000
	bne	FLOOP
	rts

COUNT	rmb	1

	end	INIT
