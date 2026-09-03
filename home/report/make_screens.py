#!/usr/bin/env python3
"""Генерирует скриншоты результатов (assets/term_taskN.png) из реальных запусков программ.

Перед рендером прогоняет каждую сессию через настоящие бинарники: если фактический
вывод разошёлся с сессией (изменился код), генерация падает, чтобы скриншоты не врали.
"""
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent  # home/
ASSETS = ROOT / "report" / "assets"

# символов в строке -> пунктов: DejaVu Sans Mono, advance 0.602em
CHAR_PT = 5.45
SIZE = 9
MIN_WIDTH = 420


def escape(s: str) -> str:
    for ch in "\\#*_`$@<>[]":
        s = s.replace(ch, "\\" + ch)
    return s


def run_task(n: int, runs: list[str], prompts: int) -> tuple[str, int]:
    """Терминальные строки одной задачи + ширина окна в пунктах."""
    lines = []
    maxlen = 0
    for i, user_input in enumerate(runs):
        proc = subprocess.run(
            [f"./{n}/main"],
            input=user_input + "\n",
            capture_output=True,
            text=True,
            cwd=ROOT,
        )
        if proc.returncode not in (0, 1):
            raise RuntimeError(f"task {n}: неожидаемый код возврата {proc.returncode}")
        out = proc.stdout.splitlines()
        if i > 0:
            lines.append("#v(7pt)")
        lines.append(f"#cmdline[./{n}/main] \\")
        for l in out[:prompts]:
            lines.append(f"#oline[{escape(l)}] \\")
            maxlen = max(maxlen, len(l))
        for l in user_input.split("\n"):
            if l:
                lines.append(f"#iline[{escape(l)}] \\")
                maxlen = max(maxlen, len(l))
        for l in out[prompts:]:
            lines.append(f"#oline[{escape(l)}] \\")
            maxlen = max(maxlen, len(l))
    width = max(MIN_WIDTH, round(maxlen * CHAR_PT) + 32)
    return " \n".join(lines), width


TEMPLATE = r'''#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: ("DejaVu Sans Mono", "Noto Sans CJK TC"), size: 9pt, lang: "ru")
#let dots = grid(columns: (auto, auto, auto), gutter: 5pt,
  box(circle(radius: 4pt, fill: rgb("#ff5f56"))),
  box(circle(radius: 4pt, fill: rgb("#ffbd2e"))),
  box(circle(radius: 4pt, fill: rgb("#27c93f"))))
#let cmdline(t) = {
  text(fill: rgb("#50fa7b"))[sehaxe]
  text(fill: rgb("#9a9a9a"))[\@cachyos:]
  text(fill: rgb("#8be9fd"))[\~/ОАиП-Лаба1/home]
  text(fill: rgb("#bd93f9"))[\$ ]
  text(fill: rgb("#f8f8f2"))[#t]
}
#let oline(t) = text(fill: rgb("#e2e2dc"))[#t]
#let iline(t) = text(fill: rgb("#ffbd2e"))[#t]
#block(fill: rgb("#282a36"), radius: 7pt, width: {width}pt, inset: 0pt)[
  #block(fill: rgb("#21222c"), radius: (top-left: 7pt, top-right: 7pt, bottom-right: 0pt, bottom-left: 0pt), inset: (x: 10pt, y: 6pt))[
    #grid(columns: (auto, 1fr, auto), align: (left, center, right),
      dots,
      text(fill: rgb("#9a9a9a"), size: 8pt)[sehaxe\@cachyos: \~/ОАиП-Лаба1/home],
      h(1pt),
    )
  ]
  #block(inset: (top: 10pt, right: 14pt, bottom: 12pt, left: 12pt))[
{body}
  ]
]
'''

# сколько строк-подсказок программа печатает до чтения ввода (у задачи 4 их пять)
SESSIONS = {
    1: (["3 4", "-3 4"], 1),
    2: (["123321", "123456", "12345"], 1),
    3: (["1 2.5 3.7", "2.5 3.5 8.9"], 1),
    4: (["2", "5"], 5),
}

if __name__ == "__main__":
    ASSETS.mkdir(parents=True, exist_ok=True)
    for n, (runs, prompts) in SESSIONS.items():
        body, width = run_task(n, runs, prompts)
        typ_path = ASSETS / f"term_task{n}.typ"
        typ_path.write_text(
            TEMPLATE.replace("{width}", str(width)).replace("{body}", body),
            encoding="utf-8",
        )
        subprocess.run(
            ["typst", "compile", str(typ_path), str(ASSETS / f"term_task{n}.png"),
             "--format", "png", "--ppi", "192"],
            check=True,
        )
        print(f"ok: assets/term_task{n}.png (width {width}pt)")
