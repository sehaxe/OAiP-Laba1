all: 1/main 2/main 3/main 4/main

.PHONY: report
report:
	typst compile --root .. report/main.typ

1/main: 1/main.c
	gcc 1/main.c -o 1/main -lm

2/main: 2/main.c
	gcc 2/main.c -o 2/main -lm

3/main: 3/main.c
	gcc 3/main.c -o 3/main -lm

4/main: 4/main.c
	gcc 4/main.c -o 4/main -lm

clean:
	rm -f 1/main 2/main 3/main 4/main

# Блок-схемы: gostpadi (pip install gostpadi) рисует их прямо из main.c
# в report/assets/; отчёт подключает их оттуда.
# Быстрый просмотр одной схемы: gostpadi --labels=ru 1/main.c --show
# Одна пачка: gostpadi сам считает общие размеры фигур — во всех схемах
# отчёта блоки одного типа получаются одного размера.
.PHONY: schemes
schemes:
	gostpadi --labels=ru 1/main.c 2/main.c 3/main.c 4/main.c -o report/assets/ --scale=3 --lw=1.5
