with System;

package Kernel is
   procedure Start;
   pragma Export (
      Convention    => Asm,
      Entity        => Start,
      External_Name => "Kernel_Start");

   procedure Panic with No_Return;
   pragma Export (
      Convention    => Asm,
      Entity        => Panic,
      External_Name => "Kernel_Panic_Handler");

   procedure Interrupt_Handler;
   pragma Export (
      Convention    => Asm,
      Entity        => Interrupt_Handler,
      External_Name => "Kernel_Interrupt_Handler");
end Kernel;
