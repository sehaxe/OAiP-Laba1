# oaip — шаблон отчёта по лабораторным работам по ОАиП (БГУИР)

Typst-шаблон в концепции «**всё как в статье arXiv, только титульник другой**»:

- **стр. 1** — титульный лист по образцу кафедры (Times/Liberation Serif, по
  центру министерство/БГУИР, «Выполнил/Проверил» правее центра, «Минск 2026»),
  номер страницы на нём не ставится;
- **тело** — конвенции LaTeX article / arXiv: шрифт Computer Modern
  (New Computer Modern) 10pt, одинарный интервал, выравнивание по ширине,
  абзацы с втяжкой 1.5em (первый после заголовка — без втяжки), заголовки
  секций жирные слева, подписи «Рисунок 1: …» / «Листинг 1: …» мелким кеглем;
- **листинги** — как пакет `listings` с `frame=single`: тонкая прямоугольная
  рамка без заливки, моноширинный Computer Modern Mono, серые номера строк
  слева; длинные листинги разрываются между страницами, картинки — нет
  (картинка никогда не отрывается от подписи);
- широкая блок-схема (switch на 4–5 веток) выносится на отдельный альбомный
  лист — аналог `sidewaysfigure`.

## Использование

```typst
#import "../../template/oaip.typ": *

#show: oaip.with(
  lab: 1,                                               // номер лабы
  title: "Структура программы на Си. Функции ввода-вывода",
  group: "658304",
  variant: 5,
  student: "Иванов И. И.",
  teacher: "Селезнев А. И.",
  year: 2026,
  goal: [Научиться разрабатывать линейные и разветвляющиеся алгоритмы…],
)

= Задание № 1

*Описание задания.* …

#listing(read("../1/main.c"), caption: [Программа к заданию № 1])
#shot("/lab2/report/assets/term1.png", caption: [Результаты выполнения])
#flow("/lab2/report/assets/scheme1.png", caption: [Блок-схема программы])
#flow-wide("/lab2/report/assets/big.png", caption: [Широкая схема])
```

Сборка — от папки лабы, `--root` указывает на корень проекта
(иначе typst не найдёт картинки; пути в `shot`/`flow` пишутся от корня, со слэша):

```bash
cd home && make report        # = typst compile --root .. report/main.typ
```

## Параметры `oaip.with`

| Параметр        | Назначение                                     | По умолчанию             |
|-----------------|------------------------------------------------|--------------------------|
| `lab`           | номер лабораторной                             | —                        |
| `title`         | тема работы                                    | —                        |
| `discipline`    | дисциплина на титульнике                       | «Основы алгоритмизации…» |
| `group`         | учебная группа                                 | —                        |
| `variant`       | номер варианта                                 | —                        |
| `student`       | фамилия исполнителя                            | —                        |
| `teacher`       | кто проверяет                                  | —                        |
| `city`, `year`  | нижняя строка титульника                       | «Минск», —               |
| `goal`          | цель работы (сверстается как Abstract)         | —                        |
| `gost-captions` | `true` — подписи по ГОСТ «Рисунок 1 — …» вместо «Рисунок 1: …» | `false`  |
| `margin`        | поля страницы                                  | 25/25/25/30 мм, как в article |
| `size`          | основной кегль тела                            | 10pt                     |

## Помощники

- `listing(source, caption:, lang:, line-numbers:)` — листинг; `source` —
  строка с кодом, удобно `read("../1/main.c")`.
- `shot(path, caption:, width:)` — скриншот результата.
- `flow(path, caption:, width:)` — блок-схема.
- `flow-wide(path, caption:)` — широкая схема на альбомном листе.
- Русские псевдонимы: `листинг`, `скрин`, `схема`.

## Шрифты

Тело — **New Computer Modern** (свободная цифровая версия Computer Modern),
моно — New Computer Modern Mono. Ставится из CTAN:

```bash
curl -sL https://mirrors.ctan.org/fonts/newcomputermodern.zip -o ncm.zip
unzip ncm.zip 'newcomputermodern/otf/*'
mkdir -p ~/.local/share/fonts/newcm
cp newcomputermodern/otf/NewCM10-{Regular,Bold,Italic,BoldItalic}.otf \
   newcomputermodern/otf/NewCMMono10-{Regular,Bold,Italic}.otf \
   ~/.local/share/fonts/newcm/
fc-cache -f
```

Без него шаблон не упадёт — тело откатится на Liberation Serif (только будет
warning). Титульник — Liberation Serif (метрический двойник Times New Roman);
для Windows замените первую строку `_serif-title` в `oaip.typ` на
`"Times New Roman"`. Все шрифты встраиваются в PDF.
