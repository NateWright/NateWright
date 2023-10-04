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
