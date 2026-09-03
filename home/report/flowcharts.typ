// Блок-схемы для отчёта по лабораторной работе №1 (вариант 5).
// Все линии ортогональные (углы 90 градусов), фигуры одного типа имеют
// одинаковый размер, начало и конец: прямоугольники со скруглёнными углами.
// Внутри блоков помещён реальный код программ.
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: rect, diamond, parallelogram, hexagon

// Единые размеры фигур одного типа
#let TERM_W = 72pt
#let TERM_H = 24pt
#let RECT_W = 118pt
#let RECT_H = 36pt
#let PARL_W = 126pt
#let PARL_H = 40pt
#let HEX_W = 130pt
#let HEX_H = 36pt
#let DMD_W = 126pt
#let DMD_H = 54pt

#let lbl(t) = text(font: ("Liberation Serif", "DejaVu Sans Mono"), size: 8pt, fill: black, t)

#let term(pos, t) = node(pos, raw(t), shape: rect, width: TERM_W, height: TERM_H,
  corner-radius: 8pt, fill: white, stroke: 0.6pt + black, inset: 2pt)
#let box(pos, t) = node(pos, raw(t, block: true), shape: rect, width: RECT_W, height: RECT_H,
  fill: white, stroke: 0.6pt + black, inset: 3pt)
#let parl(pos, t) = node(pos, raw(t, block: true), shape: parallelogram.with(angle: 20deg),
  width: PARL_W, height: PARL_H, fill: white, stroke: 0.6pt + black, inset: 3pt)
#let hexa(pos, t) = node(pos, raw(t, block: true), shape: hexagon.with(angle: 30deg),
  width: HEX_W, height: HEX_H, fill: white, stroke: 0.6pt + black, inset: 2pt)
#let dmd(pos, t) = node(pos, raw(t, block: true), shape: diamond.with(fit: 0.7),
  width: DMD_W, height: DMD_H, fill: white, stroke: 0.6pt + black, inset: 2pt)

// Ортогональное ребро: все сегменты строго под углами 90 градусов
#let oedge(..args) = edge(..args, corner-radius: 0pt)

// ---------- Задача 1 ----------
#let flow1 = diagram(spacing: 8mm,
  term((245pt, -20pt), "начало"),
  parl((245pt, -76pt), "scanf(\"%f %f\", &a, &b)"),
  dmd((245pt, -148pt), "scanf(\"%f %f\",\n&a, &b) != 2\n|| a <= 0 || b <= 0"),
  box((70pt, -148pt), "printf(\"Ошибка ввода!\");\nreturn 1;"),
  hexa((245pt, -244pt), "printf(\"Гипотенуза:\n%.2f\", sqrt(a * a\n+ b * b));"),
  hexa((245pt, -300pt), "printf(\"Площадь: %.2f\",\na * b / 2);"),
  term((245pt, -356pt), "конец"),
  edge((245pt, -20pt), (245pt, -76pt), "-|>"),
  edge((245pt, -76pt), (245pt, -148pt), "-|>"),
  edge((245pt, -148pt), (95pt, -148pt), lbl[да], "-|>"),
  edge((245pt, -148pt), (245pt, -244pt), lbl[нет], "-|>"),
  edge((245pt, -244pt), (245pt, -300pt), "-|>"),
  edge((245pt, -300pt), (245pt, -356pt), "-|>"),
  oedge((95pt, -148pt), (95pt, -380pt), (245pt, -380pt), (245pt, -356pt), "-|>"),
)

// ---------- Задача 2 ----------
#let flow2 = diagram(spacing: 8mm,
  term((245pt, -20pt), "начало"),
  parl((245pt, -76pt), "scanf(\"%d\", &a)"),
  dmd((245pt, -148pt), "a < 100000\n|| a > 999999"),
  box((95pt, -148pt), "printf(\"Ошибка ввода!\");\nreturn 1;"),
  box((245pt, -238pt), "b = a / 100000\n+ a / 10000 % 10\n+ a / 1000 % 10;"),
  box((245pt, -296pt), "c = a % 10\n+ a / 10 % 10\n+ a / 100 % 10;"),
  dmd((245pt, -366pt), "b == c"),
  hexa((410pt, -366pt), "printf(\"БИЛЕТ\nСЧАСТЛИВЫЙ!!!\");"),
  hexa((245pt, -436pt), "printf(\"Вам не повезло\");"),
  term((245pt, -496pt), "конец"),
  edge((245pt, -20pt), (245pt, -76pt), "-|>"),
  edge((245pt, -76pt), (245pt, -148pt), "-|>"),
  edge((245pt, -148pt), (95pt, -148pt), lbl[да], "-|>"),
  edge((245pt, -148pt), (245pt, -238pt), lbl[нет], "-|>"),
  edge((245pt, -238pt), (245pt, -296pt), "-|>"),
  edge((245pt, -296pt), (245pt, -366pt), "-|>"),
  edge((245pt, -366pt), (410pt, -366pt), lbl[да], "-|>"),
  edge((245pt, -366pt), (245pt, -436pt), lbl[нет], "-|>"),
  edge((245pt, -436pt), (245pt, -496pt), "-|>"),
  oedge((410pt, -366pt), (410pt, -512pt), (245pt, -512pt), (245pt, -496pt), "-|>"),
  oedge((95pt, -148pt), (95pt, -526pt), (245pt, -526pt), (245pt, -496pt), "-|>"),
)

