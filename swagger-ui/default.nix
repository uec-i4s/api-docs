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
    hash = "sha256-JZzzvo0jSJ4B59YHlp7M5kSKusdPGs/YqMn+Nflv2hg=";
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
