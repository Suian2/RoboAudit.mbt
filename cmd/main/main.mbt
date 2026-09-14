///|
/// Native command-line entry point. Core parsing and reporting remain in the
/// library package so they can be reused by future adapters and WASM tooling.
extern "c" fn process_exit(code : Int) = "exit"

///|
fn print_usage() -> Unit {
  println(
    "usage: roboaudit <validate|summarize|audit|report|report-json|report-csv|fingerprint> <file> | compare <file-a> <file-b> | manifest <paths...> | verify-file <path> <sha256>",
  )
}

///|
async fn main {
  let matches = @argparse.Command(
    "roboaudit",
    about="Audit robot and embodied-AI evaluation logs.",
    version="0.1.0",
    positionals=[
      PositionArg(
        "args",
        about="command followed by one or two JSON input files",
        num_args=ValueRange(lower=2),
      ),
    ],
  ).parse()
  match matches.values {
    { "args": ["verify-file", path, expected], .. } => {
      let data = @fs.read_file(path).binary()
      let observed = @lib.sha256_bytes(data)
      if observed == expected.to_lower() {
        println("valid")
      } else {
        println(
          "RA012: artifact hash mismatch; expected=" +
          expected.to_lower() +
          ", observed=" +
          observed,
        )
        process_exit(1)
      }
    }
    { "args": ["manifest", .. paths], .. } => {
      let sorted_paths = paths.to_owned()
      sorted_paths.sort_by((left, right) => left.compare(right))
      let output = StringBuilder()
      output.write_string("{\n  \"algorithm\": \"sha256\",\n  \"files\": [")
      for index, path in sorted_paths {
        let data = @fs.read_file(path).binary()
        if index > 0 {
          output.write_char(',')
        }
        output.write_string(
          "\n    {\"path\": " +
          path.escape() +
          ", \"size\": " +
          data.length().to_string() +
          ", \"sha256\": \"" +
          @lib.sha256_bytes(data) +
          "\"}",
        )
      }
      output.write_string("\n  ]\n}")
      println(output.to_string())
    }
    { "args": [command, path], .. } => {
      let input = @fs.read_file(path).text()
      match command {
        "validate" => {
          let output = @lib.validate_json(input)
          println(output)
          if output != "valid" {
            process_exit(1)
          }
        }
        "audit" => {
          let output = @lib.validate_json(input)
          println(output)
          if output != "valid" {
            process_exit(1)
          }
        }
        "summarize" => println(@lib.report_json(input))
        "report" => println(@lib.report_markdown(input))
        "report-json" => println(@lib.report_json(input))
        "report-csv" => println(@lib.report_csv(input))
        "fingerprint" => println(@lib.protocol_fingerprint(input))
        _ => {
          print_usage()
          process_exit(2)
        }
      }
    }
    { "args": ["compare", first_path, second_path], .. } => {
      let first = @fs.read_file(first_path).text()
      let second = @fs.read_file(second_path).text()
      println(@lib.compare_json(first, second))
    }
    _ => {
      print_usage()
      process_exit(2)
    }
  }
}
