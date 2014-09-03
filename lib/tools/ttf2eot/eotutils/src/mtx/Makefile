
mtx: main.o libmtx.a
	$(CC) -o mtx main.o libmtx.a lzcomp/liblzcomp.a

libmtx.a: mtx.o
	rm -f libmtx.a
	ar q libmtx.a mtx.o

clean:
	rm -f *.o *.core core *.a
