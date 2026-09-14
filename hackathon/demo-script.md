# Demo script

```powershell
moon test --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
moon run --target native cmd/main -- validate examples/robosyn/evaluation-metrics-anonymized.json
moon run --target native cmd/main -- validate examples/minimal/audit-findings.json
```

Expected narrative: the clean fixture recomputes 2/3 successes; the RoboSyn-shaped fixture preserves a skipped-candidate disclosure as RA006; the malformed fixture identifies duplicate seed/index, invalid success, inconsistent count, and action-step violations.
