with Integers; use Integers;
with System;

package Descriptor_Tables.Global is
   type Descriptor_Type is (System_Descriptor, Code_Or_Data_Descriptor);
   for Descriptor_Type use (System_Descriptor => 0, Code_Or_Data_Descriptor => 1);
   for Descriptor_Type'Size use 1;

   type Default_Operation_Size_Type is (Sixteen_Bit, Thirty_Two_Bit);
   for Default_Operation_Size_Type use (Sixteen_Bit => 0, Thirty_Two_Bit => 1);
   for Default_Operation_Size_Type'Size use 1;

   type Granularity_Type is (Byte, Four_Kilobyte);
   for Granularity_Type use (Byte => 0, Four_Kilobyte => 1);
   for Granularity_Type'Size use 1;

   type Segment_Selector is range 0 .. 2 ** 16 - 1;
   for Segment_Selector'Size use 16;

   type Direction_Or_Conforming_Type is (
      Up_Or_Non_Conforming,
      Down_Or_Conforming);
   for Direction_Or_Conforming_Type'Size use 1;
   for Direction_Or_Conforming_Type use (
      Up_Or_Non_Conforming => 0,
      Down_Or_Conforming   => 1);

   type Segment_Descriptor is
      record
         Segment_Limit_0_15             : U16;
         -- In the manual, this is technically 2 fields 0_15 and 16_24
         -- comprising of a U16 and U8. We can do better with the type system
         Base_0_23                      : U24;

         -- "Access byte"
         -- cpu sets to True when segment is accessed
         Accessed                       : Boolean;
         -- Set when this code segment is readable or this data segment is writable
         Code_Readable_Or_Data_Writable : Boolean;
         -- set when this data segment grows down or this code segment can be
         -- executed from an equal or lower privilege level
         Direction_Or_Conforming        : Direction_Or_Conforming_Type;
         -- Defines whether this is a code segment or data segment
         Executable                     : Boolean;
         Type_Of_Descriptor             : Descriptor_Type;
         Privilege                      : Privilege_Level;
         Present                        : Boolean;

         Segment_Limit_16_19            : U4;
         Reserved                       : Boolean;
         Long                           : Boolean;
         Default_Operation_Size         : Default_Operation_Size_Type;
         Granularity                    : Granularity_Type;
         Base_24_31                     : U8;
      end record;

   for Segment_Descriptor'Size use 64;
   for Segment_Descriptor use
      record
         Segment_Limit_0_15             at 0 range 0 .. 15;
         Base_0_23                      at 2 range 0 .. 23;
         Accessed                       at 4 range 8 .. 8;
         Code_Readable_Or_Data_Writable at 4 range 9 .. 9;
         Direction_Or_Conforming        at 4 range 10 .. 10;
         Executable                     at 4 range 11 .. 11;
         Type_Of_Descriptor             at 4 range 12 .. 12;
         Privilege                      at 4 range 13 .. 14;
         Present                        at 4 range 15 .. 15;
         Segment_Limit_16_19            at 4 range 16 .. 19;
         Reserved                       at 4 range 20 .. 20;
         Long                           at 4 range 21 .. 21;
         Default_Operation_Size         at 4 range 22 .. 22;
         Granularity                    at 4 range 23 .. 23;
         Base_24_31                     at 4 range 24 .. 31;
      end record;

   Null_Segment_Descriptor : constant Segment_Descriptor := (
         Segment_Limit_0_15             => 0,
         Base_0_23                      => 0,
         Accessed                       => False,
         Code_Readable_Or_Data_Writable => False,
         Direction_Or_Conforming        => Up_Or_Non_Conforming,
         Executable                     => False,
         Type_Of_Descriptor             => System_Descriptor,
         Privilege                      => Ring_0,
         Present                        => False,
         Segment_Limit_16_19            => 0,
         Long                           => False,
         Default_Operation_Size         => Sixteen_Bit,
         Granularity                    => Byte,
         Base_24_31                     => 0,

         Reserved                       => False);

   type Task_State is
      record
         Previous_Task_Link   : Segment_Selector;
         Reserved_1           : U16 := 0;
         Esp0                 : U32;
         SS0                  : U16;
         Reserved_2           : U16 := 0;
         Esp1                 : U32;
         SS1                  : U16;
         Reserved_3           : U16 := 0;
         Esp2                 : U32;
         SS2                  : U16;
         Reserved_4           : U16 := 0;
         Cr3                  : U16;
         Eip                  : U32;
         Eflags               : U32;
         Eax                  : U32;
         Ecx                  : U32;
         Edx                  : U32;
         Ebx                  : U32;
         Esp                  : U32;
         Ebp                  : U32;
         Esi                  : U32;
         Edi                  : U32;
         Es                   : U16;
         Reserved_5           : U16 := 0;
         Cs                   : U16;
         Reserved_6           : U16 := 0;
         Ss                   : U16;
         Reserved_7           : U16 := 0;
         Ds                   : U16;
         Reserved_8           : U16 := 0;
         Fs                   : U16;
         Reserved_9           : U16 := 0;
         Gs                   : U16;
         Reserved_10          : U16 := 0;
         Ldt_Segment_Selector : U16;
         Reserved_11          : U16 := 0;
         Trap                 : Boolean;
         Reserved_12          : U15 := 0;
         Io_Map_Base_Address  : U16;
         SSP                  : U32;
      end record;

   for Task_State'Size use 108 * 8;
   for Task_State use
      record
         Previous_Task_Link   at 0   range 0  .. 15;
         Reserved_1           at 0   range 16 .. 31;
         Esp0                 at 4   range 0  .. 31;
         SS0                  at 8   range 0  .. 15;
         Reserved_2           at 8   range 16 .. 31;
         Esp1                 at 12  range 0  .. 31;
         SS1                  at 16  range 0  .. 15;
         Reserved_3           at 16  range 16 .. 31;
         Esp2                 at 20  range 0  .. 31;
         SS2                  at 24  range 0  .. 15;
         Reserved_4           at 24  range 16 .. 31;
         Cr3                  at 28  range 0  .. 31;
         Eip                  at 32  range 0  .. 31;
         Eflags               at 36  range 0  .. 31;
         Eax                  at 40  range 0  .. 31;
         Ecx                  at 44  range 0  .. 31;
         Edx                  at 48  range 0  .. 31;
         Ebx                  at 52  range 0  .. 31;
         Esp                  at 56  range 0  .. 31;
         Ebp                  at 60  range 0  .. 31;
         Esi                  at 64  range 0  .. 31;
         Edi                  at 68  range 0  .. 31;
         Es                   at 72  range 0  .. 15;
         Reserved_5           at 72  range 16 .. 31;
         Cs                   at 76  range 0  .. 15;
         Reserved_6           at 76  range 16 .. 31;
         Ss                   at 80  range 0  .. 15;
         Reserved_7           at 80  range 16 .. 31;
         Ds                   at 84  range 0  .. 15;
         Reserved_8           at 84  range 16 .. 31;
         Fs                   at 88  range 0  .. 15;
         Reserved_9           at 88  range 16 .. 31;
         Gs                   at 92  range 0  .. 15;
         Reserved_10          at 92  range 16 .. 31;
         Ldt_Segment_Selector at 96  range 0  .. 15;
         Reserved_11          at 96  range 16 .. 31;
         Trap                 at 100 range 0  .. 0;
         Reserved_12          at 100 range 1  .. 15;
         Io_Map_Base_Address  at 100 range 16 .. 31;
         SSP                  at 104 range 0  .. 31;
      end record;

   procedure Set_Base (
      Descriptor : in out Segment_Descriptor;
      Base       :        U32);
   procedure Set_Limit (
      Descriptor : in out Segment_Descriptor;
      Limit      :        U20);

   -- lgdt
   -- REMEMBER THAT `From.Limit` IS IN BYTES, NOT ENTRIES
   procedure Load (From : Register)
      with Inline;
end Descriptor_Tables.Global;
