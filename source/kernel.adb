with Debug_IO;
with Descriptor_Tables.Global;
with Descriptor_Tables;
with Interrupts;
with Multiboot2;
with Serial;
with System.Address_To_Access_Conversions;
with System.Machine_Code;
with System.Storage_Elements;
with Terminal;
with VGA_Console;

use System.Storage_Elements;
use type VGA_Console.Cursor_State;

package body Kernel is
   package Addr_Conv is new System.Address_To_Access_Conversions (System.Address);

   procedure Capture_Stack_Trace (Addresses : in out Address_Array) is
      use type Integers.U32;
      use type System.Address;

      Frame_Pointer  : System.Address;
      Return_Address : System.Address;

      Index : Positive := Addresses'First;
   begin
      System.Machine_Code.Asm (
         "mov %%ebp, %0",
         Outputs  => System.Address'Asm_Output ("=g", Frame_Pointer),
         Volatile => True);

      loop
         exit when Frame_Pointer = System.Null_Address;

         Frame_Pointer  := Addr_Conv.To_Pointer (Frame_Pointer).all;
         Return_Address := Addr_Conv.To_Pointer (Integers.U32_To_Address (
            Integers.Address_To_U32 (Frame_Pointer) + System.Address'Size / 8)).all;

         Addresses (Index) := Return_Address;
         exit when Index = Addresses'Last;
         Index := @ + 1;
      end loop;
   end Capture_Stack_Trace;

   -- procedure Dump_Stack_Trace with Inline is
      -- function Hex (Addr : System.Address) return Integers.Hex_String renames Integers.Hex_Image;

      -- Addresses : Address_Array (1 .. 16) := [others => System.Null_Address];
      -- use type System.Address;
   -- begin
      -- Capture_Stack_Trace (Addresses);

      -- Log ("Backtrace:");
      -- for Address of Addresses loop
         -- exit when Address = System.Null_Address;

         -- Log ("   " & Hex (Address));
      -- end loop;
   -- end Dump_Stack_Trace;

   procedure Disable_VGA_Cursor is
      Aliased_Byte : Storage_Element := Serial.In_B (VGA_Console.Misc_Output_Register_Read);

      Reg : VGA_Console.Misc_Output_Register with
         Import, Convention => Ada,
         Address => Aliased_Byte'Address;
      Cursor_Reg : VGA_Console.Cursor_Start_Register with
         Import, Convention => Ada,
         Address => Aliased_Byte'Address;

      Addr_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
         16#3d4# else 16#3b4#);
      Data_Port : constant Serial.Port_Address := (if Reg.IO_Address_Select then
         16#3d5# else 16#3b5#);
   begin
      Serial.Out_B (Addr_Port, 16#0a#);
      Aliased_Byte := Serial.In_B (Data_Port);
      Cursor_Reg.State := VGA_Console.Disabled;
      Serial.Out_B (Data_Port, Aliased_Byte);
   end Disable_VGA_Cursor;

   -- called by asm interrupt handler
   procedure Interrupt_Handler is
   begin
      Log ("Interrupt!");
   end Interrupt_Handler;

   procedure Memory_Copy (
      Destination : System.Address;
      Source      : System.Address;
      Units       : System.Storage_Elements.Storage_Count) with
      Export,
      Convention => C,
      External_Name => "memcpy";

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

      Destination_Elements : Elements with
         Import, Convention => Ada,
         Address => Destination;
      Source_Elements      : Elements with
         Import, Convention => Ada,
         Address => Source;
   begin
      for I in 1 .. Units loop
         Destination_Elements (I) := Source_Elements (I);
      end loop;
   end Memory_Copy;

   procedure Reload_Segments with
      Import,
      Convention => Asm,
      External_Name => "reload_segments";

   type Global_Descriptor_Table_Type is array (Positive range <>) of Descriptor_Tables.Global.Segment_Descriptor;
   for Global_Descriptor_Table_Type'Alignment use 16;
   pragma Pack (Global_Descriptor_Table_Type);

   Global_Descriptor_Table : Global_Descriptor_Table_Type (1 .. 6) with
      Export,
      Convention => Asm,
      External_Name => "Kernel_Global_Descriptor_Table";

   Task_State : Descriptor_Tables.Global.Task_State with
      Export,
      Convention => Asm,
      External_Name => "Kernel_Task_State";

   Stack : System.Address with
      Import,
      Convention => Asm,
      External_Name => "kernel_stack_pointer";

   procedure Panic is
      procedure Hang with
         No_Return,
         Import,
         Convention => Asm,
         External_Name => "hang";

      Stack_Trace_Addrs : Address_Array (1 .. 16) := [others => System.Null_Address];

      function Hex (Addr : System.Address) return Integers.Hex_String renames Integers.Hex_Image;
      use type System.Address;
      use type VGA_Console.Row;
   begin
      Capture_Stack_Trace (Stack_Trace_Addrs);

      Terminal.Foreground_Color := VGA_Console.White;
      Terminal.Background_Color := VGA_Console.Red;
      Terminal.Current_Column := VGA_Console.Column'First;
      Terminal.Current_Row := VGA_Console.Row'First + 1;
      Terminal.Clear;

      Log (" * Kernel Panic! :(");
      Log ("");
      Log (" * Backtrace:");
      for Addr of Stack_Trace_Addrs loop
         exit when Addr = System.Null_Address;
         Log ("    * " & Hex (Addr));
      end loop;

      Hang;
   end Panic;

   procedure Read_Multiboot2_Info (Addr : System.Address) is
      package Conv is new System.Address_To_Access_Conversions (Integers.U32);

      Total_Size : Integers.U32;

      use type Integers.U32;
      Current : Integers.U32 := Integers.Address_To_U32 (Addr);
   begin
      Log ("Attempting to read multiboot 2 info...");
      Total_Size := Conv.To_Pointer (Integers.U32_To_Address (Current)).all;

      Log ("   * Total_Size => " & Integers.Hex_Image (Total_Size) & " bytes");

      Current := @ + 8;
      loop
         declare
            use type Multiboot2.Tag_Type;
            Tag_Type_Int : constant Integers.U32 := Conv.To_Pointer (Integers.U32_To_Address (Current)).all;
            Tag_Type : Multiboot2.Tag_Type with Import, Address => Tag_Type_Int'Address;
            Size     : constant Integers.U32 := Conv.To_Pointer (Integers.U32_To_Address (Current + 4)).all;
         begin
            -- Enum images require runtime things :P
            Log ("   * " & (case Tag_Type is
               when Multiboot2.Null_Tag => "Null",
               when Multiboot2.Boot_Command_Line_Tag => "Boot_Command_Line_Tag",
               when Multiboot2.Boot_Loader_Name_Tag => "Boot_Loader_Name_Tag",
               when Multiboot2.Modules_Tag => "Modules_Tag",
               when Multiboot2.Memory_Info_Tag => "Memory_Info_Tag",
               when Multiboot2.BIOS_Boot_Device_Tag => "BIOS_Boot_Device_Tag",
               when Multiboot2.Memory_Map_Tag => "Memory_Map_Tag",
               when Multiboot2.VBE_Info_Tag => "VBE_Info_Tag",
               when Multiboot2.Framebuffer_Info_Tag => "Framebuffer_Info_Tag",
               when Multiboot2.ELF_Symbols_Tag => "ELF_Symbols_Tag",
               when Multiboot2.APM_Table_Tag => "APM_Table_Tag",
               when Multiboot2.EFI_32_Bit_System_Table_Pointer_Tag => "EFI_32_Bit_System_Table_Pointer_Tag",
               when Multiboot2.EFI_64_Bit_System_Table_Pointer_Tag => "EFI_64_Bit_System_Table_Pointer_Tag",
               when Multiboot2.SMBIOS_Tables_Tag => "SMBIOS_Tables_Tag",
               when Multiboot2.ACPI_1_RSDP_Tag => "ACPI_1_RSDP_Tag",
               when Multiboot2.ACPI_2_RSDP_Tag => "ACPI_2_RSDP_Tag",
               when Multiboot2.Networking_Info_Tag => "Networking_Info_Tag",
               when Multiboot2.EFI_Memory_Map_Tag => "EFI_Memory_Map_Tag",
               when Multiboot2.EFI_Boot_Services_Not_Terminated_Tag => "EFI_Boot_Services_Not_Terminated_Tag",
               when Multiboot2.EFI_32_Bit_Image_Handle_Pointer_Tag => "EFI_32_Bit_Image_Handle_Pointer_Tag",
               when Multiboot2.EFI_64_Bit_Image_Handle_Pointer_Tag => "EFI_64_Bit_Image_Handle_Pointer_Tag",
               when Multiboot2.Image_Load_Base_Physical_Address_Tag => "Image_Load_Base_Physical_Address_Tag"));

            exit when Tag_Type = Multiboot2.Null_Tag;
            Current := @ + Size - 8;
         end;
      end loop;
   end Read_Multiboot2_Info;

   procedure Setup_GDT is
      Null_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with Import, Address => Global_Descriptor_Table (1)'Address;

      Privileged_Code_Segment : Descriptor_Tables.Global.Segment_Descriptor
         with Import, Address => Global_Descriptor_Table (2)'Address;

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

   Interrupt_Descriptor_Table : Interrupts.Descriptor_Table := [others => Interrupts.Null_Gate] with
      Export,
      External_Name => "Kernel_IDT";

   procedure Interrupt_Service_Request_Wrapper with
      Import,
      Convention => Asm,
      External_Name => "interrupt_service_request_wrapper";

   procedure Setup_IDT is
      use type Integers.U16;
   begin
      Log ("Attempting to setup idt...");
      for Vec in Interrupt_Descriptor_Table'Range loop
         declare
            Gate : Interrupts.Gate with
               Import,
               Convention => Asm,
               Address => Interrupt_Descriptor_Table (Vec)'Address;
         begin
            Interrupts.Set_Address (Gate, Interrupt_Service_Request_Wrapper'Address);
            Gate.Segment_Selector := 16#08#;
            Gate.Kind := Interrupts.Thirty_Two_Bit_Interrupt_Gate;
            Gate.Descriptor_Privilege_Level := Descriptor_Tables.Ring_0;
            Gate.Present := True;
         end;
      end loop;

      Log ("About to load interrupt descriptor table...");
      Interrupts.Load_Descriptor_Table_Register ([
         Limit        => Interrupt_Descriptor_Table'Size / 8,
         Base_Address => Interrupt_Descriptor_Table'Address]);
   end Setup_IDT;

   procedure Start (
      Magic     : Integers.U32;
      Info_Addr : System.Address) is
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

      Log ("Magic => " & Integers.Hex_Image (Magic) & " (Should be " & Integers.Hex_Image (Multiboot2.Magic) & ")");
      Log ("Multiboot Info Address => " & Integers.Hex_Image (Info_Addr));

      Read_Multiboot2_Info (Info_Addr);

      Interrupts.Disable; -- Interrupts should already be disabled, but just to be safe :P
      Setup_GDT;
      Setup_IDT;
      Interrupts.Enable;
      Disable_VGA_Cursor;

      Log ("About to do a software interrupt...");
      System.Machine_Code.Asm ("int $32", Volatile => True);
      Log ("Did a software interrupt. Hopefully everything is fine?");
   end Start;
end Kernel;
