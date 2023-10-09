{ stdenv, fetchFromGitHub, hugo }:
stdenv.mkDerivation {
  name = "nwright-tech-hugo-site";
  src = ./.;

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
