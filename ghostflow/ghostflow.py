#!/usr/bin/env python3
"""ghostflow — блок-схемы по ГОСТ из простого текста.

Формат схемы (построчный, как markdown; «начало» и «конец» добавляются сами):

    # комментарий
    ввод scanf("%d", &a)              # параллелограмм (ввод)
    b = a / 100000 + ...              # прямоугольник (действие)
    вывод printf("Гипотенуза...")     # параллелограмм (вывод)
    если a < 100000 || a > 999999     # ромб; ниже ветки с отступом (4 пробела)
        да: printf("Ошибка...")       # одна плитка на ветку
        нет:                          # пустая ветка = подпись на основной линии
    если switch (status)              # веток может быть сколько угодно
        1: printf("Декабрь...")
        иначе: printf("Как ты сюда попал...")
        да -> конец: printf(...)      # ветка уходит напрямую в конец

Условие ромба автоматически оформляется как «if (...)»
(кроме случаев, когда оно уже начинается с if/switch).
Длинные подписи можно сокращать и заканчивать троеточием.

Использование:
    python ghostflow.py схема.txt результат.png
или из python:
    import ghostflow
    ghostflow.render(open("схема.txt").read(), "результат.png")

Зависимости: matplotlib.
"""
import re
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch, Polygon, Rectangle

# ---------- геометрия и типографика ----------

CHAR_W = 7.3      # ширина символа моношрифта при кегле FONT (DejaVu: 0.61em)
FONT = 12.0       # базовый кегль
PAD_X = 18.0      # поля текста внутри фигуры (суммарно по горизонтали)
PAD_Y = 14.0      # поля текста внутри фигуры (суммарно по вертикали)
LINE_H = 15.0     # высота строки текста
VGAP = 34.0       # вертикальный зазор между блоками
HGAP = 42.0       # зазор между ромбом и колонкой веток
STUB = 12.0       # горизонтальный вход в плитку ветки
RAIL_OFF = 14.0   # отступ вертикальной рельсы слияния от плиток
TERM_ROUND = 14.0 # скругление углов начала/конца
A4_W = 468.0      # рабочая ширина A4 вертикально (165 мм в пунктах)
A4_H = 700.0      # рабочая высота A4 вертикально (247 мм в пунктах)
DPI = 200
EDGE_LW = 1.1


class ParseError(Exception):
    pass


class Block:
    def __init__(self, kind, text, branches=None):
        self.kind = kind                  # term | io | act | if
        self.text = text
        self.branches = branches or []    # [(метка, текст|None, to_end)]


# ---------- разбор формата ----------

def parse(text):
    """Текст схемы -> список блоков (начало/конец добавляются автоматически)."""
    lines = []
    for lineno, line in enumerate(text.splitlines(), 1):
        body = re.sub(r"#.*$", "", line).rstrip()
        if not body.strip():
            continue
        lines.append((lineno, body))

    blocks = [Block("term", "начало")]
    i = 0
    while i < len(lines):
        lineno, line = lines[i]
        stripped = line.strip()
        indent = len(line) - len(line.lstrip())
        if indent >= 4:
            raise ParseError(f"строка {lineno}: отступ допустим только внутри «если»")
        if stripped.startswith("если "):
            cond = stripped[5:].strip()
            branches = []
            j = i + 1
            while j < len(lines):
                jline = lines[j][1]
                jindent = len(jline) - len(jline.lstrip())
                if jindent < 4:
                    break
                m1 = re.match(r"(.+?)\s*->\s*конец\s*:\s*(.*)$", jline.strip())
                m2 = re.match(r"(.+?)\s*:\s*(.*)$", jline.strip())
                if m1:
                    label, to_end, btext = m1.group(1).strip(), True, m1.group(2).strip()
                elif m2:
                    label, to_end, btext = m2.group(1).strip(), False, m2.group(2).strip()
                else:
                    raise ParseError(
                        f"строка {lines[j][0]}: ветка должна быть вида «метка: текст»")
                if btext.endswith("-> конец"):
                    btext = btext[:-len("-> конец")].rstrip()
                    to_end = True
                branches.append((label, btext if btext else None, to_end))
                j += 1
            if not branches:
                raise ParseError(f"строка {lineno}: у «если» нет ни одной ветки")
            blocks.append(Block("if", cond, branches))
            i = j
            continue
        if stripped.startswith("ввод "):
            blocks.append(Block("io", stripped[5:].strip()))
        elif stripped.startswith("вывод "):
            blocks.append(Block("io", stripped[6:].strip()))
        elif stripped.startswith("действие "):
            blocks.append(Block("act", stripped[9:].strip()))
        else:
            blocks.append(Block("act", stripped))
        i += 1
    blocks.append(Block("term", "конец"))
    return blocks


