# Audit-rule test matrix

Every audit rule has an explicit triggering case and a non-triggering boundary or clean case. Test names below are stable labels in `roboaudit_wbtest.mbt`.

| Rule | Triggering test | Non-triggering test |
| --- | --- | --- |
| RA001 | `audit detects duplicate seed and skipped candidate` | `unique seeds pass RA001` |
| RA002 | `JSONL missing indices are RA002 even with stable fallbacks` | `present unique episode indices pass RA002` |
| RA003 | `missing success is RA003` | `boolean success values pass RA003` |
| RA004 | `audit recomputes summary and retry fields` | `correct declared success count is accepted` |
| RA005 | `declared episode count mismatch is RA005` | `RoboSyn field aliases normalize without count finding` |
| RA006 | `empty skipped reason remains disclosed` | `absent skipped candidates pass RA006` |
| RA007 | `audit recomputes summary and retry fields` | `declared retry policy permits later attempts` |
| RA008 | `audit recomputes summary and retry fields` | `candidate at final valid index is accepted` |
| RA009 | `compare rejects observation mismatch with RA009` | `compatible comparison reports rate difference` |
| RA010 | `compare rejects evaluator mismatch with RA010` | `compatible comparison reports rate difference` |
| RA011 | `training and evaluation seed overlap is RA011` | `disjoint training and evaluation seeds pass RA011` |
| RA012 | `artifact hash mismatch is RA012` | `matching artifact hash accepts hexadecimal case` |
| RA013 | `audit recomputes summary and retry fields` | `correct failure count and annotation are accepted` |
| RA014 | `successful timeout violation is RA014` | `non-negative action steps within timeout pass RA014` |
| RA015 | `missing provenance or code revision is RA015` | `complete provenance and code revision pass RA015` |

Additional tests cover malformed input, JSON escaping, Unicode, JSONL/CSV adapters, deterministic ordering, Wilson interval boundaries, grouped statistics, manifest hashing primitives, and the public library surface. The native suite currently contains 87 tests.
