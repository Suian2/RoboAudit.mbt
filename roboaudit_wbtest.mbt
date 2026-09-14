///|
test "canonical parser and deterministic report" {
  let input =
    #|{
    #|  "run_id": "fixture-clean",
    #|  "task": "synthetic-pick",
    #|  "protocol": "random100",
    #|  "evaluator_version": "v1",
    #|  "summary": { "episodes": 2 },
    #|  "episodes": [
    #|    { "episode_index": 0, "seed": 11, "success": true, "action_steps": 10 },
    #|    { "episode_index": 1, "seed": 12, "success": false, "action_steps": 12, "failure_type": "timeout" }
    #|  ]
    #|}
  assert_eq(validate_json(input), "valid")
  assert_true(report_markdown(input).contains("Success: 1/2"))
}

///|
test "audit detects duplicate seed and skipped candidate" {
  let input =
    #|{
    #|  "task": "synthetic",
    #|  "evaluator_version": "v1",
    #|  "episodes": [
    #|    { "episode_index": 0, "seed": 4, "success": true },
    #|    { "episode_index": 0, "seed": 4, "success": false }
    #|  ],
    #|  "skipped": [{ "reason": "generation_failed" }]
    #|}
  let findings = validate_json(input)
  assert_true(findings.contains("RA001"))
  assert_true(findings.contains("RA002"))
  assert_true(findings.contains("RA006"))
}

///|
test "audit recomputes summary and retry fields" {
  let input =
    #|{
    #|  "task": "synthetic",
    #|  "evaluator_version": "v1",
    #|  "summary": { "episodes": 1, "success_count": 0, "failure_count": 0 },
    #|  "episodes": [
    #|    { "episode_index": 0, "candidate_index": 2, "attempt_index": 1, "seed": 5, "success": true, "failure_type": "invalid_annotation" }
    #|  ]
    #|}
  let findings = validate_json(input)
  assert_true(findings.contains("RA004"))
  assert_true(findings.contains("RA007"))
  assert_true(findings.contains("RA008"))
  assert_true(findings.contains("RA013"))
}

///|
test "invalid JSON reports parser error" {
  assert_eq(validate_json("{not-json}"), "RA000: invalid JSON input")
}

///|
test "RoboSyn field aliases normalize without count finding" {
  let input =
    #|{
    #|  "config": { "task": "real-shape", "timeout_action_steps": 9 },
    #|  "evaluator_version": "v1",
    #|  "summary": { "episode_count": 1, "success_count": 1 },
    #|  "episodes": [
    #|    { "episode_index": 0, "episode_attempt_index": 0, "seed": 17, "success": true, "action_steps": 9 }
    #|  ]
    #|}
  let findings = validate_json(input)
  assert_true(!findings.contains("RA004"))
  assert_true(!findings.contains("RA005"))
}
