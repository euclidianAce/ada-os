package body Efi is
   function Handle_Image (H : Handle) return Integers.Hex_String
      is (Integers.Hex_Image (System.Address (H)));
end Efi;
