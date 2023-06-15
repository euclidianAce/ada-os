with Interrupts;
with Kernel;
with Multiboot2;
with Serial;
with System.Machine_Code;
with Terminal;
with VGA_Console;

procedure Kernel_Entry (
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

   Kernel.Log ("Magic => " & Integers.Hex_Image (Magic) & " (Should be " & Integers.Hex_Image (Multiboot2.Magic) & ")");
   Kernel.Log ("Multiboot Info Address => " & Integers.Hex_Image (Info_Addr));

   Kernel.Read_Multiboot2_Info (Info_Addr);

   Interrupts.Disable; -- Interrupts should already be disabled, but just to be safe :P
   Kernel.Setup_GDT;
   Kernel.Setup_IDT;
   Interrupts.Enable;
   Kernel.Disable_VGA_Cursor;

   Kernel.Log ("About to do a software interrupt...");
   System.Machine_Code.Asm ("int $32", Volatile => True);
   Kernel.Log ("Did a software interrupt. Hopefully everything is fine?");
end Kernel_Entry;
