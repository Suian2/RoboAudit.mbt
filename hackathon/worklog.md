# Worklog

## 2026-09-14

- Confirmed the local MoonBit toolchain and initialized skeleton state without reinitializing the project.
- Verified the read-only remote reference root is visible. Metadata recursion encountered access-denied historical `archive/.../repo_snapshot/policy` directories; direct inspection confirmed the parent is listable but those child directories cannot be enumerated in the sandbox. They were not read or changed.
- Implemented and executed the first JSON-to-audit-to-Markdown vertical slice in MoonBit.
- Added synthetic and anonymized fixtures only; no remote artifacts or private paths were copied.
- Verified `moon fmt`, `moon info`, `moon check --target native`, `moon test --target native`, `moon build --target native`, and CLI demo commands locally.
- Read one formal evaluation JSON only to extract a SHA-256, field names, and aggregate schema evidence; updated aliases for `summary.episode_count`, `config.timeout_action_steps`, and `episode_attempt_index`. No raw content was committed.
- Added Wilson 95% intervals, deterministic JSON reports, protocol fingerprints, safe compare behavior, CLI aliases for the required command names, and public-API/boundary tests. Native test total reached 31/31 passing.
- Added JSONL and simple CSV adapters, action-step statistics, failure/skipped distributions, stage funnels, public canonical model types, all RA001-RA015 checks, deterministic CSV reports, binary-safe pure MoonBit SHA-256, sorted manifests, and direct file verification. Native test total reached 77/77 passing, including single-record JSONL and missing-index checks.
- Ran native release benchmarks on synthetic 1,000-episode input: validate 2.46 ms +/- 125.79 us; JSON report 3.05 ms +/- 250.48 us in this run.
- `moon package --list` completed and produced the local package ZIP. `moon publish --dry-run` completed its check/package phase but stopped because Mooncakes credentials are absent; no publication occurred.
- The read-only reference drive later became unavailable in the execution session. Ten-task metadata audit remains pending; local work continued without requesting credentials or touching remote state.
