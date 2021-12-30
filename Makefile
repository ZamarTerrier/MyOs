# $@ = target file
# $< = first dependency
# $^ = all dependencies

# First rule is the one executed when no parameters are fed to the Makefile
all: run

#pm_code.bin: pm_code.o 
#ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary 


pm_code.bin: pm_code.asm
	nasm $< -f bin -o $@

bl.bin: bl.asm
	nasm $< -f bin -o $@

os-image.bin: bl.bin pm_code.bin
	cat $^ > $@

run: os-image.bin
	qemu-system-i386 -fda $<

clean:
	$(RM) *.bin *.o *.dis
