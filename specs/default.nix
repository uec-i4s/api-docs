{ stdenv }:

stdenv.mkDerivation {
  name = "specs-dist";
  src = ./.;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp index.html $out/index.html
    cp src/*.yaml $out/

    runHook postInstall
  '';
}
