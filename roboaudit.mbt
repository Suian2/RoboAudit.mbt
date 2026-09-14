///|
/// Canonical, license-safe in-memory representation of one evaluated episode.
pub(all) struct Stage {
  name : String
  completed : Bool
} derive(Eq, Debug)

///|
pub(all) struct AuditFinding {
  rule_id : String
  severity : String
  path : String
  message : String
  suggestion : String
} derive(Eq, Debug, ToJson)

///|
pub(all) struct ArtifactRef {
  path : String
  expected_sha256 : String?
  observed_sha256 : String?
  exists : Bool
} derive(Eq, Debug)

///|
pub(all) struct Episode {
  index : Int
  index_is_present : Bool
  candidate_index : Int?
  attempt_index : Int?
  seed : Int?
  success : Bool
  success_is_valid : Bool
  action_steps : Int?
  duration_ms : Int?
  failure_type : String?
  stages : Array[Stage]
  artifact_refs : Array[ArtifactRef]
} derive(Eq, Debug)

///|
/// Canonical representation shared by canonical JSON and the RoboSyn adapter.
pub(all) struct Run {
  schema_version : String
  run_id : String
  task : String
  policy : String
  protocol : String
  observation_mode : String
  evaluator_version : String
  code_revision : String
  seed_policy : String
  success_definition : String
  environment : String
  provenance : String
  timeout_steps : Int?
  declared_episode_count : Int?
  declared_success_count : Int?
  declared_failure_count : Int?
  retry_policy : String
  episodes : Array[Episode]
  skipped_reasons : Array[String]
  failure_annotations : Array[String]
  training_seeds : Array[Int]
} derive(Eq, Debug)

///|
priv struct StepStats {
  count : Int
  mean : Double
  median : Double
  minimum : Int?
  maximum : Int?
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
  let explicit_index = match json_int(json_field(value, "episode_index")) {
    Some(value) => value
    None =>
      match json_int(json_field(value, "index")) {
        Some(value) => value
        None => fallback_index
      }
  }
  let index_is_present = json_int(json_field(value, "episode_index")) is Some(_) ||
    json_int(json_field(value, "index")) is Some(_)
  let (success, success_is_valid) = json_bool(json_field(value, "success"))
  {
    index: explicit_index,
    index_is_present,
    candidate_index: json_int(json_field(value, "candidate_index")),
    attempt_index: match json_int(json_field(value, "attempt_index")) {
      Some(value) => Some(value)
      None => json_int(json_field(value, "episode_attempt_index"))
    },
    seed: json_int(json_field(value, "seed")),
    success,
    success_is_valid,
    action_steps: json_int(json_field(value, "action_steps")),
    duration_ms: json_int(json_field(value, "duration_ms")),
    failure_type: json_string(json_field(value, "failure_type")),
    stages: parse_stages(json_field(value, "stages")),
    artifact_refs: parse_artifact_refs(json_field(value, "artifact_refs")),
  }
}

///|
fn parse_artifact_refs(value : Json?) -> Array[ArtifactRef] {
  match value {
    Some(Array(values)) => {
      let refs : Array[ArtifactRef] = []
      for value in values {
        if value is Object(_) {
          let (exists, exists_valid) = json_bool(json_field(value, "exists"))
          refs.push({
            path: string_or(json_string(json_field(value, "path")), ""),
            expected_sha256: json_string(json_field(value, "sha256")),
            observed_sha256: json_string(json_field(value, "observed_sha256")),
            exists: exists_valid && exists,
          })
        }
      }
      refs
    }
    _ => []
  }
}

///|
fn parse_int_array(value : Json?) -> Array[Int] {
  let values : Array[Int] = []
  match value {
    Some(Array(items)) =>
      for item in items {
        match json_int(Some(item)) {
          Some(value) => values.push(value)
          None => ()
        }
      }
    _ => ()
  }
  values
}

