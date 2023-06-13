# ada-os

A toy os for playing around with Ada in a baremetal environment.

Based on the [osdev wiki's Ada Bare Bones](https://wiki.osdev.org/Ada_Bare_Bones). The code in the tutorial itself is fine, but the instructions for setting up the tooling were either outdated, not explained well enough for me, or just plain wrong. Since I struggled for many fruitless hours trying and failing to get gprbuild to work, the build system is a crappy shell script that just globs all `.adb` files and shoves them into `gcc`.

# Quick start

```console
$ cd ada-os
$ scripts/make-toolchain.sh
$ scripts/build.sh run
```

# Dependencies

 - `qemu` - to run the os
 - `grub2`, `xorriso` - to build the disk image
 - `mpfr`, `libmpc`, `isl`, `gmp` - to build the gcc cross compiler

For nix users, there is a `flake.nix` with a `devShell` that should provide all of these.

# TODO

 - [ ] Set up a real build system (I'd like to actually use `gprbuild`, but holy hell is there little to no documentation on this use case)
 - [ ] non text mode graphics
   - [ ] which then needs custom text rendering
 - [ ] PS/2 keyboard and mouse drivers
 - [ ] actual interrupt handlers
 - [ ] file system (probably ext2) + ELF reader for symbolic backtraces
 - [ ] APIC
   - why do we get a 64 bit efi table from the multiboot 2 info rather than the apic fields with the address of the RSDT/XSDT?
 - [ ] Memory allocator
 - [ ] Secondary stack
 - Things to figure out whether or not I care
   - [ ] user mode
   - [ ] virtual memory
