# RoboAudit.mbt

RoboAudit.mbt 是一个以 MoonBit 为主体实现的原生命令行工具和可复用库，用于把机器人与具身智能 episode 日志转换成可审计、可复现的评测证据。

## 功能

- 支持 canonical JSON、JSONL episode 流、简单无引号 CSV，以及 RoboSyn 风格 `evaluation_metrics.json` 的真实字段别名。
- 生成确定性的 Markdown、JSON 和 CSV 报告。
- 重算成功数与成功率，并计算 Wilson 95% 置信区间、动作步分组统计、失败频数/比例、阶段漏斗和跳过原因。
- 实现 RA001–RA015，包括重试披露、协议不兼容、训练/评测种子重叠、artifact 校验及 provenance/code revision 完整性。
- 使用纯 MoonBit、二进制安全的 SHA-256 生成协议指纹、排序 manifest，并直接校验文件。
- 包含 100 项自动测试、native release benchmark、CI、固定报告哈希，以及合成或匿名 fixture。

CSV 输入有意限定为简单无引号字段；值含逗号或换行时请使用 JSON/JSONL。仓库不包含模型、视频、原始数据集、仿真资产、凭据或许可不明内容。

## 快速开始

```powershell
moon fmt --check
moon info
moon check --target native
moon test --target native
moon build --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json --format json
moon run --target native cmd/main -- --version
```

## 命令

```text
roboaudit validate <file>
roboaudit summarize <file>
roboaudit audit <file>
roboaudit compare <file-a> <file-b>
roboaudit report <file>
roboaudit report-json <file>
roboaudit report-csv <file>
roboaudit fingerprint <file>
roboaudit manifest <paths...>
roboaudit verify-file <path> <sha256>
```

除 `report-json` 与 `report-csv` 快捷命令外，也支持 `report <file> --format json|csv|markdown`。

`validate` 和 `audit` 输出 `valid` 或稳定的 `RAxxx` 发现；存在发现时以状态码 1 退出。用法错误以状态码 2 退出，文件不存在及解析错误也会非零退出。`summarize` / `report-json` 输出结构化 JSON，`report` 输出 Markdown。非空 `skipped` 列表会被明确标记，避免成功率掩盖被排除的候选。

## 文档

- [架构](docs/architecture.md)
- [Canonical schema](docs/schema.md)
- [审计规则](docs/audit-rules.md)
- [审计规则测试矩阵](docs/test-matrix.md)
- [复现步骤](docs/reproducibility.md)
- [参考证据](docs/reference-evidence.md)
- [来源与安全数据政策](docs/provenance.md)
- [AI 辅助说明](docs/ai-assistance.md)
- [Native benchmark 证据](benchmarks/README.md)
- [可执行 Demo](hackathon/demo-script.md)
- [提交需求矩阵](hackathon/requirements-matrix.md)

`examples/incompatible-protocols/` 演示不兼容协议保护；`examples/minimal/skipped-and-retries.json` 演示跳过候选与重试披露。

## 许可

项目采用 Apache-2.0 许可证，详见 [LICENSE](LICENSE) 和 [NOTICE](NOTICE)。
