with System;
with Descriptor_Tables;

with Integers; use Integers;

package Interrupts is
   type Segment_Selector_Type is range 0 .. 2 ** 16 - 1;
   for Segment_Selector_Type'Size use 16;

   type Gate_Kind is (
      Task_Gate,
      Sixteen_Bit_Interrupt_Gate,
      Sixteen_Bit_Trap_Gate,
      Thirty_Two_Bit_Interrupt_Gate,
      Thirty_Two_Bit_Trap_Gate);

   for Gate_Kind'Size use 4;
   for Gate_Kind use (
      Task_Gate                     => 2#0101#,
      Sixteen_Bit_Interrupt_Gate    => 2#0110#,
      Sixteen_Bit_Trap_Gate         => 2#0111#,
      Thirty_Two_Bit_Interrupt_Gate => 2#1110#,
      Thirty_Two_Bit_Trap_Gate      => 2#1111#);

   type Gate is
      record
         Offset_0_15                : U16;
         Segment_Selector           : Segment_Selector_Type;
         Kind                       : Gate_Kind;
         Descriptor_Privilege_Level : Descriptor_Tables.Privilege_Level;
         Present                    : Boolean;
         Offset_16_31               : U16;

         Reserved : U8 := 0;
         Zero     : U1 := 0;
      end record;

   for Gate'Size use 64;
   for Gate use
      record
         Offset_0_15                at 0 range 0 .. 15;
         Segment_Selector           at 0 range 16 .. 31;
         Reserved                   at 4 range 0 .. 7;
         Kind                       at 4 range 8 .. 11;
         Zero                       at 4 range 12 .. 12;
         Descriptor_Privilege_Level at 4 range 13 .. 14;
         Present                    at 4 range 15 .. 15;
         Offset_16_31               at 4 range 16 .. 31;
      end record;

   Null_Gate : constant Gate := (
      Offset_0_15                => 0,
      Segment_Selector           => 0,
      Kind                       => Thirty_Two_Bit_Interrupt_Gate,
      Descriptor_Privilege_Level => Descriptor_Tables.Ring_0,
      Present                    => False,
      Offset_16_31               => 0,
      others => <>);

   procedure Set_Address (
      On      : in out Gate;
      Address :        System.Address);

   type Vector is range 0 .. 255;
   type Descriptor_Table is array (Vector) of aliased Gate
      with Pack;

   function Load_Descriptor_Table_Register return Descriptor_Tables.Register
      with Inline;
   procedure Store_Descriptor_Table_Register (Register : Descriptor_Tables.Register)
      with Inline;

   Divide_By_Zero                : constant Vector := 0;
   -- Reserved := 1
   Non_Maskable_Interrupt        : constant Vector := 2;
   Breakpoint                    : constant Vector := 3;
   Overflow                      : constant Vector := 4;
   Bounds_Range_Exceeded         : constant Vector := 5;
   Invalid_Opcode                : constant Vector := 6;
   Device_Not_Available          : constant Vector := 7;
   Double_Fault                  : constant Vector := 8;
   Coprocessor_Segment_Overrun   : constant Vector := 9;
   Invalid_Task_State_Segment    : constant Vector := 10;
   Segment_Not_Present           : constant Vector := 11;
   Stack_Segment_Fault           : constant Vector := 12;
   General_Protection_Fault      : constant Vector := 13;
   Page_Fault                    : constant Vector := 14;
   -- Reserved := 15;
   x86_Floating_Point_Unit_Error : constant Vector := 16;
   Alignment_Check               : constant Vector := 17;
   Machine_Check                 : constant Vector := 18;
   SIMD_Floating_Point_Exception : constant Vector := 19;
   Virtualization_Exception      : constant Vector := 20;
   Control_Protection_Exception  : constant Vector := 21;
   -- 22 - 31 Intel reserved
   -- 32 - 255 User Defined

   subtype User_Defined_Vector is Vector range 32 .. 255;

   procedure Disable with Inline;
   procedure Enable with Inline;
end Interrupts;
