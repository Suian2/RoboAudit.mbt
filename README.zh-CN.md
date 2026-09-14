# RoboAudit.mbt

RoboAudit.mbt 是一个以 MoonBit 为主体实现的原生命令行工具，用于把机器人和具身智能 episode 日志转为可审计、可复现的评测证据。

## 功能

- 支持 canonical JSON、JSONL episode 流、简单无引号 CSV，以及 RoboSyn 风格 `evaluation_metrics.json` 的真实字段别名。
- 生成确定性的 Markdown、JSON 和 CSV 报告。
- 重算成功数与成功率，计算 Wilson 95% 置信区间、动作步分组、失败类型、阶段漏斗和跳过原因。
- 实现 RA001 至 RA015，包括重试披露、协议不兼容、训练/评测种子重叠和 artifact 校验。
- 使用纯 MoonBit、二进制安全的 SHA-256 生成协议指纹、排序 manifest，并直接校验文件。
- 包含 77 项自动测试、native release benchmark、CI，以及合成/匿名 fixture。

CSV 输入有意限定为简单无引号字段；值含逗号或换行时请使用 JSON/JSONL。仓库不包含模型、视频、原始数据集、仿真资产、凭据或许可不明内容。

## 快速开始

```powershell
moon fmt --check
moon info
moon check --target native
moon test --target native
moon build --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
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

复现流程见 [docs/reproducibility.md](docs/reproducibility.md)，数据与许可边界见 [docs/provenance.md](docs/provenance.md)。项目采用 Apache-2.0 许可证。
