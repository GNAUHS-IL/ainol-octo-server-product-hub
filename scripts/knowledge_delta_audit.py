#!/usr/bin/env python3
"""Map upstream octo-server changes to the product-hub nine knowledge areas.

This script is intentionally deterministic: it does not claim to rewrite product
knowledge by itself. It detects drift, points to impacted knowledge files, and
fails in strict mode until the new upstream HEAD is recorded in the audit report.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable

AREA_RULES = [
    ("01-auth-identity", "knowledge/01-auth-identity.md", [
        "pkg/auth/", "modules/oidc/", "modules/user/", "modules/integration/",
        "token", "auth", "session", "exchange-jwt", "redemption_ledger",
    ]),
    ("02-authorization-model", "knowledge/02-authorization-model.md", [
        "pkg/auth/", "pkg/authtree/", "pkg/project/", "pkg/space/", "modules/project/",
        "modules/group/", "modules/space/", "modules/bot_api/", "modules/ai_team/",
        "admission", "middleware", "membership", "permission", "role",
    ]),
    ("03-configs", "knowledge/03-configs.md", [
        "configs/", "main.go", "config.go", "config_", "system_setting",
        "OCTO_", "DM_", "env", "settings",
    ]),
    ("04-modules", "knowledge/04-modules.md", [
        "internal/modules.go", "1module.go", "register.AddModule", "modules/",
    ]),
    ("05-api-errors", "knowledge/05-api-errors.md", [
        "pkg/errcode/", "pkg/httperr/", "api_i18n", "error", "Err", "codes",
    ]),
    ("06-im-control-plane", "knowledge/06-im-control-plane.md", [
        "modules/message/", "modules/channel/", "modules/group/", "modules/thread/",
        "modules/incomingwebhook/", "modules/webhook/", "modules/space/api_directory",
        "group_member", "WuKongIM", "datasource", "directory",
    ]),
    ("07-bot-agent", "knowledge/07-bot-agent.md", [
        "modules/bot_api/", "modules/app_bot/", "modules/botfather/", "modules/bot_provision/",
        "modules/bot_mention/", "modules/bot_task/", "modules/ai_team/",
        "modules/robot/", "pkg/botevent", "bot", "agent",
    ]),
    ("08-storage-dependencies", "knowledge/08-storage-dependencies.md", [
        "pkg/db/", "pkg/redis/", "modules/file/", "sql/", ".sql", "migration",
        "internal/projectprovision/", "pkg/octosign/", "redis", "mysql", "outbox",
    ]),
    ("09-build-release", "knowledge/09-build-release.md", [
        "Dockerfile", "Dockerfile.ghcr", "Makefile", ".github/workflows/", "ci/",
        "BUILDING.md", "RELEASING.md", "go.mod", "go.sum",
    ]),
]

MUST_COVER_TERMS = {
    "project": ["project", "octo_project", "project_on", "OCTO_PROJECT"],
    "ai_team": ["ai_team", "DM_AI_TEAM_ON", "ai_session_container"],
    "bot_task": ["bot_task", "OCTO_BOT_TASK", "bot-tasks"],
    "space_directory": ["/v1/space/directory", "agent_hosting", "directoryAgentsPerOwner"],
    "group_admission": ["admission", "group_member", "project_id"],
    "oidc_redemption": ["redemption_ledger", "exchange-jwt", "redeemLedger"],
    "octosign": ["pkg/octosign", "CanonicalRequest", "X-Octo-Signature"],
    "new_errcodes": ["err.server.project", "err.server.ai_team", "err.server.bot_task"],
}

@dataclass
class Audit:
    base: str
    head: str
    changed_count: int
    commits: list[str]
    impacted_areas: list[str]
    review_files: list[str]
    changed_paths_sample: list[str]
    uncovered_terms: dict[str, list[str]]
    status: str


def git(repo: Path, *args: str) -> str:
    return subprocess.check_output(["git", "-C", str(repo), *args], text=True).strip()


def changed_paths(repo: Path, base: str, head: str) -> list[str]:
    out = git(repo, "diff", "--name-only", f"{base}..{head}")
    return [x for x in out.splitlines() if x.strip()]


def commit_lines(repo: Path, base: str, head: str) -> list[str]:
    out = git(repo, "log", "--reverse", "--date=iso", "--pretty=format:%h %ad %s", f"{base}..{head}")
    return [x for x in out.splitlines() if x.strip()]


def impacted(paths: Iterable[str]) -> tuple[list[str], list[str]]:
    areas: list[str] = []
    files: list[str] = []
    for area, knowledge, needles in AREA_RULES:
        if any(any(n.lower() in p.lower() for n in needles) for p in paths):
            areas.append(area)
            files.append(knowledge)
    if len(areas) >= 2:
        files.append("knowledge/10-cross-module-quickref.md")
    return areas, sorted(dict.fromkeys(files))


def knowledge_text(root: Path) -> str:
    parts = []
    for p in sorted((root / "knowledge").glob("*.md")):
        parts.append(p.read_text(encoding="utf-8", errors="replace"))
    return "\n".join(parts).lower()


def uncovered_for_changed(paths: Iterable[str], text: str) -> dict[str, list[str]]:
    joined_paths = "\n".join(paths).lower()
    out: dict[str, list[str]] = {}
    for key, terms in MUST_COVER_TERMS.items():
        if not any(t.lower() in joined_paths for t in terms):
            continue
        missing = [t for t in terms if t.lower() not in text]
        if missing:
            out[key] = missing
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--source-root", default="../octo-server")
    ap.add_argument("--docs-root", default=".")
    ap.add_argument("--base", required=True)
    ap.add_argument("--head", default="HEAD")
    ap.add_argument("--json-out")
    ap.add_argument("--md-out")
    ap.add_argument("--strict", action="store_true")
    args = ap.parse_args()

    source = Path(args.source_root).resolve()
    docs = Path(args.docs_root).resolve()
    base = git(source, "rev-parse", args.base)
    head = git(source, "rev-parse", args.head)
    paths = changed_paths(source, base, head)
    areas, files = impacted(paths)
    text = knowledge_text(docs)
    uncovered = uncovered_for_changed(paths, text)
    status = "ok" if not uncovered else "needs_review"
    audit = Audit(
        base=base, head=head, changed_count=len(paths), commits=commit_lines(source, base, head),
        impacted_areas=areas, review_files=files, changed_paths_sample=paths[:250],
        uncovered_terms=uncovered, status=status,
    )
    data = asdict(audit)
    if args.json_out:
        Path(args.json_out).parent.mkdir(parents=True, exist_ok=True)
        Path(args.json_out).write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if args.md_out:
        p = Path(args.md_out)
        p.parent.mkdir(parents=True, exist_ok=True)
        lines = [
            "# Upstream Knowledge Delta Audit", "",
            f"- Base: `{base[:12]}`", f"- Head: `{head[:12]}`", f"- Changed files: {len(paths)}",
            f"- Status: **{status}**", "", "## Commits", "",
        ]
        lines += [f"- {c}" for c in audit.commits] or ["- none"]
        lines += ["", "## Impacted knowledge files", ""]
        lines += [f"- `{f}`" for f in files] or ["- none"]
        lines += ["", "## Uncovered required terms", ""]
        if uncovered:
            for k, vals in uncovered.items():
                lines.append(f"- {k}: {', '.join(vals)}")
        else:
            lines.append("- none")
        lines += ["", "## Changed paths sample", ""]
        lines += [f"- `{p}`" for p in paths[:250]]
        p.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return 1 if args.strict and uncovered else 0

if __name__ == "__main__":
    raise SystemExit(main())
