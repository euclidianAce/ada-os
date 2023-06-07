with Integers; use Integers;

package Multiboot2 with Pure is
   Magic : constant := 16#36d76289#;

   type Architecture_Type is new U32;

   I386_Protected_Mode : constant Architecture_Type := 0;
   Mips_32_Bit         : constant Architecture_Type := 4;

   type Header is
      record
         Magic         : U32;
         Architecture  : Architecture_Type;
         Header_Length : U32;
         Checksum      : U32;
      end record;

   for Header use
      record
         Magic         at 0 range 0 .. 31;
         Architecture  at 4 range 0 .. 31;
         Header_Length at 8 range 0 .. 31;
         Checksum      at 12 range 0 .. 31;
      end record;

   type Tag_Type is (
      Null_Tag,
      Boot_Command_Line_Tag,
      Boot_Loader_Name_Tag,
      Modules_Tag,
      Memory_Info_Tag,
      BIOS_Boot_Device_Tag,
      Memory_Map_Tag,
      VBE_Info_Tag,
      Framebuffer_Info_Tag,
      ELF_Symbols_Tag,
      APM_Table_Tag,
      EFI_32_Bit_System_Table_Pointer_Tag,
      EFI_64_Bit_System_Table_Pointer_Tag,
      SMBIOS_Tables_Tag,
      ACPI_1_RSDP_Tag,
      ACPI_2_RSDP_Tag,
      Networking_Info_Tag,
      EFI_Memory_Map_Tag,
      EFI_Boot_Services_Not_Terminated_Tag,
      EFI_32_Bit_Image_Handle_Pointer_Tag,
      EFI_64_Bit_Image_Handle_Pointer_Tag,
      Image_Load_Base_Physical_Address_Tag);

   for Tag_Type'Size use 16;
   for Tag_Type use (
      Null_Tag                             => 0,
      Boot_Command_Line_Tag                => 1,
      Boot_Loader_Name_Tag                 => 2,
      Modules_Tag                          => 3,
      Memory_Info_Tag                      => 4,
      BIOS_Boot_Device_Tag                 => 5,
      Memory_Map_Tag                       => 6,
      VBE_Info_Tag                         => 7,
      Framebuffer_Info_Tag                 => 8,
      ELF_Symbols_Tag                      => 9,
      APM_Table_Tag                        => 10,
      EFI_32_Bit_System_Table_Pointer_Tag  => 11,
      EFI_64_Bit_System_Table_Pointer_Tag  => 12,
      SMBIOS_Tables_Tag                    => 13,
      ACPI_1_RSDP_Tag                      => 14,
      ACPI_2_RSDP_Tag                      => 15,
      Networking_Info_Tag                  => 16,
      EFI_Memory_Map_Tag                   => 17,
      EFI_Boot_Services_Not_Terminated_Tag => 18,
      EFI_32_Bit_Image_Handle_Pointer_Tag  => 19,
      EFI_64_Bit_Image_Handle_Pointer_Tag  => 20,
      Image_Load_Base_Physical_Address_Tag => 21);

   type Tag is
      record
         Kind  : Tag_Type;
         Flags : U16;
         Size  : U32;
      end record;

   for Tag'Size use 64;
   for Tag use
      record
         Kind  at 0 range 0 .. 15;
         Flags at 2 range 0 .. 15;
         Size  at 4 range 0 .. 31;
      end record;


end Multiboot2;
