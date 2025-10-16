{
  lib,
  stdenv,
  nodejs,
  pnpm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swagger-ui";
  version = "0.0.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  postPatch = ''
    rm public/specs
    ln -s ${../specs} public/specs
  '';

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-bI2Tdad9xNuKNAtV2IgHg/kmdaq5TMHQTovl3/4B/0s=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    mv dist/* $out/

    runHook postInstall
  '';
})
