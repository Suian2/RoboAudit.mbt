# Risk register

| Risk | State | Mitigation / evidence |
| --- | --- | --- |
| Remote historical snapshots deny enumeration | Contained | Exclude unreadable archives; formal evaluation artifact schema and SHA metadata are recorded separately. |
| Accidentally redistribute restricted assets | Controlled | Only hand-written fixtures are committed; provenance policy forbids models, video, raw datasets, credentials, and unknown-license assets. |
| Protocol-incompatible success rates are compared | Controlled | SHA-256 protocol fingerprint plus RA009/RA010 gate; differences omitted when incompatible. |
| Report output changes nondeterministically | Controlled | Explicit field order, stable first-observed distributions, sorted manifest paths, and determinism tests. |
| CSV parser overclaims RFC 4180 support | Controlled | Input is documented as simple unquoted CSV; output applies quote doubling. |
| Quadratic duplicate detection on very large runs | Accepted for v0.1 | Current benchmark is 1,000 episodes; optimize after correctness if larger corpora require it. |
| Mooncakes publication cannot be preflighted without login | Open external | Package list and ZIP succeed; repeat `moon publish --dry-run` after user login. |
| Public repository and formal submission incomplete | Open external | Requires explicit user confirmation after local completion audit. |
