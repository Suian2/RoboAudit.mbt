# Demo script

Run the complete demo from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File hackathon/demo.ps1
```

The runner treats audit findings as expected exit status 1 and fails on any unexpected command result. The individual commands are listed below for narrated recording.

## Suggested 2.5-minute judge recording

| Time | Screen | Narration |
| --- | --- | --- |
| 0:00–0:20 | README problem statement | “A success rate is not enough to establish whether a robot evaluation is reproducible or even comparable. RoboAudit turns raw episode logs into audit evidence locally, without uploading experiment data.” |
| 0:20–0:50 | Run the clean Markdown report | Point out the recomputed `2/3`, Wilson interval, action-step split, failure type, stage funnel, and absence of findings. |
| 0:50–1:15 | Run the RoboSyn-shaped audit | Show RA006 and the skipped reason. Explain that the evaluated success rate is retained, but cannot conceal excluded candidates. |
| 1:15–1:50 | Compare the incompatible fixtures | Highlight the dramatic `0/2` versus `2/2` inputs, RA009, two protocol fingerprints, and the deliberate refusal to print a misleading delta. |
| 1:50–2:10 | Emit JSON and a manifest | Show that the same core produces machine-readable evidence and binary-safe SHA-256 manifests for CI or delivery review. |
| 2:10–2:30 | Run the test summary and show CI | Close with 100 tests, RA001–RA015 coverage, Windows/Ubuntu native CI, deterministic golden hashes, and the MoonBit-first architecture. |

Use a terminal font large enough to keep the finding IDs and “Success-rate difference: not reported” readable. Avoid showing any reference-drive path, local username, credential file, browser session, or unrelated desktop content.

### Short recording commands

```powershell
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
moon run --target native cmd/main -- audit examples/robosyn/evaluation-metrics-anonymized.json
moon run --target native cmd/main -- compare examples/incompatible-protocols/pure-observation.json examples/incompatible-protocols/public-pose.json
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json --format json
moon run --target native cmd/main -- manifest examples/minimal/episodes.csv examples/minimal/episodes.jsonl
moon test --target native
```

The audit command intentionally exits 1 because it found RA006; this is expected evidence, not a crash. For an uninterrupted unattended check, use `hackathon/demo.ps1` instead.

## Complete demo command set

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
