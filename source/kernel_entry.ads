with Integers;
with System;

procedure Kernel_Entry (
   Magic     : Integers.U32;
   Info_Addr : System.Address) with
   Export,
   Convention => C,
   External_Name => "Kernel_Entry";
