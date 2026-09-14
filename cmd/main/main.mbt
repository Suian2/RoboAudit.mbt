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
async fn read_text_or_exit(path : String) -> String {
  @fs.read_file(path).text() catch {
    _ => {
      println("error: cannot read input file: " + path)
      process_exit(2)
      panic()
    }
  }
}

///|
async fn read_bytes_or_exit(path : String) -> Bytes {
  @fs.read_file(path).binary() catch {
    _ => {
      println("error: cannot read input file: " + path)
      process_exit(2)
      panic()
    }
  }
}

///|
async fn main {
  let matches = @argparse.Command(
    "roboaudit",
    about="Audit robot and embodied-AI evaluation logs.",
    version="0.1.0",
    options=[
      OptionArg("format", about="report output format: json, csv, or markdown"),
    ],
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
      let data = read_bytes_or_exit(path)
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
        let data = read_bytes_or_exit(path)
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
      let input = read_text_or_exit(path)
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
        "report" =>
          match matches.values.get("format") {
            None => println(@lib.report_markdown(input))
            Some(["markdown"]) => println(@lib.report_markdown(input))
            Some(["json"]) => println(@lib.report_json(input))
            Some(["csv"]) => println(@lib.report_csv(input))
            _ => {
              println("error: --format must be json, csv, or markdown")
              process_exit(2)
            }
          }
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
      let first = read_text_or_exit(first_path)
      let second = read_text_or_exit(second_path)
      println(@lib.compare_json(first, second))
    }
    _ => {
      print_usage()
      process_exit(2)
    }
  }
}
