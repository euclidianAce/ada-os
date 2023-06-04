with System;
with Integers; use Integers;

package Descriptor_Tables is
   type Privilege_Level is (
      Ring_0,
      Ring_1,
      Ring_2,
      Ring_3);

   for Privilege_Level'Size use 2;
   for Privilege_Level use (
      Ring_0 => 0,
      Ring_1 => 1,
      Ring_2 => 2,
      Ring_3 => 3);

   type Register is
      record
         Limit        : U16;
         Base_Address : System.Address;
      end record;
   for Register'Size use 48;
   for Register use
      record
         Limit        at 0 range 0 .. 15;
         Base_Address at 0 range 16 .. 47;
      end record;
end Descriptor_Tables;
