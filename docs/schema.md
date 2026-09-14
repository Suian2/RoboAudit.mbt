# Canonical schema (current slice)

`Run` normalizes `schema_version`, `run_id`, `task`, `policy`, `protocol`, `observation_mode`, `evaluator_version`, `code_revision`, `seed_policy`, `success_definition`, `environment`, `provenance`, `timeout_steps`, `retry_policy`, declared summary values, `episodes`, `skipped`, top-level `failure_annotations`, and `training_seeds`.

Each `Episode` normalizes `episode_index`, optional `candidate_index`, optional `attempt_index`, optional `seed`, `success`, optional `action_steps`, optional `duration_ms`, optional `failure_type`, `stages`, and `artifact_refs`. `Stage`, `ArtifactRef`, `Episode`, `Run`, and `AuditFinding` are public MoonBit model types.

Fields absent from a source log retain an explicit fallback or optional value; they are never invented. JSONL treats each non-empty line as an episode object and takes run metadata from the first record. CSV requires `episode_index` and `success` headers and deliberately supports only unquoted fields.
