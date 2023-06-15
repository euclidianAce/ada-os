with System;

package Kernel is
   type Address_Array is array (Positive range <>) of System.Address;
   procedure Capture_Stack_Trace (
      Addresses : in out Address_Array) with Inline;

   procedure Panic with
      No_Return,
      Export,
      Convention => Asm,
      External_Name => "Kernel_Panic_Handler";

   procedure Interrupt_Handler with
      Export,
      Convention => Asm,
      External_Name => "Kernel_Interrupt_Handler";

   procedure Log (Message : String);
   procedure Read_Multiboot2_Info (Addr : System.Address);

   -- TODO: have a hardware abstraction package
   procedure Setup_IDT;
   procedure Setup_GDT;
   procedure Disable_VGA_Cursor;
end Kernel;
