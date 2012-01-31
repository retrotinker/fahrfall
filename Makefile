.PHONY: all clean

CFLAGS=-Wall

TARGETS=fahrfall.bin fahrfall.s19 fahrfall.dsk

all: $(TARGETS)

%.bin: %.asm
	mamou -mb -tb -l -y -o$@ $<

%.s19: %.asm
	mamou -mb -ts -l -y -o$@ $<

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

fahrfall.dsk: fahrfall.bin fahrfall.bas LICENSE.TXT
	decb dskini fahrfall.dsk
	decb copy -2 -b fahrfall.bin fahrfall.dsk,FAHRFALL.BIN
	decb copy -0 -b -l -t fahrfall.bas fahrfall.dsk,FAHRFALL.BAS
	decb copy -3 -a -l LICENSE.TXT fahrfall.dsk,LICENSE.TXT

clean:
	rm $(TARGETS)
