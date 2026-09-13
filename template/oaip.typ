// ============================================================================
// oaip.typ — шаблон отчёта по лабораторным работам по ОАиП (БГУИР)
//
// Оформление тела отчёта — по СТП 01–2024 БГУИР «Дипломные проекты (работы).
// Общие требования» (требования разделов 2 и 3 распространяются и на отчёты
// по лабораторным работам):
//   · А4, поля: левое 30 мм, правое 15 мм, верхнее и нижнее 20 мм (п. 2.1.1);
//   · Times New Roman 14 pt, межстрочный интервал 1,0 = 18 pt,
//     абзацный отступ 1,25 см, выравнивание по ширине (п. 2.1.1);
//   · заголовки полужирные без переносов и точки в конце (п. 2.2.5);
//     нумерованные разделы «1 ЗАГОЛОВОК» — с абзацного отступа по левому
//     краю, подразделы «1.1 Заголовок» — строчными (п. 2.1.1, 2.2.2,
//     приложение Л); ненумерованные разделы (цель работы, введение,
//     заключение, список использованных источников, приложения) —
//     ПРОПИСНЫМИ по центру без отступа (п. 2.1.1); чтобы раздел был без
//     номера: #heading(level: 1, numbering: none)[Название];
//     вокруг заголовка — пробельная строка (п. 2.1.1, 2.2.6);
//     каждый нумерованный раздел — с новой страницы (п. 2.2.6);
//   · формулы — по центру отдельной строкой, номер в скобках у правого
//     края (п. 2.4.3, 2.4.7), нумерация сквозная: $ x = 1 $;
//   · номер страницы внизу справа; титульный лист входит в нумерацию,
//     но номер на нём не ставится (п. 2.2.8);
//   · подпись рисунка «Рисунок 1 – Название» под рисунком по центру,
//     без точки в конце (п. 2.5.5); подпись таблицы «Таблица 1 – Заголовок»
//     над таблицей слева (п. 2.6.2);
//   · перечисления — с абзацного отступа и знака «тире» (п. 2.3.5).
// Титульный лист — по образцу кафедры, обязательный.
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
// Шрифты: основной — Times New Roman, на Linux подставляется Liberation Serif
// (метрический двойник). Листинги — Courier New / Liberation Mono.
// Все шрифты встраиваются в PDF.
// ============================================================================

// --- шрифты -----------------------------------------------------------------

#let _serif = ("Times New Roman", "Liberation Serif", "Noto Serif")
#let _mono = ("Courier New", "Liberation Mono", "DejaVu Sans Mono")

// --- параметры СТП 01–2024 --------------------------------------------------

