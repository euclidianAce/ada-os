with Serial;
with VGA_Console;
with System.Storage_Elements;

use System.Storage_Elements;

package body Debug_IO is
   procedure Put (Message : String) is
      Elements : Storage_Array (1 .. Message'Length)
         with Address => Message'Address;
   begin
      for Element of Elements loop
         Serial.Write (Serial.Com1, Element);
      end loop;
   end Put;

   procedure Put (Message : Character) is
      Element : Storage_Element
         with Address => Message'Address;
   begin
      Serial.Write (Serial.Com1, Element);
   end Put;

   procedure Put_Line (Message : String) is
   begin
      Put (Message);
      Serial.Write (Serial.Com1, 10);
   end Put_Line;

   procedure Put_Line (Message : Character) is
   begin
      Put (Message);
      Serial.Write (Serial.Com1, 10);
   end Put_Line;

-- begin
   -- if not Serial.Initialize (Serial.Com1) then
      -- VGA_Console.Put (
         -- "Unable to initialize serial output",
         -- 1, VGA_Console.Row'Last,
         -- Foreground => VGA_Console.White,
         -- Background => VGA_Console.Red);
   -- end if;
end Debug_IO;
