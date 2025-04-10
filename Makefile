clean:
	rm -rf obj
build: clean
	gprbuild -g -p -P debugging.gpr
vs: build
	powershell -File debugging.ps1