# ---------- измерение и раскладка ----------

def lines_of(text):
    return text.split("\n")


def btype(text):
    t = text.strip()
    if re.match(r"^(printf|вывод)\b", t) and "return" not in t:
        return "io"
    return "act"


def cond_text(cond):
    cond = cond.strip()
    if re.match(r"^(if|switch)\b", cond):
        return cond
    return f"if ({cond})"


def measure(kind, text):
    """(ширина, высота) фигуры по тексту."""
    ls = text.split("\n")
    w = max(len(l) for l in ls) * CHAR_W + PAD_X
    h = len(ls) * LINE_H + PAD_Y
    if kind == "term":
        return max(w, 76.0), max(h * 0.8, 34.0)
    if kind == "if":
        return max(w * 1.1, 150.0), h + LINE_H
    return w, h


def layout(blocks):
    """Схема -> (фигуры, рёбра, подписи, (minx, miny, width, height)) в пунктах.

    Фигура: dict(kind, cx, cy, w, h, lines)
    Ребро:  dict(points=[(x, y), ...])  — ломаная, все сегменты под углами 90°,
            стрелка ставится в конце (последняя точка).
    Подпись: dict(x, y, text, ha) — «да»/«нет»/номер ветви.
    Все рёбра выходят из вершин фигур (N/S/E/W).
    """
    shapes = []   # все фигуры
    edges = []    # ломаные рёбер
    elabels = []  # подписи ветвей
    pending = []  # плитки веток, ждущие следующего основного узла
    to_left = []  # плитки веток «-> конец» (уходят в конец по левой рельсе)

    sizes = [measure(b.kind, b.text) for b in blocks]

    def add(kind, cx, cy, text):
        w, h = measure(kind, text)
        sh = dict(kind=kind, cx=cx, cy=cy, w=w, h=h, lines=lines_of(text))
        shapes.append(sh)
        return sh

    # начало
    y = sizes[0][1] / 2
    add(blocks[0].kind, 0.0, y, blocks[0].text)
    prev_exit = (0.0, sizes[0][1])
    cursor = sizes[0][1]

    # основной поток (без конечного «конца» — он замыкает рельсы веток)
    for i in range(1, len(blocks) - 1):
        b = blocks[i]
        w, h = sizes[i]
        if b.kind != "if":
            cy = cursor + VGAP + h / 2
            shape = add(b.kind, 0.0, cy, b.text)
            edges.append(dict(points=[prev_exit, (0.0, cy - h / 2)]))
            for pb in pending:
                sh = pb["shape"]
                pts = [(sh["cx"], sh["cy"] + sh["h"] / 2),
                       (pb["rail"], sh["cy"] + sh["h"] / 2),
                       (pb["rail"], cy),
                       (shape["cx"] + shape["w"] / 2, cy)]
                edges.append(dict(points=pts))
            pending = []
            prev_exit = (0.0, cy + h / 2)
            cursor = cy + h / 2
            continue

        # ---------- ромб «если» ----------
        dtext = cond_text(b.text)
        dw, dh = measure("if", dtext)
        cy = cursor + VGAP + dh / 2
        dmd = add("if", 0.0, cy, dtext)
        edges.append(dict(points=[prev_exit, (0.0, cy - dh / 2)]))
        prev_exit = (0.0, cy + dh / 2)
        empty_label = next((lbl for lbl, bt, _te in b.branches if not bt), None)
        if empty_label:
            elabels.append(dict(x=14.0, y=cy + dh / 2 + 14.0, text=empty_label,
                                ha="left"))

        # единый размер плиток веток этой схемы
        bw = bh = 0.0
        for label, btext, to_end in b.branches:
            if btext:
                w2, h2 = measure(btype(btext), btext)
                bw, bh = max(bw, w2), max(bh, h2)
        railr = dmd["w"] / 2 + 14.0   # рельса распределения справа
        raill = -dmd["w"] / 2 - 14.0  # рельса слева (для «-> конец»)
        colx = railr + STUB + bw / 2

        last_bottom = cy + dh / 2
        for bi, (label, btext, to_end) in enumerate(b.branches):
            by = cy + bi * (bh + VGAP)
            last_bottom = max(last_bottom, by + bh / 2)
            if not btext:
                continue
            bt = Block(btype(btext), btext)
            w2, h2 = measure(bt.kind, bt.text)
            if to_end:
                bcx = raill - STUB - bw / 2
                shape = add(bt.kind, bcx, by, bt.text)
                to_left.append(dict(shape=shape, railL=raill))
                pts = [(-dmd["w"] / 2, cy)]
                if by != cy:
                    pts += [(raill, cy), (raill, by)]
                pts += [(bcx + bw / 2, by)]
                edges.append(dict(points=pts))
                elabels.append(dict(x=-dmd["w"] / 2 - 10.0, y=cy - 12.0,
                                    text=label, ha="right"))
            else:
                bcx = railr + STUB + bw / 2
                shape = add(bt.kind, bcx, by, bt.text)
                pending.append(dict(shape=shape, rail=railr))
                pts = [(dmd["w"] / 2, cy)]
                if by != cy:
                    pts += [(railr, cy), (railr, by)]
                pts += [(bcx - bw / 2, by)]
                edges.append(dict(points=pts))
                if by == cy:
                    elabels.append(dict(x=dmd["w"] / 2 + 10.0, y=cy - 12.0,
                                        text=label, ha="left"))
                else:
                    elabels.append(dict(x=bcx - bw / 2 - 10.0, y=by - 12.0,
                                        text=label, ha="right"))
        cursor = last_bottom

    def ex_of(dmd_shape):
        return dmd_shape["w"] / 2

    # конец: замыкаем основной поток и все рельсы
    stop_h = sizes[-1][1]
    cy_stop = cursor + VGAP + stop_h / 2
    stop = add(blocks[-1].kind, 0.0, cy_stop, blocks[-1].text)
    edges.append(dict(points=[prev_exit, (0.0, cy_stop - stop_h / 2)]))
    stop_e = stop["cx"] + stop["w"] / 2
    stop_w = stop["cx"] - stop["w"] / 2
    for pb in pending:
        sh = pb["shape"]
        pts = [(sh["cx"], sh["cy"] + sh["h"] / 2),
               (pb["rail"], sh["cy"] + sh["h"] / 2),
               (pb["rail"], cy_stop),
               (stop_e, cy_stop)]
        edges.append(dict(points=pts))
    for b in to_left:
        pts = [(b["shape"]["cx"], b["shape"]["cy"] + b["shape"]["h"] / 2),
               (b["railL"], b["shape"]["cy"] + b["shape"]["h"] / 2),
               (b["railL"], cy_stop),
               (stop_w, cy_stop)]
        edges.append(dict(points=pts))

    # границы
    allx = ([p[0] for e in edges for p in e["points"]] +
            [l["x"] for l in elabels])
    allxs = ([s["cx"] + s["w"] / 2 for s in shapes] +
             [s["cx"] - s["w"] / 2 for s in shapes])
    allx += allxs
    ally = ([p[1] for e in edges for p in e["points"]] +
            [l["y"] for l in elabels] +
            [s["cy"] + s["h"] / 2 for s in shapes] +
            [s["cy"] - s["h"] / 2 for s in shapes])
    pad = 12.0
    minx, miny = min(allx) - pad, min(ally) - pad
    return shapes, edges, elabels, (minx, miny,
                                    max(allx) - minx + 2 * pad,
                                    max(ally) - miny + 2 * pad)


