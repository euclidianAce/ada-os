with System;
with System.Machine_Code;

package body Descriptor_Tables.Global is
   procedure Load (From : Register) is
   begin
      System.Machine_Code.Asm (
         "lgdt %0",
         Inputs   => Register'Asm_Input ("m", From),
         Volatile => True);
   end Load;

   procedure Set_Base (
      Descriptor : in out Segment_Descriptor;
      Base       :        U32) is

      type M32 is mod 2 ** 32;
      pragma Provide_Shift_Operators (M32);
   begin
      Descriptor.Base_0_23 := U24 (M32 (Base) and 16#ff_ffff#);
      Descriptor.Base_24_31 := U8 (Shift_Right (M32 (Base), 24));
   end Set_Base;

   procedure Set_Limit (
      Descriptor : in out Segment_Descriptor;
      Limit      :        U20) is

      type M20 is mod 2 ** 20;
   begin
      Descriptor.Segment_Limit_0_15 := U16 (M20 (Limit) and 16#ffff#);
      Descriptor.Segment_Limit_16_19 := U4 (M20 (Limit) / 2 ** 16);
   end Set_Limit;
end Descriptor_Tables.Global;
