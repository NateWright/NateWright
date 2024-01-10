{ stdenv, fetchFromGitHub, hugo }:
stdenv.mkDerivation {
  name = "nwright-tech-hugo-site";

  src = fetchFromGitHub {
    owner = "NateWright";
    repo = "NateWright";
    rev = "a24638c468f3a5394d7d8c6aabe9bf2f77486c3b";
    sha256 = "sha256-SRoIA1TjME7AQH3jzgElfPNSumwwHn2xHH4zZlgRfXI=";
    fetchSubmodules = true;
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
