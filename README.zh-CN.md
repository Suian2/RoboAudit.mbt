# RoboAudit.mbt

RoboAudit.mbt 是一个以 MoonBit 为主体实现的原生命令行工具，用于审计机器人与具身智能评测日志。它将 episode 日志转为可追溯证据：重算成功数、输出审计发现，并生成确定性 Markdown 报告。

当前已实现 canonical JSON 与兼容的 RoboSyn `evaluation_metrics.json` 核心字段解析、`validate`/`summarize`/`audit`/`compare`/`report` 命令、确定性 JSON/Markdown、协议指纹、Wilson 95% 区间、匿名 fixture，以及 RA001–RA010、RA013–RA015 的可执行检查。JSONL/CSV、动作步分布、阶段漏斗、hash manifest、RA011/RA012 和 60+ 测试仍在开发中，未被宣称完成。

```powershell
moon check --target native
moon test --target native
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
```

仓库不包含模型、视频、原始数据集、仿真资产、密钥或机器内部路径。数据边界见 [docs/provenance.md](docs/provenance.md)。
