
all: main.42m

main.42m: main.4gl form.42f
	fglcomp --verbose --make main.4gl

form.42f: form.per
	fglform $^

clean:
	rm -f *.42?

run: main.42m
	fglrun main
