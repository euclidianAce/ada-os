with VGA_Console;
with Debug_IO;
with Serial;
with System.Storage_Elements;

use System.Storage_Elements;
use type Serial.Port_Address;
use type VGA_Console.Cursor_State;

package body Kernel is

   procedure Log (Message : String) is
      Prefix : constant String :=
         (Character'Val (16#1b#), '[', '3', '7', 'm') &
         "Kernel: " &
         (Character'Val (16#1b#), '[', '0', 'm');
   begin
      Debug_IO.Put (Prefix);
      Debug_IO.Put_Line (Message);
      Terminal.Put_Line (Message);
      Terminal.Flush;
   end Log;



   procedure Start is
   begin
      if not Serial.Initialize (Serial.Com1) then
         VGA_Console.Put (
            "Unable to initialize serial port :(", 1, VGA_Console.Row'Last,
            Foreground => VGA_Console.White,
            Background => VGA_Console.Red);
         return;
      end if;

      Terminal.Foreground_Color := VGA_Console.White;
      Terminal.Background_Color := VGA_Console.Blue;

      Terminal.Clear;
      Terminal.Flush;

      declare
         Aliased_Byte : Storage_Element := Serial.In_B (VGA_Console.Misc_Output_Register_Read);

         Reg : VGA_Console.Misc_Output_Register
            with Address => Aliased_Byte'Address;
         pragma Import (Ada, Reg);
         Cursor_Reg : VGA_Console.Cursor_Start_Register
            with Address => Aliased_Byte'Address;
         pragma Import (Ada, Cursor_Reg);

         Addr_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
            16#3d4# else 16#3b4#);
         Data_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
            16#3d5# else 16#3b5#);
      begin
         Serial.Out_B (Addr_Port, 16#0a#);
         Aliased_Byte := Serial.In_B (Data_Port);

         if Cursor_Reg.State = VGA_Console.Enabled then
            Log ("Cursor is enabled");
         else
            Log ("Cursor is disabled");
         end if;

         Cursor_Reg.State := VGA_Console.Disabled;
         -- Cursor_Reg.Scan_Line_Start := 0;

         Serial.Out_B (Data_Port, Aliased_Byte);
         Log ("Cursor should now be disabled");
      end;
   end Start;

   procedure Panic is
      procedure Hang;
      pragma No_Return (Hang);
      pragma Import (
         Convention => Asm,
         Entity => Hang,
         External_Name => "hang");
   begin
      Debug_IO.Put_Line ("Panic! (Todo, get panic info)");

      -- VGA_Console.Clear (VGA_Console.Red);
      VGA_Console.Put (
         "Kernel Panic! :(",
         1, VGA_Console.Row'Last,
         Foreground => VGA_Console.White,
         Background => VGA_Console.Red);

      -- VGA_Console.Put (
         -- " * TODO: dump some sorta stack trace here?",
         -- 2, 3,
         -- Foreground => VGA_Console.White,
         -- Background => VGA_Console.Red);

      -- declare -- Dump a backtrace (just of addresses for now)
         -- Row : VGA_Console.Row := 3;
         -- BP  : System.Address;
      -- begin
         -- System.Machine_Code.Asm (
            -- "mov %0, ebp",
            -- Outputs  => System.Address'Asm_Output (BP, "g"),
            -- Volatile => True);
      -- end;

      Hang;
   end Panic;
   -- Very crappy impl to satisfy generated code
   procedure Memory_Copy (
      Destination : System.Address;
      Source      : System.Address;
      Units       : System.Storage_Elements.Storage_Count) is

      type Elements is array (1 .. Units) of System.Storage_Elements.Storage_Element;

      Destination_Elements : Elements with Address => Destination;
      Source_Elements      : Elements with Address => Source;

      pragma Import (Ada, Destination_Elements);
      pragma Import (Ada, Source_Elements);
   begin
      for I in 1 .. Units loop
         Destination_Elements (I) := Source_Elements (I);
      end loop;
   end Memory_Copy;

end Kernel;
