package body VGA_Console is
   procedure Clear (Color : Background_Color := Black) is
   begin
      for Y in Row'Range loop
         for X in Column'Range loop
            Put (' ', X, Y, Background => Color);
         end loop;
      end loop;
   end Clear;

   procedure Put (
      Char       : Character;
      X          : Column;
      Y          : Row;
      Foreground : Foreground_Color := White;
      Background : Background_Color := Black) is
   begin
      Video_Memory (Y, X) := (
         Char => Char,
         Color => (
            Foreground => Foreground,
            Background => Background));
   end Put;

   procedure Put (
      Str        : String;
      X          : Column;
      Y          : Row;
      Foreground : Foreground_Color := White;
      Background : Background_Color := Black) is
   begin
      for I in Str'Range loop
         Put (
            Str (I),
            X + Column (I) - 1,
            Y,
            Foreground,
            Background);
      end loop;
   end Put;

end VGA_Console;
