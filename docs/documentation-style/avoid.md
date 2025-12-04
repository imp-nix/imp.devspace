BAD EXAMPLE BELOW. AVOID WRITING LIKE THIS:

---

# Troubleshooting
Common issues and solutions when using imp.
## Error: "You need to call withLib before..."
**Error message:**
```
error: You need to call withLib before using tree.
error: You need to call withLib before trying to read the tree.
```
**Cause:** Methods like `.tree`, `.configTree`, `.leafs`, and `.files` require `lib` from nixpkgs.
**Solution:** Call `.withLib` first:
```nix
# Wrong
imp.tree ./modules
# Correct
(imp.withLib lib).tree ./modules
# Or use treeWith as shorthand
imp.treeWith lib (x: x) ./modules
```
## Error: "infinite recursion encountered"
**Cause:** Usually happens when a config tree file tries to access the result of its own evaluation.
**Solution:** Ensure config tree files don't reference themselves or the module system config before it's built:
```nix
# Wrong - references config during build
{ config, ... }:
{
  programs.git.userName = config.users.primaryUser;
}
# Correct - use module system properly
{ config, lib, ... }:
{
  programs.git.userName = lib.mkDefault "default";
}
```
## Files not being found
**Symptoms:** `.leafs` or `.files` returns empty list or missing files.
**Common causes:**
1. **Files start with underscore:** By default, paths containing `/_` are excluded.
```nix
# These are ignored:
modules/_internal/foo.nix
modules/bar/_hidden.nix
# Use initFilter to change this:
(imp.initFilter (lib.hasSuffix ".nix")).leafs ./modules
```
2. **Files don't have `.nix` extension:** Only `.nix` files are included by default.
3. **Wrong path:** Check that the path exists and is accessible.
```nix
# Debug: print what's being found
builtins.trace (imp.withLib lib).leafs ./modules) ...
```
## Registry path not found
**Error message:**
```
error: attribute 'myModule' missing
```
**Cause:** Trying to access a registry path that doesn't exist.
**Solution:** Check the registry structure:
```nix
# Debug: see what paths exist
builtins.attrNames registry.modules.home
```
The registry maps directory structure to attributes:
- Directory `registry/modules/home/shell/` → `registry.modules.home.shell`
- File `registry/modules/home/base.nix` → `registry.modules.home.base`