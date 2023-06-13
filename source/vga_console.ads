with System;
with Serial;

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
   for Cell use
      record
         Char  at 0 range 0 .. 7;
         Color at 1 range 0 .. 7;
      end record;

   Screen_Width  : constant := 80;
   Screen_Height : constant := 25;

   type Row    is range 1 .. Screen_Height;
   type Column is range 1 .. Screen_Width;
   type Screen_Cells is array (Row, Column) of Cell;
   pragma Pack (Screen_Cells);

   Video_Memory : Screen_Cells with
      Import,
      Convention => Ada,
      Address    => System'To_Address (16#000B_8000#);

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

   -- CRTC_Address_Register : constant Port_Address := 16#3x4#;
   -- CRTC_Data_Register    : constant Port_Address := 16#3x5#;

   Misc_Output_Register_Write : constant Serial.Port_Address := 16#3c2#;
   Misc_Output_Register_Read  : constant Serial.Port_Address := 16#3cc#;

   type Clock_Select_Type is (
      Clock_25_Mhz,
      Clock_28_Mhz,
      External_1,
      External_2);
   for Clock_Select_Type'Size use 2;
   for Clock_Select_Type use (
      Clock_25_Mhz => 2#00#,
      Clock_28_Mhz => 2#01#,
      External_1   => 2#10#,
      External_2   => 2#11#);

   type Odd_Even_Page_Selector is (
      Low,
      High);
   for Odd_Even_Page_Selector'Size use 1;
   for Odd_Even_Page_Selector use (
      Low  => 0,
      High => 1);

   type Horizontal_Sync_Polarity is (
      Positive,
      Negative);
   for Horizontal_Sync_Polarity'Size use 1;
   for Horizontal_Sync_Polarity use (
      Positive => 0,
      Negative => 1);

   type Vertical_Sync_Polarity is (
      Positive,
      Negative);
   for Vertical_Sync_Polarity'Size use 1;
   for Vertical_Sync_Polarity use (
      Positive => 0,
      Negative => 1);

   type Misc_Output_Register is
      record
         IO_Address_Select    : Boolean;
         RAM_Enable           : Boolean;
         Clock_Select         : Clock_Select_Type;
         Odd_Even_Page        : Odd_Even_Page_Selector;
         Horizontal_Polarity  : Horizontal_Sync_Polarity;
         Vertical_Polarity    : Vertical_Sync_Polarity;
      end record;
   for Misc_Output_Register'Size use 8;
   for Misc_Output_Register use
      record
         IO_Address_Select    at 0 range 0 .. 0;
         RAM_Enable           at 0 range 1 .. 1;
         Clock_Select         at 0 range 2 .. 3;
         Odd_Even_Page        at 0 range 5 .. 5;
         Horizontal_Polarity  at 0 range 6 .. 6;
         Vertical_Polarity    at 0 range 7 .. 7;
      end record;

   type Cursor_State is (Enabled, Disabled);
   for Cursor_State use (Enabled => 0, Disabled => 1);
   for Cursor_State'Size use 1;

   type Cursor_Scan_Line is range 0 .. 2 ** 5 - 1;
   for Cursor_Scan_Line'Size use 5;

   type Cursor_Start_Register is
      record
         Scan_Line_Start : Cursor_Scan_Line;
         State           : Cursor_State;
      end record;

   for Cursor_Start_Register use
      record
         Scan_Line_Start at 0 range 0 .. 4;
         State           at 0 range 5 .. 5;
      end record;

end VGA_Console;
