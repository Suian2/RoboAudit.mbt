///|
/// Native command-line entry point. Core parsing and reporting remain in the
/// library package so they can be reused by future adapters and WASM tooling.
async fn main {
  let matches = @argparse.Command(
    "roboaudit",
    about="Audit robot and embodied-AI evaluation logs.",
    positionals=[
      PositionArg(
        "args",
        about="command followed by one or two JSON input files",
        num_args=ValueRange(lower=2, upper=3),
      ),
    ],
  ).parse()
  match matches.values {
    { "args": [command, path], .. } => {
      let input = @fs.read_file(path).text()
      match command {
        "validate" => println(@lib.validate_json(input))
        "audit" => println(@lib.validate_json(input))
        "summarize" => println(@lib.report_json(input))
        "report" => println(@lib.report_markdown(input))
        "report-json" => println(@lib.report_json(input))
        "fingerprint" => println(@lib.protocol_fingerprint(input))
        _ =>
          println(
            "usage: roboaudit <validate|summarize|audit|report|report-json|fingerprint> <file> | compare <file-a> <file-b>",
          )
      }
    }
    { "args": ["compare", first_path, second_path], .. } => {
      let first = @fs.read_file(first_path).text()
      let second = @fs.read_file(second_path).text()
      println(@lib.compare_json(first, second))
    }
    _ =>
      println(
        "usage: roboaudit <validate|summarize|audit|report|report-json|fingerprint> <file> | compare <file-a> <file-b>",
      )
  }
}
