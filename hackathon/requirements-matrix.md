# Submission requirements matrix

Verified locally on 2026-09-19. “Complete” means implemented and backed by the named repository evidence; it does not claim that an external publication or contest action occurred.

| Requirement | Status | Evidence |
| --- | --- | --- |
| MoonBit-first core | Complete | `roboaudit.mbt`, `sha256.mbt`; `cmd/main` is only the native I/O/argument adapter |
| JSON → validation → recomputed success rate → Markdown vertical slice | Complete | `examples/minimal/canonical-clean.json`, `validate_json`, `report_markdown` |
| `validate`, `summarize`, `audit`, `compare`, `report` | Complete | CLI dispatch in `cmd/main/main.mbt`; native smoke commands in `hackathon/demo.ps1` |
| Canonical Run/Episode/Stage/AuditFinding | Complete | Public interfaces in `pkg.generated.mbti` |
| Canonical JSON, JSONL, simple CSV | Complete | Parser functions plus fixtures under `examples/minimal/` |
| RoboSynChallenge adapter | Complete | `config`/`summary`/episode/feasibility aliases and `examples/robosyn/evaluation-metrics-anonymized.json` |
| Protocol fingerprint and safe comparison | Complete | Pure MoonBit SHA-256 fingerprint; incompatible protocol fixtures suppress misleading deltas |
| Wilson 95% confidence interval | Complete | `wilson_interval`; boundary and generated property-style tests |
| Action-step groups and success/failure statistics | Complete | JSON/Markdown summaries and tests |
| Failure type/count/proportion and comparison deltas | Complete | Failure distributions, compatible-run failure-category changes, tests |
| Stage funnel | Complete | Canonical stages, deterministic funnel report, tests |
| Skipped reasons and retry disclosure | Complete | RA006/RA007 and `examples/minimal/skipped-and-retries.json` |
| Manifest/hash verification | Complete | Binary-safe pure MoonBit SHA-256, sorted manifest CLI, `verify-file`, tests |
| RA001–RA015 | Complete | `docs/audit-rules.md` and per-rule positive/negative cases in `docs/test-matrix.md` |
| Coverage evidence | Complete | Core 778/824 (94.42%), overall 831/963 (86.29%); CLI instrumentation limitation disclosed in `docs/test-matrix.md` |
| Deterministic JSON/Markdown/CSV | Complete | Explicit output order, determinism tests, fixed JSON/Markdown SHA-256 golden tests |
| 3+ safe fixtures | Complete | Eight synthetic/anonymized JSON/JSONL/CSV fixture files; no reference media or raw logs |
| 60+ automated tests | Complete | Native suite: 100/100 passing |
| Windows and Ubuntu CI | Complete locally; hosted runs await push | Two-OS native matrix with format/info/check/test/build, smoke, interface-diff, exit-code, manifest, and package checks |
| English and Chinese README | Complete | `README.md`, `README.zh-CN.md` |
| License/NOTICE/provenance/AI disclosure | Complete | Apache-2.0 `LICENSE`, `NOTICE`, `docs/provenance.md`, `docs/ai-assistance.md` |
| One-page proposal and Demo | Complete locally | `hackathon/one-page-proposal.md`, `hackathon/demo-script.md`, runnable `hackathon/demo.ps1` |
| Worklog, risk register, benchmark, checklist | Complete | Files under `hackathon/` and `benchmarks/README.md` |
| Read-only ten-task reference evidence | Complete within ACL boundary | `docs/reference-evidence.md`; protected roots are explicitly excluded and not inferred |
| Clean-directory reproduction | Complete | `docs/reproducibility.md`; fresh no-hardlinks clone passed all gates and stayed content-clean |
| Public repository and module identity | Complete | Public `https://github.com/Suian2/RoboAudit.mbt`; `moon.mod` uses `Suian2/roboaudit` |
| Mooncakes release, registration, final submission | External confirmation required | Not performed or claimed |

## MoonBit implementation share

At this verification point, Git-tracked and newly prepared nonblank lines are 2,542 in eight `*.mbt` files, 65 in one `*.ps1` Demo runner, and 127 in two `*.yml` automation files. MoonBit therefore accounts for 92.98% of this explicitly defined code-and-automation line set. Markdown, fixtures, licenses, configuration, and generated `*.mbti` interfaces are excluded from both numerator and denominator; this is a transparent repository snapshot, not a universal language-statistics claim.
