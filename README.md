# Dev Workspace for the `imp-nix` Org

This is a simple (convenience) monorepo for developing `imp-nix` repos. It contains all `imp-nix` repos as submodules with a few extra dev tools and settings.

## Quick Start

```bash
# Enter dev shell with common tools
nix develop

# Format the workspace
nix fmt
```

## Git Submodule Aliases

Convenient aliases for managing all submodules at once:

| Alias                | Description                                           | Command                                                        |
| -------------------- | ----------------------------------------------------- | -------------------------------------------------------------- |
| `sub-update`         | Update flake locks in all submodules                  | `git submodule foreach 'nix flake update \|\| :'`              |
| `sub-update-push`    | Update locks, commit, and push in dependency order    | Updates imp.fmt → docgen/graph/refactor → lib → ixample       |
| `sub-check`          | Check flakes in all submodules                        | `git submodule foreach 'nix flake check \|\| :'`               |
| `sub-fmt`            | Format all submodules                                 | `git submodule foreach 'nix fmt \|\| :'`                       |
| `sub-pull`           | Pull latest changes in all submodules                 | `git submodule update --remote --merge`                        |
| `sub-status`         | Show git status of all submodules                     | `git submodule foreach 'echo "==> $name" && git status -s'`    |
| `sub-log`            | Show recent commits in all submodules                 | `git submodule foreach 'echo "==> $name" && git log -5'`       |
| `sub-push`           | Push all submodules                                   | `git submodule foreach 'git push \|\| :'`                      |
| `sub-run <cmd>`      | Run arbitrary command in all submodules               | `git submodule foreach '<cmd>'`                                |
| `sub-clean`          | Clean nix store (collect garbage) in all submodules   | `git submodule foreach 'nix-collect-garbage \|\| :'`           |

### Examples

```bash
# Check status of all submodules
git sub-status

# Update all flake locks (without committing)
git sub-update

# Update, commit, and push all submodules in dependency order
# This is the recommended way to update the ecosystem
git sub-update-push

# Run custom command in all submodules
git sub-run "git diff --stat"

# Format all submodules
git sub-fmt
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