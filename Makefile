clean:
	rm -rf obj
build: clean
	gprbuild -g -p -P debugging.gpr
gdb: build
	powershell -File debugging.ps1 -debugger "gdb"
gs: build
	powershell -File debugging.ps1 -debugger "gnatstudio"
vs: build
	powershell -File debugging.ps1 -debugger "vscode"