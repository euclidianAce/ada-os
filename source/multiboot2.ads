with Integers; use Integers;

package Multiboot2 with Pure is
   Magic : constant := 16#36d76289#;

   type Architecture_Type is new U32;

   I386_Protected_Mode : constant Architecture_Type := 0;
   Mips_32_Bit         : constant Architecture_Type := 4;

   type Header is
      record
         Magic         : U32;
         Architecture  : Architecture_Type;
         Header_Length : U32;
         Checksum      : U32;
      end record;

   for Header use
      record
         Magic         at 0 range 0 .. 31;
         Architecture  at 4 range 0 .. 31;
         Header_Length at 8 range 0 .. 31;
         Checksum      at 12 range 0 .. 31;
      end record;

   type Tag is
      record
         Tag_Type : U16;
         Flags    : U16;
         Size     : U32;
      end record;

   for Tag'Size use 64;
   for Tag use
      record
         Tag_Type at 0 range 0 .. 15;
         Flags    at 2 range 0 .. 15;
         Size     at 4 range 0 .. 31;
      end record;

end Multiboot2;