// ---------- Задача 3 ----------
#let flow3 = diagram(spacing: 8mm,
  term((245pt, -20pt), "начало"),
  parl((245pt, -76pt), "scanf(\"%f %f %f\", &a, &b, &c)"),
  dmd((245pt, -152pt), "scanf(\"%f %f %f\",\n&a, &b, &c) != 3"),
  box((95pt, -152pt), "printf(\"Ошибка ввода!\");\nreturn 1;"),
  dmd((245pt, -250pt), "fmodf(a, 1) == 0"),
  hexa((410pt, -250pt), "printf(\"Число 1\nявляется целым!\");"),
  dmd((245pt, -334pt), "fmodf(b, 1) == 0"),
  hexa((410pt, -334pt), "printf(\"Число 2\nявляется целым!\");"),
  dmd((245pt, -418pt), "fmodf(c, 1) == 0"),
  hexa((410pt, -418pt), "printf(\"Число 3\nявляется целым!\");"),
  dmd((245pt, -508pt), "fmodf(a, 1) != 0\n&& fmodf(b, 1) != 0\n&& fmodf(c, 1) != 0"),
  hexa((410pt, -508pt), "printf(\"Ни одно из чисел\nне является целым(\");"),
  term((245pt, -590pt), "конец"),
  edge((245pt, -20pt), (245pt, -76pt), "-|>"),
  edge((245pt, -76pt), (245pt, -152pt), "-|>"),
  edge((245pt, -152pt), (95pt, -152pt), lbl[да], "-|>"),
  edge((245pt, -152pt), (245pt, -250pt), lbl[нет], "-|>"),
  edge((245pt, -250pt), (410pt, -250pt), lbl[да], "-|>"),
  edge((245pt, -250pt), (245pt, -334pt), lbl[нет], "-|>"),
  oedge((410pt, -250pt), (410pt, -298pt), (308pt, -298pt), (308pt, -334pt), "-|>"),
  edge((245pt, -334pt), (410pt, -334pt), lbl[да], "-|>"),
  edge((245pt, -334pt), (245pt, -418pt), lbl[нет], "-|>"),
  oedge((410pt, -334pt), (410pt, -382pt), (308pt, -382pt), (308pt, -418pt), "-|>"),
  edge((245pt, -418pt), (410pt, -418pt), lbl[да], "-|>"),
  edge((245pt, -418pt), (245pt, -508pt), lbl[нет], "-|>"),
  oedge((410pt, -418pt), (410pt, -466pt), (308pt, -466pt), (308pt, -508pt), "-|>"),
  edge((245pt, -508pt), (410pt, -508pt), lbl[да], "-|>"),
  edge((245pt, -508pt), (245pt, -590pt), lbl[нет], "-|>"),
  oedge((410pt, -508pt), (410pt, -590pt), (281pt, -590pt), (245pt, -590pt), "-|>"),
  oedge((95pt, -152pt), (95pt, -604pt), (245pt, -604pt), (245pt, -590pt), "-|>"),
)

// ---------- Задача 4 ----------
#let flow4 = diagram(spacing: 8mm,
  term((225pt, -20pt), "начало"),
  parl((225pt, -80pt), "printf(\"Введите время\nгода\"); ...\nscanf(\"%d\", &status)"),
  dmd((225pt, -158pt), "status <= 0\n|| status >= 5"),
  box((85pt, -158pt), "printf(\"ТЫ НЕ\nПРОЙДЕШЬ!!!!\");\nreturn 1;"),
  dmd((225pt, -272pt), "switch (status)"),
  hexa((380pt, -212pt), "printf(\"Декабрь, Январь,\nФевраль\");"),
  hexa((380pt, -276pt), "printf(\"Март, Апрель,\nМай\");"),
  hexa((380pt, -340pt), "printf(\"Июнь, Июль,\nАвгуст\");"),
  hexa((380pt, -404pt), "printf(\"Сентябрь,\nОктябрь, Ноябрь\");"),
  hexa((380pt, -468pt), "printf(\"Как ты сюда\nпопал, но это очень\nвпечатляет\");"),
  term((225pt, -560pt), "конец"),
  edge((225pt, -20pt), (225pt, -80pt), "-|>"),
  edge((225pt, -80pt), (225pt, -158pt), "-|>"),
  edge((225pt, -158pt), (85pt, -158pt), lbl[да], "-|>"),
  edge((225pt, -158pt), (225pt, -272pt), lbl[нет], "-|>"),
  oedge((305pt, -272pt), (305pt, -212pt), (315pt, -212pt), lbl[1], "-|>"),
  oedge((305pt, -272pt), (305pt, -276pt), (315pt, -276pt), lbl[2], "-|>"),
  oedge((305pt, -272pt), (305pt, -340pt), (315pt, -340pt), lbl[3], "-|>"),
  oedge((305pt, -272pt), (305pt, -404pt), (315pt, -404pt), lbl[4], "-|>"),
  oedge((162pt, -272pt), (140pt, -272pt), (140pt, -468pt), (315pt, -468pt), lbl[иначе], "-|>"),
  oedge((380pt, -212pt), (460pt, -212pt), (460pt, -582pt), (225pt, -582pt), (225pt, -560pt), "-|>"),
  oedge((380pt, -276pt), (460pt, -276pt), (460pt, -582pt), "-|>"),
  oedge((380pt, -340pt), (460pt, -340pt), (460pt, -582pt), "-|>"),
  oedge((380pt, -404pt), (460pt, -404pt), (460pt, -582pt), "-|>"),
  oedge((380pt, -468pt), (460pt, -468pt), (460pt, -582pt), "-|>"),
  oedge((85pt, -158pt), (85pt, -606pt), (225pt, -606pt), (225pt, -560pt), "-|>"),
)
