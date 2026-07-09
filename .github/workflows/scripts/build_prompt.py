#!/usr/bin/env python3

from __future__ import annotations

import sys
import textwrap
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path

INPUT_FILE = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("pmd-report.xml")
OUTPUT_FILE = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("prompt.txt")

CONTEXT_LINES = 3


def strip_namespaces(root: ET.Element) -> None:
    """Remove XML namespaces to simplify XPath queries."""
    for elem in root.iter():
        if "}" in elem.tag:
            elem.tag = elem.tag.split("}", 1)[1]


def get_code_snippet(file_path: Path, line_number: int, context: int = CONTEXT_LINES) -> str:
    """Returns a few lines around the reported violation."""

    try:
        lines = file_path.read_text(encoding="utf-8").splitlines()

        start = max(0, line_number - context - 1)
        end = min(len(lines), line_number + context)

        snippet = []

        for i in range(start, end):
            marker = ">" if i + 1 == line_number else " "
            snippet.append(f"{marker} {i + 1:4}: {lines[i]}")

        return "\n".join(snippet)

    except Exception:
        return "(Unable to read source file.)"


def read_pmd_report(report: Path) -> dict[str, list[dict]]:
    """Reads the PMD XML report and groups findings by file."""

    tree = ET.parse(report)
    root = tree.getroot()

    strip_namespaces(root)

    findings = defaultdict(list)

    for file in root.findall("file"):
        filename = file.attrib["name"]

        for violation in file.findall("violation"):
            line = int(violation.attrib.get("beginline", "0"))

            findings[filename].append(
                {
                    "line": line,
                    "rule": violation.attrib.get("rule", "Unknown"),
                    "ruleset": violation.attrib.get("ruleset", "Unknown"),
                    "priority": violation.attrib.get("priority", "Unknown"),
                    "message": (violation.text or "").strip(),
                    "snippet": get_code_snippet(Path(filename), line),
                }
            )

    return findings


def build_prompt(findings: dict[str, list[dict]]) -> str:
    """Creates the prompt to send to the LLM."""

    if not findings:
        return "No PMD violations were found."

    sections = []

    total = sum(len(v) for v in findings.values())

    for filename, violations in findings.items():

        file_section = [
            f"# File\n{filename}\n"
        ]

        for index, violation in enumerate(violations, start=1):

            file_section.append(
                textwrap.dedent(
                    f"""
                    ## Finding {index}

                    **Line:** {violation["line"]}

                    **Rule:** {violation["rule"]}

                    **Ruleset:** {violation["ruleset"]}

                    **Priority:** {violation["priority"]}

                    **Message:**
                    {violation["message"]}

                    **Code**

                    ```apex
                    {violation["snippet"]}
                    ```
                    """
                ).strip()
            )

        sections.append("\n\n".join(file_section))

    return textwrap.dedent(
        f"""
## Objective
Analyze the PMD XML report and generate a Markdown review using the template below.

## Requirements
- Group findings by PMD rule (do not repeat the same rule).
- Count occurrences of each rule.
- Include all affected files and line numbers under "Locations".
- For each finding, provide:
  - Rule
  - Locations
  - Issue
  - Fix
- Include a minimal code example only when it helps explain the fix.
- Keep explanations concise (1–2 sentences).
- Do not invent code specific to the project; use generic Apex examples.
- Finish with a short list of recommendations.

## Formatting
- Wrap all file names, file paths, PMD rule names, class names, method names, variable names, and other code identifiers in inline code using single backticks (`...`).
- Do not use bold or plain text for code-related identifiers; always use inline code formatting.
- Reserve fenced code blocks (```...```) only for multi-line code examples.

## Response Format
# PMD Review

## Summary

| File | Issues |
|------|-------:|
| `<file>` | `<count>` |

---

## Findings

### <Rule Name> (<Count>)
**Rule:** `<Rule>`

**Locations:**
- `<file>`: Line(s) `<line(s)>`
- `<file>`: Line(s) `<line(s)>`

**Issue:**
<Brief explanation of why this is reported.>

**Fix:**
<Short description of how to resolve it.>

**Example (if applicable):**
```<language>
<Minimal code example>
```

---


{chr(10).join(sections)}
        """
    ).strip()


def main() -> None:

    if not INPUT_FILE.exists():
        raise FileNotFoundError(f"PMD report not found: {INPUT_FILE}")

    findings = read_pmd_report(INPUT_FILE)

    prompt = build_prompt(findings)

    OUTPUT_FILE.write_text(prompt, encoding="utf-8")

    total = sum(len(v) for v in findings.values())

    print(f"Generated prompt with {total} PMD violation(s).")
    print(f"Output written to: {OUTPUT_FILE}")


if __name__ == "__main__":
    main()