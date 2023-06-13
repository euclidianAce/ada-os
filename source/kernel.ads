with System;
with Integers;

package Kernel is
   type Address_Array is array (Positive range <>) of System.Address;
   procedure Capture_Stack_Trace (
      Addresses : in out Address_Array) with Inline;

   procedure Start (
      Magic     : Integers.U32;
      Info_Addr : System.Address) with
      Export,
      Convention => C,
      External_Name => "Kernel_Start";

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
end Kernel;
