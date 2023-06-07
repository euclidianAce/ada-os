package body Integers is
   function Hex_Image (Value : U32) return Hex_String is
      Result : Hex_String := "0000_0000";
      Acc : U32 := Value;

      subtype String_Index is Integer range 1 .. 9;
      type Hex_Digit is range 0 .. 15;

      Hex_Characters : constant array (Hex_Digit) of Character := "0123456789abcdef";
      Index : String_Index := Result'Last;
   begin
      while Acc > 0 loop
         declare
            D : constant Hex_Digit := Hex_Digit (Acc mod 16);
         begin
            Acc := Acc / 16;

            Result (Index) := Hex_Characters (D);
            exit when Index = String_Index'First;
            Index := @ - 1;

            if Index = 5 then
               Index := 4;
            end if;
         end;
      end loop;

      return Result;
   end Hex_Image;
end Integers;
