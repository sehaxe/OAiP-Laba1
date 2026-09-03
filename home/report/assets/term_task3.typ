#set page(width: auto, height: auto, margin: 0pt, fill: none)
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
#block(fill: rgb("#282a36"), radius: 7pt, width: 420pt, inset: 0pt)[
  #block(fill: rgb("#21222c"), radius: (top-left: 7pt, top-right: 7pt, bottom-right: 0pt, bottom-left: 0pt), inset: (x: 10pt, y: 6pt))[
    #grid(columns: (auto, 1fr, auto), align: (left, center, right),
      dots,
      text(fill: rgb("#9a9a9a"), size: 8pt)[sehaxe\@cachyos: \~/ОАиП-Лаба1/home],
      h(1pt),
    )
  ]
  #block(inset: (top: 10pt, right: 14pt, bottom: 12pt, left: 12pt))[
#cmdline[./3/main] \ 
#oline[Введите три числа] \ 
#iline[1 2.5 3.7] \ 
#oline[Число 1 является целым!] \ 
#v(7pt) 
#cmdline[./3/main] \ 
#oline[Введите три числа] \ 
#iline[2.5 3.5 8.9] \ 
#oline[Ни одно из чисел не является целым(] \
  ]
]
