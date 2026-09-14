# Architecture

`cmd/main` is a thin native adapter for filesystem and argument handling. The root MoonBit package owns JSON parsing, canonical normalization, validation, statistics, audit findings, and report rendering. This separation keeps business logic usable by future CLI and WASM front ends.

The current flow is `JSON -> Run/Episode -> audit findings -> Markdown`. Parsing accepts canonical fields and the overlapping RoboSyn evaluation shape (`config.task`, `config.observation_mode`, `summary.episodes`, `episodes`, and `skipped`).
