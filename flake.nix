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
            specs-dist = pkgs.callPackage ./specs { };
            api-docs = pkgs.callPackage ./api-docs.nix {
              inherit swagger-ui-dist manual-dist specs-dist;
            };
            dockerImage = pkgs.dockerTools.buildImage {
              name = "api-docs";
              copyToRoot = pkgs.buildEnv {
                name = "api-docs-image-root";
                paths = with linuxPkgs; [
                  (callPackage ./api-docs.nix {
                    swagger-ui-dist = callPackage ./swagger-ui { };
                    manual-dist = callPackage ./manual { };
                    specs-dist = callPackage ./specs { };
                  })
                ];
              };
              config = {
                Cmd = [ "/bin/api-docs" ];
                Expose = [ "80:80" ];
              };
            };
          in
          {
            inherit
              swagger-ui-dist
              manual-dist
              specs-dist
              api-docs
              dockerImage
              ;
            default = api-docs;
          };

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            static-web-server
            mdbook
            ruby
            rubyPackages.solargraph
            nodejs_24
            pnpm
            nil
            typescript-language-server
            vscode-json-languageserver
          ];
        };

        formatter = treefmt-nix.lib.mkWrapper pkgs {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            prettier = {
              enable = true;
              includes = [
                "*.md"
                "*.html"
              ];
            };
          };
        };
      }
    );
}
