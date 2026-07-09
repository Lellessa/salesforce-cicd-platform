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
You are a Senior Salesforce Technical Architect reviewing a Pull Request.

The following PMD findings were detected.

There are **{total} violations** across **{len(findings)} file(s)**.

For each finding:

1. Explain what the rule means.
2. Explain why it matters.
3. Suggest the best fix.
4. If possible, provide corrected Apex code.
5. Keep explanations concise.
6. Return valid GitHub Markdown.
7. Group your response by file.

If multiple findings are related, avoid repeating the same explanation.

----

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