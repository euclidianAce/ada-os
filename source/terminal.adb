with Debug_IO;

package body Terminal is
   procedure Clear is
   begin
      Dirty  := [others => [others => True]];
      Buffer := [others => [others => [' ', [Foreground_Color, Background_Color]]]];
   end Clear;

   procedure Flush is
   begin
      for Row in VGA_Console.Row'Range loop
         for Column in VGA_Console.Column'Range loop
            if Dirty (Row, Column) then
               VGA_Console.Put (
                  Buffer (Row, Column).Char, Column, Row,
                  Foreground => Buffer (Row, Column).Color.Foreground,
                  Background => Buffer (Row, Column).Color.Background);
               Dirty (Row, Column) := False;
            end if;
         end loop;
      end loop;
   end Flush;

   procedure Scroll (By : Positive) is
      use type VGA_Console.Row;
   begin
      if By >= Positive (VGA_Console.Row'Last) then
         Clear;
         Current_Row := VGA_Console.Row'First;
         return;
      end if;

      Dirty := [others => [others => True]];

      for Dest_Row in 1 .. VGA_Console.Row'Last - VGA_Console.Row (By) loop
         declare
            Src_Row : constant VGA_Console.Row := Dest_Row + VGA_Console.Row (By);
         begin
            for Column in VGA_Console.Column'Range loop
               Buffer (Dest_Row, Column) := Buffer (Src_Row, Column);
            end loop;
         end;
      end loop;

      for Row in VGA_Console.Row'Last - VGA_Console.Row (By) + 1 .. VGA_Console.Row'Last loop
         for Column in VGA_Console.Column'Range loop
            Buffer (VGA_Console.Row (Row), Column) := (' ', (Foreground_Color, Background_Color));
         end loop;
      end loop;
   end Scroll;

   procedure Increment_Row (By : VGA_Console.Row) is
      Current     : constant Integer := Integer (Current_Row);
      By_Int      : constant Integer := Integer (By);

      New_Row     : constant Integer := Current + By_Int;
      To_Scroll   : constant Integer := (if New_Row > Integer (VGA_Console.Row'Last) then
            New_Row - Integer (VGA_Console.Row'Last)
         else
            0);

      use type VGA_Console.Row;
   begin
      if To_Scroll > 0 then
         Scroll (Positive (To_Scroll));
         return;
      end if;

      if New_Row > Integer (VGA_Console.Row'Last) then
         Current_Row := VGA_Console.Row'Last;
      else
         Current_Row := VGA_Console.Row (New_Row);
      end if;
   end Increment_Row;

   procedure Increment_Column (By : VGA_Console.Column) is
      Current     : constant Integer := Integer (Current_Column);
      By_Int      : constant Integer := Integer (By);

      New_Column  : constant Integer := (Current + By_Int - 1) mod Integer (VGA_Console.Column'Last) + 1;
      Row_Delta   : constant Integer := (Current + By_Int - 1) / Integer (VGA_Console.Column'Last);
   begin
      Current_Column := VGA_Console.Column (New_Column);

      if Row_Delta /= 0 then
         Increment_Row (VGA_Console.Row (Row_Delta));
      end if;
   end Increment_Column;

   procedure Put (Char : Character) is
   begin
      if Char = Character'Val(10) then
         Current_Column := VGA_Console.Column'First;
         Increment_Row (1);
         return;
      end if;

      Buffer (Current_Row, Current_Column) := [
         Char  => Char,
         Color => [
            Foreground => Foreground_Color,
            Background => Background_Color]];
      Dirty (Current_Row, Current_Column) := True;
      Increment_Column (1);
   end Put;

   procedure Put (Message : String) is
   begin
      for C of Message loop
         Put (C);
      end loop;
   end Put;

   procedure Put_Line (Char : Character) is
   begin
      Put (Char);
      Increment_Row (1);
      Current_Column := VGA_Console.Column'First;
   end Put_Line;

   procedure Put_Line (Message : String) is
   begin
      Put (Message);
      Increment_Row (1);
      Current_Column := VGA_Console.Column'First;
   end Put_Line;
end Terminal;
