# clang --target=wasm32-wasi --sysroot ~/wspace/wasi-libc/dist -Wl,--no-entry main.c util.c

C_FILES = $(wildcard *.c)
OBJ_FILES = $(C_FILES:%.c=%.o)

clean:
	rm -f main.ll main.o main.s util.ll util.o util.s main.wasm

%.o: %.c
	clang \
		-cc1 \
		-triple wasm32-unknown-wasi \
		-emit-obj \
		-disable-free \
		-clear-ast-before-backend \
		-disable-llvm-verifier \
		-discard-value-names \
		-main-file-name main.c \
		-mrelocation-model static \
		-mframe-pointer=none \
		-ffp-contract=on \
		-fno-rounding-math \
		-mconstructor-aliases \
		-target-cpu generic \
		-fvisibility=hidden \
		-mllvm \
		-treat-scalable-fixed-error-as-warning \
		-debugger-tuning=gdb \
		-target-linker-version 857.1 \
		-fcoverage-compilation-dir=/Users/anoopelias/wspace/clang-trials \
		-resource-dir /opt/homebrew/Cellar/llvm/16.0.6/lib/clang/16 \
		-isysroot /Users/anoopelias/wspace/wasi-libc/dist \
		-internal-isystem /opt/homebrew/Cellar/llvm/16.0.6/lib/clang/16/include \
		-internal-isystem /Users/anoopelias/wspace/wasi-libc/dist/include/wasm32-wasi \
		-internal-isystem /Users/anoopelias/wspace/wasi-libc/dist/include \
		-fdebug-compilation-dir=/Users/anoopelias/wspace/clang-trials \
		-ferror-limit 19 \
		-fgnuc-version=4.2.1 \
		-fcolor-diagnostics \
		-o $@ \
		-x c $<

main.wasm: main.o util.o
	wasm-ld \
		-m wasm32 \
		-L/Users/anoopelias/wspace/wasi-libc/dist/lib/wasm32-wasi \
		/Users/anoopelias/wspace/wasi-libc/dist/lib/wasm32-wasi/crt1-command.o \
		--no-entry \
		main.o util.o \
		-lc /opt/homebrew/Cellar/llvm/16.0.6/lib/clang/16/lib/wasi/libclang_rt.builtins-wasm32.a \
		-o main.wasm

all: clean main.wasm

run: all
	${WAMR_PATH}/product-mini/platforms/darwin/build/iwasm main.wasm
