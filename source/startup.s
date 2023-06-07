.intel_syntax noprefix

.global startup
.global kernel_stack_pointer
.global hang
.global interrupt_service_request_wrapper
.global multiboot2_header

multiboot2_header:
.align 8
.long 0xe85250d6 # magic number
.long 0 # i386 protected mode
.long multiboot2_header_end - multiboot2_header # header length (in bytes)
.long -(0xe85250d6 + (multiboot2_header_end - multiboot2_header)) # checksum

# end tag
.short 0
.short 0
.long 0

multiboot2_header_end:

# tags

# initial kernel stack
.set STACKSIZE, 0x4000  # 16k
.lcomm kernel_stack_pointer, STACKSIZE # reserve stack on 32 bit boundary

startup:
	lea esp, [kernel_stack_pointer + STACKSIZE] # setup stack
	xor ebp, ebp
	# ebx contains info pointer
	# eax contains magic number
	; push ebx
	; push eax
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
