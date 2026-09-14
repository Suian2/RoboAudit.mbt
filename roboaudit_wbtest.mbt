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

///|
test "Wilson empty interval is defined" {
  assert_eq(wilson_interval(0, 0), (0.0, 0.0))
}

///|
test "Wilson all-success interval contains the estimate" {
  let (low, high) = wilson_interval(5, 5)
  assert_true(low > 0.56 && low < 0.57)
  assert_true(high > 0.99 && high <= 1.0)
}

///|
test "Wilson all-failure interval contains zero" {
  let (low, high) = wilson_interval(0, 5)
  assert_true(low >= 0.0 && low < 0.001)
  assert_true(high > 0.43 && high < 0.44)
}

///|
test "protocol fingerprint is deterministic" {
  let input =
    #|{"task":"t","protocol":"p","observation_mode":"rgb","evaluator_version":"v","success_definition":"done","timeout_steps":10,"retry_policy":"none","episodes":[]}
  assert_eq(protocol_fingerprint(input), protocol_fingerprint(input))
  assert_true(protocol_fingerprint(input).contains("v1|task=t|protocol=p"))
}

///|
test "protocol fingerprint changes with observation mode" {
  let first =
    #|{"task":"t","protocol":"p","observation_mode":"rgb","evaluator_version":"v","episodes":[]}
  let second =
    #|{"task":"t","protocol":"p","observation_mode":"state","evaluator_version":"v","episodes":[]}
  assert_true(protocol_fingerprint(first) != protocol_fingerprint(second))
}

///|
test "compare rejects observation mismatch with RA009" {
  let first =
    #|{"task":"t","protocol":"p","observation_mode":"rgb","evaluator_version":"v","episodes":[]}
  let second =
    #|{"task":"t","protocol":"p","observation_mode":"state","evaluator_version":"v","episodes":[]}
  assert_true(compare_json(first, second).contains("RA009"))
}

///|
test "compare rejects evaluator mismatch with RA010" {
  let first =
    #|{"task":"t","protocol":"p","observation_mode":"rgb","evaluator_version":"v1","episodes":[]}
  let second =
    #|{"task":"t","protocol":"p","observation_mode":"rgb","evaluator_version":"v2","episodes":[]}
  assert_true(compare_json(first, second).contains("RA010"))
}

///|
test "compatible comparison reports rate difference" {
  let first =
    #|{"task":"t","protocol":"p","observation_mode":"rgb","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1,"success":false}]}
  let second =
    #|{"task":"t","protocol":"p","observation_mode":"rgb","evaluator_version":"v","episodes":[{"episode_index":0,"seed":2,"success":true}]}
  let report = compare_json(first, second)
  assert_true(report.contains("Compatible: true"))
  assert_true(report.contains("difference (B - A): 1"))
}

///|
test "invalid compare input is deterministic" {
  assert_true(compare_json("{", "{}").contains("RA000"))
}

///|
test "JSON report recomputes success statistics" {
  let input =
    #|{"run_id":"r","task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1,"success":true},{"episode_index":1,"seed":2,"success":false}]}
  let report = report_json(input)
  assert_true(report.contains("\"episode_count\": 2"))
  assert_true(report.contains("\"success_count\": 1"))
  assert_true(report.contains("\"success_rate\": 0.5"))
}

///|
test "JSON report is byte deterministic" {
  let input =
    #|{"run_id":"r","task":"t","evaluator_version":"v","episodes":[]}
  assert_eq(report_json(input), report_json(input))
}

///|
test "JSON report safely escapes input strings" {
  let input =
    #|{"run_id":"quote-\"-run","task":"line\\nname","evaluator_version":"v","episodes":[]}
  let report = report_json(input)
  assert_true(report.contains("quote-\\\"-run"))
}

///|
test "invalid JSON report remains valid JSON-shaped output" {
  assert_true(report_json("{").contains("\"error\": \"RA000"))
}

///|
test "missing success is RA003" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1}]}
  assert_true(validate_json(input).contains("RA003"))
}

///|
test "negative action steps are RA014" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1,"success":false,"action_steps":-1}]}
  assert_true(validate_json(input).contains("RA014"))
}

///|
test "successful timeout violation is RA014" {
  let input =
    #|{"task":"t","evaluator_version":"v","timeout_steps":5,"episodes":[{"episode_index":0,"seed":1,"success":true,"action_steps":6}]}
  assert_true(validate_json(input).contains("RA014"))
}

///|
test "candidate at final valid index is accepted" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"candidate_index":0,"seed":1,"success":true}]}
  assert_true(!validate_json(input).contains("RA008"))
}

///|
test "declared retry policy permits later attempts" {
  let input =
    #|{"task":"t","evaluator_version":"v","retry_policy":"up-to-two","episodes":[{"episode_index":0,"attempt_index":1,"seed":1,"success":true}]}
  assert_true(!validate_json(input).contains("RA007"))
}

///|
test "correct declared success count is accepted" {
  let input =
    #|{"task":"t","evaluator_version":"v","summary":{"success_count":1},"episodes":[{"episode_index":0,"seed":1,"success":true}]}
  assert_true(!validate_json(input).contains("RA004"))
}

///|
test "correct failure count and annotation are accepted" {
  let input =
    #|{"task":"t","evaluator_version":"v","summary":{"failure_count":1},"episodes":[{"episode_index":0,"seed":1,"success":false,"failure_type":"timeout"}]}
  assert_true(!validate_json(input).contains("RA013"))
}

///|
test "empty skipped reason remains disclosed" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[],"skipped":[{}]}
  assert_true(validate_json(input).contains("RA006"))
}

///|
test "empty run report avoids division by zero" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[]}
  assert_true(report_markdown(input).contains("Success: 0/0 (n/a)"))
}
