CC      = gcc
CFLAGS  = -Wall -g -D_DEFAULT_SOURCE -std=c99 -Werror -pedantic
PROGS		= matrix_test

.SUFFIXES: .c .o

.PHONY: all clean

all: 

test: matrix_test
	./matrix_test

matrix_test: common.o matrix_test.o matrix.o
matrix_test.o: common.h matrix.h
matrix.o: common.h matrix.h
ann.o: common.h matrix.h

clean:
	rm -f $(wildcard *.o) $(PROGS) *~ gmon.out callgrind.out.*
