# Reproducibility

From a clean checkout with the current official MoonBit toolchain:

```powershell
moon update
moon fmt --check
moon info
moon check --target native
moon test --target native
moon build --target native
moon bench --target native --release
moon package --list
```

Functional smoke tests:

```powershell
moon run --target native cmd/main -- summarize examples/minimal/canonical-clean.json
moon run --target native cmd/main -- summarize examples/minimal/episodes.jsonl
moon run --target native cmd/main -- summarize examples/minimal/episodes.csv
moon run --target native cmd/main -- compare examples/minimal/canonical-clean.json examples/minimal/canonical-clean.json
moon run --target native cmd/main -- manifest examples/minimal/episodes.csv examples/minimal/episodes.jsonl
```

Generated report ordering is explicit. Hashes are computed over original file bytes by the MoonBit SHA-256 implementation. The publish package can be inspected with `moon package --list`; actual Mooncakes publication requires login and contributor confirmation.
