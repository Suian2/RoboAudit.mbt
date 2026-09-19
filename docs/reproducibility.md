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

On 2026-09-19, release-candidate commit `22986a39d8f73f95916a9cb59a0d44cfea7da56f` was cloned with `--no-hardlinks` into a new directory. With the official MoonBit toolchain and the pinned `moonbitlang/async@0.21.3` dependency resolved from the local Moon cache, the checkout passed format checking, interface generation, a clean generated-interface diff, native checking, all 100 tests, native building, the complete `hackathon/demo.ps1` run, and package listing. `git status --short` remained clean.

The main checkout and clean clone produced identical byte evidence:

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `examples/minimal/episodes.csv` | 602 | `ab320071c33ac96354f7e259cb518f36600b3f3a8bedfe32d0574cb0f1051705` |
| `examples/minimal/episodes.jsonl` | 603 | `62bea690f2597a1b62234053756cbe3ff9bd672e7b391b8b4870f758648180fc` |
| `Suian2-roboaudit-0.1.0.zip` | 60,447 | `c21a92b8a3dcbafa9c80d4ca4084862282500ce98564a8cd9ec4175144126202` |

No source file or build directory from the original checkout was copied into the clone. The package hash is recorded as evidence for these two checkouts and toolchain state, not as a promise that every future ZIP implementation will preserve byte-identical archive metadata.

All tracked text and fixture formats are pinned to LF in `.gitattributes`; common image/archive extensions are explicitly binary. This keeps byte-level fixture manifests and generated `*.mbti` interfaces stable across Windows and Linux checkouts rather than allowing `core.autocrlf` to change their hashes.

The native C build emits an `EINVAL` macro-redefinition warning from the upstream async package against the installed Windows SDK. It does not originate in RoboAudit.mbt and did not affect any command exit status.
