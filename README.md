# bare-idris

Just playing with the most basic (still pleasant) Idris dev environment possible.

Once in nix shell, run:

```sh
, watch
```

## Dependencies

- Core dependencies, like `contrib`, can be added to the `.ipkg` file.
- Custom dependencies can be added as a flake input (via `IDRIS2_PREFIX`) in flake.nix. This is WIP.