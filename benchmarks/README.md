# Native benchmark evidence

Command:

```powershell
moon bench --target native --release
```

Measured on 2026-09-19 with MoonBit 0.1.20260904 on the local Windows native toolchain after configuring the final `Suian2/roboaudit` module identity:

| Workload | Mean | Standard deviation | Runs |
| --- | ---: | ---: | ---: |
| Validate synthetic 1,000-episode JSON | 5.15 ms | 226.96 us | 10 x 22 |
| Generate JSON report for 1,000 episodes | 5.42 ms | 228.93 us | 10 x 19 |

These are one recorded development-machine run, not universal performance claims or a statistically controlled cross-machine comparison. Source workload generation is in `roboaudit_bench_test.mbt`; it contains no external or private data. Earlier runs are preserved in the worklog rather than silently replacing their historical evidence.
