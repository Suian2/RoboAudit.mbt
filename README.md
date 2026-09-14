# RoboAudit.mbt

RoboAudit.mbt is a MoonBit-first native CLI for checking robot and embodied-AI evaluation logs. It turns an episode list into reproducible evidence: recalculated success counts, audit findings, and deterministic Markdown.

The project is deliberately independent of models, videos, datasets, and simulator assets. Fixtures are synthetic or anonymized, minimal examples.

## Current vertical slice

- Parses canonical JSON and the compatible core shape of RoboSyn-style `evaluation_metrics.json`.
- Emits deterministic Markdown with episode/success totals and failure annotations.
- Audits duplicate seeds and episode indices, invalid success values, inconsistent counts, skipped candidates, undeclared retries, out-of-range candidates, inconsistent failure totals, action-step violations, and missing provenance (RA001–RA008, RA013–RA015 subset).
- Runs as a native MoonBit executable and has anonymous fixtures.

P1 work still in progress: JSONL/CSV, protocol fingerprints and compare, Wilson intervals, stage funnels, manifest hashing, and the remaining rules. They are not claimed as complete.

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
roboaudit report <file>
```

`validate` prints `valid` or stable `RAxxx` findings. `report` emits human-readable Markdown. A non-empty `skipped` list is intentionally flagged so a success rate cannot hide excluded candidates.

## Data and provenance

No remote reference artifacts are committed. `examples/robosyn/evaluation-metrics-anonymized.json` is a hand-written, anonymous schema fixture. See [docs/provenance.md](docs/provenance.md).

## License

Apache-2.0. See [LICENSE](LICENSE), [NOTICE](NOTICE), and [docs/ai-assistance.md](docs/ai-assistance.md).
