
OS := $(shell uname -s | tr A-Z a-z)

all: main.wasm

main.wasm:
	rustc +nightly --target wasm32-wasi main.rs

run: all
	$(WAMR_PATH)/product-mini/platforms/$(OS)/build/iwasm main.wasm

