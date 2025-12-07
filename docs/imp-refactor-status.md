# imp.refactor Implementation Status

The Rust-based registry refactoring tool now exists as a functional CLI that solves the core problem: detecting broken registry references by reading the working directory while evaluating the committed registry. This document covers what works, what doesn't, and what remains.

## The Working Pipeline

A user runs `nix run .# -- detect` from a flake directory. The tool walks the working tree for `.nix` files, skipping anything prefixed with `.` or `_`. Each file is parsed with rnix, and the AST walker extracts `NODE_SELECT` nodes whose base identifier matches the registry name. For `registry.home.alice`, this yields `home.alice` with its source location.

The registry comes from `nix eval --json .#registry` by default, producing a nested JSON object that gets flattened into a set of valid paths. Optionally, `--git-ref HEAD^` evaluates the registry from a specific git commit, enabling detection of renames between commits. Comparison is straightforward: if an extracted path isn't in the valid set, it's broken.

Suggestion generation tries two strategies. First, explicit rename mappings supplied via `--rename old=new` are applied using longest-prefix-wins semantics. `--rename home=users` transforms `home.alice` to `users.alice`. Second, if no mapping applies, the leaf-name heuristic searches valid paths for exactly one match ending in the same final component. Ambiguous matches (multiple candidates) and no-match cases get flagged with reasons.

The `apply` subcommand performs the same detection, then rewrites files. By default it operates as a dry-run, printing what would change. Add `--write` to modify files, or use `--interactive` for per-file confirmation prompts.

## Interactive Mode

The `--interactive` flag (or `-i`) prompts before applying changes to each file:

```sh
# Review each file's changes before applying
imp-refactor apply --interactive

# Combine with git ref for migration workflow
imp-refactor apply --git-ref HEAD^ --interactive
```

For each file with changes, the tool displays:
- File path
- List of changes with line numbers and old/new paths
- A prompt with options: Apply, Skip, or Abort

Interactive mode implies `--write` (no need to specify both). After processing all files, a summary shows how many files were updated vs skipped.

The UX uses per-file granularity rather than per-reference. This balances control against prompt fatigue—files typically have related changes that should be applied together.

## Git Ref Support

The `--git-ref` flag enables comparison against any git ref (branch, tag, commit, or relative reference like `HEAD^`). This solves a key workflow: detecting what changed between commits.

```sh
# Compare working tree against previous commit's registry
imp-refactor detect --git-ref HEAD^

# Compare against a specific branch
imp-refactor detect --git-ref main

# Apply fixes based on previous commit's registry
imp-refactor apply --git-ref HEAD^ --write
```

Under the hood, `--git-ref` resolves the ref to a commit hash via `git rev-parse`, then evaluates the registry using `builtins.getFlake "git+file:.?rev=<hash>"`. This ensures the comparison uses exactly the committed registry state, not the working tree.

The `registry` subcommand also accepts `--git-ref` to inspect the registry structure at any commit.

## Test Coverage

53 unit tests cover the scanner, analyzer, registry, and rewriter modules. Scanner tests verify AST extraction from various Nix patterns: single references, multiple per line, deep nesting, custom registry names. Analyzer tests verify rename map application, leaf heuristics, ambiguity detection, and full detection integration. Registry tests verify path flattening and git ref resolution. Rewriter tests verify position-aware replacement: single references, multiple on same line, multiline content, preservation of comments containing matching text. Eight fixture-based tests use the `complex-renames` and `migrate-test` directories copied from imp.lib.

The test fixtures exercise:
- `home` to `users` renames
- `svc.db` to `services.database` mid-level renames  
- `mods.profiles` prefix collapse to `profiles`
- Files with only valid refs (expect no broken)
- Files with only broken refs (expect all detected)
- Mixed valid and broken in same file
- Ambiguous leaf names returning null suggestions
- Nonexistent leaves returning null with reason

All tests pass. `nix flake check` validates formatting and clippy.

## What's Missing

### Minor CLI gaps

The `validate` subcommand (`imp-refactor validate --rename home=users`) would check whether a rename map produces valid target paths before running detection. Not critical; users can run `detect --verbose` to see failures.

The `--only` filter for `apply` would restrict which suggestions get applied. Useful for incremental migration but rarely needed.

### imp.lib integration

Phase 4 of the plan calls for adding imp.refactor as an optional input to imp.lib and exposing `apps.imp-migrate` that wraps the binary. This would let users run `nix run .#imp-migrate` from their flake. The existing `migrate.nix` would be deprecated but kept for backwards compatibility.

## File Structure

```
imp.refactor/
├── rs/
│   ├── src/
│   │   ├── lib.rs          # Public API re-exports
│   │   ├── main.rs         # CLI entrypoint, subcommand dispatch
│   │   ├── cli.rs          # Clap argument definitions
│   │   ├── scanner.rs      # File walking, rnix extraction (17 tests)
│   │   ├── analyzer.rs     # Comparison, suggestions (23 tests)
│   │   ├── registry.rs     # nix eval, git ref resolution, tree printing (6 tests)
│   │   └── rewriter.rs     # Position-aware file modification (7 tests)
│   ├── tests/fixtures/     # Test Nix files from imp.lib
│   ├── Cargo.toml
│   └── Cargo.lock
├── nix/
│   ├── tests/default.nix   # nix-unit integration tests
│   └── lib.nix             # Nix helper functions
├── flake.nix
└── README.md
```

## Next Steps

imp.lib integration is next. This is mostly Nix wiring: add an optional input, create an app that wraps the binary, update the flakeModule to expose it. The migrate.nix deprecation can happen gradually.

## Comparison with Nix Implementation

The Rust tool fixes the fundamental store-path problem. The Nix version reads files from `/nix/store/xxx-source/...` and compares against a registry built from the same store path. Both reflect the same committed state, so renames are invisible.

The Rust version reads files from the working directory (`std::fs::read_to_string`) and evaluates the registry from the committed flake (`nix eval`). This separation is why the tool works at all.

Other improvements: AST parsing instead of regex catches multi-line expressions and ignores comments. Rich diagnostics explain why suggestions fail. JSON output enables scripting. Colored terminal output makes results scannable. Interactive mode via `dialoguer` enables careful migration review.

The Nix implementation remains useful for generating ast-grep commands in contexts where the Rust binary isn't available. It won't be removed, just deprecated in favor of the more capable tool.
