.PHONY: all clean

CFLAGS=-Wall

TARGETS=fahrfall.bin fahrfall.s19 fahrfall.dsk fahrfall.wav
EXTRA=fahrfall.ram

all: $(TARGETS)

%.bin: %.asm
	mamou -mb -tb -l -y -o$@ $<

%.s19: %.asm
	mamou -mb -ts -l -y -o$@ $<

%.ram: %.asm
	mamou -mr -tb -l -y -o$@ $<

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

fahrfall.dsk: fahrfall.bin fahrfall.bas LICENSE.TXT
	decb dskini fahrfall.dsk
	decb copy -2 -b fahrfall.bin fahrfall.dsk,FAHRFALL.BIN
	decb copy -0 -b -l -t fahrfall.bas fahrfall.dsk,FAHRFALL.BAS
	decb copy -3 -a -l LICENSE.TXT fahrfall.dsk,LICENSE.TXT

fahrfall.wav: fahrfall.ram
	makewav -r -nFAHRFALL -2 -a -d0x0041 -e0x0041 -o$@ $<

clean:
	rm -f $(TARGETS) $(EXTRA)
