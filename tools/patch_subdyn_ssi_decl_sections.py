# -*- coding: utf-8 -*-
"""Insert ! Passed variables / ! Local variables after each procedure signature in SubDyn_SSI.f90 (CONTAINS only)."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "modules" / "subdyn" / "src" / "SubDyn_SSI.f90"

PASSED_MARK = "   ! Passed variables\n"
LOCAL_MARK = "   ! Local variables\n"


def strip_f90_comment(line: str) -> str:
    if "!" not in line:
        return line.rstrip("\n")
    return line.split("!", 1)[0].rstrip("\n")


def is_proc_start(line: str) -> bool:
    s = line.strip()
    if not s or s.startswith("!"):
        return False
    if re.match(r"END\s+SUBROUTINE\b", s, re.I) or re.match(r"END\s+FUNCTION\b", s, re.I):
        return False
    up = s.upper()
    if "SUBROUTINE" in up and "(" in s:
        return True
    if "FUNCTION" in up and "(" in s:
        return True
    return False


def find_signature_end(lines: list[str], start: int) -> int:
    j = start
    while j < len(lines):
        code = strip_f90_comment(lines[j])
        if ")" in code:
            return j
        j += 1
    return start


def classify_line(line: str) -> str:
    raw = line.rstrip("\n")
    s = raw.strip()
    if not s:
        return "blank"
    if s.startswith("!"):
        return "comment"

    code = strip_f90_comment(raw).strip()
    if not code:
        return "comment"

    if re.match(r"END\s+SUBROUTINE\b", code, re.I) or re.match(r"END\s+FUNCTION\b", code, re.I):
        return "endproc"

    exec_prefixes = (
        "IF (",
        "IF(",
        "ELSEIF",
        "ELSE",
        "END IF",
        "DO ",
        "DO\t",
        "END DO",
        "SELECT ",
        "CASE ",
        "END SELECT",
        "CALL ",
        "RETURN",
        "CYCLE",
        "EXIT",
        "GO TO",
        "GOTO",
        "WRITE(",
        "WRITE ",
        "READ(",
        "READ ",
        "OPEN(",
        "OPEN ",
        "CLOSE(",
        "CLOSE ",
        "ALLOCATE(",
        "DEALLOCATE(",
        "NULLIFY(",
        "WHERE(",
        "FORALL(",
    )
    cu = code.upper()
    for p in exec_prefixes:
        if cu.startswith(p.upper()):
            return "exec"

    decl_starts = (
        "INTEGER",
        "REAL",
        "LOGICAL",
        "CHARACTER",
        "TYPE(",
        "COMPLEX",
        "DOUBLE PRECISION",
    )
    for d in decl_starts:
        if cu.startswith(d):
            if "INTENT(" in cu:
                return "passed"
            return "local"

    # assignment / executable without leading keyword
    if "::" not in code and "=" in code:
        return "exec"

    return "exec"


def process(text: str) -> str:
    lines = text.splitlines(keepends=True)
    try:
        cidx = next(i for i, ln in enumerate(lines) if ln.strip().upper() == "CONTAINS")
    except StopIteration:
        return text

    i = cidx + 1
    out: list[str] = lines[: i]

    while i < len(lines):
        ln = lines[i]
        if ln.strip().upper().startswith("END MODULE"):
            out.extend(lines[i:])
            break

        if is_proc_start(ln):
            se = find_signature_end(lines, i)
            out.extend(lines[i : se + 1])
            i = se + 1

            while i < len(lines) and classify_line(lines[i]) in ("blank", "comment"):
                out.append(lines[i])
                i += 1

            if i < len(lines) and lines[i].lstrip().startswith("! Passed variables"):
                while i < len(lines):
                    if is_proc_start(lines[i]):
                        break
                    if lines[i].strip().upper().startswith("END MODULE"):
                        out.extend(lines[i:])
                        return "".join(out)
                    out.append(lines[i])
                    i += 1
                continue

            out.append(PASSED_MARK)
            local_mark = False
            while i < len(lines):
                cl = classify_line(lines[i])
                if cl == "endproc":
                    if not local_mark:
                        out.append(LOCAL_MARK)
                        local_mark = True
                    out.append(lines[i])
                    i += 1
                    break
                if cl == "passed":
                    out.append(lines[i])
                    i += 1
                    continue
                if cl in ("blank", "comment"):
                    out.append(lines[i])
                    i += 1
                    continue
                if cl == "local":
                    if not local_mark:
                        out.append(LOCAL_MARK)
                        local_mark = True
                    out.append(lines[i])
                    i += 1
                    continue
                # exec
                if not local_mark:
                    out.append(LOCAL_MARK)
                    local_mark = True
                break
            continue

        out.append(ln)
        i += 1

    return "".join(out)


def main() -> int:
    text = PATH.read_text(encoding="utf-8", errors="replace")
    new = process(text)
    if new == text:
        print("No changes.")
        return 1
    PATH.write_text(new, encoding="utf-8", newline="\n")
    print("Updated", PATH)
    return 0


if __name__ == "__main__":
    sys.exit(main())
