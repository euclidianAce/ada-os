#!/usr/bin/env sh

set -e

toolchain_dir="toolchain"
build_target="i686-elf"
host="x86_64-pc-linux-gnu"
concurrency=3

mkdir -p $toolchain_dir
build_prefix="$PWD/$toolchain_dir/cross/$build_target"
mkdir -p $build_prefix

binutils_version="2.40"
gcc_version="12.3.0"

make_binutils () {
	local dir="binutils-$binutils_version"
	fetch_and_extract \
		$dir \
		"https://ftp.gnu.org/gnu/binutils/$dir.tar.xz" \
		"$dir.tar.xz"

	pushd $dir

	./configure \
		--target="$build_target" \
		--prefix="$build_prefix" \
		--host="$host" \
		--disable-nls \
		--disable-multilib \
		--disable-shared \
		--with-sysroot

	make configure-host
	make -j $concurrency
	make -j $concurrency install

	popd
}

make_gcc () {
	local dir="gcc-$gcc_version"
	fetch_and_extract \
		$dir \
		"https://ftp.gnu.org/gnu/gcc/$dir/$dir.tar.xz" \
		"$dir.tar.xz"

	local gcc_dir="$PWD/$dir"
	# While not technically disallowed, gcc maintainers say in tree builds
	# are broken and not a priority to fix. Do an out of tree build
	local build_dir="$dir-build"
	mkdir -p $build_dir

	pushd $build_dir

	# To build a cross compiler with Ada support, we need an initial one with C support
	log "Building initial gcc"
	$gcc_dir/configure \
		--target="$build_target" \
		--prefix="$build_prefix" \
		--enable-languages="c" \
		--disable-multilib \
		--disable-shared \
		--disable-nls \
		--with-gmp="/usr/local" \
		--with-mpc="/usr/local" \
		--with-mpfr="/usr/local" \
		--without-headers

	make -j $concurrency all-gcc
	make -j $concurrency install-gcc

	log "Building gcc with Ada support"
	$gcc_dir/configure \
		--target="$build_target" \
		--prefix="$build_prefix" \
		--enable-languages="c,c++,ada" \
		--disable-libada \
		--disable-nls \
		--disable-threads \
		--disable-multilib \
		--disable-shared \
		--with-gmp="/usr/local" \
		--with-mpc="/usr/local" \
		--with-mpfr="/usr/local" \
		--without-headers

	make -j $concurrency all-gcc
	make -j $concurrency install-strip-gcc

	popd
}

log () {
	echo -n -e " \x1b[36m[Toolchain]\x1b[0m "
	echo $@
}

fetch_and_extract () {
	local dir=$1
	local url=$2
	local tarball="$3"

	if [ -e $tarball ]; then
		log "Already have $tarball"
	else
		log "Fetching $tarball..."
		curl "$url" > $tarball
	fi

	if [ -e $dir ]; then
		log "Already have $tarball extracted"
	else
		log "Extracting..."
		tar xf "$tarball"
	fi
}

pushd $toolchain_dir

make_binutils
make_gcc

popd
