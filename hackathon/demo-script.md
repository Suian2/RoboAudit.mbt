# Demo script

```powershell
moon test --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
moon run --target native cmd/main -- validate examples/robosyn/evaluation-metrics-anonymized.json
moon run --target native cmd/main -- validate examples/minimal/audit-findings.json
moon run --target native cmd/main -- summarize examples/minimal/episodes.jsonl
moon run --target native cmd/main -- summarize examples/minimal/episodes.csv
moon run --target native cmd/main -- report-csv examples/minimal/canonical-clean.json
moon run --target native cmd/main -- compare examples/minimal/canonical-clean.json examples/minimal/canonical-clean.json
moon run --target native cmd/main -- manifest examples/minimal/episodes.csv examples/minimal/episodes.jsonl
```

Expected narrative: the clean fixture recomputes 2/3 successes, a Wilson interval, action groups and stage funnel; JSONL and CSV normalize to the same report model; the RoboSyn-shaped fixture preserves a skipped-candidate disclosure as RA006; the malformed fixture identifies duplicate seed/index, invalid success, inconsistent count, and action-step violations; manifest output is sorted and hashes original bytes.
