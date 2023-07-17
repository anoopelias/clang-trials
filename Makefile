# clang --target=wasm32-wasi --sysroot ~/wspace/wasi-libc/dist -Wl,--no-entry main.c util.c

OS := $(shell uname -s | tr A-Z a-z)
RESOURCE_DIR = $(shell clang -print-resource-dir)
C_FILES = $(wildcard *.c)
OBJ_FILES = $(C_FILES:%.c=%.o)

all: clean main.wasm

clean:
	rm -f main.ll main.o main.s util.ll util.o util.s main.wasm

%.ll: %.c
	clang -cc1 -triple wasm32-unknown-wasi -emit-llvm \
		-internal-isystem $(RESOURCE_DIR)/include \
		-internal-isystem $(WASI_LIBC_PATH)/dist/include \
		-o $@ $<

main.o: main.ll
	llc -march=wasm32 $< -filetype=obj

util.o: util.ll
	llc -march=wasm32 $< -filetype=obj

main.wasm: main.o util.o
	wasm-ld \
		-L $(WASI_LIBC_PATH)/dist/lib/wasm32-wasi \
		$(WASI_LIBC_PATH)/dist/lib/wasm32-wasi/crt1-command.o main.o util.o \
		-lc $(WASI_SDK_PATH)/lib/clang/16/lib/wasi/libclang_rt.builtins-wasm32.a \
		-o $@

run: all
	$(WAMR_PATH)/product-mini/platforms/$(OS)/build/iwasm main.wasm
