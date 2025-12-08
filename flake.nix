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
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Formatters
              nixfmt-rfc-style
              mdformat

              # Dev tools
              git
              gh
            ];
          };
        }
      );
    };
}
