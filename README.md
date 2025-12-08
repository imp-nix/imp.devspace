# Dev Workspace for the `imp-nix` Org

This is a simple (convenience) monorepo for developing `imp-nix` repos. It contains all `imp-nix` repos as submodules with a few extra dev tools and settings.

## Quick Start

```bash
# Enter dev shell with submodule commands
nix develop

# Format the workspace
nix fmt
```

## Submodule Management Commands

The dev shell provides convenient commands for managing all submodules at once:

| Command              | Description                                           |
| -------------------- | ----------------------------------------------------- |
| `sub-update`         | Update flake locks in all submodules                  |
| `sub-update-push`    | Update locks, commit, and push in dependency order    |
| `sub-check`          | Check flakes in all submodules                        |
| `sub-fmt`            | Format all submodules                                 |
| `sub-pull`           | Pull latest changes in all submodules                 |
| `sub-status`         | Show git status of all submodules                     |
| `sub-log`            | Show recent commits in all submodules                 |
| `sub-push`           | Push all submodules                                   |
| `sub-clean`          | Clean nix store (collect garbage) in all submodules   |

### Examples

```bash
# Enter the dev shell first
nix develop

# Check status of all submodules
sub-status

# Update all flake locks (without committing)
sub-update

# Update, commit, and push all submodules in dependency order
# This is the recommended way to update the ecosystem
sub-update-push

# Format all submodules
sub-fmt
```

### Dependency Order

The `sub-update-push` command updates packages in this order to ensure dependencies are updated before their consumers:

1. **imp.fmt** (no dependencies)
2. **imp.docgen, imp.graph, imp.refactor** (depend on imp.fmt)
3. **imp.lib** (depends on imp.fmt, imp.docgen)
4. **imp.ixample** (depends on imp.lib, imp.graph, imp.refactor)

## Cross-Testing with `--override-input`

Test local changes across packages before committing:

```bash
# Test local imp.fmt changes in imp.lib
cd imp.lib
nix flake check --override-input imp-fmt path:../imp.fmt

# Test local imp.lib changes in imp.ixample
cd imp.ixample
nix build --override-input imp-lib path:../imp.lib
```