# clang --target=wasm32-wasi --sysroot ~/wspace/wasi-libc/dist -Wl,--no-entry main.c util.c

C_FILES = $(wildcard *.c)
OBJ_FILES = $(C_FILES:%.c=%.o)

all: clean main.wasm

clean:
	rm -f main.ll main.o main.s util.ll util.o util.s main.wasm

%.o: %.c
	clang -cc1 -triple wasm32-unknown-wasi -emit-obj \
		-internal-isystem /opt/homebrew/Cellar/llvm/16.0.6/lib/clang/16/include \
		-internal-isystem /Users/anoopelias/wspace/wasi-libc/dist/include \
		-o $@ $<

main.wasm: main.o util.o
	wasm-ld \
		-m wasm32 \
		-L/Users/anoopelias/wspace/wasi-libc/dist/lib/wasm32-wasi \
		/Users/anoopelias/wspace/wasi-libc/dist/lib/wasm32-wasi/crt1-command.o \
		--no-entry \
		main.o util.o \
		-lc /opt/homebrew/Cellar/llvm/16.0.6/lib/clang/16/lib/wasi/libclang_rt.builtins-wasm32.a \
		-o $@

run: all
	${WAMR_PATH}/product-mini/platforms/darwin/build/iwasm main.wasm
