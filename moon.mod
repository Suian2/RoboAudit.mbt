// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "Suian2/roboaudit"

version = "0.1.0"

readme = "README.md"

repository = "https://github.com/Suian2/RoboAudit.mbt"

license = "Apache-2.0"

keywords = [ "robotics", "evaluation", "audit", "reproducibility" ]

preferred_target = "native"

description = "MoonBit-first auditing for robot and embodied-AI evaluation logs."

import {
  "moonbitlang/async@0.21.3",
}
