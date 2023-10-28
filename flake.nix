# {
#   description = "A basic flake";

#   inputs.systems.url = "github:nix-systems/default";

#   outputs = { self, systems, nixpkgs }:
#     let
#       eachSystem = nixpkgs.lib.genAttrs (import systems);
#     in
#     {
#       # packages = eachSystem (system: {
#       #   natewright-hugo-site = pkgs.callPackage ./default.nix { };
#       # });
#       devShell = eachSystem (system: {
#         natewright-hugo-site = nixpkgs.callPackage ./devShell.nix { };
#       });

#     };
# }

{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages.default = pkgs.callPackage ./default.nix { };

        devShell = pkgs.mkShell { buildInputs = [ pkgs.hugo ]; };
      });
}
