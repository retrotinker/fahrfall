.PHONY: all clean

TARGETS=fahrfall.bin fahrfall.s19 fahrfall.dsk fahrfall.wav \
	fahrfall.ccc fahrfall.8k

all: $(TARGETS)

%.bin: %.asm
	lwasm -DDAC -9 -l -f decb -o $@ $<

%.s19: %.asm
	lwasm -DGMC -DMON09 -9 -l -f srec -o $@ $<

%.ccc: %.asm
	lwasm -DGMC -DROM -9 -l -f raw -o $@ $<

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

fahrfall.8k: fahrfall.ccc
	rm -f $@
	dd if=/dev/zero bs=8k count=1 | \
		tr '\000' '\377' > $@
	dd if=$< of=$@ conv=notrunc

clean:
	rm -f $(TARGETS)
