#!/usr/bin/env sh

# gpr build was a complete NIGHTMARE to configure
# this shell script is stupidly simple :P

TOOLCHAIN_BIN="../toolchain/cross/i686-elf/bin"
GCC="$TOOLCHAIN_BIN/i686-elf-gcc"
AS="$TOOLCHAIN_BIN/i686-elf-as"
LD="$TOOLCHAIN_BIN/i686-elf-ld"
ADA_RUNTIME_DIR="../ada-runtime"

######################

compile_ada () {
	$GCC -x ada --RTS=$ADA_RUNTIME_DIR -c $@
}

compile_asm () {
	$AS $@
}

link () {
	$LD $@
}

#####################

set -xe

mkdir -p build
cd build

mkdir -p disk/boot/grub
compile_ada ../source/vga_console.adb
compile_ada ../source/kernel.adb
compile_asm ../source/startup.s -o startup.o
link -o disk/boot/kernel.elf -T ../source/linker.ld vga_console.o kernel.o startup.o
cp ../grub.cfg disk/boot/grub
grub-mkrescue -o boot.img disk
