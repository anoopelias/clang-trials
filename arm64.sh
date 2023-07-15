
which clang
clang -S -emit-llvm main.c
clang -S -emit-llvm util.c

which llc
llc main.ll
llc util.ll

which as
as -o main.o main.s
as -o util.o util.s


which ld64.lld
# ld -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX13.sdk -o a.out main.o util.o -lSystem /opt/homebrew/Cellar/llvm/16.0.6/lib/clang/16/lib/darwin/libclang_rt.osx.a
ld64.lld -arch arm64 -platform_version macos 13.0.0 13.0.0 -syslibroot /Library/Developer/CommandLineTools/SDKs/MacOSX13.sdk -o a.out main.o util.o -lSystem /opt/homebrew/Cellar/llvm/16.0.6/lib/clang/16/lib/darwin/libclang_rt.osx.a

./a.out
