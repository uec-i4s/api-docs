{
  lib,
  stdenv,
  nodejs,
  pnpm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swagger-ui-dist";
  version = "0.0.0";

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    nodejs
    pnpm.configHook
  ];

  postPatch = ''
    rm public/specs
    cp -r ${../specs/src} public/specs
  '';

  pnpmDeps = pnpm.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-x4yjc8CXs1m3O7TdnEfdxXxsbG70ul0nZiawKtT7WjM=";
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
