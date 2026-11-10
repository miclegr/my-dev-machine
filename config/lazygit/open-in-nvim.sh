#!/usr/bin/env bash
# Open a file in the nvim running in another tmux window, at (roughly)
# the position currently shown in lazygit's diff view.
set -euo pipefail

file="${1:?usage: open-in-nvim.sh <file> [tmux-window]}"
win="${2:-nvim}"

[[ -n "${TMUX:-}" ]] || { echo "open-in-nvim: not inside tmux" >&2; exit 1; }
pane_id="${TMUX_PANE:?open-in-nvim: TMUX_PANE not set}"
session=$(tmux display-message -p -t "$pane_id" '#S')
target="$session:$win"
abs=$(realpath -- "$file" 2>/dev/null || printf '%s' "$file")

info=$(tmux capture-pane -p -t "$pane_id" | python3 -c '
import re, sys
lines = sys.stdin.read().split("\n")

header = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@[ ]?(.*)$")

def main_segment(line):
    if "\u2502" not in line:
        return None
    parts = line.split("\u2502")
    seg = parts[-1] if parts[-1].strip() else (parts[-2] if len(parts) >= 2 else "")
    return seg.rstrip()

for line in lines:
    seg = main_segment(line)
    if not seg or len(seg) < 2 or seg[0] not in "@ +-":
        continue
    m = header.match(seg)
    if m:
        text = m.group(2).strip()
        print("HEADER\t%s\t%s" % (m.group(1), text))
        sys.exit(0)
    if seg[0] in " +" and seg[1:].strip():
        print("SEARCH\t\t%s" % seg[1:].lstrip())
        sys.exit(0)
    # lines starting with - are deletions: not present in the working file
print("NONE\t\t")
')

kind=${info%%$'\t'*}
rest=${info#*$'\t'}
line=${rest%%$'\t'*}
text=${rest#*$'\t'}

if [[ "${OPEN_NVIM_DRY:-}" == "1" ]]; then
    printf 'target=%s\nkind=%s\nline=%s\ntext=%s\n' "$target" "$kind" "$line" "$text"
    exit 0
fi

tmux send-keys -t "$target" Escape
sleep 0.05
tmux send-keys -t "$target" -l ":e $abs"
tmux send-keys -t "$target" Enter
sleep 0.08

if [[ "$kind" == "HEADER" && -n "$line" ]]; then
    tmux send-keys -t "$target" -l ":$line"
    tmux send-keys -t "$target" Enter
elif [[ "$kind" == "SEARCH" && -n "$text" ]]; then
    pat=${text//\\/\\\\}
    pat=${pat//\//\\/}
    tmux send-keys -t "$target" -l "/\\V$pat"
    tmux send-keys -t "$target" Enter
fi

sleep 0.05
tmux send-keys -t "$target" -l "zz"
tmux select-window -t "$target"
