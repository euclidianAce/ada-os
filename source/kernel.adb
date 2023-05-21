with VGA_Console;
with Debug_IO;
with Serial;
with System.Storage_Elements;

use System.Storage_Elements;
use type Serial.Port_Address;
use type VGA_Console.Cursor_State;

package body Kernel is
   procedure Start is
   begin
      VGA_Console.Clear (VGA_Console.Blue);
      VGA_Console.Put (
         "Hello world!", 1, 1,
         Foreground => VGA_Console.White,
         Background => VGA_Console.Blue);

      if not Serial.Initialize (Serial.Com1) then
         VGA_Console.Put (
            "Unable to initialize serial port :(", 1, VGA_Console.Row'Last,
            Foreground => VGA_Console.White,
            Background => VGA_Console.Red);
      end if;

      Debug_IO.Put_Line ("Hello world!");

      declare
         Aliased_Byte : Storage_Element := Serial.In_B (VGA_Console.Misc_Output_Register_Read);

         Reg : VGA_Console.Misc_Output_Register
            with Address => Aliased_Byte'Address;
         Cursor_Reg : VGA_Console.Cursor_Start_Register
            with Address => Aliased_Byte'Address;

         Addr_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
            16#3d4# else 16#3b4#);
         Data_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
            16#3d5# else 16#3b5#);
      begin
         Serial.Out_B (Addr_Port, 16#0a#);
         Aliased_Byte := Serial.In_B (Data_Port);

         if Cursor_Reg.State = VGA_Console.Enabled then
            Debug_IO.Put_Line ("Cursor is enabled");
         else
            Debug_IO.Put_Line ("Cursor is disabled");
         end if;

         Cursor_Reg.State := VGA_Console.Disabled;
         Serial.Out_B (Data_Port, Aliased_Byte);
         Debug_IO.Put_Line ("Cursor should now be disabled");
      end;
   end Start;
end Kernel;
