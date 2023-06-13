procedure Last_Chance_Handler (
   Source_Location : System.Address;
   Line            : Integer) is
   pragma Unreferenced (Source_Location, Line);

   procedure Panic with
      No_Return,
      Import,
      Convention => Asm,
      External_Name => "Kernel_Panic_Handler";
begin
   Panic;
end Last_Chance_Handler;