# ---------- рендер ----------

def _draw_shape(ax, sh, sx, sy, ox, oy, fs):
    X = lambda x: (x - ox) * sx
    Y = lambda y: (y - oy) * sy
    cx, cy = X(sh["cx"]), Y(sh["cy"])
    w, h = sh["w"] * sx, sh["h"] * sy
    k = sh["kind"]
    if k == "term":
        # начало/конец: прямоугольник со скруглёнными краями
        ax.add_patch(FancyBboxPatch(
            (cx - w / 2, cy - h / 2), w, h,
            boxstyle=f"round,pad=0,rounding_size={min(TERM_ROUND * sx, h / 2.4)}",
            mutation_aspect=1.0, fill=True, facecolor="white",
            edgecolor="black", lw=EDGE_LW))
    elif k == "io":
        skew = h * 0.3
        x0, y0, x1, y1 = cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2
        ax.add_patch(Polygon([(x0 + skew, y0), (x1, y0), (x1 - skew, y1), (x0, y1)],
                             closed=True, fill=True, facecolor="white",
                             edgecolor="black", lw=EDGE_LW))
    elif k == "if":
        ax.add_patch(Polygon([(cx - w / 2, cy), (cx, cy - h / 2),
                              (cx + w / 2, cy), (cx, cy + h / 2)],
                             closed=True, fill=True, facecolor="white",
                             edgecolor="black", lw=EDGE_LW))
    else:
        ax.add_patch(Rectangle((cx - w / 2, cy - h / 2), w, h, fill=True,
                               facecolor="white", edgecolor="black", lw=EDGE_LW))
    ax.text(cx, cy, "\n".join(sh["lines"]), ha="center", va="center",
            fontsize=fs, family="DejaVu Sans Mono", linespacing=1.25, color="black")


