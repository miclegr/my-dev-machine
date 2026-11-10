#!/usr/bin/env bash
# Copy "<repo root> <commit sha>" to the clipboard.
# Usage: copy-repo-commit.sh [sha]
# With no argument, fall back to HEAD.
set -euo pipefail

sha="${1:-}"
if [[ -z "$sha" ]]; then
    sha=$(git rev-parse --verify HEAD)
fi
root=$(git rev-parse --show-toplevel)
text="$root $sha"

copy() {
    printf '%s' "$text" | "$@"
}

if command -v wl-copy >/dev/null 2>&1; then
    copy wl-copy
elif command -v xclip >/dev/null 2>&1; then
    copy xclip -in -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
    copy xsel --input --clipboard
elif command -v clip.exe >/dev/null 2>&1; then
    copy clip.exe
elif command -v pbcopy >/dev/null 2>&1; then
    copy pbcopy
else
    printf 'copy-repo-commit: no clipboard utility found (tried wl-copy, xclip, xsel, clip.exe, pbcopy)\n' >&2
    exit 1
fi
