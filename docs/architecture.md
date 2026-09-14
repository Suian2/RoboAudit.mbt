# Architecture

`cmd/main` is a thin native adapter for filesystem, argument handling, exit codes, and byte-oriented file verification. The root MoonBit package owns input parsing, canonical normalization, validation, statistics, audit findings, protocol comparison, SHA-256, and report rendering. This separation keeps business logic usable by future CLI and WASM front ends.

The current flow is `canonical JSON | RoboSyn JSON | JSONL | CSV -> Run/Episode/Stage -> validation + audit + statistics -> deterministic Markdown/JSON/CSV`. Protocol fingerprints gate comparisons before any success-rate delta is reported. Parsing accepts canonical fields and overlapping RoboSyn evaluation shapes, including `config`, `summary`, `episodes`, and `feasibility_filter` aliases.

Manifest generation sorts input paths and hashes original bytes. Reports use explicit field order; golden SHA-256 tests detect accidental output changes. The CLI contains no audit business rules.
