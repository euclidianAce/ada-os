with System.Storage_Elements;
use System.Storage_Elements;
package Serial is
   type Port_Address is range 0 .. 2 ** 16 - 1;
   for Port_Address'Size use 16;

   Com1 : constant Port_Address := 16#3f8#;
   Com2 : constant Port_Address := 16#2f8#;
   Com3 : constant Port_Address := 16#3e8#;
   Com4 : constant Port_Address := 16#2e8#;
   Com5 : constant Port_Address := 16#5f8#;
   Com6 : constant Port_Address := 16#4f8#;
   Com7 : constant Port_Address := 16#5e8#;
   Com8 : constant Port_Address := 16#4e8#;

   -- Returns True on success
   function Initialize (Port : Port_Address) return Boolean;

   function Read (
      Port : Port_Address) return Storage_Element;

   procedure Write (
      Port    : Port_Address;
      Element : Storage_Element);
end Serial;
