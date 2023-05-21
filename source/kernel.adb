with VGA_Console;

package body Kernel is
   procedure Start is
   begin
      VGA_Console.Clear (VGA_Console.Blue);
      VGA_Console.Put (
         "Hello world!",
         VGA_Console.Column'First,
         VGA_Console.Row'First,
         Foreground => VGA_Console.White,
         Background => VGA_Console.Blue);
   end Start;
end Kernel;
