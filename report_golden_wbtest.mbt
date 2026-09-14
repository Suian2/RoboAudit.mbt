///|
test "deterministic JSON and Markdown golden hashes" {
  let input =
    #|{"schema_version":"1.0","run_id":"golden","task":"pick","policy":"demo","protocol":"fixed","observation_mode":"state","evaluator_version":"v1","code_revision":"rev1","seed_policy":"fixed-list","success_definition":"placed","environment":"sim","provenance":"synthetic","timeout_steps":10,"summary":{"episode_count":1,"success_count":1,"failure_count":0},"episodes":[{"episode_index":0,"seed":7,"success":true,"action_steps":5,"duration_ms":20,"stages":["reach","place"]}]}
  assert_eq(
    sha256_text(report_json(input)),
    "09c007b7e7600862ae987141e54df77cfde88008a1efb57b6e122a2a2610c4cc",
  )
  assert_eq(
    sha256_text(report_markdown(input)),
    "604a2d070245d8e901e2694bc0c7c6f8479fdc3816c8e4000e3f8329c064ad9b",
  )
}
