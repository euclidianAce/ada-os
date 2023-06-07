with System.Machine_Code;
with System.Storage_Elements;
with Ada.Unchecked_Conversion;
with Serial;

package body Interrupts is
   procedure Disable is
   begin
      System.Machine_Code.Asm ("cli", Volatile => True);
   end Disable;

   procedure Disable_Non_Maskable is
      use type System.Storage_Elements.Storage_Element;
      E : System.Storage_Elements.Storage_Element;
   begin
      Serial.Out_B (
         16#70#,
         Serial.In_B (16#70#) or 16#7F#);
      E := Serial.In_B (16#71#);
      pragma Unreferenced (E);
   end Disable_Non_Maskable;

   procedure Enable is
   begin
      System.Machine_Code.Asm ("sti", Volatile => True);
   end Enable;

   procedure Enable_Non_Maskable is
      use type System.Storage_Elements.Storage_Element;
      E : System.Storage_Elements.Storage_Element;
   begin
      Serial.Out_B (
         16#70#,
         Serial.In_B (16#70#) and 16#7F#);
      E := Serial.In_B (16#71#);
      pragma Unreferenced (E);
   end Enable_Non_Maskable;

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
