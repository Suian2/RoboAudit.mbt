///|
/// Native command-line entry point. Core parsing and reporting remain in the
/// library package so they can be reused by future adapters and WASM tooling.
async fn main {
  let matches = @argparse.Command(
    "roboaudit",
    about="Audit robot and embodied-AI evaluation logs.",
    positionals=[
      PositionArg(
        "command",
        about="validate or report",
        num_args=ValueRange(lower=1, upper=1),
      ),
      PositionArg(
        "file",
        about="JSON input file",
        num_args=ValueRange(lower=1, upper=1),
      ),
    ],
  ).parse()
  match matches.values {
    { "command": [command], "file": [path], .. } => {
      let input = @fs.read_file(path).text()
      match command {
        "validate" => println(@lib.validate_json(input))
        "report" => println(@lib.report_markdown(input))
        _ => println("usage: roboaudit <validate|report> <file>")
      }
    }
    _ => println("usage: roboaudit <validate|report> <file>")
  }
}
