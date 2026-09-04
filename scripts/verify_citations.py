#!/usr/bin/env python3
"""Verify source citations in product-hub markdown files.

Citation format expected by the exam:
    来源: <relative/path>#L<start>-L<end>

The source path is resolved under the read-only octo-server checkout by default.
This script only reads files and never writes to the target octo-server repo.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path

CITATION_RE = re.compile(r"来源:\s*([^\s#]+)#L(\d+)-L(\d+)")


@dataclass
class CitationResult:
    doc: str
    doc_line: int
    source_path: str
    start: int
    end: int
    ok: bool
    reason: str = "ok"


def iter_markdown_files(root: Path):
    for path in sorted(root.rglob("*.md")):
        parts = set(path.parts)
        if ".git" in parts:
            continue
        yield path


def verify_one(repo_root: Path, doc_root: Path, doc: Path, line_no: int, match: re.Match[str]) -> CitationResult:
    source_path = match.group(1)
    start = int(match.group(2))
    end = int(match.group(3))
    rel_doc = str(doc.relative_to(doc_root))

    if start < 1 or end < 1:
        return CitationResult(rel_doc, line_no, source_path, start, end, False, "line_number_must_be_positive")
    if end < start:
        return CitationResult(rel_doc, line_no, source_path, start, end, False, "end_before_start")
    if source_path.startswith("/") or ".." in Path(source_path).parts:
        return CitationResult(rel_doc, line_no, source_path, start, end, False, "source_path_must_be_repo_relative")

    source_file = repo_root / source_path
    try:
        resolved_repo = repo_root.resolve()
        resolved_file = source_file.resolve()
    except FileNotFoundError:
        return CitationResult(rel_doc, line_no, source_path, start, end, False, "source_file_missing")

    if resolved_repo not in resolved_file.parents and resolved_file != resolved_repo:
        return CitationResult(rel_doc, line_no, source_path, start, end, False, "source_path_escapes_repo")
    if not source_file.is_file():
        return CitationResult(rel_doc, line_no, source_path, start, end, False, "source_file_missing")

    try:
        with source_file.open("rb") as f:
            total_lines = sum(1 for _ in f)
    except OSError as exc:
        return CitationResult(rel_doc, line_no, source_path, start, end, False, f"source_read_failed:{exc.__class__.__name__}")

    if end > total_lines:
        return CitationResult(rel_doc, line_no, source_path, start, end, False, f"line_range_exceeds_file:{total_lines}")
    return CitationResult(rel_doc, line_no, source_path, start, end, True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify exam source citations in markdown files.")
    parser.add_argument("--docs-root", default=".", help="product-hub root to scan, default: current directory")
    parser.add_argument("--source-root", default="../octo-server", help="read-only octo-server checkout, default: ../octo-server")
    parser.add_argument("--json", action="store_true", help="emit machine-readable JSON")
    parser.add_argument("--fail-fast", action="store_true", help="stop at first invalid citation")
    args = parser.parse_args()

    doc_root = Path(args.docs_root).resolve()
    source_root = Path(args.source_root).resolve()

    results: list[CitationResult] = []
    for doc in iter_markdown_files(doc_root):
        try:
            lines = doc.read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            lines = doc.read_text(encoding="utf-8", errors="replace").splitlines()
        for line_no, line in enumerate(lines, 1):
            for match in CITATION_RE.finditer(line):
                result = verify_one(source_root, doc_root, doc, line_no, match)
                results.append(result)
                if args.fail_fast and not result.ok:
                    break
            if args.fail_fast and results and not results[-1].ok:
                break
        if args.fail_fast and results and not results[-1].ok:
            break

    total = len(results)
    failed = [r for r in results if not r.ok]
    passed = total - len(failed)
    summary = {
        "source_root": str(source_root),
        "docs_root": str(doc_root),
        "total": total,
        "passed": passed,
        "failed": len(failed),
        "status": "ok" if not failed else "failed",
    }

    if args.json:
        print(json.dumps({"summary": summary, "failures": [asdict(r) for r in failed]}, ensure_ascii=False, indent=2))
    else:
        print(f"citation verification: {summary['status']}")
        print(f"source_root: {source_root}")
        print(f"docs_root: {doc_root}")
        print(f"total={total} passed={passed} failed={len(failed)}")
        for r in failed[:50]:
            print(f"FAIL {r.doc}:{r.doc_line} {r.source_path}#L{r.start}-L{r.end} {r.reason}")
        if len(failed) > 50:
            print(f"... {len(failed) - 50} more failures omitted")

    return 0 if not failed else 1


if __name__ == "__main__":
    sys.exit(main())
