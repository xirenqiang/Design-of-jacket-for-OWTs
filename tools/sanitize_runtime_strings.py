from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1] / "modules"
TRIGGER_RE = re.compile(r"(disp\s*\(|fprintf\s*\(|error\s*\(|warning\s*\(|prompt\s*=)")
LITERAL_RE = re.compile(r"'([^']*)'")


def has_non_ascii(text: str) -> bool:
    return any(ord(ch) > 127 for ch in text)


def sanitize_literal(text: str, context: str, func_name: str) -> str:
    ascii_only = "".join(ch for ch in text if ord(ch) < 128)
    ascii_only = re.sub(r"\s+", " ", ascii_only).strip()
    if context == "prompt":
        return ascii_only if ascii_only else "Enter value: "
    if context == "fprintf":
        return ascii_only if ascii_only else "Runtime status message.\\n"
    if context == "disp":
        return ascii_only if ascii_only else "Runtime status message."
    if context == "warning":
        return ascii_only if ascii_only else f"{func_name}: runtime warning."
    if context == "error_id":
        return ascii_only if ascii_only else f"{func_name}:RuntimeError"
    if context == "error_msg":
        return ascii_only if ascii_only else "Runtime validation failed."
    return ascii_only if ascii_only else text


def sanitize_file(path: Path) -> bool:
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        try:
            text = path.read_text(encoding="gbk")
        except UnicodeDecodeError:
            text = path.read_text(encoding="latin-1")
    lines = text.splitlines(True)
    out: list[str] = []
    changed = False
    func_name = path.stem

    for line in lines:
        if (not TRIGGER_RE.search(line)) or (not has_non_ascii(line)):
            out.append(line)
            continue

        if "prompt" in line and "=" in line:
            context = "prompt"
        elif "fprintf" in line:
            context = "fprintf"
        elif "disp" in line:
            context = "disp"
        elif "warning" in line:
            context = "warning"
        elif "error" in line:
            context = "error"
        else:
            context = "other"

        literals = LITERAL_RE.findall(line)
        if not literals:
            out.append(line)
            continue

        index = 0

        def replacer(match: re.Match[str]) -> str:
            nonlocal index, changed
            literal = match.group(1)
            if not has_non_ascii(literal):
                index += 1
                return match.group(0)

            local_context = context
            if context == "error":
                local_context = "error_id" if index == 0 and ":" in literal else "error_msg"

            replacement = sanitize_literal(literal, local_context, func_name)
            index += 1
            changed = True
            return "'" + replacement.replace("'", "''") + "'"

        out.append(LITERAL_RE.sub(replacer, line))

    if changed:
        path.write_text("".join(out), encoding="utf-8")
    return changed


def main() -> None:
    count = 0
    for file_path in ROOT.glob("*.m"):
        if sanitize_file(file_path):
            count += 1
    print(count)


if __name__ == "__main__":
    main()
