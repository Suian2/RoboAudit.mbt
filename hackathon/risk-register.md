# Risk register

| Risk | State | Mitigation / evidence |
| --- | --- | --- |
| Protected historical snapshots and three aggregate output roots deny enumeration | Contained | Skip unreadable ACL-protected roots without changing permissions; the accessible ten-task inventory and nearest formal delivery schema/hash evidence are recorded separately. |
| Accidentally redistribute restricted assets | Controlled | Only hand-written fixtures are committed; provenance policy forbids models, video, raw datasets, credentials, and unknown-license assets. |
| Protocol-incompatible success rates are compared | Controlled | SHA-256 protocol fingerprint plus RA009/RA010 gate; differences omitted when incompatible. |
| Report output changes nondeterministically | Controlled | Explicit field order, stable first-observed distributions, sorted manifest paths, determinism tests, and fixed Markdown/JSON golden hashes. |
| CSV parser overclaims RFC 4180 support | Controlled | Input is documented as simple unquoted CSV; output applies quote doubling. |
| Quadratic duplicate detection on very large runs | Accepted for v0.1 | Current benchmark is 1,000 episodes; optimize after correctness if larger corpora require it. |
| Mooncakes publication cannot be preflighted without login | Resolved | Authenticated server-side dry-run accepted the package; the extracted package passed `moon check`. |
| Public repository could expose unreviewed content | Resolved | Contributor approved publication after clean-clone, privacy, package, and Git-history audits; `Suian2/RoboAudit.mbt` is public. |
| Mooncakes publication and formal submission incomplete | Resolved for entrant actions | Version 0.1.0 is public on Mooncakes and GitHub; registration is submitted and the contributor joined the event group. Organizer review remains external. |
| Reviewers interpret the project as relying on a universal log standard | Mitigated; reconsideration pending | The application and both READMEs now state that RoboAudit owns a documented canonical schema, uses source adapters, and is scoped to episode-based evaluation evidence rather than arbitrary logs. |
| Git commit metadata could expose a personal email | Resolved locally | With explicit contributor approval, all unpublished author and committer emails now use the account's ID-based GitHub noreply address. |
