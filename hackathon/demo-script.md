# Demo script

Run the complete demo from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File hackathon/demo.ps1
```

The runner treats audit findings as expected exit status 1 and fails on any unexpected command result. The individual commands are listed below for narrated recording.

```powershell
moon test --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json --format json
moon run --target native cmd/main -- validate examples/robosyn/evaluation-metrics-anonymized.json
moon run --target native cmd/main -- validate examples/minimal/audit-findings.json
moon run --target native cmd/main -- audit examples/minimal/skipped-and-retries.json
moon run --target native cmd/main -- summarize examples/minimal/episodes.jsonl
moon run --target native cmd/main -- summarize examples/minimal/episodes.csv
moon run --target native cmd/main -- report-csv examples/minimal/canonical-clean.json
moon run --target native cmd/main -- compare examples/minimal/canonical-clean.json examples/minimal/canonical-clean.json
moon run --target native cmd/main -- compare examples/incompatible-protocols/pure-observation.json examples/incompatible-protocols/public-pose.json
moon run --target native cmd/main -- manifest examples/minimal/episodes.csv examples/minimal/episodes.jsonl
```

Expected narrative: the clean fixture recomputes 2/3 successes, a Wilson interval, action groups and stage funnel; `--format` selects deterministic Markdown, JSON, or CSV without changing the normalized run; JSONL and CSV normalize to the same report model; the RoboSyn-shaped fixture preserves a skipped-candidate disclosure as RA006; the malformed fixture identifies duplicate seed/index, invalid success, inconsistent count, and action-step violations; the skipped/retry fixture shows explicit reasons and failure annotations; incompatible protocols are refused instead of producing a misleading delta; manifest output is sorted and hashes original bytes.
