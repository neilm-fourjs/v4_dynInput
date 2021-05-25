
export FGLPROFILE=./fglprofile

all: cstmnt.42m stkmnt.42m

cstmnt.42m: cstmnt.4gl cstmnt.42f
	fglcomp --verbose --make cstmnt.4gl

stkmnt.42m: stkmnt.4gl stkmnt.42f
	fglcomp --verbose --make stkmnt.4gl

cstmnt.42f: cstmnt.per
	fglform $^

stkmnt.42f: stkmnt.per
	fglform $^

clean:
	rm -f *.42?

run: cstmnt.42m
	fglrun cstmnt

run2: stkmnt.42m
	fglrun stkmnt
