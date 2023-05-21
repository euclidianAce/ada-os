with VGA_Console;
with Debug_IO;
with Serial;

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
   end Start;
end Kernel;
