clean:
	gprclean -ws -q -P debugging.gpr

build: clean
	gprbuild -g -p -P debugging.gpr

gdb: build
	DEBUGGER=gdb powershell -File live-debug.ps1

gs: build
	DEBUGGER=gnatstudio powershell -File live-debug.ps1

vs: build
	DEBUGGER=vscode powershell -File live-debug.ps1
