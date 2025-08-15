{
  stdenv,
  writeTextFile,
  caddy,
  swagger-ui-dist,
  manual-dist,
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
      cp -r ${./specs}/* $out/specs/

      runHook postInstall
    '';
  });

  caddyfile = writeTextFile {
    name = "Caddyfile";
    text = ''
      http://192.168.7.133, :2080 {
         vars upstream_prefix /docs

         redir /manual {vars.upstream_prefix}/manual/
         redir /swagger-ui {vars.upstream_prefix}/swagger-ui/
         redir /specs {vars.upstream_prefix}/specs/
         redir / {vars.upstream_prefix}/manual/

         handle_path /manual/* {
             root * ${all-site}/manual
             file_server
         }

         handle_path /swagger-ui/* {
             root * ${all-site}/swagger-ui
             file_server
         }

         handle_path /specs/* {
             root * ${all-site}/specs
             file_server browse
         }
      }
    '';
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "api-docs";
  version = "0.0.0";

  nativeBuildInputs = [ caddy ];

  phases = [ "installPhase" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cat > $out/bin/api-docs-run << EOF
    #!${stdenv.shell}
    set -e
    exec caddy run --config ${caddyfile} --adapter caddyfile
    EOF
    chmod +x $out/bin/api-docs-run

    cat > $out/bin/api-docs-start << EOF
    #!${stdenv.shell}
    set -e
    exec caddy start --config ${caddyfile} --adapter caddyfile
    EOF
    chmod +x $out/bin/api-docs-start

    cat > $out/bin/api-docs-stop << EOF
    #!${stdenv.shell}
    set -e
    exec caddy stop
    EOF
    chmod +x $out/bin/api-docs-stop

    runHook postInstall
  '';
})
