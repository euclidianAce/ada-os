#!/usr/bin/env sh

# gpr build was a complete NIGHTMARE to configure
# this shell script is stupidly simple :P

TOOLCHAIN_BIN="../toolchain/cross/i686-elf/bin"
GCC="$TOOLCHAIN_BIN/i686-elf-gcc"
AS="$TOOLCHAIN_BIN/i686-elf-as"
LD="$TOOLCHAIN_BIN/i686-elf-ld"
ADA_RUNTIME_DIR="../ada-runtime"

ADA_FLAGS="\
-gnatwa \
-gnaty3 \
-gnatya \
-gnatyA \
-gnatyB \
-gnatyb \
-gnatyB \
-gnatyC \
-gnatyd \
-gnatyD \
-gnatye \
-gnatyf \
-gnatyh \
-gnatyi \
-gnatyI \
-gnatyk \
-gnatyl \
-gnatyL5 \
-gnatyM120 \
-gnatyn \
-gnatyO \
-gnatyo \
-gnatyp \
-gnatyr \
-gnatyS \
-gnatyt \
-gnatyu \
-gnatyx \
-gnatW8 \
-gnatw.X"

######################

compile_ada () {
	$GCC -nostdlib -nostdinc -x ada -gnat2022 -ffunction-sections -fdata-sections --RTS=$ADA_RUNTIME_DIR -gnatec=../gnat.adc -c $@
}

compile_asm () {
	$AS --32 -march=i386 $@
}

link () {
	$LD --gc-sections $@
}

#####################

set -xe

mkdir -p build
cd build

mkdir -p disk/boot/grub
compile_ada -gnatg ../ada-runtime/adainclude/*.adb -gnatyN -Os
compile_ada ../source/*.adb -Os -g $ADA_FLAGS
compile_asm ../source/startup.s -o startup.o
link -o disk/boot/kernel.elf -T ../source/linker.ld *.o
../toolchain/cross/i686-elf/bin/i686-elf-objcopy --only-keep-debug disk/boot/kernel.elf kernel.sym
cp ../grub.cfg disk/boot/grub
grub-mkrescue -o boot.img disk

if [ "$1" = "run" ]; then
	shift
	qemu-system-i386 -cdrom boot.img -serial stdio -s -no-reboot -d cpu_reset "$@"
fi
