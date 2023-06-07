.intel_syntax noprefix

.global startup
.global kernel_stack_pointer
.global hang
.global interrupt_service_request_wrapper
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
.set STACKSIZE, 0x4000  # 16k
.lcomm kernel_stack_pointer, STACKSIZE # reserve stack on 32 bit boundary
.comm mbd, 4            # reserve symbol mbd
.comm magic, 4          # reserve symbol magic

startup:
	lea esp, [kernel_stack_pointer + STACKSIZE] # setup stack

	mov eax, magic              # indicates that the os was loaded by a multiboot compliant boot loader
	mov ebx, mbd                # address of multiboot info

	xor ebp, ebp

	call Kernel_Start

hang:
	cli

1:
	hlt
	jmp 1b

# TODO: give panic some tagged union with the data given to these runtime functions

.global __gnat_rcheck_CE_Invalid_Data
__gnat_rcheck_CE_Invalid_Data:

.global __gnat_rcheck_CE_Overflow_Check
__gnat_rcheck_CE_Overflow_Check:

.global __gnat_rcheck_CE_Range_Check
__gnat_rcheck_CE_Range_Check:

.global __gnat_rcheck_CE_Index_Check
__gnat_rcheck_CE_Index_Check:

	jmp Kernel_Panic_Handler

.global reload_segments
reload_segments:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	jmp 0x08:.reload_cs
.reload_cs:
	ret

.align 4
interrupt_service_request_wrapper:
	pusha
	call Kernel_Interrupt_Handler
	popa
	iret
