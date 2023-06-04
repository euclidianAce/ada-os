with Serial;
with VGA_Console;

package Terminal is
   Current_Column   : VGA_Console.Column           := VGA_Console.Column'First;
   Current_Row      : VGA_Console.Row              := VGA_Console.Row'First;
   Foreground_Color : VGA_Console.Foreground_Color := VGA_Console.White;
   Background_Color : VGA_Console.Background_Color := VGA_Console.Black;

   procedure Clear;
   procedure Flush;

   procedure Put (Char : Character);
   procedure Put (Message : String);

   procedure Put_Line (Char : Character);
   procedure Put_Line (Message : String);

   procedure Scroll (By : Positive);

private
   type Dirty_Cells is array (
      VGA_Console.Row, VGA_Console.Column) of Boolean;
   pragma Pack (Dirty_Cells);

   Buffer : VGA_Console.Screen_Cells := [
      others => [others => [' ', [VGA_Console.Black, VGA_Console.Black]]]];
   Dirty  : Dirty_Cells := [others => [others => True]];

end Terminal;
