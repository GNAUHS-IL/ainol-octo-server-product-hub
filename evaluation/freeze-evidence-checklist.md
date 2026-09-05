# Freeze Evidence Checklist

> Purpose: one-page evidence index for AINOL Agent practice exam B. This file only summarizes existing deliverables and verification evidence; it does not change product rules, labels, templates, cron, or source code.

- Generated at: 2026-09-05 22:49:35 CST
- Product hub latest local commit at generation: `c779975`
- Read-only upstream checkout commit at generation: `49dc9fd`
- Target upstream repository: `Mininglamp-OSS/octo-server`
- Product hub policy: public requirement pool only; never write to upstream source repository.

## 1. Core exam deliverables

| Deliverable | Evidence path | Check |
| --- | --- | --- |
| Product hub overview | `README.md` | Present |
| Nine-domain knowledge base | `knowledge/00-index.md`, `knowledge/01-auth-identity.md` ... `knowledge/09-build-release.md` | Present |
| Cross-module quick reference | `knowledge/10-cross-module-quickref.md` | Present |
| Label system | `labels.yml` | Present |
| GitHub issue templates | `.github/ISSUE_TEMPLATE/` | Present |
| PRD template | `prd/TEMPLATE.md` | Present |
| Review checklist | `review/REVIEW_CHECKLIST.md` | Present |
| Cron / scheduler evidence | `docs/cron-evidence.md` | Present |
| Triage decision table | `docs/triage-decision-table.md` | Present |
| Status arbitration rules | `docs/status-arbitration-rules.md` | Present |
| Escalation policy | `docs/escalation-policy.md` | Present |
| Sample issues | `evaluation/sample-issues/` | Present |
| Evaluation scorecard | `evaluation/scorecard.md` | Present |

## 2. Source-grounding evidence

- Source citation verifier: `scripts/verify_citations.py`
- Last verification command:

```bash
python3 scripts/verify_citations.py --docs-root . --source-root ../octo-server
```

- Last verification result before this checklist was created:

```text
citation verification: ok
total=2655 passed=2655 failed=0
```

## 3. Read-only upstream boundary

- The upstream source checkout is `../octo-server/`.
- The product-ops agent must not write to `Mininglamp-OSS/octo-server`.
- Source/product answers must cite real source paths and narrow line ranges.
- If evidence is missing or conflicting, the answer must say “不确定” and state the next place to inspect.

## 4. PM workflow evidence

| Workflow stage | Evidence path |
| --- | --- |
| Intake and triage | `docs/triage-decision-table.md` |
| PRD writing policy | `prd/TEMPLATE.md` |
| What-only PRD review | `review/REVIEW_CHECKLIST.md` |
| Status arbitration | `docs/status-arbitration-rules.md` |
| Upstream change scan | `docs/upstream-change-scan.md`, `scripts/scan_upstream_changes.sh` |
| Audit log format | `docs/audit-log-format.md` |
| Cron evidence | `docs/cron-evidence.md` |

## 5. Final freeze self-check

- [x] Upstream repository remains read-only from this workspace.
- [x] Product hub repository exists and is the only intended writable public requirement pool.
- [x] Knowledge base has source-grounded citations.
- [x] Citation verification passed before checklist creation.
- [x] Labels, issue templates, PRD template, review checklist, and cron evidence are present.
- [x] Sample issues are present for exam demonstration.
- [x] No token, cookie, secret, private key, or production credential is recorded here.

## 6. Freeze rule

After final freeze, do not modify core prompt, state machine, label system, issue templates, PRD template, review checklist, or cron configuration unless the exam owner explicitly requests it.
