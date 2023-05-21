.global startup
# multiboot header
.set ALIGN,   1 << 0
.set MEMINFO, 1 << 1  # provide memory map
.set FLAGS, ALIGN | MEMINFO
.set MAGIC, 0x1badb002
.set CHECKSUM, -(MAGIC + FLAGS)

header:
.align 4, 0x90

.long MAGIC
.long FLAGS
.long CHECKSUM

# initial kernel stack
.set STACKSIZE, 0x4000 # 16k
.lcomm stack, STACKSIZE # reserve stack on 32 bit boundary
.comm mbd, 4 # reserve symbol mbd
.comm magic, 4 # reserve symbol magic

startup:
	movl $(stack + STACKSIZE), %esp # setup stack

	movl %eax, magic # indicates that the os was loaded by a multiboot compliant boot loader
	movl %ebx, mbd # address of multiboot info

	call Kernel_Start

.global __gnat_rcheck_CE_Invalid_Data
__gnat_rcheck_CE_Invalid_Data:

.global __gnat_rcheck_CE_Overflow_Check
__gnat_rcheck_CE_Overflow_Check:

.global __gnat_rcheck_CE_Range_Check
__gnat_rcheck_CE_Range_Check:

	cli

hang:
	hlt
	jmp hang
