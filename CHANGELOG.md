# Changelog

## Unreleased

- Created the MoonBit core canonical JSON parser, validation rules, deterministic Markdown report, and native CLI.
- Added synthetic/anonymized fixtures, audit documentation, provenance policy, and native CI.
- Added deterministic JSON summary reports, Wilson 95% intervals, normalized protocol fingerprints, compatible-run comparison, RA009/RA010 checks, and a 31-test P0 matrix.
- Added JSONL/simple CSV input, deterministic CSV output, action/failure/stage/skipped statistics, RA011/RA012, public canonical model types, pure MoonBit SHA-256 manifests, file verification, 100 tests, and native benchmarks.
- Completed canonical provenance fields and corrected RA015 to require both provenance and code revision; added CLI version and non-zero audit exits.
- Added explicit positive/negative coverage for every RA001-RA015 rule and stable per-rule finding paths and suggestions.
- Added schema version, policy, seed policy, environment, duration, run-level failure annotations, failure proportions, relative success-rate comparison, and failure-category deltas.
- Added `report --format`, deterministic JSON/Markdown golden hashes, protocol-incompatibility fixtures, skipped/retry fixtures, and an auditable ten-task read-only reference evidence record.
- Normalized RoboSyn `feasibility_filter.skipped_seeds`, treated an enabled feasibility filter as retry disclosure, and bounded candidate indices against the disclosed completed-plus-skipped population.
