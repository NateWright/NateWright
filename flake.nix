{
  description = "A basic flake";

  inputs.systems.url = "github:nix-systems/default";

  outputs = { self, systems, nixpkgs }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      # packages = eachSystem (system: {
      #   natewright-hugo-site = pkgs.callPackage ./default.nix { };
      # });
      devShells = eachSystem (system: {
        natewright-hugo-site = pkgs.callPackage ./devShell.nix { };
      });

    };
}
