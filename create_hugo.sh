#!/bin/bash
rm -r build
mkdir -p build
REV=`git rev-parse HEAD`
cd build
echo "{ stdenv, fetchFromGitHub, hugo }:
stdenv.mkDerivation {
  name = \"nwright-tech-hugo-site\";

  src = fetchFromGitHub {
    owner = \"NateWright\";
    repo = \"NateWright\";
    rev = \"$REV\";
    sha256 = \"\";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ hugo ];
  buildPhase = ''
    cp -r $src/* .
    \${hugo}/bin/hugo
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r public/* $out/
    runHook postInstall
  '';
}
" > derivation.nix
echo "{ pkgs ? import <nixpkgs> { } }:
pkgs.callPackage ./derivation.nix { }" > default.nix
sha=`nix-build 2>&1 | grep got:`
sha="${sha#*sha256}"
rm default.nix derivation.nix
echo "{ stdenv, fetchFromGitHub, hugo }:
stdenv.mkDerivation {
  name = \"nwright-tech-hugo-site\";

  src = fetchFromGitHub {
    owner = \"NateWright\";
    repo = \"NateWright\";
    rev = \"$REV\";
    sha256 = \"sha256$sha\";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ hugo ];
  buildPhase = ''
    cp -r \$src/* .
    \${hugo}/bin/hugo
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p \$out
    cp -r public/* \$out/
    runHook postInstall
  '';
}
" > default.nix