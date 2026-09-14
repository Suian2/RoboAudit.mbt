# Read-only reference evidence

This page records metadata, hashes, and aggregate schema observations. It does not redistribute source logs, model weights, videos, datasets, internal absolute paths, or private data.

## Scope and access boundary

The read-only reference root was inspected on 2026-09-14. Top-level metadata showed evaluation results, artifacts, source/configuration directories, models, datasets, logs, and historical archives. Only small text/JSON evaluation artifacts and filenames were read. Model outputs, videos, datasets, 3D assets, and large trace bodies were not opened.

Full traversal of historical `archive/.../repo_snapshot/policy/...` and newer aggregate `outputs/ten_tasks_*` directories was denied by their ACL in this execution session. These paths were recorded and skipped without changing permissions. The semantically nearest complete ten-task evaluation root and the latest accessible formal delivery were used, as required by the audit procedure.

## Ten-task evaluation inventory

The relative root `eval_result/final_official_random100_20260907/` contains these ten tasks:

`click_bell`, `drawer_open_place`, `handle_basket`, `item_assembly`, `items_handover`, `manipulate_pipette`, `mixer_operating`, `sample_loading`, `table_rearrangement`, and `water_pouring`.

Every accessible leaf video set below contains exactly 100 completed filenames, zero `*.tmp.mp4`, 100 unique episode seeds, and the same ordered seed-sequence SHA-256 `55CF614B68709ADDD2D6D248951B4F0B9BB9D5F2668ADCE70FB3DFCC2A3CF916`. The hash is over the comma-joined decimal seed sequence derived from filenames; no video content was read.

| Task | 2026-09-07/08 run | 2026-09-10/11 rerun |
| --- | ---: | ---: |
| click_bell | 85/100 | 86/100 |
| drawer_open_place | 71/100 | 72/100 |
| handle_basket | 90/100 | 94/100 |
| item_assembly | 64/100 | 59/100 |
| items_handover | 59/100 | 58/100 |
| manipulate_pipette | 47/100 | 33/100 |
| mixer_operating | 96/100 | 94/100 |
| sample_loading | 0/100 | not present in this root |
| table_rearrangement | 21/100 | 22/100 |
| water_pouring | 76/100 | 79/100 |

Filename structure is `episode_<index>_seed_<seed>_<success|fail>.mp4`. Identical seed sequences but different outcomes across reruns support preserving protocol, code revision, environment, evaluator, and observation mode rather than treating a seed list alone as experiment identity.

The relative summary `LATEST_10_TASK_RANDOM100_RESULTS_AND_COMMANDS_20260908_V2.txt` is 10,727 bytes with SHA-256 `A7E82F45EA261AE9A2FD9B8E523F546A1D82908E7F19C6B388996838EBAD242E`. It records the first complete results above and separately identifies a 78/100 sample-loading simulator-closed-loop candidate. That candidate is not merged with the pure-observation 0/100 run because their observation/protocol conditions differ. This distinction directly motivates RA009/RA010 and the protocol compatibility gate.

## Formal delivery schema evidence

The latest accessible complete delivery is under the relative root `artifacts/items_handover_v3/final_delivery_v30_20260913/`.

