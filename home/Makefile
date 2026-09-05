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

# Блок-схемы: gostpadi (https://github.com/sehaxe/gostpadi)
# генерируются прямо из main.c
GOSTPADI := uv run --with matplotlib $(HOME)/gostpadi/gostpadi.py

.PHONY: schemes
schemes:
	$(GOSTPADI) 1/main.c --labels=ru -o 1/scheme.png
	$(GOSTPADI) 2/main.c --labels=ru -o 2/scheme.png
	$(GOSTPADI) 3/main.c --labels=ru -o 3/scheme.png
	$(GOSTPADI) 4/main.c --labels=ru -o 4/scheme.png
