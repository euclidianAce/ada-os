with System;

package VGA_Console with Preelaborate is
   type Background_Color is (
      Black,
      Blue,
      Green,
      Cyan,
      Red,
      Magenta,
      Brown,
      Light_Gray);

   for Background_Color use (
      Black      => 0,
      Blue       => 1,
      Green      => 2,
      Cyan       => 3,
      Red        => 4,
      Magenta    => 5,
      Brown      => 6,
      Light_Gray => 7);

   for Background_Color'Size use 4;

   type Foreground_Color is (
      Black,
      Blue,
      Green,
      Cyan,
      Red,
      Magenta,
      Brown,
      Light_Grey,
      Dark_Grey,
      Light_Blue,
      Light_Green,
      Light_Cyan,
      Light_Red,
      Light_Magenta,
      Yellow,
      White);

   for Foreground_Color use (
      Black         => 0,
      Blue          => 1,
      Green         => 2,
      Cyan          => 3,
      Red           => 4,
      Magenta       => 5,
      Brown         => 6,
      Light_Grey    => 7,
      Dark_Grey     => 8,
      Light_Blue    => 9,
      Light_Green   => 10,
      Light_Cyan    => 11,
      Light_Red     => 12,
      Light_Magenta => 13,
      Yellow        => 14,
      White         => 15);

   for Foreground_Color'Size use 4;

   type Cell_Color is
      record
         Foreground : Foreground_Color;
         Background : Background_Color;
      end record;

   for Cell_Color use
      record
         Foreground at 0 range 0 .. 3;
         Background at 0 range 4 .. 7;
      end record;

   for Cell_Color'Size use 8;

   type Cell is
      record
         Char  : Character;
         Color : Cell_Color;
      end record;

   for Cell'Size use 16;

   Screen_Width  : constant := 80;
   Screen_Height : constant := 25;

   type Row    is range 1 .. Screen_Height;
   type Column is range 1 .. Screen_Width;
   type Screen_Cells is array (Row, Column) of Cell;
   pragma Pack (Screen_Cells);

   Video_Memory : Screen_Cells;

   for Video_Memory'Address use System'To_Address (16#000B_8000#);
   pragma Import (Ada, Video_Memory);

   procedure Put (
      Char       : Character;
      X          : Column;
      Y          : Row;
      Foreground : Foreground_Color := White;
      Background : Background_Color := Black);

   -- Str must fit on the screen
   procedure Put (
      Str        : String;
      X          : Column;
      Y          : Row;
      Foreground : Foreground_Color := White;
      Background : Background_Color := Black);

   procedure Clear (Color : Background_Color := Black);

end VGA_Console;
