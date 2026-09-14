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
  assert_true(protocol_fingerprint(input).has_prefix("sha256:"))
  assert_eq(protocol_fingerprint(input).length(), 71)
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

///|
test "action step statistics handle odd-length median" {
  let run = parse_input(
    (
      #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"action_steps":9},{"success":false,"action_steps":3},{"success":true,"action_steps":6}]}
    ),
  ).unwrap()
  let stats = action_step_stats(run, 0)
  assert_eq(stats.count, 3)
  assert_eq(stats.mean, 6.0)
  assert_eq(stats.median, 6.0)
  assert_eq(stats.minimum, Some(3))
  assert_eq(stats.maximum, Some(9))
}

///|
test "action step statistics handle even-length median" {
  let run = parse_input(
    (
      #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"action_steps":2},{"success":false,"action_steps":8}]}
    ),
  ).unwrap()
  assert_eq(action_step_stats(run, 0).median, 5.0)
}

///|
test "action step statistics split success and failure" {
  let run = parse_input(
    (
      #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"action_steps":2},{"success":true,"action_steps":4},{"success":false,"action_steps":9}]}
    ),
  ).unwrap()
  assert_eq(action_step_stats(run, 1).mean, 3.0)
  assert_eq(action_step_stats(run, 2).mean, 9.0)
}

///|
test "empty action step statistics are defined" {
  let run = parse_input(
    (
      #|{"task":"t","evaluator_version":"v","episodes":[{"success":true}]}
    ),
  ).unwrap()
  let stats = action_step_stats(run, 0)
  assert_eq(stats.count, 0)
  assert_eq(stats.minimum, None)
  assert_eq(stats.maximum, None)
}

///|
test "JSONL parses episode stream" {
  let input =
    #|{"task":"jsonl","evaluator_version":"v","episode_index":0,"seed":1,"success":true}
    #|{"task":"jsonl","evaluator_version":"v","episode_index":1,"seed":2,"success":false}
  let report = report_json(input)
  assert_true(report.contains("\"episode_count\": 2"))
  assert_true(report.contains("\"success_count\": 1"))
}

///|
test "JSONL ignores blank lines" {
  let input =
    #|{"task":"jsonl","evaluator_version":"v","episode_index":0,"seed":1,"success":true}
    #|
    #|{"task":"jsonl","evaluator_version":"v","episode_index":1,"seed":2,"success":true}
  assert_true(report_json(input).contains("\"episode_count\": 2"))
}

///|
test "JSONL rejects malformed record" {
  let input =
    #|{"task":"jsonl","evaluator_version":"v","success":true}
    #|not-json
  assert_true(report_json(input).contains("RA000"))
}

///|
test "JSONL audit catches duplicate seed" {
  let input =
    #|{"task":"jsonl","evaluator_version":"v","episode_index":0,"seed":1,"success":true}
    #|{"task":"jsonl","evaluator_version":"v","episode_index":1,"seed":1,"success":false}
  assert_true(validate_json(input).contains("RA001"))
}

///|
test "simple CSV parses episode rows" {
  let input =
    #|episode_index,seed,success,action_steps,task,evaluator_version
    #|0,10,true,4,csv,v1
    #|1,11,false,8,csv,v1
  let report = report_json(input)
  assert_true(report.contains("\"episode_count\": 2"))
  assert_true(report.contains("\"success_rate\": 0.5"))
}

///|
test "CSV zero and one success aliases parse" {
  let input =
    #|episode_index,seed,success,task,evaluator_version
    #|0,10,1,csv,v1
    #|1,11,0,csv,v1
  assert_true(report_json(input).contains("\"success_count\": 1"))
}

///|
test "CSV invalid success is RA003" {
  let input =
    #|episode_index,seed,success,task,evaluator_version
    #|0,10,yes,csv,v1
  assert_true(validate_json(input).contains("RA003"))
}

///|
test "CSV missing required header is rejected" {
  let input =
    #|index,seed,result
    #|0,10,true
  assert_true(report_json(input).contains("RA000"))
}

///|
test "CSV failure type contributes annotation" {
  let input =
    #|episode_index,seed,success,failure_type,task,evaluator_version
    #|0,10,false,timeout,csv,v1
  assert_true(report_markdown(input).contains("Episode 0: timeout"))
}

///|
test "CSV duplicate episode index is RA002" {
  let input =
    #|episode_index,seed,success,task,evaluator_version
    #|0,10,true,csv,v1
    #|0,11,false,csv,v1
  assert_true(validate_json(input).contains("RA002"))
}

///|
test "stage string shorthand means completed" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"stages":["reach"]}]}
  assert_true(report_json(input).contains("\"completed_count\": 1"))
}

///|
test "stage object records incomplete outcome" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":false,"stages":[{"name":"place","completed":false}]}]}
  let report = report_json(input)
  assert_true(report.contains("\"stage\": \"place\""))
  assert_true(report.contains("\"completed_count\": 0"))
}

///|
test "stage success alias is accepted" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"stages":[{"stage":"grasp","success":true}]}]}
  assert_true(report_json(input).contains("\"stage\": \"grasp\""))
}

///|
test "unsupported stage values are ignored" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"stages":[7,null]}]}
  assert_true(report_json(input).contains("\"stage_funnel\": []"))
}

///|
test "failure type distribution aggregates repeated labels" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":false,"failure_type":"timeout"},{"success":false,"failure_type":"timeout"}]}
  let report = report_json(input)
  assert_true(report.contains("\"name\": \"timeout\""))
  assert_true(report.contains("\"count\": 2"))
}

