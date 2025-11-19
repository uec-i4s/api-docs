{
  lib,
  stdenv,
  mdbook,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "manual-dist";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    mdbook
  ];

  buildPhase = ''
    runHook preBuild

    mdbook build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv book/* $out/

    runHook postInstall
  '';
})
