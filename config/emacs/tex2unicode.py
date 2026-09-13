#!/usr/bin/env python3
"""Batch LaTeX -> unicode converter for org TTY math preview.

Reads a JSON array of LaTeX strings on stdin, writes a JSON array of
unicode strings on stdout.  Pre-processes \\frac/\\sqrt for grouping
(pylatexenc renders them as `a/b` and `\u221ax` without parentheses), then
delegates the rest to pylatexenc.

Installed by bootstrap.yaml into ~/.local/share/tex2unicode and invoked by
`org-unicode-math-render' in ~/.spacemacs.
"""
import json
import re
import sys

from pylatexenc.latex2text import LatexNodes2Text

L2T = LatexNodes2Text(math_mode="text")


def read_group(s, i):
    """s[i] == '{'; return (contents, index just past matching '}')."""
    depth = 0
    j = i
    while j < len(s):
        if s[j] == "{":
            depth += 1
        elif s[j] == "}":
            depth -= 1
            if depth == 0:
                return s[i + 1 : j], j + 1
        j += 1
    return s[i + 1 :], len(s)


FRAC = ("\\frac", "\\dfrac", "\\tfrac", "\\cfrac")


def convert_latex(s):
    out = []
    i = 0
    n = len(s)
    while i < n:
        cmd = next((c for c in FRAC if s.startswith(c, i)), None)
        if cmd:
            j = i + len(cmd)
            while j < n and s[j] == " ":
                j += 1
            if j < n and s[j] == "{":
                num, j = read_group(s, j)
                while j < n and s[j] == " ":
                    j += 1
                if j < n and s[j] == "{":
                    den, j = read_group(s, j)
                    out.append("(" + convert_latex(num) + ")/("
                               + convert_latex(den) + ")")
                    i = j
                    continue
        if s.startswith("\\sqrt", i):
            j = i + 5
            index = None
            while j < n and s[j] == " ":
                j += 1
            if j < n and s[j] == "[":
                k = s.find("]", j)
                if k != -1:
                    index, j = s[j + 1 : k], k + 1
            while j < n and s[j] == " ":
                j += 1
            if j < n and s[j] == "{":
                rad, j = read_group(s, j)
                inner = convert_latex(rad)
                if index:
                    out.append("(" + inner + ")^(1/"
                               + convert_latex(index) + ")")
                else:
                    out.append("\u221a(" + inner + ")")
                i = j
                continue
        out.append(s[i])
        i += 1
    return "".join(out)


def convert(s):
    s = s.strip()
    s = re.sub(r"^\$+|\$+$", "", s)          # strip $ / $$ delimiters
    s = re.sub(r"^\\\[|\\\]$", "", s)
    s = re.sub(r"^\\\(|\\\)$", "", s)
    try:
        return L2T.latex_to_text(convert_latex(s)).strip()
    except Exception:
        return s


def main():
    data = json.load(sys.stdin)
    json.dump([convert(x) if isinstance(x, str) else "" for x in data],
              sys.stdout, ensure_ascii=False)


if __name__ == "__main__":
    main()