| Relative file | Bytes | SHA-256 |
| --- | ---: | --- |
| `evaluation_metrics.json` | 34,100 | `4633E7C2E0B2AA59A3A2B42B173E2484C98C82F02DFC153AA31A376A7B2A22CF` |
| `formal_audit_summary.json` | 212,310 | `0E7D3958AFC2896C1A8C14A28E4DBDDADC47AC4C80EB3EB0CEA5EFFF6F8CA65F` |
| `formal_delivery_metadata.json` | 10,147 | `4F5205697E71F1142A81E338374B024D192A996C072E5EBB9644169550C02DA3` |
| `formal_compliance_audit.json` | 13,459 | `D0688C65472D5A8B2EABCFA9BC6418BA5B4AC7B2118AEE05F1E6FA635CF9CA02` |
| `dataset_audit.json` | 18,802 | `36CDB38CCD26292890EC2949BF4ED34DA8A43D9E122215600BB4E785BBAF17BA` |
| `failure_annotations.json` | 10,065 | `C161D99817A5C09B875559FBBE86472E8DC7148A0E9B188C72B888F7400CE53C` |
| `accepted_episode_seeds.json` | 14,565 | `01FA1F81A24EBB2EFA6DE9C90BD6D5C9C367D5CC6250A6A8C1DAFBEC99D4A396` |
| `sha256_manifest_v2.json` | 167,149 | `36CF55FB95E172A614B60F0FB751BE23402C2B6B23072A2AC77E0CA971161544` |
| `DELIVERY.md` | 1,905 | `ADBC24FF07268C3CE5462F2E71AE6E9D22496B38F905C8DC23F714A650C469A9` |
| `REPRODUCE.md` | 3,372 | `3EB973F5BA1E80EA920B08C2998AAD046B2AAB2D089D46CC27081EFE93C5AB72` |
| `failure_analysis.md` | 4,389 | `398055EDE41AE5407522B9D875C40A186E980B6655B24DCEE2C135890A32B5B7` |

Observed `evaluation_metrics.json` roots are `schema_version`, `created_at`, `config`, `inference_timing_scope`, `platform`, `summary`, `episodes`, and `feasibility_filter`. Its aggregate is 100 episodes, 80 successes, success rate 0.8. Episode fields include `episode_index`, `candidate_index`, `episode_attempt_index`, `seed`, `success`, `action_steps`, and `expert_plan_steps`. The feasibility block includes attempted/accepted/skipped candidate counts and skipped seeds.

Observed formal-audit summary fields add master seed, failure count/taxonomy, action-step percentiles, inference counters/timings, artifact counts, protocol, per-episode status/evidence, and 20 failure records. `failure_annotations.json` likewise contains 20 failures with category, contributing categories, first obvious failure step, evidence, and confidence.

Observed delivery metadata groups official identity/commit, formal protocol, policy and learned assets, authoritative versus supplementary metrics, failure analysis, dataset audit, compliance, artifact roots, and portable smoke evidence. The manifest declares 296 files and 836,964,920 bytes with per-entry path, byte size, and SHA-256. RoboAudit's canonical provenance, protocol fingerprint, skipped/retry checks, grouped failures, and manifest rules are derived from these patterns.

An earlier reconstructed metrics file at `artifacts/items_handover_v3/baseline58_rerun_official_random100_20260910_audit_v1/evaluation_metrics.json` is 5,994 bytes with SHA-256 `8F60B137134D60CE0A7819303D7F409CFB840B6D6ABE87D0E8811EC8A2A3D744`. Its distinct root fields (`schema`, `reconstruction_reason`, `protocol`, `inputs`, `summary`, `timing_precision_note`, `comparison`) show why adapters must tolerate semantically equivalent versioned shapes without erasing provenance.

## Source and licensing metadata

The reference root declares project name `robosynchallenge`, Python `>=3.10`, and Apache-2.0 in `pyproject.toml`. Metadata hashes are:

| Relative file | Bytes | SHA-256 |
| --- | ---: | --- |
| `LICENSE` | 11,357 | `C71D239DF91726FC519C6EB72D318EC65820627232B2F796219E87DCF35D0AB4` |
| `README.md` | 2,344 | `B184922E4F18D3CB40BB95AFAAEFD1C95627C5AB93DA9678E6784163DF20ADFC` |
| `pyproject.toml` | 1,099 | `18D2D31570B4F93037FF6FAEDFDEEC451FE1818ED2C9492BEAB8CB8CFAAF0948` |
| `VERSION` | 6 | `E6635045E1D2478EC4CA712D8C0E1DFCEF8BB7B5B1E8E3BB560D37FE399A9E72` |

RoboAudit does not copy any reference source or data. Its committed RoboSyn-shaped fixture is hand-written and anonymous; Apache-2.0 metadata does not imply that third-party simulator assets, datasets, videos, or model weights are redistributable.
