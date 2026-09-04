#!/usr/bin/env bash
set -euo pipefail
REPO_NAME="ainol-octo-server-product-hub"
DESC="Product inbox, source-grounded knowledge base, PRD workflow and cron-based status loop for Mininglamp-OSS/octo-server AINOL Agent exam."
if ! command -v gh >/dev/null 2>&1; then
  echo "gh_not_installed" >&2
  exit 2
fi
gh auth status >/dev/null
if ! gh repo view "$REPO_NAME" >/dev/null 2>&1; then
  gh repo create "$REPO_NAME" --public --description "$DESC" --source "$REPO_NAME" --remote origin --push
else
  echo "repo_exists:$REPO_NAME"
fi
