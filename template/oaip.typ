// ============================================================================
// oaip.typ — шаблон отчёта по лабораторным работам по ОАиП (БГУИР)
//
// Концепция: «всё как в статье arXiv, только титульник другой».
// Титульный лист — по образцу кафедры (Times, по центру), обязательный.
// Всё тело документа свёрстано по конвенциям LaTeX article / arXiv:
//   · шрифт Computer Modern (New Computer Modern), кегль 10pt, одинарный;
//   · абзацы с втяжкой 1.5em, первый абзац после заголовка — без втяжки;
//   · заголовки секций — жирные, крупнее текста, слева;
//   · подписи «Рисунок 1: …» / «Листинг 1: …» мелко, как \small в LaTeX;
//   · листинги как пакет listings: тонкая рамка (frame=single),
//     номера строк слева серым, моноширинный Computer Modern Mono.
//
// Использование:
//   #import "../../template/oaip.typ": *
//   #show: oaip.with(
//     lab: 1,
//     title: "Структура программы на Си. Функции ввода-вывода",
//     group: "658304",
//     student: "Иванов И. И.",
//     teacher: "Селезнев А. И.",
//     variant: 5,
//     goal: [Научиться разрабатывать линейные и разветвляющиеся алгоритмы…],
//   )
//
//   = Задание № 1
//   #listing(read("../1/main.c"), caption: [Программа к заданию № 1])
//   #shot("/lab/report/assets/term.png", caption: [Результаты выполнения])
//   #flow("/lab/report/assets/flow.png", caption: [Блок-схема программы])
//   #flow-wide("/lab/report/assets/big.png", caption: [Широкая схема])
//
// Пути к картинкам в shot()/flow()/flow-wide() — ОТ КОРНЯ ПРОЕКТА (со слэша),
// сборка: typst compile --root <корень> report/main.typ
//
// Шрифты: New Computer Modern (тело) — свободная цифровая версия Computer
// Modern; ставится из CTAN (fonts/newcomputermodern) в ~/.local/share/fonts.
// Титульник — Liberation Serif (двойник Times New Roman; для Windows замените
// на "Times New Roman"). Все шрифты встраиваются в PDF, при отсутствии
// New Computer Modern тело откатывается на Liberation Serif.
// ============================================================================

// --- шрифты -----------------------------------------------------------------

// Титульный лист (по образцу кафедры): Liberation Serif — метрический
// двойник Times New Roman. Для Windows поменяйте на "Times New Roman".
#let _serif-title = ("Liberation Serif", "Noto Serif")
// Тело отчёта: Computer Modern, как в arXiv.
#let _cm = ("New Computer Modern", "Liberation Serif", "Noto Serif")
// Листинги: моноширинный Computer Modern.
#let _mono = ("New Computer Modern Mono", "DejaVu Sans Mono", "Liberation Mono")

#let _ink = luma(20)          // основной текст
#let _faint = rgb("#9a958c")  // номера строк

// --- главный show-rule ------------------------------------------------------

