package Kernel is
   procedure Start;
   pragma Export (
      Convention => C,
      Entity => Start,
      External_Name => "Kernel_Start");
end Kernel;
