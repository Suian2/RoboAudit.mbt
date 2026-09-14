# RoboAudit.mbt — one-page proposal

## Problem

Robot and embodied-AI experiments frequently publish a single success rate without enough information to reproduce, compare, or audit it. Episode logs can omit seeds, retries, skipped candidates, protocol context, or failure annotations.

## Solution

RoboAudit.mbt is a MoonBit-first command-line library and native CLI that normalizes episode logs, recalculates metrics, detects audit risks, and produces deterministic reports. Its initial compatibility target is the common core of canonical evaluation JSON and RoboSyn-style `evaluation_metrics.json`.

## Why MoonBit

MoonBit implements the parsing, canonical model, validation, audit rules, statistics, and report rendering. The command executable only handles arguments and file I/O. The resulting core is suitable for native CI now and a future WASM viewer without duplicating business logic.

## Demonstration

The included anonymous fixtures show a clean three-episode run, a RoboSyn-shaped evaluation log with a disclosed skipped candidate, and deliberately malformed audit data. `validate` prints stable RA rule identifiers; `report` produces readable Markdown with recalculated success totals.

## Responsible reuse

The tool learns field conventions and audit needs from a read-only reference project, but it redistributes no models, raw datasets, videos, simulator assets, credentials, or unknown-license content. Fixtures are hand-written and anonymous.

## Delivery status

The submitted baseline contains the working JSON vertical slice, native build/test workflow, documentation, and local reproduction steps. Planned P1 work is documented separately and is not claimed as complete.
