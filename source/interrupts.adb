with System.Machine_Code;
with Ada.Unchecked_Conversion;

package body Interrupts is
   procedure Disable is
   begin
      System.Machine_Code.Asm ("cli", Volatile => True);
   end Disable;

   procedure Enable is
   begin
      System.Machine_Code.Asm ("sti", Volatile => True);
   end Enable;

   -- LIDT
   procedure Load_Descriptor_Table_Register (Register : Descriptor_Tables.Register) is
   begin
      System.Machine_Code.Asm (
         "lidt %0",
         Inputs => Descriptor_Tables.Register'Asm_Input ("m", Register),
         Volatile => True);
   end Load_Descriptor_Table_Register;

   procedure Set_Address (
      On      : in out Gate;
      Address :        System.Address) is

      type U32 is mod 2 ** 32;
      pragma Provide_Shift_Operators (U32);
      function Convert is new Ada.Unchecked_Conversion (System.Address, U32);

      Int_Addr : constant U32 := Convert (Address);
   begin
      On.Offset_0_15  := U16 (Int_Addr and 16#ffff#);
      On.Offset_16_31 := U16 (Shift_Right (Int_Addr, 16));
   end Set_Address;
end Interrupts;
