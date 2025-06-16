{
  description = "api docs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        writeShellScript =
          name: script:
          toString (
            pkgs.writeShellScript name ''
              set -euo pipefail
              while true; do
                if [[ -f flake.nix ]]; then
                  break
                fi
                if [[ "$(pwd)" == "/" ]]; then
                  echo "flake.nix not found." >&2
                  exit 1
                fi
                cd ..
              done
              ESC=$(printf '\033')
              message() {
                printf "''${ESC}[32m==>''${ESC}[m ''${ESC}[1m%s''${ESC}[m\n" "$*"
              }
              ${script}
            ''
          );
      in
      {
        apps =
          let
            exportPath = plist: ''
              export PATH="${pkgs.lib.makeBinPath plist}:$PATH"
            '';
          in
          {
            up = {
              type = "app";
              program = writeShellScript "up" ''
                ${exportPath [
                  pkgs.nodejs_22
                  pkgs.pnpm
                  pkgs.mdbook
                  pkgs.caddy
                ]}

                message Build swagger-ui [pnpm]
                cd ./swagger-ui && pnpm install && pnpm build && cd ..

                message Build manual [mdbook]
                cd ./manual && mdbook build && cd ..

                message caddy start
                sudo env "PATH=$PATH" caddy start
              '';
            };
            down = {
              type = "app";
              program = writeShellScript "down" ''
                ${exportPath [
                  pkgs.caddy
                ]}
                message caddy stop
                sudo env "PATH=$PATH" caddy stop
              '';
            };
          };

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            caddy
            redocly
            mdbook
            nodejs_22
            pnpm
            nil
            typescript-language-server
          ];
        };

        formatter = treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
          };
        };
      }
    );
}
