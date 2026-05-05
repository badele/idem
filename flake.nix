{
  description = "A Nix-flake-based idem project development environment";

  # 'github:NixOS/nixpkgs/79a13f1437e149dc7be2d1290c74d378dad60814' (2024-02-03)
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  # inputs.nixpkgs.url = "path:/home/badele/ghq/github.com/badele/fork-nixpkgs";

  outputs =
    { self, nixpkgs }:
    let
      ###########################################################################
      # Lanuages Activation
      ###########################################################################
      ansible_support = false;
      copilot_support = true;
      dockerfile_support = false;
      go_support = false;
      javascript_support = false;
      json_support = false;
      latex_support = false;
      ledger_support = false;
      lua_support = false;
      make_support = false;
      markdown_support = true;
      nix_support = true;
      python_support = true;
      rust_support = false;
      scala_support = false;
      sh_support = true;
      terraform_support = false;
      yaml_support = false;

      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true; # For terraform
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        let
          ###########################################################################
          # Lanuages support
          ###########################################################################
          ansible_packages = with pkgs; [ ansible ];

          copilot_packages = with pkgs; [ copilot-language-server ];

          dockerfile_packages = with pkgs; [
            dockerfile-language-server

            # dockfmt installed from mise.toml
          ];

          go_packages = with pkgs; [
            go

            # gomodifytags installed from mise.toml
            # gotest installed from mise.tomls
            # gor installed from mise.tomle
          ];

          javascript_packages = with pkgs; [
            nodejs
          ];

          json_packages = with pkgs; [
            vscode-json-languageserver
          ];

          ledger_packages = with pkgs; [
            ledger
            hledger
          ];

          # Latex
          latex_packages = with pkgs; [
            ghostscript
            (texlive.combine {
              inherit (texlive)
                scheme-medium
                tabularray
                ninecolors
                msg
                lipsum
                pgf
                ;
            })
          ];

          lua_packages = with pkgs; [
            lua51Packages.lua
            lua-language-server
          ];

          make_packages = with pkgs; [ gnumake ];

          markdown_packages = with pkgs; [
            go-grip
            markdownlint-cli
            pandoc
            proselint
          ];

          nix_packages = with pkgs; [
            nixfmt
          ];

          python_packages = with pkgs; [
            pipenv
            poetry
            ty
            uv
            (python3.withPackages (
              ps: with ps; [
                black
                pyflakes
                pytest
              ]
            ))
          ];

          rust_packages = with pkgs; [
            rust-analyzer
            rustfmt

            clippy

            # cargo-check installed from mise.toml
          ];

          scala_packages = with pkgs; [
            sbt
            metals
            scalafmt
          ];

          sh_packages = with pkgs; [
            bash-language-server
            bashdb
            shellcheck
            shfmt
          ];

          terraform_packages = with pkgs; [
            terraform
            terraform-ls
          ];

          yaml_packages = with pkgs; [ yaml-language-server ];
        in
        with pkgs;
        with lib;
        {
          default = pkgs.mkShell {
            shellHook = ''
              export IDEM_ANSIBLE_SUPPORT=${boolToString ansible_support}
              export IDEM_COPILOT_SUPPORT=${boolToString copilot_support}
              export IDEM_SH_SUPPORT=${boolToString sh_support}
              export IDEM_DOCKERFILE_SUPPORT=${boolToString dockerfile_support}
              export IDEM_GO_SUPPORT=${boolToString go_support}
              export IDEM_JAVASCRIPT_SUPPORT=${boolToString javascript_support}
              export IDEM_JSON_SUPPORT=${boolToString json_support}
              export IDEM_LATEX_SUPPORT=${boolToString latex_support}
              export IDEM_LUA_SUPPORT=${boolToString lua_support}
              export IDEM_LEDGER_SUPPORT=${boolToString ledger_support}
              export IDEM_MAKE_SUPPORT=${boolToString make_support}
              export IDEM_MARKDOWN_SUPPORT=${boolToString markdown_support}
              export IDEM_NIX_SUPPORT=${boolToString nix_support}
              export IDEM_PYTHON_SUPPORT=${boolToString python_support}
              export IDEM_RUST_SUPPORT=${boolToString rust_support}
              export IDEM_SCALA_SUPPORT=${boolToString scala_support}
              export IDEM_TERRAFORM_SUPPORT=${boolToString terraform_support}
              export IDEM_YAML_SUPPORT=${boolToString yaml_support}

              eval "$(mise activate bash)"
              export MISE_TRUSTED_CONFIG_PATHS="$PWD"
              if missing_tools="$(mise ls --missing 2>/dev/null)"; then
                if [ -n "$missing_tools" ]; then
                  mise install
                fi
              else
                mise install
              fi
            '';

            packages =
              with pkgs;
              [
                # IDEM project requirements
                pre-commit

                # Emacs
                emacs

                # commands tools
                fd
                just
                mise

                # Commons formater
                prettier
              ]
              ++ optionals ansible_support ansible_packages
              ++ optionals copilot_support copilot_packages
              ++ optionals sh_support sh_packages
              ++ optionals dockerfile_support dockerfile_packages
              ++ optionals go_support go_packages
              ++ optionals javascript_support javascript_packages
              ++ optionals json_support json_packages
              ++ optionals latex_support latex_packages
              ++ optionals ledger_support ledger_packages
              ++ optionals lua_support lua_packages
              ++ optionals make_support make_packages
              ++ optionals markdown_support markdown_packages
              ++ optionals nix_support nix_packages
              ++ optionals python_support python_packages
              ++ optionals rust_support rust_packages
              ++ optionals scala_support scala_packages
              ++ optionals terraform_support terraform_packages
              ++ optionals yaml_support yaml_packages;
          };
        }
      );
    };
}
