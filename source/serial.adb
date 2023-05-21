with System;
with System.Machine_Code;
package body Serial is

   procedure Out_B (
      Port  : Port_Address;
      Value : Storage_Element) is
   begin
      System.Machine_Code.Asm (
         "out %0, %1",
         Inputs => (
            Storage_Element'Asm_Input ("a", Value),
            Port_Address'Asm_Input ("d", Port)),
         Volatile => True);
   end Out_B;
   pragma Inline (Out_B);

   function In_B (Port : Port_Address) return Storage_Element is
      Result : Storage_Element;
   begin
      System.Machine_Code.Asm (
         "in %1, %0",
         Inputs  => Port_Address'Asm_Input ("d", Port),
         Outputs => Storage_Element'Asm_Output ("=a", Result));
      return Result;
   end In_B;
   pragma Inline (In_B);

   function Initialize (Port : Port_Address) return Boolean is
   begin
      Out_B (Port + 1, 16#00#); -- Disable all interrupts
      Out_B (Port + 3, 16#80#); -- Enable DLAB (set baud rate divisor)
      Out_B (Port + 0, 16#03#); -- Set divisor to 3 (low byte) 38400 baud
      Out_B (Port + 1, 16#00#); --                  (high byte)
      Out_B (Port + 3, 16#03#); -- 8 bits, no parity, one stop bit
      Out_B (Port + 2, 16#c7#); -- Enable FIFO, clear them, with 14-byte threshold
      Out_B (Port + 4, 16#0b#); -- IRQs enabled, RTS/DSR set
      Out_B (Port + 4, 16#1e#); -- Set in loopback mode, test the serial chip
      Out_B (Port + 0, 16#ae#); -- Test the serial chip (send byte 16#ae# and check if serial returns the same byte)

      if In_B (Port) /= 16#ae# then
         return False;
      end if;

      -- Set to normal operation mode
      -- (not-loopback with IRQs enabled and OUT#1 and OUT#2 bits enabled)
      Out_B (Port + 4, 16#0f#);
      return True;
   end Initialize;

   function Received_Full (Port : Port_Address) return Boolean is
       ((In_B (Port + 5) and 1) /= 0);

   function Transmit_Empty (Port : Port_Address) return Boolean is
       ((In_B (Port + 5) and 16#20#) /= 0);

   function Read (
      Port : Port_Address) return Storage_Element is
   begin
      while not Received_Full (Port) loop
         null;
      end loop;

      return In_B (Port);
   end Read;

   procedure Write (
      Port    : Port_Address;
      Element : Storage_Element) is
   begin
      while not Transmit_Empty (Port) loop
         null;
      end loop;

      Out_B (Port, Element);
   end Write;

end Serial;
