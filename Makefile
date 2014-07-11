.PHONY: all clean

TARGETS=fahrfall.bin fahrfall.s19 fahrfall.dsk fahrfall.wav fahrfall.ccc

all: $(TARGETS)

%.bin: %.asm
	lwasm -9 -l -f decb -o $@ $<

%.s19: %.asm
	lwasm -DMON09 -9 -l -f srec -o $@ $<

%.ccc: %.asm
	lwasm -DROM -9 -l -f raw -o $@ $<

%.wav: %.bin
	cecb bulkerase $@
	cecb copy -2 -b -g $< \
		$(@),$$(echo $< | cut -c1-8 | tr [:lower:] [:upper:])

fahrfall.dsk: fahrfall.bin fahrfall.bas LICENSE.TXT
	rm -f $@
	decb dskini $@
	decb copy -2 -b fahrfall.bin $@,FAHRFALL.BIN
	decb copy -0 -b -l -t fahrfall.bas $@,FAHRFALL.BAS
	decb copy -3 -a -l LICENSE.TXT $@,LICENSE.TXT

clean:
	rm -f $(TARGETS)
