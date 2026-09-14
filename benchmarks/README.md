# Native benchmark evidence

Command:

```powershell
moon bench --target native --release
```

Measured on 2026-09-14 with MoonBit 0.1.20260904 on the local Windows native toolchain:

| Workload | Mean | Standard deviation | Runs |
| --- | ---: | ---: | ---: |
| Validate synthetic 1,000-episode JSON | 3.23 ms | 424.61 us | 10 x 31 |
| Generate JSON report for 1,000 episodes | 3.49 ms | 502.97 us | 10 x 31 |

These are the latest observed development-machine results, not universal performance claims. Source workload generation is in `roboaudit_bench_test.mbt`; it contains no external or private data. Earlier runs are preserved in the worklog rather than silently replacing their historical evidence.
