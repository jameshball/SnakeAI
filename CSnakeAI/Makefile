CC      = gcc
CFLAGS  = -Wall -g -D_DEFAULT_SOURCE -std=c99 -Werror -pedantic
PROGS		= matrix_test

.SUFFIXES: .c .o

.PHONY: all clean

all: 

test: matrix_test
	./matrix_test

matrix_test: matrix_test.o matrix.o
matrix_test.o: matrix.h
matrix.o: matrix.h

clean:
	rm -f $(wildcard *.o) $(PROGS) *~ gmon.out callgrind.out.*
