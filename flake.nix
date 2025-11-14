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
        lib = pkgs.lib;
        linuxPkgs =
          if pkgs.stdenv.hostPlatform.isLinux then
            pkgs
          else if system == "aarch64-darwin" then
            pkgs.pkgsCross.aarch64-multiplatform
          else if system == "x86_64-darwin" then
            pkgs.pkgsCross.gnu64
          else
            throw "Unsupported system: ${system}";
      in
      {
        packages =
          let
            swagger-ui-dist = pkgs.callPackage ./swagger-ui { };
            manual-dist = pkgs.callPackage ./manual { };
            api-docs = pkgs.callPackage ./api-docs.nix {
              inherit swagger-ui-dist manual-dist;
            };
            dockerImage = pkgs.dockerTools.buildImage {
              name = "api-docs";
              copyToRoot = pkgs.buildEnv {
                name = "api-docs-image-root";
                paths = with linuxPkgs; [
                  (callPackage ./api-docs.nix {
                    swagger-ui-dist = callPackage ./swagger-ui { };
                    manual-dist = callPackage ./manual { };
                  })
                ];
              };
              config = {
                Cmd = [ "/bin/api-docs-run" ];
                Expose = [ "80:80" ];
              };
            };
          in
          {
            inherit
              swagger-ui-dist
              manual-dist
              api-docs
              dockerImage
              ;
            default = api-docs;
          };

        apps =
          let
            api-docs = self.packages.${system}.api-docs;
            getExe = lib.getExe;
          in
          {
            run = {
              type = "app";
              program = "${api-docs}/bin/api-docs-run";
            };

            start = {
              type = "app";
              program = "${api-docs}/bin/api-docs-start";
            };

            stop = {
              type = "app";
              program = "${api-docs}/bin/api-docs-stop";
            };

            default = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "chose-api-docs-cmd" ''
                  choose=$(${getExe pkgs.gum} choose --header="" \
                    --cursor-prefix='○ ' --selected-prefix='● ' --unselected-prefix='○ ' \
                    --cursor.foreground='75' --selected.foreground='75' \
                    'caddy run' 'caddy start' 'caddy stop')
                  case "$choose" in
                    'caddy run')   exec sudo ${api-docs}/bin/api-docs-run ;;
                    'caddy start') exec sudo ${api-docs}/bin/api-docs-start ;;
                    'caddy stop')  exec sudo ${api-docs}/bin/api-docs-stop ;;
                  esac
                ''
              );
            };
          };

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            caddy
            mdbook
            nodejs_24
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
