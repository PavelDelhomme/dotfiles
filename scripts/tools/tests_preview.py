#!/usr/bin/env python3
"""Génère docs/TESTS.preview.html — boutons copier pour blocs bash de TESTS.md."""

from __future__ import annotations

import html
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TESTS_MD = ROOT / "docs" / "TESTS.md"
OUT_HTML = ROOT / "docs" / "TESTS.preview.html"


def esc(text: str) -> str:
    return html.escape(text, quote=True)


def parse_steps(content: str) -> list[dict]:
    steps: list[dict] = []
    step_id = ""
    step_title = ""
    in_bash = False
    bash_lines: list[str] = []

    for line in content.splitlines():
        m = re.match(r"^### Étape ([^—]+) — (.+)$", line)
        if m:
            if step_id and bash_lines:
                steps.append(
                    {
                        "id": step_id.strip(),
                        "title": step_title.strip(),
                        "lines": bash_lines[:],
                    }
                )
            step_id = m.group(1).strip()
            step_title = m.group(2).strip()
            bash_lines = []
            in_bash = False
            continue
        trimmed = line.lstrip()
        if in_bash:
            if trimmed == "```":
                in_bash = False
            else:
                bash_lines.append(line)
            continue
        if trimmed.startswith("```bash"):
            in_bash = True

    if step_id and bash_lines:
        steps.append({"id": step_id, "title": step_title, "lines": bash_lines})
    return steps


def render_html(steps: list[dict], source: Path) -> str:
    blocks = []
    for step in steps:
        full = "\n".join(step["lines"])
        line_buttons = []
        for i, ln in enumerate(step["lines"], 1):
            line_buttons.append(
                f'<button type="button" class="copy" data-copy="{esc(ln)}" '
                f'title="Ligne {i}">L{i}</button>'
            )
        blocks.append(
            f"""
<section class="step" id="{esc(step['id'])}">
  <h2>{esc(step['id'])} — {esc(step['title'])}</h2>
  <div class="toolbar">
    <button type="button" class="copy primary" data-copy="{esc(full)}">📋 Bloc complet</button>
    <span class="lines">Lignes : {' '.join(line_buttons)}</span>
  </div>
  <pre><code>{esc(full)}</code></pre>
  <p class="cli">CLI : <code>make tests-copy STEP={esc(step['id'])}</code>
  · ligne n : <code>make tests-copy STEP={esc(step['id'])} LINE=n</code></p>
</section>"""
        )

    body = "\n".join(blocks)
    return f"""<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8">
  <title>TESTS.md — copie presse-papiers</title>
  <style>
    body {{ font-family: system-ui, sans-serif; max-width: 960px; margin: 2rem auto; padding: 0 1rem; }}
    h1 {{ font-size: 1.4rem; }}
    .step {{ border: 1px solid #ccc; border-radius: 8px; padding: 1rem; margin: 1.5rem 0; }}
    pre {{ background: #f6f8fa; padding: 1rem; overflow-x: auto; border-radius: 6px; }}
    button.copy {{ cursor: pointer; margin: 0.15rem; padding: 0.35rem 0.55rem; border-radius: 4px; border: 1px solid #888; background: #fff; }}
    button.copy.primary {{ background: #e8f4ff; font-weight: 600; }}
    button.copy.ok {{ background: #d4edda; border-color: #28a745; }}
    .cli {{ font-size: 0.9rem; color: #444; }}
    #toast {{ position: fixed; bottom: 1rem; right: 1rem; background: #222; color: #fff; padding: 0.6rem 1rem; border-radius: 6px; display: none; }}
  </style>
</head>
<body>
  <h1>Copie commandes — {esc(source.name)}</h1>
  <p>Généré depuis <code>{esc(str(source))}</code>. Ouvrir avec <code>make tests-preview</code> puis un navigateur.</p>
  <nav><strong>Étapes :</strong> {' · '.join(f'<a href="#{esc(s["id"])}">{esc(s["id"])}</a>' for s in steps)}</nav>
  {body}
  <div id="toast">Copié</div>
  <script>
    const toast = document.getElementById('toast');
    function showToast() {{
      toast.style.display = 'block';
      setTimeout(() => {{ toast.style.display = 'none'; }}, 1200);
    }}
    document.querySelectorAll('button.copy').forEach(btn => {{
      btn.addEventListener('click', async () => {{
        const text = btn.getAttribute('data-copy');
        try {{
          await navigator.clipboard.writeText(text);
          btn.classList.add('ok');
          setTimeout(() => btn.classList.remove('ok'), 800);
          showToast();
        }} catch (e) {{
          alert('Copie impossible : ' + e);
        }}
      }});
    }});
  </script>
</body>
</html>
"""


def main() -> int:
    md = TESTS_MD if len(sys.argv) < 2 else Path(sys.argv[1])
    out = OUT_HTML if len(sys.argv) < 3 else Path(sys.argv[2])
    content = md.read_text(encoding="utf-8")
    steps = parse_steps(content)
    out.write_text(render_html(steps, md), encoding="utf-8")
    print(f"Écrit : {out} ({len(steps)} étapes avec bloc bash)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
