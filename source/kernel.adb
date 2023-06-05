with Debug_IO;
with Descriptor_Tables.Global;
with Descriptor_Tables;
with Integers;
with Interrupts;
with Serial;
with System.Machine_Code;
with System.Storage_Elements;
with System;
with Terminal;
with VGA_Console;

use System.Storage_Elements;
use type VGA_Console.Cursor_State;

package body Kernel is
   -- called by asm interrupt handler
   procedure Interrupt_Handler is
   begin
      Log ("Interrupt!");
   end Interrupt_Handler;

   procedure Memory_Copy (
      Destination : System.Address;
      Source      : System.Address;
      Units       : System.Storage_Elements.Storage_Count);
   pragma Export (C, Memory_Copy, "memcpy");

   procedure Log (Message : String) is
      Prefix : constant String :=
         [Character'Val (16#1b#), '[', '3', '7', 'm'] &
         "Kernel: " &
         [Character'Val (16#1b#), '[', '0', 'm'];
   begin
      Debug_IO.Put (Prefix);
      Debug_IO.Put_Line (Message);
      Terminal.Put_Line (Message);
      Terminal.Flush;
   end Log;

   -- Very crappy impl to satisfy generated code
   procedure Memory_Copy (
      Destination : System.Address;
      Source      : System.Address;
      Units       : System.Storage_Elements.Storage_Count) is

      type Elements is array (1 .. Units) of System.Storage_Elements.Storage_Element;

      Destination_Elements : Elements with Address => Destination;
      Source_Elements      : Elements with Address => Source;

      pragma Import (Ada, Destination_Elements);
      pragma Import (Ada, Source_Elements);
   begin
      for I in 1 .. Units loop
         Destination_Elements (I) := Source_Elements (I);
      end loop;
   end Memory_Copy;

   procedure Reload_Segments;
   pragma Import (
      Convention    => Asm,
      Entity        => Reload_Segments,
      External_Name => "reload_segments");

   type Global_Descriptor_Table_Type is array (Positive range <>) of Descriptor_Tables.Global.Segment_Descriptor;
   pragma Pack (Global_Descriptor_Table_Type);

   Global_Descriptor_Table : Global_Descriptor_Table_Type (1 .. 6);
   pragma Export (Asm, Global_Descriptor_Table, "Kernel_Global_Descriptor_Table");

   Task_State : Descriptor_Tables.Global.Task_State;
   pragma Export (
      Convention    => Asm,
      Entity        => Task_State,
      External_Name => "Kernel_Task_State");

   Stack : System.Address;
   pragma Import (
      Convention    => Asm,
      Entity        => Stack,
      External_Name => "kernel_stack_pointer");

   procedure Panic is
      procedure Hang;
      pragma No_Return (Hang);
      pragma Import (
         Convention => Asm,
         Entity => Hang,
         External_Name => "hang");
   begin
      Debug_IO.Put_Line ("Panic! (Todo, get panic info)");

      -- VGA_Console.Clear (VGA_Console.Red);
      VGA_Console.Put (
         "Kernel Panic! :(",
         1, VGA_Console.Row'Last,
         Foreground => VGA_Console.White,
         Background => VGA_Console.Red);

      -- VGA_Console.Put (
         -- " * TODO: dump some sorta stack trace here?",
         -- 2, 3,
         -- Foreground => VGA_Console.White,
         -- Background => VGA_Console.Red);

      -- declare -- Dump a backtrace (just of addresses for now)
         -- Row : VGA_Console.Row := 3;
         -- BP  : System.Address;
      -- begin
         -- System.Machine_Code.Asm (
            -- "mov %0, ebp",
            -- Outputs  => System.Address'Asm_Output (BP, "g"),
            -- Volatile => True);
      -- end;

      Hang;
   end Panic;

   procedure Setup_GDT is
      Null_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with
            Import,
            Address => Global_Descriptor_Table (1)'Address;

      Privileged_Code_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with
            Import,
            Address => Global_Descriptor_Table (2)'Address;

      Privileged_Data_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with Import, Address => Global_Descriptor_Table (3)'Address;

      User_Code_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with Import, Address => Global_Descriptor_Table (4)'Address;

      User_Data_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with Import, Address => Global_Descriptor_Table (5)'Address;

      Task_State_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with Import, Address => Global_Descriptor_Table (6)'Address;

      use type Integers.U16;
      use type Integers.U20;
   begin
      Log ("Attempting to setup gdt...");

      Null_Segment := Descriptor_Tables.Global.Null_Segment_Descriptor;

      Descriptor_Tables.Global.Set_Limit (Privileged_Code_Segment, 16#fffff#);
      Descriptor_Tables.Global.Set_Base (Privileged_Code_Segment, 0);
      Privileged_Code_Segment.Code_Readable_Or_Data_Writable := True;
      Privileged_Code_Segment.Direction_Or_Conforming        := Descriptor_Tables.Global.Up_Or_Non_Conforming;
      Privileged_Code_Segment.Executable                     := True;
      Privileged_Code_Segment.Type_Of_Descriptor             := Descriptor_Tables.Global.Code_Or_Data_Descriptor;
      Privileged_Code_Segment.Privilege                      := Descriptor_Tables.Ring_0;
      Privileged_Code_Segment.Present                        := True;
      Privileged_Code_Segment.Long                           := False;
      Privileged_Code_Segment.Default_Operation_Size         := Descriptor_Tables.Global.Thirty_Two_Bit;
      Privileged_Code_Segment.Granularity                    := Descriptor_Tables.Global.Four_Kilobyte;

      Descriptor_Tables.Global.Set_Limit (Privileged_Data_Segment, 16#fffff#);
      Descriptor_Tables.Global.Set_Base (Privileged_Data_Segment, 0);
      Privileged_Data_Segment.Code_Readable_Or_Data_Writable := True;
      Privileged_Data_Segment.Direction_Or_Conforming        := Descriptor_Tables.Global.Up_Or_Non_Conforming;
      Privileged_Data_Segment.Executable                     := False;
      Privileged_Data_Segment.Type_Of_Descriptor             := Descriptor_Tables.Global.Code_Or_Data_Descriptor;
      Privileged_Data_Segment.Privilege                      := Descriptor_Tables.Ring_0;
      Privileged_Data_Segment.Present                        := True;
      Privileged_Data_Segment.Long                           := False;
      Privileged_Data_Segment.Default_Operation_Size         := Descriptor_Tables.Global.Thirty_Two_Bit;
      Privileged_Data_Segment.Granularity                    := Descriptor_Tables.Global.Four_Kilobyte;

      Descriptor_Tables.Global.Set_Limit (User_Code_Segment, 16#fffff#);
      Descriptor_Tables.Global.Set_Base (User_Code_Segment, 0);
      User_Code_Segment.Code_Readable_Or_Data_Writable := True;
      User_Code_Segment.Direction_Or_Conforming        := Descriptor_Tables.Global.Up_Or_Non_Conforming;
      User_Code_Segment.Executable                     := True;
      User_Code_Segment.Type_Of_Descriptor             := Descriptor_Tables.Global.Code_Or_Data_Descriptor;
      User_Code_Segment.Privilege                      := Descriptor_Tables.Ring_3;
      User_Code_Segment.Present                        := True;
      User_Code_Segment.Long                           := False;
      User_Code_Segment.Default_Operation_Size         := Descriptor_Tables.Global.Thirty_Two_Bit;
      User_Code_Segment.Granularity                    := Descriptor_Tables.Global.Four_Kilobyte;

      Descriptor_Tables.Global.Set_Limit (User_Data_Segment, 16#fffff#);
      Descriptor_Tables.Global.Set_Base (User_Data_Segment, 0);
      User_Data_Segment.Code_Readable_Or_Data_Writable := True;
      User_Data_Segment.Direction_Or_Conforming        := Descriptor_Tables.Global.Up_Or_Non_Conforming;
      User_Data_Segment.Executable                     := False;
      User_Data_Segment.Type_Of_Descriptor             := Descriptor_Tables.Global.Code_Or_Data_Descriptor;
      User_Data_Segment.Privilege                      := Descriptor_Tables.Ring_3;
      User_Data_Segment.Present                        := True;
      User_Data_Segment.Long                           := False;
      User_Data_Segment.Default_Operation_Size         := Descriptor_Tables.Global.Thirty_Two_Bit;
      User_Data_Segment.Granularity                    := Descriptor_Tables.Global.Four_Kilobyte;

      Descriptor_Tables.Global.Set_Limit (Task_State_Segment, Descriptor_Tables.Global.Task_State'Size / 8);
      Descriptor_Tables.Global.Set_Base (Task_State_Segment, Integers.Address_To_U32 (Task_State'Address));
      Task_State_Segment.Code_Readable_Or_Data_Writable := True;
      Task_State_Segment.Direction_Or_Conforming        := Descriptor_Tables.Global.Up_Or_Non_Conforming;
      Task_State_Segment.Executable                     := False;
      Task_State_Segment.Type_Of_Descriptor             := Descriptor_Tables.Global.System_Descriptor;
      Task_State_Segment.Privilege                      := Descriptor_Tables.Ring_0;
      Task_State_Segment.Present                        := True;
      Task_State_Segment.Long                           := False;
      Task_State_Segment.Default_Operation_Size         := Descriptor_Tables.Global.Thirty_Two_Bit;
      Task_State_Segment.Granularity                    := Descriptor_Tables.Global.Byte;

      Task_State := (
         Previous_Task_Link   => 0,
         Esp0                 => Integers.Address_To_U32 (Stack),
         Ss0                  => 16#10#,
         Esp1                 => 0,
         Ss1                  => 0,
         Esp2                 => 0,
         Ss2                  => 0,
         Cr3                  => 0,
         Eip                  => 0,
         Eflags               => 0,
         Eax                  => 0,
         Ecx                  => 0,
         Edx                  => 0,
         Ebx                  => 0,
         Esp                  => 0,
         Ebp                  => 0,
         Esi                  => 0,
         Edi                  => 0,
         Es                   => 0,
         Cs                   => 0,
         Ss                   => 0,
         Ds                   => 0,
         Fs                   => 0,
         Gs                   => 0,
         Ldt_Segment_Selector => 0,
         Trap                 => False,
         Io_Map_Base_Address  => 0,
         Ssp                  => 0,
         others               => <>);

      Log ("About to load global descriptor table...");
      Descriptor_Tables.Global.Load ((
         Limit        => (Descriptor_Tables.Global.Segment_Descriptor'Size / 8) * Global_Descriptor_Table'Length,
         Base_Address => Global_Descriptor_Table'Address));

      Log ("About to reload segments...");
      Reload_Segments;
   end Setup_GDT;

   Interrupt_Descriptor_Table : Interrupts.Descriptor_Table := [others => Interrupts.Null_Gate];
   pragma Export (
      Convention    => Asm,
      Entity        => Interrupt_Descriptor_Table,
      External_Name => "Kernel_IDT");

   procedure Interrupt_Service_Request_Wrapper;
   pragma Import (
      Convention    => Asm,
      Entity        => Interrupt_Service_Request_Wrapper,
      External_Name => "interrupt_service_request_wrapper");

   procedure Setup_IDT is
      use type Integers.U16;
   begin
      for Vec in Interrupt_Descriptor_Table'Range loop
         declare
            Gate : Interrupts.Gate
               with Address => Interrupt_Descriptor_Table (Vec)'Address;
            pragma Import (Asm, Gate);
         begin
            Interrupts.Set_Address (Gate, Interrupt_Service_Request_Wrapper'Address);
            Gate.Segment_Selector := 16#08#;
            Gate.Kind := Interrupts.Thirty_Two_Bit_Interrupt_Gate;
            Gate.Descriptor_Privilege_Level := Descriptor_Tables.Ring_0;
            Gate.Present := True;
         end;
      end loop;

      Log ("Loading interrupt descriptor table...");
      Interrupts.Load_Descriptor_Table_Register ([
         Limit        => Interrupt_Descriptor_Table'Size / 8,
         Base_Address => Interrupt_Descriptor_Table'Address]);
   end Setup_IDT;

   procedure Start is
   begin
      if not Serial.Initialize (Serial.Com1) then
         VGA_Console.Put (
            "Unable to initialize serial port :(", 1, VGA_Console.Row'Last,
            Foreground => VGA_Console.White,
            Background => VGA_Console.Red);
         return;
      end if;

      Terminal.Foreground_Color := VGA_Console.White;
      Terminal.Background_Color := VGA_Console.Blue;

      Terminal.Clear;
      Terminal.Flush;

      Interrupts.Disable;
      Setup_GDT;
      Setup_IDT;
      Interrupts.Enable;

      declare
         Aliased_Byte : Storage_Element := Serial.In_B (VGA_Console.Misc_Output_Register_Read);

         Reg : VGA_Console.Misc_Output_Register
            with Address => Aliased_Byte'Address;
         pragma Import (Ada, Reg);
         Cursor_Reg : VGA_Console.Cursor_Start_Register
            with Address => Aliased_Byte'Address;
         pragma Import (Ada, Cursor_Reg);

         Addr_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
            16#3d4# else 16#3b4#);
         Data_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
            16#3d5# else 16#3b5#);
      begin
         Serial.Out_B (Addr_Port, 16#0a#);
         Aliased_Byte := Serial.In_B (Data_Port);

         if Cursor_Reg.State = VGA_Console.Enabled then
            Log ("Cursor is enabled");
         else
            Log ("Cursor is disabled");
         end if;

         Cursor_Reg.State := VGA_Console.Disabled;
         -- Cursor_Reg.Scan_Line_Start := 0;

         Serial.Out_B (Data_Port, Aliased_Byte);
         Log ("Cursor should now be disabled");
      end;

      System.Machine_Code.Asm ("int $32", Volatile => True);
   end Start;
end Kernel;
