{
  description = "my project description";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShells.default = import ./shell.nix { inherit pkgs; };
          packages = rec {
            nwright-hugo-website = pkgs.callPackage ./derivation.nix { };
            default = nwright-hugo-website;
          };
        }
      );
}
