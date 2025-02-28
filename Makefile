clean:
	gprclean -ws -q -P debugging.gpr

build: clean
	gprbuild -g -p -P debugging.gpr

gdb: build
	powershell -File live-debug.ps1 -debugger "gdb"

gs: build
	powershell -File live-debug.ps1 -debugger "gnatstudio"

vs: build
	powershell -File live-debug.ps1 -debugger "vscode"
