#set page(width: auto, height: auto, margin: 0pt, fill: none)
#set text(font: ("DejaVu Sans Mono", "Noto Sans CJK TC"), size: 9pt, lang: "ru")
#let dots = grid(columns: (auto, auto, auto), gutter: 5pt,
  box(circle(radius: 4pt, fill: rgb("#ff5f56"))),
  box(circle(radius: 4pt, fill: rgb("#ffbd2e"))),
  box(circle(radius: 4pt, fill: rgb("#27c93f"))))
#let cmdline(t) = {
  text(fill: rgb("#1a7f37"))[sehaxe]
  text(fill: rgb("#6e7781"))[\@cachyos:]
  text(fill: rgb("#0969da"))[\~/ОАиП-Лаба1/home]
  text(fill: rgb("#8250df"))[\$ ]
  text(fill: rgb("#24292f"))[#t]
}
#let oline(t) = text(fill: rgb("#24292f"))[#t]
#let iline(t) = text(fill: rgb("#bc4c00"))[#t]
#block(fill: white, stroke: 0.7pt + rgb("#c9c9c9"), radius: 7pt, width: 420pt, inset: 0pt)[
  #block(fill: rgb("#eeeef0"), radius: (top-left: 7pt, top-right: 7pt, bottom-right: 0pt, bottom-left: 0pt), inset: (x: 10pt, y: 6pt))[
    #grid(columns: (auto, 1fr, auto), align: (left, center, right),
      dots,
      text(fill: rgb("#6e7781"), size: 8pt)[sehaxe\@cachyos: \~/ОАиП-Лаба1/home],
      h(1pt),
    )
  ]
  #block(inset: (top: 10pt, right: 14pt, bottom: 12pt, left: 12pt))[
#cmdline[./2/main] \ 
#oline[Введите номер билета] \ 
#iline[123321] \ 
#oline[БИЛЕТ СЧАСТЛИВЫЙ!!! (✿^‿^)] \ 
#v(7pt) 
#cmdline[./2/main] \ 
#oline[Введите номер билета] \ 
#iline[123456] \ 
#oline[Вам не повезло (｡ŏ﹏ŏ)] \ 
#v(7pt) 
#cmdline[./2/main] \ 
#oline[Введите номер билета] \ 
#iline[12345] \ 
#oline[Ошибка ввода!] \
  ]
]
