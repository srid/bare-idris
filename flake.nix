{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mission-control.url = "github:Platonic-Systems/mission-control";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.mission-control.flakeModule
      ];
      perSystem = { pkgs, lib, config, ... }: {
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
              echo *.idr | ${lib.getExe pkgs.entr} , run
            '';
          };
        };
        devShells.default =
          let
            shell = pkgs.mkShell {
              nativeBuildInputs = [
                pkgs.idris2
              ];
            };
          in
          config.mission-control.installToDevShell shell;
      };
    };
}
