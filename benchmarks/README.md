# Native benchmark evidence

Command:

```powershell
moon bench --target native --release
```

Measured on 2026-09-14 with MoonBit 0.1.20260904 on the local Windows native toolchain:

| Workload | Mean | Standard deviation | Runs |
| --- | ---: | ---: | ---: |
| Validate synthetic 1,000-episode JSON | 2.46 ms | 125.79 us | 10 x 39 |
| Generate JSON report for 1,000 episodes | 3.05 ms | 250.48 us | 10 x 36 |

These are observed development-machine results, not universal performance claims. Source workload generation is in `roboaudit_bench_test.mbt`; it contains no external or private data.
