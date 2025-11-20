{
  lib,
  stdenv,
  mdbook,
  ruby,
}:

stdenv.mkDerivation (finalAttrs: {
  name = "manual-dist";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    mdbook
    ruby
  ];

  postPatch = ''
    rm preprocess/specs-src
    cp -r ${../specs/src} preprocess/specs-src
  '';

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
