///|
/// Canonical, license-safe in-memory representation of one evaluated episode.
priv struct Episode {
  index : Int
  candidate_index : Int?
  attempt_index : Int?
  seed : Int?
  success : Bool
  success_is_valid : Bool
  action_steps : Int?
  failure_type : String?
}

///|
/// Canonical representation shared by canonical JSON and the RoboSyn adapter.
priv struct Run {
  run_id : String
  task : String
  protocol : String
  observation_mode : String
  evaluator_version : String
  success_definition : String
  timeout_steps : Int?
  declared_episode_count : Int?
  declared_success_count : Int?
  declared_failure_count : Int?
  retry_policy : String
  episodes : Array[Episode]
  skipped_reasons : Array[String]
}

///|
fn json_field(value : Json, key : String) -> Json? {
  match value {
    Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn json_string(value : Json?) -> String? {
  match value {
    Some(String(text)) => Some(text)
    _ => None
  }
}

///|
fn json_int(value : Json?) -> Int? {
  match value {
    Some(Number(number, ..)) => Some(number.to_int())
    _ => None
  }
}

///|
fn json_bool(value : Json?) -> (Bool, Bool) {
  match value {
    Some(True) => (true, true)
    Some(False) => (false, true)
    _ => (false, false)
  }
}

///|
fn string_or(value : String?, fallback : String) -> String {
  match value {
    Some(text) => text
    None => fallback
  }
}

///|
fn object_field(value : Json, object_key : String, field_key : String) -> Json? {
  match json_field(value, object_key) {
    Some(object) => json_field(object, field_key)
    None => None
  }
}

///|
fn parse_episode(value : Json, fallback_index : Int) -> Episode {
  let index = match json_int(json_field(value, "episode_index")) {
    Some(value) => value
    None =>
      match json_int(json_field(value, "index")) {
        Some(value) => value
        None => fallback_index
      }
  }
  let (success, success_is_valid) = json_bool(json_field(value, "success"))
  {
    index,
    candidate_index: json_int(json_field(value, "candidate_index")),
    attempt_index: match json_int(json_field(value, "attempt_index")) {
      Some(value) => Some(value)
      None => json_int(json_field(value, "episode_attempt_index"))
    },
    seed: json_int(json_field(value, "seed")),
    success,
    success_is_valid,
    action_steps: json_int(json_field(value, "action_steps")),
    failure_type: json_string(json_field(value, "failure_type")),
  }
}

///|
fn parse_episodes(value : Json?) -> Array[Episode] {
  match value {
    Some(Array(values)) => {
      let episodes = []
      for index, value in values {
        episodes.push(parse_episode(value, index))
      }
      episodes
    }
    _ => []
  }
}

///|
fn parse_skipped_reasons(value : Json?) -> Array[String] {
  match value {
    Some(Array(values)) => {
      let reasons = []
      for value in values {
        match json_string(json_field(value, "reason")) {
          Some(reason) => reasons.push(reason)
          None => reasons.push("unspecified")
        }
      }
      reasons
    }
    _ => []
  }
}

///|
fn parse_run(value : Json) -> Run {
  let task = string_or(
    json_string(json_field(value, "task")),
    string_or(json_string(object_field(value, "config", "task")), "unknown"),
  )
  {
    run_id: string_or(json_string(json_field(value, "run_id")), "anonymous-run"),
    task,
    protocol: string_or(
      json_string(json_field(value, "protocol")),
      "unspecified",
    ),
    observation_mode: string_or(
      json_string(json_field(value, "observation_mode")),
      string_or(
        json_string(object_field(value, "config", "observation_mode")),
        "unspecified",
      ),
    ),
    evaluator_version: string_or(
      json_string(json_field(value, "evaluator_version")),
      "unspecified",
    ),
    success_definition: string_or(
      json_string(json_field(value, "success_definition")),
      "unspecified",
    ),
    timeout_steps: match json_int(json_field(value, "timeout_steps")) {
      Some(value) => Some(value)
      None => json_int(object_field(value, "config", "timeout_action_steps"))
    },
    declared_episode_count: match
      json_int(object_field(value, "summary", "episodes")) {
      Some(value) => Some(value)
      None => json_int(object_field(value, "summary", "episode_count"))
    },
    declared_success_count: json_int(
      object_field(value, "summary", "success_count"),
    ),
    declared_failure_count: json_int(
      object_field(value, "summary", "failure_count"),
    ),
    retry_policy: string_or(
      json_string(json_field(value, "retry_policy")),
      "unspecified",
    ),
    episodes: parse_episodes(json_field(value, "episodes")),
    skipped_reasons: parse_skipped_reasons(json_field(value, "skipped")),
  }
}

///|
fn parse_input(input : String) -> Run? {
  Some(parse_run(@json.parse(input))) catch {
    _ => None
  }
}

///|
fn add_issue(issues : Array[String], rule : String, message : String) -> Unit {
  issues.push(rule + ": " + message)
}

///|
fn run_issues(run : Run) -> Array[String] {
  let issues = []
  if run.task == "unknown" || run.evaluator_version == "unspecified" {
    add_issue(issues, "RA015", "missing task or evaluator provenance")
  }
  match run.declared_episode_count {
    Some(declared) =>
      if declared != run.episodes.length() {
        add_issue(
          issues, "RA005", "declared episode count differs from episodes",
        )
      }
    None => ()
  }
  match run.declared_success_count {
    Some(declared) =>
      if declared != success_count(run) {
        add_issue(
          issues, "RA004", "declared success count differs from episodes",
        )
      }
    None => ()
  }
  match run.declared_failure_count {
    Some(declared) =>
      if declared != failure_count(run) ||
        annotated_failure_count(run) > failure_count(run) {
        add_issue(
          issues, "RA013", "declared or annotated failures differ from failed episodes",
        )
      }
    None => ()
  }
  if !run.skipped_reasons.is_empty() {
    add_issue(issues, "RA006", "skipped candidates require disclosure")
  }
  for episode in run.episodes {
    if !episode.success_is_valid {
      add_issue(
        issues,
        "RA003",
        "episode " + episode.index.to_string() + " has invalid success",
      )
    }
    match episode.action_steps {
      Some(steps) => {
        if steps < 0 {
          add_issue(
            issues,
            "RA014",
            "episode " +
            episode.index.to_string() +
            " has negative action_steps",
          )
        }
        match run.timeout_steps {
          Some(timeout) =>
            if episode.success && steps > timeout {
              add_issue(
                issues, "RA014", "successful episode exceeds timeout_steps",
              )
            }
          None => ()
        }
      }
      None => ()
    }
    match episode.attempt_index {
      Some(attempt) =>
        if attempt > 0 && run.retry_policy == "unspecified" {
          add_issue(
            issues, "RA007", "retry attempt exists without retry_policy",
          )
        }
      None => ()
    }
    match episode.candidate_index {
      Some(candidate) =>
        if candidate >= run.episodes.length() {
          add_issue(
            issues, "RA008", "candidate_index exceeds final episode count",
          )
        }
      None => ()
    }
  }
  for left in 0..<run.episodes.length() {
    let mut right = left + 1
    while right < run.episodes.length() {
      if run.episodes[left].index == run.episodes[right].index {
        add_issue(issues, "RA002", "duplicate episode_index")
      }
      match (run.episodes[left].seed, run.episodes[right].seed) {
        (Some(a), Some(b)) =>
          if a == b {
            add_issue(issues, "RA001", "duplicate evaluation seed")
          }
        _ => ()
      }
      right += 1
    }
  }
  issues
}

///|
fn success_count(run : Run) -> Int {
  let mut count = 0
  for episode in run.episodes {
    if episode.success {
      count += 1
    }
  }
  count
}

///|
fn failure_count(run : Run) -> Int {
  run.episodes.length() - success_count(run)
}

///|
fn annotated_failure_count(run : Run) -> Int {
  let mut count = 0
  for episode in run.episodes {
    if episode.failure_type is Some(_) {
      count += 1
    }
  }
  count
}

///|
fn rate_text(successes : Int, total : Int) -> String {
  if total == 0 {
    "n/a"
  } else {
    (successes.to_double() * 100.0 / total.to_double()).to_string() + "%"
  }
}

///|
fn wilson_interval(successes : Int, total : Int) -> (Double, Double) {
  if total == 0 {
    (0.0, 0.0)
  } else {
    let n = total.to_double()
    let p = successes.to_double() / n
    let z = 1.96
    let z2 = z * z
    let denominator = 1.0 + z2 / n
    let center = (p + z2 / (2.0 * n)) / denominator
    let margin = z *
      (p * (1.0 - p) / n + z2 / (4.0 * n * n)).sqrt() /
      denominator
    let low = if center - margin < 0.0 { 0.0 } else { center - margin }
    let high = if center + margin > 1.0 { 1.0 } else { center + margin }
    (low, high)
  }
}

///|
fn protocol_fingerprint_of(run : Run) -> String {
  let timeout = match run.timeout_steps {
    Some(value) => value.to_string()
    None => "unspecified"
  }
  "v1|task=" +
  run.task +
  "|protocol=" +
  run.protocol +
  "|observation=" +
  run.observation_mode +
  "|evaluator=" +
  run.evaluator_version +
  "|timeout=" +
  timeout +
  "|retry=" +
  run.retry_policy +
  "|success=" +
  run.success_definition
}

///|
fn compare_runs(first : Run, second : Run) -> String {
  let output = StringBuilder()
  let mut compatible = true
  output.write_string("# RoboAudit comparison\n\n")
  if first.observation_mode != second.observation_mode {
    compatible = false
    output.write_string("- RA009: observation_mode differs\n")
  }
  if first.evaluator_version != second.evaluator_version ||
    first.success_definition != second.success_definition {
    compatible = false
    output.write_string("- RA010: evaluator or success definition differs\n")
  }
  if first.task != second.task ||
    first.protocol != second.protocol ||
    first.timeout_steps != second.timeout_steps ||
    first.retry_policy != second.retry_policy {
    compatible = false
    output.write_string("- Protocol fingerprint differs\n")
  }
  output.write_string("- Compatible: " + compatible.to_string() + "\n")
  output.write_string(
    "- Fingerprint A: `" + protocol_fingerprint_of(first) + "`\n",
  )
  output.write_string(
    "- Fingerprint B: `" + protocol_fingerprint_of(second) + "`\n",
  )
  let first_successes = success_count(first)
  let second_successes = success_count(second)
  let (first_low, first_high) = wilson_interval(
    first_successes,
    first.episodes.length(),
  )
  let (second_low, second_high) = wilson_interval(
    second_successes,
    second.episodes.length(),
  )
  output.write_string(
    "- A success: " +
    first_successes.to_string() +
    "/" +
    first.episodes.length().to_string() +
    "\n",
  )
  output.write_string(
    "- B success: " +
    second_successes.to_string() +
    "/" +
    second.episodes.length().to_string() +
    "\n",
  )
  output.write_string(
    "- A Wilson 95% CI: [" +
    first_low.to_string() +
    ", " +
    first_high.to_string() +
    "]\n",
  )
  output.write_string(
    "- B Wilson 95% CI: [" +
    second_low.to_string() +
    ", " +
    second_high.to_string() +
    "]\n",
  )
  if compatible && first.episodes.length() > 0 && second.episodes.length() > 0 {
    let difference = second_successes.to_double() /
      second.episodes.length().to_double() -
      first_successes.to_double() / first.episodes.length().to_double()
    output.write_string(
      "- Absolute success-rate difference (B - A): " +
      difference.to_string() +
      "\n",
    )
  } else {
    output.write_string(
      "- Success-rate difference: not reported for incompatible or empty runs\n",
    )
  }
  output.to_string()
}

///|
fn markdown_report(run : Run) -> String {
  let successes = success_count(run)
  let issues = run_issues(run)
  let output = StringBuilder()
  output.write_string("# RoboAudit report\n\n")
  output.write_string("- Run: `" + run.run_id + "`\n")
  output.write_string("- Task: `" + run.task + "`\n")
  output.write_string("- Protocol: `" + run.protocol + "`\n")
  output.write_string("- Observation mode: `" + run.observation_mode + "`\n")
  output.write_string("- Episodes: " + run.episodes.length().to_string() + "\n")
  output.write_string(
    "- Success: " +
    successes.to_string() +
    "/" +
    run.episodes.length().to_string() +
    " (" +
    rate_text(successes, run.episodes.length()) +
    ")\n\n",
  )
  output.write_string("## Audit findings\n\n")
  if issues.is_empty() {
    output.write_string("No findings.\n")
  } else {
    for issue in issues {
      output.write_string("- " + issue + "\n")
    }
  }
  output.write_string("\n## Failure annotations\n\n")
  let mut annotations = 0
  for episode in run.episodes {
    match episode.failure_type {
      Some(failure_type) => {
        annotations += 1
        output.write_string(
          "- Episode " + episode.index.to_string() + ": " + failure_type + "\n",
        )
      }
      None => ()
    }
  }
  if annotations == 0 {
    output.write_string("No failure annotations.\n")
  }
  output.to_string()
}

///|
fn json_report(run : Run) -> String {
  let successes = success_count(run)
  let total = run.episodes.length()
  let rate = if total == 0 {
    0.0
  } else {
    successes.to_double() / total.to_double()
  }
  let (wilson_low, wilson_high) = wilson_interval(successes, total)
  let findings = run_issues(run)
  let result : Json = {
    "schema_version": "1.0",
    "run_id": run.run_id,
    "task": run.task,
    "protocol_fingerprint": protocol_fingerprint_of(run),
    "summary": {
      "episode_count": total,
      "success_count": successes,
      "failure_count": failure_count(run),
      "success_rate": rate,
      "wilson_95_low": wilson_low,
      "wilson_95_high": wilson_high,
      "skipped_count": run.skipped_reasons.length(),
    },
    "audit": { "finding_count": findings.length(), "findings": findings },
  }
  result.stringify(indent=2)
}

///|
/// Validate canonical JSON or RoboSyn evaluation_metrics-shaped JSON.
pub fn validate_json(input : String) -> String {
  match parse_input(input) {
    Some(run) => {
      let issues = run_issues(run)
      if issues.is_empty() {
        "valid"
      } else {
        issues.join("\n")
      }
    }
    None => "RA000: invalid JSON input"
  }
}

///|
/// Produce a deterministic Markdown report from a supported JSON input.
pub fn report_markdown(input : String) -> String {
  match parse_input(input) {
    Some(run) => markdown_report(run)
    None => "# RoboAudit report\n\nRA000: invalid JSON input\n"
  }
}

///|
/// Produce deterministic, machine-readable JSON with recomputed statistics.
pub fn report_json(input : String) -> String {
  match parse_input(input) {
    Some(run) => json_report(run)
    None =>
      "{\n  \"schema_version\": \"1.0\",\n  \"error\": \"RA000: invalid JSON input\"\n}"
  }
}

///|
/// Return a stable, normalized protocol fingerprint string.
pub fn protocol_fingerprint(input : String) -> String {
  match parse_input(input) {
    Some(run) => protocol_fingerprint_of(run)
    None => "RA000: invalid JSON input"
  }
}

///|
/// Compare compatible runs and explain protocol mismatches before statistics.
pub fn compare_json(first : String, second : String) -> String {
  match (parse_input(first), parse_input(second)) {
    (Some(first), Some(second)) => compare_runs(first, second)
    _ => "# RoboAudit comparison\n\nRA000: invalid JSON input\n"
  }
}
