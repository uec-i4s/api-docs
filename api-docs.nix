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
    pname = "api-docs-all-site";
    version = "0.0.0";

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
      # Port will be specified via command line argument
      root = "${all-site}"
      log-level = "info"

      # Enable directory listing for /specs
      directory-listing = false

      [advanced]
      # Redirect / to /manual/
      [[advanced.redirects]]
      source = "/"
      destination = "/manual/"
      kind = 301

      # Enable directory listing only for /specs
      [[advanced.virtual-hosts]]
      host = "*"
      root = "${all-site}"
    '';
  };
in

writeShellApplication {
  name = "api-docs";
  runtimeInputs = [ static-web-server ];
  text = ''
    # Pass all arguments to static-web-server
    # The config file sets most options, but port can be overridden via CLI
    exec static-web-server --config-file ${configFile} "$@"
  '';
}
