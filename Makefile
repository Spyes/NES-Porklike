all:
	ca65 src/porklike.asm -g -o src/porklike.o
	ld65 -o porklike.nes -C nes.cfg src/porklike.o --dbgfile porklike.dbg -Ln porklike.labels.txt
	rm -rf src/*.o
	python3 fceux_symbols.py

clean:
	rm *.nes* *.fdb *.dbg *.labels.txt

run:
	fceux porklike.nes