# -*- coding: utf-8 -*-
# Restore DriveCodeJckDesign.m from configurable GBK reference into modules/ (UTF-8 output).
from __future__ import annotations

from pathlib import Path


def split_code_comment(line: str) -> tuple[str, str]:
    s = line.rstrip("\n\r")
    i, n = 0, len(s)
    in_string = False
    while i < n:
        ch = s[i]
        if ch == "'":
            if in_string and i + 1 < n and s[i + 1] == "'":
                i += 2
                continue
            in_string = not in_string
            i += 1
            continue
        if ch == "%" and not in_string:
            return s[:i].rstrip(), s[i + 1 :].strip()
        i += 1
    return s.rstrip(), ""


def norm_key(code: str) -> str:
    return "".join(code.split())


def leading_ws(line: str) -> str:
    return line[: len(line) - len(line.lstrip())]


REPO_ROOT = Path(__file__).resolve().parents[1]
CONFIG_PATH = Path(__file__).with_name("jacket_paths.properties")
DEFAULT_REF_PATH = REPO_ROOT / "modules" / "DriveCodeJckDesign.m"
REF_PATH = DEFAULT_REF_PATH
DST_PATH = REPO_ROOT / "modules" / "DriveCodeJckDesign.m"


def load_kv_config(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    out: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if (not line) or line.startswith("#") or ("=" not in line):
            continue
        key, value = line.split("=", 1)
        out[key.strip()] = value.strip()
    return out

HEADER_TAIL = (
    "function DriveCodeJckDesign(inputFile)\n"
    "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
    "% \u4e3b\u7a0b\u5e8f: DriveCodeJckDesign.m\uff08\u6d77\u4e0a\u98ce\u673a\u5bfc\u7ba1\u67b6\u8bbe\u8ba1\uff09\n"
    "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
    "clc;\n"
    "projRoot = fileparts(mfilename('fullpath'));\n"
    "%% \u8bfb\u53d6\u6570\u636e\u5e76\u5c06\u76f8\u5173\u53d8\u91cf\u521d\u59cb\u5316\n"
    "if nargin < 1 || isempty(inputFile)\n"
    "    inputFile = fullfile(projRoot, 'inputdata.dat');\n"
    "end\n"
    "if exist(inputFile, 'file') ~= 2\n"
    "    error('DriveCodeJckDesign: \u672a\u627e\u5230\u8f93\u5165\u6587\u4ef6: %s', inputFile);\n"
    "end\n"
    "fileName = inputFile;\n"
    "dataStruct = readData(fileName);\n"
    "% \u63d0\u53d6\u9700\u8981\u7684\u6570\u636e\n"
    "global Hydro;\n"
    "global Wave;\n"
    "global Current;\n"
    "%%\u521d\u59cb\u5316\u76f8\u5173\u53d8\u91cf%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
    "% \u98ce\u901f\u573a\u76f8\u5173\u53c2\u6570"
)

STEP10_BLOCK_COMMENT = (
    "% Step 10: \u5bfc\u51fa\u5bfc\u7ba1\u67b6\u6746\u4ef6\u4e0e\u8282\u70b9\u6570\u636e"
    "\uff08\u4f9b\u4e09\u7ef4\u5efa\u6a21\uff1a\u5c40\u90e8 y/z \u5e73\u9762\uff0c\u6ce5\u9762 z=0\uff09"
)


def main() -> None:
    cfg = load_kv_config(CONFIG_PATH)
    ref_path = Path(cfg.get("REF_PATH", str(DEFAULT_REF_PATH))).expanduser()
    if not ref_path.exists():
        raise FileNotFoundError(
            "Reference file not found. Set REF_PATH in tools/jacket_paths.properties "
            f"or place source file at {DEFAULT_REF_PATH}"
        )
    dst_path = DST_PATH
    dst_path.parent.mkdir(parents=True, exist_ok=True)

    text_ref = ref_path.read_text(encoding="gbk")
    text_dst = dst_path.read_text(encoding="utf-8")
    ref_lines = text_ref.splitlines()
    dst_lines = text_dst.splitlines()

    anchor = norm_key("k_weibull = dataStruct.k_weibull;")
    ir = next(i for i, ln in enumerate(ref_lines) if norm_key(split_code_comment(ln)[0]) == anchor)
    il = next(i for i, ln in enumerate(dst_lines) if norm_key(split_code_comment(ln)[0]) == anchor)
    offset = il - ir

    out: list[str] = []
    out.extend(HEADER_TAIL.splitlines())

    step10_enter = "\u7a0b\u5e8f\u8fdb\u5165"
    step10_done_tail = "\u5df2\u5b8c\u6210"

    for i in range(il, len(dst_lines)):
        raw = dst_lines[i]
        ws = leading_ws(raw)
        j = i - offset

        if j >= len(ref_lines):
            if "% Step 10" in raw and raw.strip().startswith("%"):
                out.append(ws + STEP10_BLOCK_COMMENT)
                continue
            if "fprintf(" in raw and "Step 10" in raw and step10_enter not in raw:
                out.append(ws + "fprintf('\u7a0b\u5e8f\u8fdb\u5165\"Step 10: \u5bfc\u51fa\u51e0\u4f55\u6570\u636e\":\\n');")
                continue
            if "fprintf(" in raw and "Step 10" in raw and step10_done_tail in raw:
                out.append(
                    ws + "fprintf('\"Step 10: \u5bfc\u51fa\u51e0\u4f55\u6570\u636e\"\u5df2\u5b8c\u6210;\\n\\n');"
                )
                continue
            out.append(raw)
            continue

        out.append(ws + ref_lines[j].lstrip())

    dst_path.write_text("\n".join(out) + "\n", encoding="utf-8")
    print("Reference", ref_path)
    print("Wrote", dst_path)
    print("Anchor ref line", ir + 1, "local line", il + 1, "offset", offset)


if __name__ == "__main__":
    main()
