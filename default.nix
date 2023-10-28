{ stdenv, fetchgit, hugo }:
stdenv.mkDerivation {
  name = "nwright-tech-hugo-site";

  # src = ./.;
  src = fetchgit {
    url = "https://github.com/natewright/natewright.git";
    inherit (flake_input) rev;
  };

  nativeBuildInputs = [ hugo ];
  buildPhase = ''
    cp -r $src/* .
    ${hugo}/bin/hugo
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r public/* $out/
    runHook postInstall
  '';
}

