///|
test "public validate accepts a supported clean run" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1,"success":true}]}
  assert_eq(@roboaudit.validate_json(input), "valid")
}

///|
test "public Markdown report exposes recomputed success" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1,"success":true}]}
  assert_true(@roboaudit.report_markdown(input).contains("Success: 1/1"))
}

///|
test "public JSON report exposes Wilson interval" {
  let input =
    #|{"task":"t","evaluator_version":"v","episodes":[{"episode_index":0,"seed":1,"success":true}]}
  assert_true(@roboaudit.report_json(input).contains("wilson_95_low"))
}

///|
test "public compare refuses incompatible observation protocols" {
  let first =
    #|{"task":"t","observation_mode":"rgb","evaluator_version":"v","episodes":[]}
  let second =
    #|{"task":"t","observation_mode":"state","evaluator_version":"v","episodes":[]}
  assert_true(@roboaudit.compare_json(first, second).contains("RA009"))
}

///|
test "public SHA-256 API matches standard vector" {
  assert_eq(
    @roboaudit.sha256_text("abc"),
    "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  )
}
