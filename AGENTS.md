# imp.devspace

Multi-repo workspace for the imp Nix ecosystem.

## Packages

```mermaid
graph TD
    fmt[imp.fmt]
    docgen[imp.docgen]
    impgraph[imp.graph]
    lib[imp.lib]
    ixample[imp.ixample]

    fmt --> docgen
    fmt --> impgraph
    fmt --> lib
    docgen -.-> lib
    impgraph -.-> lib
    lib --> ixample
```

| Package       | Description                                              |
| ------------- | -------------------------------------------------------- |
| `imp.fmt`     | Standalone opinionated treefmt-nix formatter             |
| `imp.docgen`  | API doc generator (Rust CLI + Nix lib)                   |
| `imp.graph`   | Interactive dependency graph (Rust/WASM)                 |
| `imp.lib`     | Core library + flake-parts module                        |
| `imp.ixample` | Example NixOS config consumer flake of the imp ecosystem |

Solid arrows = build-time deps. Dashed = optional.

## Development testing

Test changes across repos before committing/pushing using `--override-input`, e.g. `nix flake check --override-input imp-fmt path:../imp.fmt`

## Guidelines

- `git add` untracked files before nix evals (new files only, not necessary for edits)
- Local dev refs go in `tmp/` (gitignored)
- See [docs/documentation-style/guide.md](./docs/documentation-style/guide.md) for prose style