///|
fn parse_stages(value : Json?) -> Array[Stage] {
  match value {
    Some(Array(values)) => {
      let stages : Array[Stage] = []
      for value in values {
        match value {
          String(name) => stages.push({ name, completed: true, })
          Object(_) => {
            let name = string_or(
              json_string(json_field(value, "name")),
              string_or(json_string(json_field(value, "stage")), "unnamed"),
            )
            let (completed, valid) = match
              json_bool(json_field(value, "completed")) {
              (completed, true) => (completed, true)
              _ => json_bool(json_field(value, "success"))
            }
            stages.push({ name, completed: valid && completed, })
          }
          _ => ()
        }
      }
      stages
    }
    _ => []
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
fn parse_failure_annotations(value : Json?) -> Array[String] {
  match value {
    Some(Array(values)) => {
      let annotations = []
      for value in values {
        match value {
          String(label) => annotations.push(label)
          Object(_) =>
            annotations.push(
              string_or(
                json_string(json_field(value, "failure_type")),
                string_or(
                  json_string(json_field(value, "type")),
                  string_or(
                    json_string(json_field(value, "reason")),
                    "unspecified",
                  ),
                ),
              ),
            )
          _ => ()
        }
      }
      annotations
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
    schema_version: string_or(
      json_string(json_field(value, "schema_version")),
      "unspecified",
    ),
    run_id: string_or(json_string(json_field(value, "run_id")), "anonymous-run"),
    task,
    policy: string_or(
      json_string(json_field(value, "policy")),
      string_or(
        json_string(object_field(value, "config", "policy")),
        "unspecified",
      ),
    ),
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
    code_revision: string_or(
      json_string(json_field(value, "code_revision")),
      string_or(
        json_string(object_field(value, "config", "code_revision")),
        string_or(json_string(json_field(value, "git_commit")), "unspecified"),
      ),
    ),
    seed_policy: string_or(
      json_string(json_field(value, "seed_policy")),
      string_or(
        json_string(object_field(value, "config", "seed_policy")),
        "unspecified",
      ),
    ),
    success_definition: string_or(
      json_string(json_field(value, "success_definition")),
      "unspecified",
    ),
    environment: string_or(
      json_string(json_field(value, "environment")),
      "unspecified",
    ),
    provenance: string_or(
      json_string(json_field(value, "provenance")),
      string_or(json_string(json_field(value, "source")), "unspecified"),
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
    failure_annotations: parse_failure_annotations(
      json_field(value, "failure_annotations"),
    ),
    training_seeds: parse_int_array(json_field(value, "training_seeds")),
  }
}

///|
fn parse_json_input(input : String) -> Run? {
  let value : Json? = Some(@json.parse(input)) catch { _ => None }
  match value {
    Some(value) =>
      if json_field(value, "success") is Some(_) &&
        json_field(value, "episodes") is None {
        None
      } else {
        Some(parse_run(value))
      }
    None => None
  }
}

///|
fn run_with_episodes(template : Run, episodes : Array[Episode]) -> Run {
  {
    schema_version: template.schema_version,
    run_id: template.run_id,
    task: template.task,
    policy: template.policy,
    protocol: template.protocol,
    observation_mode: template.observation_mode,
    evaluator_version: template.evaluator_version,
    code_revision: template.code_revision,
    seed_policy: template.seed_policy,
    success_definition: template.success_definition,
    environment: template.environment,
    provenance: template.provenance,
    timeout_steps: template.timeout_steps,
    declared_episode_count: template.declared_episode_count,
    declared_success_count: template.declared_success_count,
    declared_failure_count: template.declared_failure_count,
    retry_policy: template.retry_policy,
    episodes,
    skipped_reasons: template.skipped_reasons,
    failure_annotations: template.failure_annotations,
    training_seeds: template.training_seeds,
  }
}

///|
fn parse_jsonl_input(input : String) -> Run? {
  let episodes : Array[Episode] = []
  let mut template : Run? = None
  let mut row = 0
  for raw_line in input.split("\n") {
    let line = raw_line.trim()
    if !line.is_empty() {
      let value : Json? = Some(@json.parse(line)) catch { _ => None }
      match value {
        Some(value) => {
          if template is None {
            template = Some(parse_run(value))
          }
          episodes.push(parse_episode(value, row))
          row += 1
        }
        None => return None
      }
    }
  }
  match template {
    Some(template) => Some(run_with_episodes(template, episodes))
    None => None
  }
}

///|
fn parse_int_text(value : String) -> Int? {
  Some(@string.parse_int(value)) catch {
    _ => None
  }
}

///|
fn csv_cells(line : StringView) -> Array[String] {
  let cells : Array[String] = []
  for value in line.split(",") {
    cells.push(value.trim().to_owned())
  }
  cells
}

///|
fn csv_index(headers : Array[String], name : String) -> Int? {
  for index, header in headers {
    if header == name {
      return Some(index)
    }
  }
  None
}

///|
fn csv_value(
  headers : Array[String],
  cells : Array[String],
  name : String,
) -> String? {
  match csv_index(headers, name) {
    Some(index) =>
      if index < cells.length() && !cells[index].is_empty() {
        Some(cells[index])
      } else {
        None
      }
    None => None
  }
}

///|
fn csv_int(
  headers : Array[String],
  cells : Array[String],
  name : String,
) -> Int? {
  match csv_value(headers, cells, name) {
    Some(value) => parse_int_text(value)
    None => None
  }
}

///|
fn csv_bool(headers : Array[String], cells : Array[String]) -> (Bool, Bool) {
  match csv_value(headers, cells, "success") {
    Some("true") | Some("1") => (true, true)
    Some("false") | Some("0") => (false, true)
    _ => (false, false)
  }
}

///|
fn parse_csv_input(input : String) -> Run? {
  let headers : Array[String] = []
  let episodes : Array[Episode] = []
  let mut saw_header = false
  let mut schema_version = "unspecified"
  let mut task = "unknown"
  let mut policy = "unspecified"
  let mut evaluator_version = "unspecified"
  let mut code_revision = "unspecified"
  let mut seed_policy = "unspecified"
  let mut protocol = "unspecified"
  let mut observation_mode = "unspecified"
  let mut environment = "unspecified"
  let mut provenance = "unspecified"
  for raw_line in input.split("\n") {
    let line = raw_line.trim()
    if !line.is_empty() {
      if !saw_header {
        headers.push_iter(line.split(",").map(value => value.trim().to_owned()))
        if csv_index(headers, "success") is None ||
          csv_index(headers, "episode_index") is None {
          return None
        }
        saw_header = true
      } else {
        let cells = csv_cells(line)
        let (success, success_is_valid) = csv_bool(headers, cells)
        let fallback_index = episodes.length()
        episodes.push({
          index: match csv_int(headers, cells, "episode_index") {
            Some(value) => value
            None => fallback_index
          },
          index_is_present: csv_int(headers, cells, "episode_index") is Some(_),
          candidate_index: csv_int(headers, cells, "candidate_index"),
          attempt_index: match csv_int(headers, cells, "attempt_index") {
            Some(value) => Some(value)
            None => csv_int(headers, cells, "episode_attempt_index")
          },
          seed: csv_int(headers, cells, "seed"),
          success,
          success_is_valid,
          action_steps: csv_int(headers, cells, "action_steps"),
          duration_ms: csv_int(headers, cells, "duration_ms"),
          failure_type: csv_value(headers, cells, "failure_type"),
          stages: [],
          artifact_refs: [],
        })
        if episodes.length() == 1 {
          schema_version = string_or(
            csv_value(headers, cells, "schema_version"),
            schema_version,
          )
          task = string_or(csv_value(headers, cells, "task"), task)
          policy = string_or(csv_value(headers, cells, "policy"), policy)
          evaluator_version = string_or(
            csv_value(headers, cells, "evaluator_version"),
            evaluator_version,
          )
          code_revision = string_or(
            csv_value(headers, cells, "code_revision"),
            code_revision,
          )
          seed_policy = string_or(
            csv_value(headers, cells, "seed_policy"),
            seed_policy,
          )
          protocol = string_or(csv_value(headers, cells, "protocol"), protocol)
          observation_mode = string_or(
            csv_value(headers, cells, "observation_mode"),
            observation_mode,
          )
          environment = string_or(
            csv_value(headers, cells, "environment"),
            environment,
          )
          provenance = string_or(
            csv_value(headers, cells, "provenance"),
            provenance,
          )
        }
      }
    }
  }
  if !saw_header {
    None
  } else {
    Some({
      schema_version,
      run_id: "csv-run",
      task,
      policy,
      protocol,
      observation_mode,
      evaluator_version,
      code_revision,
      seed_policy,
      success_definition: "unspecified",
      environment,
      provenance,
      timeout_steps: None,
      declared_episode_count: None,
      declared_success_count: None,
      declared_failure_count: None,
      retry_policy: "unspecified",
      episodes,
      skipped_reasons: [],
      failure_annotations: [],
      training_seeds: [],
    })
  }
}

///|
fn parse_input(input : String) -> Run? {
  match parse_json_input(input) {
    Some(run) => Some(run)
    None =>
      match parse_jsonl_input(input) {
        Some(run) => Some(run)
        None => parse_csv_input(input)
      }
  }
}

///|
fn add_issue(issues : Array[String], rule : String, message : String) -> Unit {
  issues.push(rule + ": " + message)
}

///|
fn run_issues(run : Run) -> Array[String] {
  let issues = []
  if run.provenance == "unspecified" || run.code_revision == "unspecified" {
    add_issue(issues, "RA015", "missing provenance or code revision")
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
  let failures = failure_count(run)
  let annotations = annotated_failure_count(run)
  let mut failure_mismatch = annotations > 0 && annotations != failures
  match run.declared_failure_count {
    Some(declared) => if declared != failures { failure_mismatch = true }
    None => ()
  }
  if failure_mismatch {
    add_issue(
      issues, "RA013", "declared or annotated failures differ from failed episodes",
    )
  }
  if !run.skipped_reasons.is_empty() {
    add_issue(issues, "RA006", "skipped candidates require disclosure")
  }
  for training_seed in run.training_seeds {
    for episode in run.episodes {
      match episode.seed {
        Some(evaluation_seed) =>
          if training_seed == evaluation_seed {
            add_issue(
              issues, "RA011", "training and evaluation seed sets overlap",
            )
          }
        None => ()
      }
    }
  }
  for episode in run.episodes {
    if !episode.index_is_present {
      add_issue(issues, "RA002", "episode_index is missing or invalid")
    }
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
    for artifact in episode.artifact_refs {
      let missing_metadata = artifact.path.is_empty() ||
        artifact.expected_sha256 is None ||
        artifact.observed_sha256 is None
      let mismatch = match
        (artifact.expected_sha256, artifact.observed_sha256) {
        (Some(expected), Some(observed)) =>
          expected.to_lower() != observed.to_lower()
        _ => false
      }
      if !artifact.exists || missing_metadata || mismatch {
        add_issue(
          issues, "RA012", "artifact reference is missing, unverifiable, or has a hash mismatch",
        )
      }
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
fn audit_findings(run : Run) -> Array[AuditFinding] {
  let findings : Array[AuditFinding] = []
  for issue in run_issues(run) {
    match issue.split_once(": ") {
      Some((rule_id, message)) =>
        findings.push({
          rule_id: rule_id.to_owned(),
          severity: if rule_id == "RA006" {
            "warning"
          } else {
            "error"
          },
          path: finding_path(rule_id),
          message: message.to_owned(),
          suggestion: finding_suggestion(rule_id),
        })
      None => ()
    }
  }
  findings
}

///|
fn finding_path(rule_id : StringView) -> String {
  match rule_id {
    "RA001" => "/episodes/*/seed"
    "RA002" => "/episodes/*/episode_index"
    "RA003" => "/episodes/*/success"
    "RA004" => "/summary/success_count"
    "RA005" => "/summary/episode_count"
    "RA006" => "/skipped"
    "RA007" => "/retry_policy"
    "RA008" => "/episodes/*/candidate_index"
    "RA011" => "/training_seeds"
    "RA012" => "/episodes/*/artifact_refs"
    "RA013" => "/summary/failure_count"
    "RA014" => "/episodes/*/action_steps"
    "RA015" => "/provenance"
    _ => "/"
  }
}

///|
fn finding_suggestion(rule_id : StringView) -> String {
  match rule_id {
    "RA001" => "Use one disclosed evaluation seed per episode."
    "RA002" => "Provide unique episode_index values for every episode."
    "RA003" => "Encode success as a JSON or CSV boolean."
    "RA004" => "Recompute summary.success_count from episodes."
    "RA005" => "Set summary.episode_count to the parsed episode count."
    "RA006" =>
      "Disclose skipped candidates and interpret the denominator explicitly."
    "RA007" => "Declare the retry policy whenever later attempts are present."
    "RA008" =>
      "Keep candidate indices within the disclosed candidate population."
    "RA011" => "Use disjoint training and evaluation seed sets."
    "RA012" => "Provide existing artifacts with matching SHA-256 evidence."
    "RA013" => "Align failure counts and annotations with failed episodes."
    "RA014" => "Keep action steps non-negative and within the success timeout."
    "RA015" => "Record both provenance and the evaluated code revision."
    _ => "Review the source episode log and declared evaluation protocol."
  }
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
  if !run.failure_annotations.is_empty() {
    return run.failure_annotations.length()
  }
  let mut count = 0
  for episode in run.episodes {
    if episode.failure_type is Some(_) {
      count += 1
    }
  }
  count
}

///|
fn action_step_stats(run : Run, group : Int) -> StepStats {
  let values : Array[Int] = []
  let mut total = 0
  for episode in run.episodes {
    let included = group == 0 ||
      (group == 1 && episode.success) ||
      (group == 2 && !episode.success)
    if included {
      match episode.action_steps {
        Some(value) => {
          values.push(value)
          total += value
        }
        None => ()
      }
    }
  }
  values.sort_by((left, right) => {
    if left < right {
      -1
    } else if left > right {
      1
    } else {
      0
    }
  })
  if values.is_empty() {
    { count: 0, mean: 0.0, median: 0.0, minimum: None, maximum: None, }
  } else {
    let count = values.length()
    let median = if count % 2 == 1 {
      values[count / 2].to_double()
    } else {
      (values[count / 2 - 1].to_double() + values[count / 2].to_double()) / 2.0
    }
    {
      count,
      mean: total.to_double() / count.to_double(),
      median,
      minimum: Some(values[0]),
      maximum: Some(values[count - 1]),
    }
  }
}

///|
fn optional_int_json(value : Int?) -> Json {
  match value {
    Some(value) => Json::number(value.to_double())
    None => Json::null()
  }
}

///|
fn step_stats_json(stats : StepStats) -> Json {
  {
    "count": stats.count,
    "mean": stats.mean,
    "median": stats.median,
    "minimum": optional_int_json(stats.minimum),
    "maximum": optional_int_json(stats.maximum),
  }
}

///|
fn increment_label(
  labels : Array[String],
  counts : Array[Int],
  label : String,
) -> Unit {
  for index, current in labels {
    if current == label {
      counts[index] = counts[index] + 1
      return
    }
  }
  labels.push(label)
  counts.push(1)
}

///|
fn distribution_json(
  labels : Array[String],
  counts : Array[Int],
  denominator : Int,
) -> Json {
  let entries : Array[Json] = []
  for index, label in labels {
    let proportion = if denominator == 0 {
      0.0
    } else {
      counts[index].to_double() / denominator.to_double()
    }
    entries.push({
      "name": label,
      "count": counts[index],
      "proportion": proportion,
    })
  }
  Json::array(entries)
}

///|
fn failure_distribution_json(run : Run) -> Json {
  let labels : Array[String] = []
  let counts : Array[Int] = []
  for episode in run.episodes {
    match episode.failure_type {
      Some(label) => increment_label(labels, counts, label)
      None => ()
    }
  }
  if labels.is_empty() {
    for label in run.failure_annotations {
      increment_label(labels, counts, label)
    }
  }
  distribution_json(labels, counts, failure_count(run))
}

///|
fn skipped_distribution_json(run : Run) -> Json {
  let labels : Array[String] = []
  let counts : Array[Int] = []
  for reason in run.skipped_reasons {
    increment_label(labels, counts, reason)
  }
  distribution_json(labels, counts, run.skipped_reasons.length())
}

///|
fn stage_funnel_json(run : Run) -> Json {
  let names : Array[String] = []
  let observed : Array[Int] = []
  let completed : Array[Int] = []
  for episode in run.episodes {
    for stage in episode.stages {
      let mut found = false
      for index, name in names {
        if name == stage.name {
          observed[index] = observed[index] + 1
          if stage.completed {
            completed[index] = completed[index] + 1
          }
          found = true
        }
      }
      if !found {
        names.push(stage.name)
        observed.push(1)
        completed.push(if stage.completed { 1 } else { 0 })
      }
    }
  }
  let entries : Array[Json] = []
  for index, name in names {
    entries.push({
      "stage": name,
      "observed_count": observed[index],
      "completed_count": completed[index],
    })
  }
  Json::array(entries)
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
fn optional_int_text(value : Int?) -> String {
  match value {
    Some(value) => value.to_string()
    None => "n/a"
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
    let low = if successes == 0 || center - margin < 0.0 {
      0.0
    } else {
      center - margin
    }
    let high = if successes == total || center + margin > 1.0 {
      1.0
    } else {
      center + margin
    }
    (low, high)
  }
}

///|
fn protocol_signature_of(run : Run) -> String {
  let timeout = match run.timeout_steps {
    Some(value) => value.to_string()
    None => "unspecified"
  }
  "v1|task=" +
  run.task +
  "|policy=" +
  run.policy +
  "|protocol=" +
  run.protocol +
  "|observation=" +
  run.observation_mode +
  "|evaluator=" +
  run.evaluator_version +
  "|seed_policy=" +
  run.seed_policy +
  "|environment=" +
  run.environment +
  "|timeout=" +
  timeout +
  "|retry=" +
  run.retry_policy +
  "|success=" +
  run.success_definition
}

///|
fn protocol_fingerprint_of(run : Run) -> String {
  "sha256:" + sha256_text(protocol_signature_of(run))
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
    first.policy != second.policy ||
    first.protocol != second.protocol ||
    first.seed_policy != second.seed_policy ||
    first.environment != second.environment ||
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
    let first_rate = first_successes.to_double() /
      first.episodes.length().to_double()
    let second_rate = second_successes.to_double() /
      second.episodes.length().to_double()
    let difference = second_rate - first_rate
    output.write_string(
      "- Absolute success-rate difference (B - A): " +
      difference.to_string() +
      "\n",
    )
    if first_rate == 0.0 {
      output.write_string(
        "- Relative success-rate difference: undefined (A rate is zero)\n",
      )
    } else {
      output.write_string(
        "- Relative success-rate difference ((B - A) / A): " +
        (difference / first_rate).to_string() +
        "\n",
      )
    }
    output.write_string(
      "- Failure category changes: `" +
      failure_changes_json(first, second).stringify() +
      "`\n",
    )
  } else {
    output.write_string(
      "- Success-rate difference: not reported for incompatible or empty runs\n",
    )
  }
  output.to_string()
}

///|
fn collect_failure_labels(
  run : Run,
  labels : Array[String],
  counts : Array[Int],
) -> Unit {
  for episode in run.episodes {
    match episode.failure_type {
      Some(label) => increment_label(labels, counts, label)
      None => ()
    }
  }
  if counts.is_empty() {
    for label in run.failure_annotations {
      increment_label(labels, counts, label)
    }
  }
}

///|
fn failure_changes_json(first : Run, second : Run) -> Json {
  let labels : Array[String] = []
  let first_counts : Array[Int] = []
  collect_failure_labels(first, labels, first_counts)
  let second_labels : Array[String] = []
  let second_counts : Array[Int] = []
  collect_failure_labels(second, second_labels, second_counts)
  for label in second_labels {
    let mut present = false
    for existing in labels {
      if existing == label {
        present = true
      }
    }
    if !present {
      labels.push(label)
      first_counts.push(0)
    }
  }
  let changes : Array[Json] = []
  for index, label in labels {
    let mut second_count = 0
    for second_index, second_label in second_labels {
      if label == second_label {
        second_count = second_counts[second_index]
      }
    }
    changes.push({
      "name": label,
      "count_a": first_counts[index],
      "count_b": second_count,
      "delta": second_count - first_counts[index],
    })
  }
  Json::array(changes)
}

///|
fn markdown_report(run : Run) -> String {
  let successes = success_count(run)
  let (wilson_low, wilson_high) = wilson_interval(
    successes,
    run.episodes.length(),
  )
  let issues = run_issues(run)
  let output = StringBuilder()
  output.write_string("# RoboAudit report\n\n")
  output.write_string("- Run: `" + run.run_id + "`\n")
  output.write_string("- Task: `" + run.task + "`\n")
  output.write_string("- Policy: `" + run.policy + "`\n")
  output.write_string("- Protocol: `" + run.protocol + "`\n")
  output.write_string("- Observation mode: `" + run.observation_mode + "`\n")
  output.write_string("- Evaluator: `" + run.evaluator_version + "`\n")
  output.write_string("- Code revision: `" + run.code_revision + "`\n")
  output.write_string("- Provenance: `" + run.provenance + "`\n")
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
  output.write_string(
    "- Wilson 95% CI: [" +
    wilson_low.to_string() +
    ", " +
    wilson_high.to_string() +
    "]\n\n",
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
  let all_steps = action_step_stats(run, 0)
  let success_steps = action_step_stats(run, 1)
  let failure_steps = action_step_stats(run, 2)
  output.write_string("\n## Action steps\n\n")
  output.write_string(
    "- All: count=" +
    all_steps.count.to_string() +
    ", mean=" +
    all_steps.mean.to_string() +
    ", median=" +
    all_steps.median.to_string() +
    ", min=" +
    optional_int_text(all_steps.minimum) +
    ", max=" +
    optional_int_text(all_steps.maximum) +
    "\n",
  )
  output.write_string(
    "- Successful: count=" +
    success_steps.count.to_string() +
    ", mean=" +
    success_steps.mean.to_string() +
    "\n",
  )
  output.write_string(
    "- Failed: count=" +
    failure_steps.count.to_string() +
    ", mean=" +
    failure_steps.mean.to_string() +
    "\n",
  )
  output.write_string("\n## Distributions\n\n")
  output.write_string(
    "- Failure types: `" + failure_distribution_json(run).stringify() + "`\n",
  )
  output.write_string(
    "- Stage funnel: `" + stage_funnel_json(run).stringify() + "`\n",
  )
  output.write_string(
    "- Skipped reasons: `" + skipped_distribution_json(run).stringify() + "`\n",
  )
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
  let findings = audit_findings(run)
  let all_steps = action_step_stats(run, 0)
  let success_steps = action_step_stats(run, 1)
  let failure_steps = action_step_stats(run, 2)
  let result : Json = {
    "schema_version": "1.0",
    "input_schema_version": run.schema_version,
    "run_id": run.run_id,
    "task": run.task,
    "policy": run.policy,
    "evaluator_version": run.evaluator_version,
    "code_revision": run.code_revision,
    "seed_policy": run.seed_policy,
    "environment": run.environment,
    "provenance": run.provenance,
    "protocol_fingerprint": protocol_fingerprint_of(run),
    "summary": {
      "episode_count": total,
      "success_count": successes,
      "failure_count": failure_count(run),
      "success_rate": rate,
      "wilson_95_low": wilson_low,
      "wilson_95_high": wilson_high,
      "skipped_count": run.skipped_reasons.length(),
      "action_steps": {
        "all": step_stats_json(all_steps),
        "successful": step_stats_json(success_steps),
        "failed": step_stats_json(failure_steps),
      },
      "failure_types": failure_distribution_json(run),
      "stage_funnel": stage_funnel_json(run),
      "skipped_reasons": skipped_distribution_json(run),
    },
    "audit": { "finding_count": findings.length(), "findings": findings },
  }
  result.stringify(indent=2)
}

///|
fn csv_escape(value : String) -> String {
  let output = StringBuilder()
  output.write_char('"')
  for character in value {
    if character == '"' {
      output.write_string("\"\"")
    } else {
      output.write_char(character)
    }
  }
  output.write_char('"')
  output.to_string()
}

///|
fn csv_report(run : Run) -> String {
  let successes = success_count(run)
  let total = run.episodes.length()
  let rate = if total == 0 {
    ""
  } else {
    (successes.to_double() / total.to_double()).to_string()
  }
  "run_id,task,code_revision,provenance,protocol_fingerprint,episode_count,success_count,failure_count,success_rate,skipped_count,finding_count\n" +
  csv_escape(run.run_id) +
  "," +
  csv_escape(run.task) +
  "," +
  csv_escape(run.code_revision) +
  "," +
  csv_escape(run.provenance) +
  "," +
  csv_escape(protocol_fingerprint_of(run)) +
  "," +
  total.to_string() +
  "," +
  successes.to_string() +
  "," +
  failure_count(run).to_string() +
  "," +
  rate +
  "," +
  run.skipped_reasons.length().to_string() +
  "," +
  run_issues(run).length().to_string() +
  "\n"
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
/// Produce a deterministic one-row CSV summary with RFC-style field quoting.
pub fn report_csv(input : String) -> String {
  match parse_input(input) {
    Some(run) => csv_report(run)
    None => "error\n\"RA000: invalid JSON, JSONL, or CSV input\"\n"
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