///|
test "skipped reason distribution aggregates labels" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[],"skipped":[{"reason":"generation_failed"},{"reason":"generation_failed"}]}
  let report = report_json(input)
  assert_true(report.contains("\"name\": \"generation_failed\""))
  assert_true(report.contains("\"count\": 2"))
}

///|
test "JSON audit emits structured finding objects" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1,"success":"yes"}]}
  let report = report_json(input)
  assert_true(report.contains("\"rule_id\": \"RA003\""))
  assert_true(report.contains("\"severity\": \"error\""))
  assert_true(report.contains("\"path\": \"/\""))
}

///|
test "RA006 structured severity is warning" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[],"skipped":[{"reason":"x"}]}
  let report = report_json(input)
  assert_true(report.contains("\"rule_id\": \"RA006\""))
  assert_true(report.contains("\"severity\": \"warning\""))
}

///|
test "Unicode metadata is preserved in JSON report" {
  let input =
    #|{"run_id":"实验-一","task":"抓取","evaluator_version":"版本","episodes":[]}
  let report = report_json(input)
  assert_true(report.contains("实验-一"))
  assert_true(report.contains("抓取"))
}

///|
test "CSV accepts CRLF line endings" {
  let input = "episode_index,seed,success,task,evaluator_version\r\n0,1,true,csv,v\r\n"
  assert_true(report_json(input).contains("\"episode_count\": 1"))
}

///|
test "JSONL missing indices are RA002 even with stable fallbacks" {
  let input =
    #|{"task":"t","evaluator_version":"v","seed":1,"success":true}
    #|{"task":"t","evaluator_version":"v","seed":2,"success":false}
  assert_true(validate_json(input).contains("RA002"))
}

///|
test "single-record JSONL is parsed as one episode" {
  let input =
    #|{"task":"jsonl","evaluator_version":"v","episode_index":0,"seed":1,"success":true}
  assert_true(report_json(input).contains("\"episode_count\": 1"))
}

///|
test "stage funnel preserves first-observed order" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"stages":["z-stage","a-stage"]}]}
  let report = report_json(input)
  assert_true(report.find("z-stage").unwrap() < report.find("a-stage").unwrap())
}

///|
test "failure distribution preserves first-observed order" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":false,"failure_type":"z-type"},{"success":false,"failure_type":"a-type"}]}
  let report = report_json(input)
  assert_true(report.find("z-type").unwrap() < report.find("a-type").unwrap())
}

///|
test "leading and trailing JSON whitespace is accepted" {
  let input = "  \n {\"task\":\"t\",\"evaluator_version\":\"v\",\"episodes\":[]} \r\n "
  assert_true(!report_json(input).contains("RA000"))
}

///|
test "Wilson interval always contains generated estimate" {
  for total in 1..<=20 {
    for successes in 0..<=total {
      let (low, high) = wilson_interval(successes, total)
      let estimate = successes.to_double() / total.to_double()
      assert_true(low >= 0.0 && high <= 1.0)
      assert_true(low <= estimate && estimate <= high)
    }
  }
}

///|
test "training and evaluation seed overlap is RA011" {
  let input =
    #|{"task":"t","evaluator_version":"v","training_seeds":[4,5],"episodes":[{"seed":5,"success":true}]}
  assert_true(validate_json(input).contains("RA011"))
}

///|
test "disjoint training and evaluation seeds pass RA011" {
  let input =
    #|{"task":"t","evaluator_version":"v","training_seeds":[4],"episodes":[{"seed":5,"success":true}]}
  assert_true(!validate_json(input).contains("RA011"))
}

///|
test "missing artifact is RA012" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"artifact_refs":[{"path":"trace.json","exists":false,"sha256":"aa","observed_sha256":"aa"}]}]}
  assert_true(validate_json(input).contains("RA012"))
}

///|
test "artifact hash mismatch is RA012" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"artifact_refs":[{"path":"trace.json","exists":true,"sha256":"aa","observed_sha256":"bb"}]}]}
  assert_true(validate_json(input).contains("RA012"))
}

///|
test "unverifiable artifact metadata is RA012" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"artifact_refs":[{"path":"trace.json","exists":true}]}]}
  assert_true(validate_json(input).contains("RA012"))
}

///|
test "matching artifact hash accepts hexadecimal case" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"artifact_refs":[{"path":"trace.json","exists":true,"sha256":"AABB","observed_sha256":"aabb"}]}]}
  assert_true(!validate_json(input).contains("RA012"))
}

///|
test "CSV report has deterministic summary columns" {
  let input =
    #|{"run_id":"r","task":"t","evaluator_version":"v","episodes":[{"success":true}]}
  let report = report_csv(input)
  assert_true(report.has_prefix("run_id,task,protocol_fingerprint"))
  assert_true(report.contains(",1,1,0,1,"))
}

///|
test "CSV report doubles embedded quotes" {
  let input =
    #|{"run_id":"a\"b","task":"t","evaluator_version":"v","episodes":[]}
  assert_true(report_csv(input).contains("\"a\"\"b\""))
}

///|
test "invalid CSV report returns error row" {
  assert_true(report_csv("not an input").contains("RA000"))
}

///|
test "Markdown report includes Wilson and stage summaries" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"success":true,"stages":["done"]}]}
  let report = report_markdown(input)
  assert_true(report.contains("Wilson 95% CI"))
  assert_true(report.contains("Stage funnel"))
  assert_true(report.contains("done"))
}