#let oaip(
  lab: none,
  title: "",
  discipline: "Основы алгоритмизации и программирования",
  group: "",
  variant: none,
  student: "",
  teacher: "",
  city: "Минск",
  year: none,
  goal: none,   // цель работы — сверстается как Abstract в статье
  gost-captions: false, // true — подписи по ГОСТ «Рисунок 1 — …», false — «Рисунок 1: …» как в LaTeX
  margin: (top: 25mm, bottom: 30mm, left: 25mm, right: 25mm), // как в article
  size: 10pt,   // стандартный кегль arXiv (10pt article)
  it,
) = {
  set document(
    title: if lab != none { "Отчёт по лабораторной работе №" + str(lab) + " — " + title } else { title },
    author: student,
  )

  // --- страница: А4, номер внизу по центру (LaTeX \pagestyle{plain}) ---
  set page(
    width: 21cm,
    height: 29.7cm,
    margin: margin,
    numbering: "1",
    number-align: bottom + center,
  )

  // ======================= титульный лист (по образцу кафедры) ==============
  {
    set text(font: _serif-title, size: 14pt, fill: _ink, lang: "ru")
    set page(numbering: none)
    set par(first-line-indent: 0mm, justify: false, spacing: 0em)

    align(center)[
      #text(size: 14pt)[
        Министерство образования Республики Беларусь \
        г. Минск \
        Государственное учреждение образования \
        «Белорусский государственный университет \
        информатики и радиоэлектроники»
      ]
    ]

    v(1fr)

    align(center)[
      #text(size: 16pt, weight: "bold")[
        Лабораторная работа #if lab != none [№ #lab]
      ]

      #v(8pt)
      #text(size: 14pt, weight: "bold")[«#title»]

      #if discipline != none [
        #v(4pt)
        #text(size: 14pt)[по дисциплине «#discipline»]
      ]

      #if variant != none [
        #v(4pt)
        #text(size: 14pt, weight: "bold")[Вариант #variant]
      ]

      #v(12pt)
      #text(size: 14pt, weight: "bold")[Учебная группа #group]
    ]

    v(1fr)

    // блок «Выполнил / Проверил» — правее центра, как в образце
    grid(
      columns: (1.15fr, 1fr),
      [],
      [*Выполнил:* #student \
       *Проверил:* #teacher],
    )

    v(1fr)

    align(center)[#city #year]

    pagebreak()
  }

  // титульник считается страницей 1, но номер на нём не ставится
  counter(page).update(2)

  // ======================= тело: конвенции LaTeX article ====================
  set text(font: _cm, size: size, fill: _ink, lang: "ru")
  set par(
    justify: true,
    leading: 0.65em,          // одинарный интервал
    // spacing = leading: в LaTeX \parskip = 0, но \baselineskip держится
    // и МЕЖДУ абзацами; если поставить 0, соседние абзацы слипаются плотнее,
    // чем строки внутри одного абзаца
    spacing: 0.65em,
    first-line-indent: (amount: 1.5em, all: false), // как \parindent в LaTeX
  )

  // списки: LaTeX-овские itemize/enumerate
  set list(indent: 1.5em, spacing: 0.55em, marker: ([-],))
  set enum(indent: 1.5em, spacing: 0.55em, numbering: "1.")
  show list: set par(first-line-indent: 0mm)
  show enum: set par(first-line-indent: 0mm)

  // заголовки секций: \section — жирный, крупнее текста, слева
  set heading(numbering: none)
  show heading: it => {
    set text(weight: "bold", size: size + 4pt)  // \Large при 10pt ≈ 14.4pt
    set par(justify: false, first-line-indent: 0mm, spacing: 0em)
    v(18pt, weak: true)
    it
    v(8pt, weak: true)
  }

  // рисунки: подпись снизу, «Рисунок 1: …» (или ГОСТ «Рисунок 1 — …») мелким кеглем (\small)
  set figure(supplement: [Рисунок], numbering: "1", gap: 16pt)
  set figure.caption(separator: if gost-captions { [~—~] } else { [: ] })
  show figure: set figure.caption(position: bottom)
  show figure.caption: set text(size: 0.9em)
  // при par(spacing: 0em) слабые отбивки вокруг figure схлопываются в ноль,
  // поэтому после подписи — сильный (несхлопываемый) вертикальный зазор
  show figure.caption: it => { it; v(10pt, weak: false) }
  show figure: set par(justify: false, first-line-indent: 0mm)
  // длинные листинги разрываются между страницами…
  show figure: set block(breakable: true)
  // …а рисунки с картинками — нет: картинка не должна отрываться от подписи
  show figure.where(kind: image): set block(breakable: false)

  // ======================= титульный блок в стиле arXiv =====================
  set par(first-line-indent: 0mm, justify: false, spacing: 0em)

  line(length: 100%, stroke: 2pt + _ink)
  v(4pt)
  align(center)[
    #block(text(weight: "medium", size: size + 5pt)[
      Лабораторная работа #if lab != none [№ #lab].
      #title
    ])
    #v(1em, weak: true)
  ]
  line(length: 100%, stroke: 2pt + _ink)

  pad(top: 0.5em)[
    #align(center)[
      #text(size: size)[
        #student, группа #group \
        #if teacher != none [проверил: #teacher] \
        #if variant != none [вариант #variant] \
        #city, #year
      ]
    ]
  ]

  // --- цель работы — блок Abstract ---
  if goal != none {
    pad(x: 3em, top: 1em, bottom: 0.4em)[
      #align(center)[
        #heading(level: 1, outlined: false, numbering: none,
          text(0.85em, smallcaps[Цель работы]))
      ]
      #set par(justify: true, first-line-indent: 0mm, spacing: 0em)
      #goal
    ]
  }

  v(0.5em)
  set par(first-line-indent: (amount: 1.5em, all: false), justify: true, spacing: 0.65em)

  it
}

// --- помощники для отчёта ---------------------------------------------------

// Листинг в стиле пакета listings (frame=single, номера строк слева):
// тонкая рамка, без заливки, моноширинный Computer Modern, подпись
// «Листинг N: …» снизу мелким кеглем.
// source — строка с кодом (например, read("../1/main.c")).
#let listing(source, caption: none, lang: "c", line-numbers: true) = figure(
  kind: "listing",
  supplement: [Листинг],
  numbering: "1",
  caption: caption,
  // сильный v — вне рамки: при par(spacing: 0em) слабые отбивки схлопываются,
  // и рамка листинга ложится на предшествующий текст
  v(12pt, weak: false)
  + block(
    width: 100%,
    stroke: 0.4pt + _ink,
    inset: (x: 10pt, y: 8pt),
    radius: 0pt,
    {
      set align(left) // figure центрирует содержимое по умолчанию — коду нужен левый край
      set text(font: _mono, size: 0.85em)
      set par(justify: false, leading: 0.62em, spacing: 0.62em, first-line-indent: 0mm)
      set raw(align: left, tab-size: 4)
      show raw.line: it => if line-numbers {
        box(width: 1.9em, align(right, text(fill: _faint, str(it.number)))) + h(6pt) + it
      } else {
        it
      }
      raw(source, lang: lang)
    },
  ),
)

// Скриншот результата: по центру, подпись «Рисунок N: …» снизу.
#let shot(path, caption: none, width: 88%) = figure(
  image(path, width: width),
  caption: caption,
)

// Блок-схема: белая картинка по центру, подпись «Рисунок N: …» снизу.
#let flow(path, caption: none, width: 140mm) = figure(
  image(path, width: width),
  caption: caption,
)

// Широкая блок-схема (например, switch с 4–5 ветками): выносится на
// отдельный АЛЬБОМНЫЙ лист — как sidewaysfigure в LaTeX, аналогично
// ГОСТ-практике выноса больших схем; текст схемы печатается крупнее.
#let flow-wide(path, caption: none) = page(
  flipped: true,
  numbering: "1",
  number-align: bottom + center,
  {
    set align(center)
    v(1fr)
    figure(image(path, width: 98%), caption: caption)
    v(1fr)
  },
)

// Русские псевдонимы — можно писать по-русски.
#let листинг = listing
#let скрин = shot
#let схема = flow
