{
  description = "os dev stuff";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          buildInputs = with pkgs; [
	    gdb
            grub2
            xorriso
            curl
            gmp
            gnat
            gnumake
            gprbuild
            isl
            libmpc
            mpfr
          ];
        in
        {
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [
              qemu
            ] ++ buildInputs;

            # we need the gcc that can recognize ada
            shellHook = ''
              export PATH="$(echo $PATH | perl -pe 's/:[^:]+gcc[^:]*\d+[^:]+//g')"
            '';
          };
        }
      );
}

