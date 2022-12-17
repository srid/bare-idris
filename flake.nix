{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mission-control.url = "github:Platonic-Systems/mission-control";

    # Idris dependencies
    idris-indexed.url = "github:mattpolzin/idris-indexed";
    idris-indexed.flake = false;
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.mission-control.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }:
        let
          # mkIdris2Prefix : [IdrisPackageSource] -> Derivation
          #
          # Create a derivation that represents the $IDRIS2_PREFIX containing
          # the given package sources.
          mkIdris2Prefix = packageSources:
            pkgs.runCommand "idris2-prefix"
              {
                buildInputs = [ pkgs.idris2 ];
              } ''
              set -e
              mkdir -p $out
              ${lib.concatMapStringsSep "\n" 
                (p: '' 
                  pushd ${p} 
                  IDRIS2_PREFIX=$out idris2 --build-dir $out/tmp --install *.ipkg
                  popd
                '') 
                packageSources
              }
              rm -rf $out/tmp
            '';
          # TODO: Best to parse this out of bare-idris.ipkg?
          idrisPrefix = mkIdris2Prefix [
            inputs.idris-indexed
          ];
        in
        {
          mission-control.scripts = {
            fmt = {
              description = "Format the top-level Nix files";
              command = "${lib.getExe pkgs.nixpkgs-fmt} ./*.nix";
              category = "Tools";
            };
            run = {
              description = "Compile and run the project";
              command = ''
                set -x
                ${lib.getExe pkgs.idris2} --build ./*.ipkg 
                build/exec/bare-idris
              '';
            };
            watch = {
              description = "Watch the project and re-run on changes";
              command = ''
                set -x
                (ls ./*.ipkg; ls ./*.idr;) | ${lib.getExe pkgs.entr} , run
              '';
            };
          };
          packages.idrisprefix = idrisPrefix;
          devShells.default =
            let

              shell = pkgs.mkShell {
                nativeBuildInputs = [
                  pkgs.idris2
                ];
                shellHook = ''
                  export IDRIS2_PREFIX=${idrisPrefix}
                '';
              };
            in
            config.mission-control.installToDevShell shell;
        };
    };
}
