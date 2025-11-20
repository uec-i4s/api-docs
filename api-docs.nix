{
  stdenv,
  writeTextFile,
  writeShellApplication,
  static-web-server,
  swagger-ui-dist,
  manual-dist,
  specs-dist,
}:

let
  all-site = stdenv.mkDerivation (finalAttrs: {
    name = "api-docs-all-site";

    phases = [ "installPhase" ];

    installPhase = ''
      runHook preInstall

      mkdir $out

      mkdir $out/swagger-ui
      cp -r ${swagger-ui-dist}/* $out/swagger-ui/

      mkdir $out/manual
      cp -r ${manual-dist}/* $out/manual/

      mkdir $out/specs
      cp -r ${specs-dist}/* $out/specs/

      runHook postInstall
    '';
  });

  configFile = writeTextFile {
    name = "sws.toml";
    text = ''
      [general]

      host = "::"
      root = "${all-site}"

      log-level = "info"
      log-with-ansi = true

      directory-listing = false
      health = true

      [advanced]

      [[advanced.redirects]]
      source = "/"
      destination = "/manual/"
      kind = 301
    '';
  };
in

writeShellApplication {
  name = "api-docs";
  runtimeInputs = [ static-web-server ];
  text = ''
    exec static-web-server --config-file ${configFile} "$@"
  '';
}
