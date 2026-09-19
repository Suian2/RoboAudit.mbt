# RoboAudit.mbt

RoboAudit.mbt 是一个以 MoonBit 为主体实现的原生命令行工具和可复用库，用于把机器人与具身智能 episode 日志转换成可审计、可复现的评测证据。

它回答排行榜数字背后的关键问题：**这个结果是否可信、可复现、可比较？** 一条命令即可重算证据、用稳定规则编号指出披露缺口，并在不上传实验数据的情况下生成可评审报告。

## 问题

单一成功率无法说明评测种子是否重复、候选是否被跳过、回合是否重试、交付物是否校验，以及两次运行是否采用可比较的协议。RoboAudit 从 episode 记录重新计算结果，并用稳定的规则编号揭示这些缺失披露。

## 功能

- 支持 canonical JSON、JSONL episode 流、简单无引号 CSV，以及 RoboSyn 风格 `evaluation_metrics.json` 的真实字段别名。
- 生成确定性的 Markdown、JSON 和 CSV 报告。
- 重算成功数与成功率，并计算 Wilson 95% 置信区间、动作步分组统计、失败频数/比例、阶段漏斗和跳过原因。
- 实现 RA001–RA015，包括重试披露、协议不兼容、训练/评测种子重叠、artifact 校验及 provenance/code revision 完整性。
- 使用纯 MoonBit、二进制安全的 SHA-256 生成协议指纹、排序 manifest，并直接校验文件。
- 包含 100 项自动测试、native release benchmark、CI、固定报告哈希，以及合成或匿名 fixture。
- Windows 与 Ubuntu CI 使用同一套原生库、CLI、fixture 和退出码契约。

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

## 示例

```powershell
# 有效 canonical 输入与 Markdown 报告
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json

# 刻意构造的异常输入；预期退出码为 1
moon run --target native cmd/main -- validate examples/minimal/audit-findings.json

# observation 不兼容时拒绝给出误导性的成功率差值
moon run --target native cmd/main -- compare examples/incompatible-protocols/pure-observation.json examples/incompatible-protocols/public-pose.json

# 运行完整讲解 Demo
powershell -ExecutionPolicy Bypass -File hackathon/demo.ps1
```

## Schema 与审计规则

公开 MoonBit 模型由 `Run`、`Episode`、`Stage`、`ArtifactRef` 和 `AuditFinding` 组成。源数据缺失的字段保持可选，或使用明确的 `unspecified` 回退。详见 [canonical schema](docs/schema.md)、[RA001–RA015 目录](docs/audit-rules.md)和[规则正反例矩阵](docs/test-matrix.md)。

## 架构

解析、归一化、校验、统计、协议比较、哈希和报告渲染全部由 MoonBit 实现；`cmd/main` 只处理 native 参数和文件 I/O。详见[架构说明](docs/architecture.md)。

## 测试与性能

Native 测试套件包含 100 项测试，覆盖异常/非有限数值、adapter 字段别名、统计边界、每条审计规则、确定性输出、黄金哈希和 SHA-256 向量。2026-09-19 的 MoonBit 覆盖率摘要显示：核心 `roboaudit.mbt` 为 778/824 行（94.42%），全部插桩源码为 831/963 行（86.29%）；CLI 入口通过外部进程验收，因此明确不计入核心比例。运行 `moon test --target native`；详见[测试矩阵](docs/test-matrix.md)和 1,000 episode 的 [benchmark 证据](benchmarks/README.md)。

如需快速理解为什么“满分结果”仍可能不适合比较，请阅读基于真实 CLI 输出编写的[审计案例](docs/case-study.md)。

## 2026 年 9 月黑客松新增工作

本期开始前，仓库只是可编译的 MoonBit 骨架，没有审计实现。本期完成了 canonical 模型、四种输入形态、三种报告格式、RA001–RA015、协议安全比较、manifest、100 项测试、CI、benchmark、fixture、文档和可执行 Demo。既有 RoboSynChallenge 项目仅作为只读需求来源，不被复制，也不计入本期工作量。

## AI 辅助与来源

AI 用于辅助实现、测试、文档和故障排查；贡献者仍负责审查、解释、质量和发布决策。仓库只提交手写合成/匿名 fixture 与聚合元数据证据。详见 [AI 辅助说明](docs/ai-assistance.md)、[来源政策](docs/provenance.md)和[参考证据](docs/reference-evidence.md)。

## Roadmap

- 贡献者确认公开仓库和 Mooncakes 身份后冻结并发布 v0.1.0。
- 仅在真实用户需要时增加带引号的 RFC 4180 CSV 输入；当前简单 CSV 边界保持明确。
- Native P0/P1 发布后再探索 MoonBit WASM 报告查看器，并复用同一核心逻辑。

## 文档

- [架构](docs/architecture.md)
- [Canonical schema](docs/schema.md)
- [审计规则](docs/audit-rules.md)
- [审计规则测试矩阵](docs/test-matrix.md)
- [复现步骤](docs/reproducibility.md)
- [参考证据](docs/reference-evidence.md)
- [审计案例](docs/case-study.md)
- [来源与安全数据政策](docs/provenance.md)
- [AI 辅助说明](docs/ai-assistance.md)
- [Native benchmark 证据](benchmarks/README.md)
- [可执行 Demo](hackathon/demo-script.md)
- [提交需求矩阵](hackathon/requirements-matrix.md)

`examples/incompatible-protocols/` 演示不兼容协议保护；`examples/minimal/skipped-and-retries.json` 演示跳过候选与重试披露。

## 许可

项目采用 Apache-2.0 许可证，详见 [LICENSE](LICENSE) 和 [NOTICE](NOTICE)。
