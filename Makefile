
run: 
	odin run src

debug:
	odin run src -debug -o:none -sanitize:address

debug-gdb:
	odin build src -debug -o:none -out:src.bin
	gdb -ex run --args ./src.bin

release:
	odin build src -o:speed -out:raytracer