with Ada.Unchecked_Conversion;
with System;

package Integers with Pure is
   type U32 is range 0 .. 2 ** 32 - 1;
   for U32'Size use 32;

   type U64 is
      record
         Low  : U32;
         High : U32;
      end record;

   for U64'Size use 64;
   for U64 use
      record
         Low at 0 range 0 .. 31;
         High at 0 range 32 .. 63;
      end record;

   -- TODO:
   -- function "+"(A, B : U64) return U64;
   -- function "-"(A, B : U64) return U64;
   -- function "*"(A, B : U64) return U64;
   -- function "/"(A, B : U64) return U64;
   -- etc.

   function Address_To_U32 is new Ada.Unchecked_Conversion (
      Source => System.Address,
      Target => U32);

   function U32_To_Address is new Ada.Unchecked_Conversion (
      Source => U32,
      Target => System.Address);

   subtype Hex_String is String (1 .. 9); -- "0000_0000"

   function Hex_Image (Value : U32) return Hex_String;
   function Hex_Image (Addr : System.Address) return Hex_String
      is (Hex_Image (Address_To_U32 (Addr)));

   type U24 is range 0 .. 2 ** 24 - 1;
   for U24'Size use 24;

   type U20 is range 0 .. 2 ** 20 - 1;
   for U20'Size use 20;

   type U16 is range 0 .. 2 ** 16 - 1;
   for U16'Size use 16;
   pragma Provide_Shift_Operators (U16);

   type U15 is range 0 .. 2 ** 15 - 1;
   for U15'Size use 15;

   type U8 is range 0 .. 2 ** 8 - 1;
   for U8'Size use 8;

   type U7 is range 0 .. 2 ** 7 - 1;
   for U7'Size use 7;

   type U4 is range 0 .. 2 ** 4 - 1;
   for U4'Size use 4;

   type U1 is range 0 .. 1;
   for U1'Size use 1;

end Integers;
