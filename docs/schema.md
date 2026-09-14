# Canonical schema (current slice)

`Run` normalizes `run_id`, `task`, `protocol`, `observation_mode`, `evaluator_version`, `timeout_steps`, `retry_policy`, `summary`, `episodes`, and `skipped`.

Each `Episode` normalizes `episode_index`, optional `candidate_index`, optional `attempt_index`, optional `seed`, `success`, optional `action_steps`, and optional `failure_type`.

Fields absent from a source log retain an explicit fallback or optional value; they are never invented. The public CLI currently reads JSON; JSONL and CSV are planned work.
