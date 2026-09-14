# RoboAudit.mbt

RoboAudit.mbt is a MoonBit-first native CLI for turning robot and embodied-AI episode logs into auditable, reproducible evaluation evidence.

## Features

- Canonical JSON, JSONL episode streams, simple unquoted CSV, and RoboSyn-style `evaluation_metrics.json` aliases.
- Deterministic Markdown, JSON, and CSV reports.
- Recomputed success counts and rates, Wilson 95% confidence intervals, action-step groups, failure counts/proportions, stage funnels, and skipped reasons.
- RA001 through RA015 audit rules, including retry disclosure, protocol mismatches, seed overlap, and artifact verification evidence.
- SHA-256 protocol fingerprints, sorted file manifests, and direct file verification using a binary-safe pure MoonBit implementation.
- 97 automated tests, native release benchmarks, CI, golden report hashes, and synthetic/anonymized fixtures.

Input CSV intentionally supports only simple unquoted fields. Use JSON or JSONL when values contain commas or embedded newlines. No models, videos, raw datasets, simulator assets, credentials, or unknown-license content are included.

## Quick start

```powershell
moon fmt --check
moon info
moon check --target native
moon test --target native
moon build --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json --format json
moon run --target native cmd/main -- --version
```

## Commands

```text
roboaudit validate <file>
roboaudit summarize <file>
roboaudit audit <file>
roboaudit compare <file-a> <file-b>
roboaudit report <file>
roboaudit report-json <file>
roboaudit report-csv <file>
roboaudit fingerprint <file>
roboaudit manifest <paths...>
roboaudit verify-file <path> <sha256>
```

`report <file> --format json|csv|markdown` is supported alongside the `report-json` and `report-csv` shortcuts.

`validate` and `audit` print `valid` or stable `RAxxx` findings and exit with status 1 when findings exist. Invalid usage exits 2; missing files and parsing failures are also non-zero. `summarize` and `report-json` emit structured JSON; `report` emits Markdown. A non-empty `skipped` list is deliberately flagged so a success rate cannot conceal excluded candidates.

## Documentation

- [Architecture](docs/architecture.md)
- [Canonical schema](docs/schema.md)
- [Audit rules](docs/audit-rules.md)
- [Audit-rule test matrix](docs/test-matrix.md)
- [Reproducibility](docs/reproducibility.md)
- [Reference evidence](docs/reference-evidence.md)
- [Provenance and safe-data policy](docs/provenance.md)
- [AI assistance](docs/ai-assistance.md)
- [Native benchmark evidence](benchmarks/README.md)

Protocol protection can be demonstrated with `examples/incompatible-protocols/`; skipped candidate and retry disclosure is demonstrated by `examples/minimal/skipped-and-retries.json`.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).
