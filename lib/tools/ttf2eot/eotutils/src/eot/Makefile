
all: eot

libeot.a: libeot.o properties.o
	rm -f libeot.a
	ar q libeot.a libeot.o properties.o

eot: libeot.a eot.o
	$(CC) -o eot eot.o libeot.a

clean:
	rm -f *.o *.a eot core *.core
