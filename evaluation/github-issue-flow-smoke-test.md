# GitHub Issue Flow Smoke Test

## Purpose

Verify the exam-critical flow for user feedback handling:

1. Understand a user bug/feature request.
2. Classify it into issue-first type / priority / area / status / evidence labels.
3. Create a GitHub issue in the product-hub repository.
4. Update labels after triage.
5. Add a closure/comment trail.
6. Close the smoke-test issue without leaking secrets.
7. Run the issue scanner so cron-style state tracking detects the change.

## Repository

- Product hub: `GNAUHS-IL/ainol-octo-server-product-hub`
- Visibility: public
- Upstream target repo: `Mininglamp-OSS/octo-server` remains read-only.

## Test Results

| Time | Check | Result | Evidence |
|---|---|---:|---|
| 2026-09-05 23:58 +0800 | Create issue through GitHub REST API | Pass | `#4`, HTTP `201`, <https://github.com/GNAUHS-IL/ainol-octo-server-product-hub/issues/4> |
| 2026-09-05 23:59 +0800 | Update labels after triage | Pass | labels: `type/feature`, `priority/P2`, `status/done`, `area/bot-agent`, `pm/needs-prd`, `source/evaluation`, `evidence/source-needed` |
| 2026-09-05 23:59 +0800 | Add audit comment | Pass | <https://github.com/GNAUHS-IL/ainol-octo-server-product-hub/issues/4#issuecomment-5553006119> |
| 2026-09-05 23:59 +0800 | Close smoke-test issue | Pass | `#4` closed with `state_reason=completed` |
| 2026-09-06 00:00 +0800 | Scripted smoke test helper | Pass | `#5`, closed, <https://github.com/GNAUHS-IL/ainol-octo-server-product-hub/issues/5> |
| 2026-09-06 00:00 +0800 | Issue scan after changes | Pass | `scripts/scan_issues.sh` wrote `change_detected` to local scan log |

## Implementation Notes

- `scripts/create_issue_smoke_test.sh` uses GitHub REST API and requires `GH_TOKEN` or `GITHUB_TOKEN`.
- `scripts/scan_issues.sh` now prefers `gh` CLI when available, falls back to the workspace-local `tools/bin/gh`, and finally falls back to GitHub REST API through `curl`.
- Secrets are never printed; logs only record redacted operational status.
- No write is made to `Mininglamp-OSS/octo-server`.


## Runtime Preflight Check

A non-mutating preflight check was run after the live smoke tests to confirm the exam runtime can still create/update issues when needed.

| Time | Check | Result |
|---|---|---:|
| 2026-09-06 00:06 +0800 | Token authenticates against GitHub `/user` | Pass |
| 2026-09-06 00:06 +0800 | Product-hub repo access | Pass |
| 2026-09-06 00:06 +0800 | Repo visibility | Public |
| 2026-09-06 00:06 +0800 | Repo permissions | `admin=true`, `maintain=true`, `push=true`, `triage=true`, `pull=true` |
| 2026-09-06 00:06 +0800 | Required labels readable | Pass, missing `[]` |
| 2026-09-06 00:06 +0800 | GitHub API rate limit | Pass, `remaining=5000/5000` |

Secrets were not printed or committed.

## Exam Readiness Judgment

The bug/feature intake path is executable end-to-end:

- Natural language feedback can be converted into a GitHub issue only when it needs tracking; then labels are applied.
- GitHub issue creation is verified.
- Triage labels are verified.
- Comment/status update is verified.
- Scanner change detection is verified.

Remaining operational requirement: the runtime must provide a GitHub token with issue write permission for the product-hub repository when live issue creation is expected.
