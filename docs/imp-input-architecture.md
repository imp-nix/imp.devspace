# imp Input Architecture

Nix flakes have a deduplication problem. Every input brings its own dependency tree, and those trees overlap. A consumer flake using `imp.lib`, `imp-refactor`, and `imp-graph` separately ends up with three copies of `treefmt-nix`, three copies of `nix-unit`, and three slightly different `nixpkgs` revisions. The lockfile bloats, eval slows, and the cache fills with near-identical derivations.

## Design decision

imp.lib stays lean. It includes only what it needs to function and develop:

| Input | Purpose | Consumer-followable |
|-------|---------|---------------------|
| `nixpkgs` | Core dependency | Yes |
| `flake-parts` | Flake structure | Yes |
| `imp-fmt` | Formatter config | Yes |
| `treefmt-nix` | Formatter backend (dev) | Yes |
| `nix-unit` | Testing (dev) | Yes |
| `docgen` | Documentation (dev) | Yes |

Optional tools like `imp-graph` and `imp-refactor` are not bundled. Consumers add them as direct inputs when needed and pay the lockfile cost explicitly.

## Reducing duplication

Consumers who use multiple imp ecosystem tools can reduce lockfile duplication by following imp.lib's dependencies:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    imp.url = "github:imp-nix/imp.lib";

    # Direct input with follows to reduce duplication
    imp-refactor.url = "github:imp-nix/imp.refactor";
    imp-refactor.inputs.nixpkgs.follows = "nixpkgs";
    imp-refactor.inputs.treefmt-nix.follows = "imp/treefmt-nix";
    imp-refactor.inputs.nix-unit.follows = "imp/nix-unit";
    imp-refactor.inputs.imp-fmt.follows = "imp/imp-fmt";

    imp-graph.url = "github:imp-nix/imp.graph";
    imp-graph.inputs.nixpkgs.follows = "nixpkgs";
    imp-graph.inputs.treefmt-nix.follows = "imp/treefmt-nix";
    imp-graph.inputs.nix-unit.follows = "imp/nix-unit";
    imp-graph.inputs.imp-fmt.follows = "imp/imp-fmt";
  };
}
```

This pattern gives the consumer explicit control. They see each tool in their inputs, understand the cost, and can choose whether to optimize with follows declarations.

## Why not bundle everything

The previous approach bundled optional tools inside imp.lib so consumers could write `imp-refactor.follows = "imp/imp-refactor"`. This had problems:

1. **Conflation**: imp.lib's inputs mixed dev dependencies with consumer-followable tools. Nothing distinguished "this is here so imp.lib can run its own tests" from "you should follow this."

2. **Hidden costs**: A basic consumer wanting just the flake-parts module would pull in imp-refactor's Rust toolchain and imp-graph's WASM build infrastructure as transitive dependencies.

3. **Discoverability**: The follows syntax (`"imp/imp-refactor"`) is obscure. Users had to read imp.lib's flake.nix carefully to discover the pattern.

The current approach is honest: if you want imp-refactor, you add it. If you want to deduplicate, you add follows declarations. Each tool's README documents both patterns.

## Lockfile analysis tools

For consumers who want to verify or automate deduplication, [fzakaria/nix-auto-follow](https://github.com/fzakaria/nix-auto-follow) can analyze `flake.lock` and suggest follows declarations:

```sh
# Check if lockfile is fully deduplicated
nix run github:fzakaria/nix-auto-follow -- -c

# Apply deduplication in-place
nix run github:fzakaria/nix-auto-follow -- -i
```

Note that this tool operates on the lockfile after the fact. It cannot create follows relationships for inputs that aren't declared at the root level.
