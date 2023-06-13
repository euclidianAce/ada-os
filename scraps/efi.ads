with Integers; use Integers;
with System;

package Efi with Pure is
   type Revision_Type is
      record
         Major : U16;
         Minor : U16;
      end record;

   for Revision_Type'Size use 32;
   for Revision_Type use
      record
         Minor at 0 range 0 .. 15;
         Major at 0 range 16 .. 31;
      end record;

   type Table_Header is
      record
         Signature   : U64;
         Revision    : Revision_Type;
         Header_Size : U32;
         Crc_32      : U32;
         Reserved    : U32;
      end record;

   for Table_Header'Size use 192;
   for Table_Header use
      record
         Signature   at 0 range 0 .. 63;
         Revision    at 8 range 0 .. 31;
         Header_Size at 12 range 0 .. 31;
         Crc_32      at 16 range 0 .. 31;
         Reserved    at 20 range 0 .. 31;
      end record;

   type Handle is private;
   function Handle_Image (H : Handle) return Integers.Hex_String;

   type System_Table_64 is
      record
         Header                  : Table_Header;
         Firmware_Vendor         : System.Address; -- CHAR16*
         Firmware_Revision       : U32;
         Console_In_Handle       : Handle;
         Console_In              : System.Address; -- EFI_SIMPLE_TEXT_INPUT_PROTOCOL*;
         Console_Out_Handle      : Handle;
         Console_Out             : System.Address; -- EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL*;
         Standard_Error_Handle   : Handle;
         Standard_Error          : System.Address; -- EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL*;
         Runtime_Services        : System.Address; -- EFI_RUNTIME_SERVICES*;
         Boot_Services           : System.Address; -- EFI_BOOT_SERVICES*;
         Number_Of_Table_Entries : U32;            -- UINTN;
         Configuration_Table     : System.Address; -- EFI_CONFIGURATION_TABLE*;
      end record;

private
   type Handle is new System.Address;

   for System_Table_64'Size use 592;
   for System_Table_64 use
      record
         Header                  at 0 range 0 .. 191;
         Firmware_Vendor         at 24 range 0 .. 31;
         Firmware_Revision       at 28 range 0 .. 31;
         Console_In_Handle       at 32 range 0 .. 31;
         Console_In              at 36 range 0 .. 31;
         Console_Out_Handle      at 40 range 0 .. 31;
         Console_Out             at 44 range 0 .. 31;
         Standard_Error_Handle   at 48 range 0 .. 31;
         Standard_Error          at 52 range 0 .. 31;
         Runtime_Services        at 56 range 0 .. 31;
         Boot_Services           at 60 range 0 .. 31;
         Number_Of_Table_Entries at 66 range 0 .. 31;
         Configuration_Table     at 70 range 0 .. 31;
      end record;

end Efi;