def _draw_edge(ax, e, sx, sy, ox, oy):
    X = lambda x: (x - ox) * sx
    Y = lambda y: (y - oy) * sy
    pts = [(X(x), Y(y)) for x, y in e["points"]]
    if len(pts) >= 3:
        xs, ys = zip(*pts[:-1])
        ax.plot(xs, ys, color="black", lw=EDGE_LW, solid_capstyle="projecting",
                solid_joinstyle="miter")
    a, bpt = pts[-2], pts[-1]
    ax.add_patch(FancyArrowPatch(a, bpt, arrowstyle="-|>", mutation_scale=14,
                                 color="black", lw=EDGE_LW, shrinkA=0, shrinkB=0))


def render(text, out_png, dpi=DPI):
    """Текст схемы -> PNG, вписанный в A4 вертикально (165×247 мм)."""
    blocks = parse(text)
    shapes, edges, elabels, (minx, miny, W, H) = layout(blocks)
    s = min(1.0, A4_W / W, A4_H / H)
    fig = plt.figure(figsize=(W * s / 72.0, H * s / 72.0), dpi=DPI)
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, W * s)
    ax.set_ylim(H * s, 0)
    ax.axis("off")

    def X(x):
        return (x - minx) * s

    def Y(y):
        return (y - miny) * s

    fs = FONT * s
    for sh in shapes:
        _draw_shape(ax, sh, s, s, minx, miny, fs)
    for e in edges:
        _draw_edge(ax, e, s, s, minx, miny)
    for l in elabels:
        ax.text(X(l["x"]), Y(l["y"]), l["text"], fontsize=max(7.0, fs * 0.8),
                family="DejaVu Sans", weight="bold", color="black",
                ha=l.get("ha", "left"), va="center")
    fig.savefig(out_png, dpi=DPI, facecolor="white")
    plt.close(fig)


def render_file(in_path, out_png):
    text = open(in_path, encoding="utf-8").read()
    try:
        render(text, out_png)
    except ParseError as e:
        print(f"ошибка схемы: {e}", file=sys.stderr)
        return 1
    return 0


def main(argv):
    if len(argv) != 3:
        print("использование: python ghostflow.py схема.txt результат.png")
        return 2
    return render_file(argv[1], argv[2])


if __name__ == "__main__":
    sys.exit(main(sys.argv))
