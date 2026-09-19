# Audit case study: when a score is not enough

This case study uses only the repository's hand-authored synthetic and anonymized fixtures. The outputs below are produced by the native MoonBit CLI; no private experiment data or reference-project assets are copied.

## Question 1: is the reported aggregate internally supported?

Run:

```powershell
moon run --target native cmd/main -- report examples/minimal/canonical-clean.json
```

RoboAudit recalculates `2/3` successes (66.67%), reports a Wilson 95% interval of approximately `[0.208, 0.939]`, separates successful action steps (mean 10.5) from the failed episode (30), and exposes the failure as `timeout`. The report has no audit findings because the protocol, provenance, episode records, and aggregate agree.

Decision impact: the wide confidence interval makes the small sample size visible instead of letting `66.67%` look more precise than the evidence supports.

## Question 2: did a success rate hide excluded candidates?

Run:

```powershell
moon run --target native cmd/main -- audit examples/robosyn/evaluation-metrics-anonymized.json
```

The RoboSyn-shaped fixture reports `1/2` evaluated episodes, but also contains a skipped candidate whose reason is `expert_action_generation_failed`. RoboAudit emits:

```text
RA006: skipped candidates require disclosure
```

Decision impact: the evaluated-episode success rate remains available, but downstream reviewers are warned that it does not describe the complete candidate population.

## Question 3: can two extreme scores safely be compared?

Run:

```powershell
moon run --target native cmd/main -- compare examples/incompatible-protocols/pure-observation.json examples/incompatible-protocols/public-pose.json
```

The inputs contain `0/2` and `2/2` successes. A naive comparison would announce a 100 percentage-point improvement. RoboAudit fingerprints the protocols, finds that `observation_mode` differs, emits `RA009`, and deliberately returns:

```text
Success-rate difference: not reported for incompatible or empty runs
```

Decision impact: RoboAudit prevents a strong-looking but invalid claim from being generated when the evaluated information available to the policy changed.

## Why this matters beyond the fixtures

The three checks form a reusable review sequence:

1. recompute aggregates from episode evidence;
2. disclose selection, retries, and failure composition;
3. compare results only after protocol compatibility is established.

The stable `RAxxx` identifiers make the same policy usable in local analysis, CI gates, delivery reviews, and machine-readable JSON reports. See [audit rules](audit-rules.md) for the full RA001–RA015 catalogue and [reference evidence](reference-evidence.md) for the read-only field and delivery patterns that informed the design.