// межстрочный интервал 1,0 = 18 pt при 14 pt (п. 2.1.1); leading Typst
// отсчитывается поверх высоты строки шрифта (~1.11em), поэтому вычитаем её
#let _line = 18pt - 1.11em
#let _indent = 1.25cm          // абзацный отступ (п. 2.1.1)
#let _gost-margin = (top: 20mm, bottom: 20mm, left: 30mm, right: 15mm)

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
  goal: none,   // цель работы — раздел «ЦЕЛЬ РАБОТЫ» после титульника
  it,
) = {
  set document(
    title: if lab != none { "Отчёт по лабораторной работе №" + str(lab) + " — " + title } else { title },
    author: student,
  )

  // --- страница: А4, поля по СТП, номер внизу справа (п. 2.1.1, 2.2.8) ---
  set page(width: 21cm, height: 29.7cm, margin: _gost-margin,
    numbering: "1", number-align: bottom + right)

  // ======================= титульный лист (по образцу кафедры) ==============
  {
    set text(font: _serif, size: 14pt, lang: "ru")
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

  // титульник считается страницей 1, но номер на нём не ставится (п. 2.2.8)
  counter(page).update(2)

  // ======================= тело по СТП 01–2024 ==============================
  set text(font: _serif, size: 14pt, lang: "ru")
  set par(
    justify: true,               // по ширине страницы (п. 2.1.1)
    leading: _line,              // межстрочный интервал 18 pt
    spacing: _line,              // без интервала между абзацами, как в Word
    first-line-indent: (amount: _indent, all: true), // отступ у каждого абзаца
  )

  // перечисления: тире с абзацного отступа (п. 2.3.5), нумерованные — «1)» (п. 2.3.8)
  set list(indent: _indent, spacing: _line, marker: [–])
  set enum(indent: _indent, spacing: _line, numbering: "1)")
  show list: set par(first-line-indent: 0mm)
  show enum: set par(first-line-indent: 0mm)

  // заголовки: полужирные, без переносов и точки в конце (п. 2.2.5);
  // нумерованные разделы — прописными с абзацного отступа по левому краю,
  // подразделы — строчными (п. 2.1.1, 2.2.2, 2.2.5, приложение Л);
  // ненумерованные разделы (СОДЕРЖАНИЕ, ВВЕДЕНИЕ, ЗАКЛЮЧЕНИЕ, СПИСОК
  // ИСПОЛЬЗОВАННЫХ ИСТОЧНИКОВ, ПРИЛОЖЕНИЯ) — прописными по центру (п. 2.1.1);
  // вокруг заголовка — пробельная строка (п. 2.2.6); каждый раздел —
  // с новой страницы (п. 2.2.6)
  set heading(numbering: "1")
  // первый нумерованный раздел — без пейджбрейка (цель работы остаётся
  // в начале страницы с ним), остальные — с новой (п. 2.2.6)
  let _first-section = state("oaip-first-section", true)
  show heading: it => {
    set text(weight: "bold", hyphenate: false)
    let head = if it.numbering == none or it.level == 1 { upper(it.body) } else { it.body }
    if it.numbering == none {
      // ненумерованный раздел — по центру без абзацного отступа (п. 2.1.1)
      block(width: 100%, above: 18pt, below: 18pt, breakable: false,
        align(center, head))
    } else {
      // нумерованный — с абзацного отступа; вторые и последующие строки
      // выравниваются по началу текста первой строки (п. 2.1.1, приложение Л)
      block(width: 100%, above: 18pt, below: 18pt, breakable: false, {
        set par(hanging-indent: _indent + 2em,
          first-line-indent: (amount: _indent, all: false))
        box(width: 2em, numbering(it.numbering, ..counter(heading).get()))
        head
      })
    }
  }

  // формулы: отдельной строкой по центру, номер в скобках у правого края
  // (п. 2.4.3, 2.4.7); допускается сквозная нумерация (п. 2.4.6)
  set math.equation(numbering: "(1)", number-align: right)

  // рисунки: подпись «Рисунок 1 – Название» снизу по центру, без точки
  // (п. 2.5.5); таблицы: «Таблица 1 – Заголовок» сверху слева (п. 2.6.2);
  // иллюстрация отделяется от текста и подписи пробельными строками
  // (п. 2.5.3, приложение Н — подпись идёт сразу под рисунком)
  set figure(supplement: [Рисунок], numbering: "1", gap: 8pt)
  set figure.caption(position: bottom, separator: [ – ])
  show figure: set align(center)
  show figure: set par(justify: false, first-line-indent: 0mm)
  // ни картинка, ни код не разрываются между страницами: блок целиком
  // уезжает на следующую страницу вместе с подписью
  show figure: set block(breakable: false)
  show figure: set block(above: 18pt, below: 18pt)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set align(left)

  // --- цель работы (ненумерованный раздел, как ВВЕДЕНИЕ/ЗАКЛЮЧЕНИЕ) ---
  if goal != none {
    heading(level: 1, numbering: none, outlined: false)[Цель работы]
    goal
  }

  it
}

// --- помощники для отчёта ---------------------------------------------------

// Листинг: моноширинный Courier с номерами строк, подпись
// «Листинг N – …» снизу (рамки СТП не предусматривает).
// source — строка с кодом (например, read("../1/main.c")).
#let listing(source, caption: none, lang: "c", line-numbers: true, size: 0.8em) = figure(
  kind: "listing",
  supplement: [Листинг],
  numbering: "1",
  caption: caption,
  {
    set align(left) // figure центрирует содержимое по умолчанию — коду нужен левый край
    set text(font: _mono, size: size)
    set par(justify: false, leading: 0.62em, spacing: 0.62em, first-line-indent: 0mm)
    set raw(align: left, tab-size: 4)
    show raw.line: it => if line-numbers {
      box(width: 1.9em, align(right, str(it.number))) + h(6pt) + it
    } else {
      it
    }
    raw(source, lang: lang)
  },
)

// Скриншот результата: по центру, подпись «Рисунок N – …» снизу.
#let shot(path, caption: none, width: 88%) = figure(
  image(path, width: width),
  caption: caption,
)

// Блок-схема: белая картинка по центру, подпись «Рисунок N – …» снизу.
#let flow(path, caption: none, width: 140mm) = figure(
  image(path, width: width),
  caption: caption,
)

// Широкая блок-схема (например, switch с 4–5 ветками): выносится на
// отдельный АЛЬБОМНЫЙ лист — разворот на 90° по часовой стрелке
// разрешён п. 2.5.4 СТП.
#let flow-wide(path, caption: none) = page(
  flipped: true,
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
