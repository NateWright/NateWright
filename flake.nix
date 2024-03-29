{
  description = "nwright.tech hugo website";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    paper-mod = {
      flake = false;
      url = "github:adityatelange/hugo-PaperMod";
    };
  };

  outputs = { self, nixpkgs, flake-utils, paper-mod }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in
        {
          devShells.default = import ./shell.nix { inherit pkgs; };
          packages = rec {
            nwright-hugo-website = pkgs.callPackage ./derivation.nix {
              paper-mod = paper-mod;
            };
            default = nwright-hugo-website;
          };
        }
      );
}
