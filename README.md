# RoboAudit.mbt

RoboAudit.mbt is a MoonBit-first native CLI for checking robot and embodied-AI evaluation logs. It turns an episode list into reproducible evidence: recalculated success counts, audit findings, and deterministic Markdown.

The project is deliberately independent of models, videos, datasets, and simulator assets. Fixtures are synthetic or anonymized, minimal examples.

## Current vertical slice

- Parses canonical JSON and the compatible core shape of RoboSyn-style `evaluation_metrics.json`.
- Emits deterministic Markdown and JSON with recomputed totals and Wilson 95% confidence intervals.
- Audits duplicate seeds and episode indices, invalid success values, inconsistent counts, skipped candidates, undeclared retries, out-of-range candidates, inconsistent failure totals, action-step violations, and missing provenance (RA001–RA008, RA013–RA015 subset).
- Compares runs using a normalized protocol fingerprint and refuses unsafe observation/evaluator comparisons with RA009/RA010.
- Runs as a native MoonBit executable and has anonymous fixtures.

P1 work still in progress: JSONL/CSV, action-step distributions, stage funnels, manifest hashing, artifact validation, training/evaluation seed overlap, and 60+ tests. They are not claimed as complete.

## Quick start

```powershell
moon fmt
moon check --target native
moon test --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
moon run --target native cmd/main -- validate examples/minimal/audit-findings.json
```

## Commands

```text
roboaudit validate <file>
roboaudit summarize <file>
roboaudit audit <file>
roboaudit report <file>
roboaudit report-json <file>
roboaudit fingerprint <file>
roboaudit compare <file-a> <file-b>
```

`validate` prints `valid` or stable `RAxxx` findings. `report` emits human-readable Markdown. A non-empty `skipped` list is intentionally flagged so a success rate cannot hide excluded candidates.

## Data and provenance

No remote reference artifacts are committed. `examples/robosyn/evaluation-metrics-anonymized.json` is a hand-written, anonymous schema fixture. See [docs/provenance.md](docs/provenance.md).

## License

Apache-2.0. See [LICENSE](LICENSE), [NOTICE](NOTICE), and [docs/ai-assistance.md](docs/ai-assistance.md).
