---
title: "Hugo Website, Nixos, and CD"
date: 2024-04-09T11:59:58-04:00
draft: false
---

# Probelem
I host my website at home for fun.
I also use NixOS on my server.
Previously, I had included my hugo website as a flake and built the package when I updated the system.
This is a hassle and will sometimes cause other packages to update. I wanted continuous deployment that did not effect the host.

# Solution
I was inspired by [this](https://bradparker.com/posts/deploying-a-fully-automated-nix-based-static-website) by Brad Parker. 
I also used [this](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://github.com/NixOS/nix/issues/4007&ved=2ahUKEwj-7Jupx7GFAxWkElkFHdrYBsoQjjh6BAgREAE&usg=AOvVaw3mOJpi_LfH9nkr7nIq8uz7) GitHub issue to fix a bug. 

I setup my flake like this:
```nix

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
  
```
and my derivation like this:
```nix
  
{ stdenv, hugo, paper-mod }:
stdenv.mkDerivation {
  name = "nwright-tech-hugo-site";

  src = ./.;

  nativeBuildInputs = [ hugo ];
  buildPhase = ''
    cp -r $src/* .
    mkdir -p ./themes/PaperMod
    cp -r ${paper-mod}/* ./themes/PaperMod/
    ${hugo}/bin/hugo
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r public/* $out/
    runHook postInstall
  '';
}

```
I needed to add PaperMod as an input because it is a submodule of my repo and by default when using nix this resource will not be available.
I have to copy this into the right folder to be able to build properly. The derivation.nix is pretty standard.

Now to the continuous deployment part.
I created a systemd unit to build the website and copy it to webroot of a website every 5 minutes inspired by Brad Parker.
```nix
{ config, pkgs, ... }:
let
  serverName = "nwright.tech";
  webRoot = "/var/www/${serverName}";
in
{
  systemd.services.${serverName} = {
    enable = true;
    description = ''
      https://${serverName} source
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    path = [ pkgs.nix ];
    startAt = "*:0/5";
    script = ''
      set -ex

      nix build github:NateWright/NateWright --out-link ${webRoot} --extra-experimental-features nix-command --extra-experimental-features flakes --refresh
    '';
  };
}
```

This website is then hosted by a simple nginx server pointed to /var/www/nwright.tech.


# Results

A fully continously deployed website, self-hosted and doesn't require rebuilding my server everytime I add a simple post.

# Knowledge Gained

* Systemd units
* Systemd timers
* Furthered knowledge of nix build
  * --out-link specifies where the symlink be created
  * --refresh invalidates cache of nix build system causing the latest website to get built
