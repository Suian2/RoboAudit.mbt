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

## Verified clean checkout

On 2026-09-14, commit `91a1ee1662bb88f5b129b917eb8bceed9bdaa4c9` was cloned into a new directory. With the official MoonBit toolchain and the pinned `moonbitlang/async@0.21.3` dependency resolved from the local Moon cache, the checkout passed format checking, interface generation, native checking, all 77 tests, native building, and package listing. No source file or build directory from the original checkout was copied into the clone.

The native C build emits an `EINVAL` macro-redefinition warning from the upstream async package against the installed Windows SDK. It does not originate in RoboAudit.mbt and did not affect any command exit status.
