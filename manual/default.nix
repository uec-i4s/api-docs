{
  lib,
  stdenv,
  mdbook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "manual";
  version = "0.0.0";

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
