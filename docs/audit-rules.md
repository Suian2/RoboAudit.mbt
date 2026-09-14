# Audit rules

| Rule | Check |
| --- | --- |
| RA001 | Duplicate present evaluation seeds |
| RA002 | Missing fallback or duplicate episode indices |
| RA003 | Missing or non-boolean success |
| RA004 | Declared success count differs from recomputation |
| RA005 | Declared episode count differs from parsed episodes |
| RA006 | Skipped candidates are present and must be disclosed |
| RA007 | Retry attempt exists but retry policy is absent |
| RA008 | Candidate index falls outside the disclosed completed-plus-skipped candidate population |
| RA009 | Compared observation modes differ |
| RA010 | Compared evaluator or success definitions differ |
| RA011 | Training and evaluation seed sets overlap |
| RA012 | Artifact is missing, unverifiable, or hash-mismatched |
| RA013 | Declared/annotated failures contradict failed episodes |
| RA014 | Negative action steps or successful timeout violation |
| RA015 | Missing provenance or code revision |

Findings have stable `rule_id`, `severity`, `path`, `message`, and `suggestion` fields in JSON reports. RA012 consumes explicit `exists`, expected `sha256`, and `observed_sha256` evidence in canonical episode artifact references. The CLI `verify-file` command computes observed hashes directly from original file bytes.
