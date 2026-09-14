///|
fn benchmark_run_json(count : Int) -> String {
  let output = StringBuilder()
  output.write_string(
    "{\"run_id\":\"benchmark\",\"task\":\"synthetic-benchmark\",\"protocol\":\"seeded-v1\",\"observation_mode\":\"state\",\"evaluator_version\":\"fixture-v1\",\"episodes\":[",
  )
  for index in 0..<count {
    if index > 0 {
      output.write_char(',')
    }
    let success = if index % 5 == 0 { "false" } else { "true" }
    output.write_string(
      "{\"episode_index\":" +
      index.to_string() +
      ",\"seed\":" +
      (100000 + index).to_string() +
      ",\"success\":" +
      success +
      ",\"action_steps\":" +
      (20 + index % 50).to_string() +
      "}",
    )
  }
  output.write_string("]}")
  output.to_string()
}

///|
test "bench validate 1000 episodes" (it : @bench.T) {
  let input = benchmark_run_json(1000)
  it.bench(fn() { it.keep(validate_json(input)) })
}

///|
test "bench JSON report 1000 episodes" (it : @bench.T) {
  let input = benchmark_run_json(1000)
  it.bench(fn() { it.keep(report_json(input)) })
}
