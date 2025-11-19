{ stdenv }:

stdenv.mkDerivation {
  name = "specs-dist";
  src = ./.;

  installPhase = ''
    mkdir -p $out

    # Copy index.html to root
    cp ${./index.html} $out/index.html

    # Copy all YAML files from src/ to root of output
    cp src/*.yaml $out/
  '';
}
