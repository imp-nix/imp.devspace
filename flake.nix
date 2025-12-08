/**
  Development workspace for the imp-nix ecosystem.

  Minimal flake for convenient local development and testing across packages.

  # Usage

  Test changes across packages with `--override-input`:

  ```bash
  cd imp.lib
  nix flake check --override-input imp-fmt path:../imp.fmt
  ```

  Format the entire workspace:

  ```bash
  nix fmt
  ```

  Enter dev shell with common tools:

  ```bash
  nix develop
  ```
*/
{
  description = "Development workspace for imp-nix packages";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      # Simple formatter using nixpkgs treefmt
      formatter = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.writeShellScriptBin "workspace-fmt" ''
          ${pkgs.lib.getExe pkgs.nixfmt-rfc-style} "$@"
        ''
      );

      # Dev shell with common tools for imp development
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          # Submodule management scripts
          sub-update = pkgs.writeShellScriptBin "sub-update" ''
            git submodule foreach --recursive 'nix flake update || :'
          '';

          sub-check = pkgs.writeShellScriptBin "sub-check" ''
            git submodule foreach --recursive 'nix flake check || :'
          '';

          sub-fmt = pkgs.writeShellScriptBin "sub-fmt" ''
            git submodule foreach --recursive 'nix fmt || :'
          '';

          sub-pull = pkgs.writeShellScriptBin "sub-pull" ''
            git submodule update --remote --merge
          '';

          sub-status = pkgs.writeShellScriptBin "sub-status" ''
            git submodule foreach --recursive 'echo "==> $name" && git status --short'
          '';

          sub-log = pkgs.writeShellScriptBin "sub-log" ''
            git submodule foreach --recursive 'echo "==> $name" && git log --oneline -5'
          '';

          sub-push = pkgs.writeShellScriptBin "sub-push" ''
            git submodule foreach --recursive 'git push || :'
          '';

          sub-clean = pkgs.writeShellScriptBin "sub-clean" ''
            git submodule foreach --recursive 'nix-collect-garbage || :'
          '';

          # Update, commit, and push in dependency order
          sub-update-push = pkgs.writeShellScriptBin "sub-update-push" ''
            set -e

            echo '==> Updating imp.fmt (no dependencies)'
            cd imp.fmt
            nix flake update
            git add flake.lock
            git commit -m 'Update flake lock' || echo "No changes to commit"
            git push
            cd ..

            echo '==> Updating imp.docgen (depends on imp.fmt)'
            cd imp.docgen
            nix flake update
            git add flake.lock
            git commit -m 'Update flake lock' || echo "No changes to commit"
            git push
            cd ..

            echo '==> Updating imp.graph (depends on imp.fmt)'
            cd imp.graph
            nix flake update
            git add flake.lock
            git commit -m 'Update flake lock' || echo "No changes to commit"
            git push
            cd ..

            echo '==> Updating imp.refactor (depends on imp.fmt)'
            cd imp.refactor
            nix flake update
            git add flake.lock
            git commit -m 'Update flake lock' || echo "No changes to commit"
            git push
            cd ..

            echo '==> Updating imp.lib (depends on imp.fmt, imp.docgen)'
            cd imp.lib
            nix flake update
            git add flake.lock
            git commit -m 'Update flake lock' || echo "No changes to commit"
            git push
            cd ..

            echo '==> Updating imp.ixample (depends on imp.lib, imp.graph, imp.refactor)'
            cd imp.ixample
            nix flake update
            git add flake.lock
            git commit -m 'Update flake lock' || echo "No changes to commit"
            git push
            cd ..

            echo '==> All submodules updated and pushed!'
          '';
        in
        {
          default = pkgs.mkShell {
            packages =
              with pkgs;
              [
                # Formatters
                nixfmt-rfc-style
                mdformat

                # Dev tools
                git
                gh

                # Submodule management scripts
                sub-update
                sub-check
                sub-fmt
                sub-pull
                sub-status
                sub-log
                sub-push
                sub-clean
                sub-update-push
              ];

            shellHook = ''
              echo "🚀 imp.devspace development environment"
              echo ""
              echo "Submodule commands:"
              echo "  sub-update       - Update flake locks in all submodules"
              echo "  sub-update-push  - Update, commit, and push in dependency order"
              echo "  sub-check        - Check flakes in all submodules"
              echo "  sub-fmt          - Format all submodules"
              echo "  sub-pull         - Pull latest changes in all submodules"
              echo "  sub-status       - Show status of all submodules"
              echo "  sub-log          - Show recent commits in all submodules"
              echo "  sub-push         - Push all submodules"
              echo "  sub-clean        - Clean nix store in all submodules"
              echo ""
            '';
          };
        }
      );
    };
}
