#ifndef MATRIX_H
#define MATRIX_H

#include <stdio.h>
typedef struct matrix_t matrix_t;

matrix_t *init_matrix(int rows, int cols);

matrix_t *init_random(int rows, int cols);

float matrix_get(matrix_t *m, int row, int col);

void matrix_set(matrix_t *m, int row, int col, float val);

int rows(matrix_t *m);

int cols(matrix_t *m);

void matrix_fill(matrix_t *m, float x);

matrix_t *matrix_mul(matrix_t *m1, matrix_t *m2);

void matrix_imul(matrix_t *m1, matrix_t *m2);

matrix_t *horizontal_stack(matrix_t *m1, matrix_t *m2);

void ihorizontal_stack(matrix_t *m1, matrix_t *m2);

matrix_t *vertical_stack(matrix_t *m1, matrix_t *m2);

void ivertical_stack(matrix_t *m1, matrix_t *m2);

typedef enum { ADD, SUBTRACT, MULTIPLY } OP;

matrix_t *matrix_elem_op(matrix_t *m1, matrix_t *m2, OP op);

void matrix_elem_iop(matrix_t *m1, matrix_t *m2, OP op);

matrix_t *matrix_add_const(matrix_t *m, float value);

void matrix_iadd_const(matrix_t *m, float value);

matrix_t *matrix_scale(matrix_t *m, float scalar);

void matrix_iscale(matrix_t *m, float scalar);

void matrix_iclip(matrix_t *m, float floor, float ceiling);

void destroy_matrix(matrix_t *m);

void pretty_print(matrix_t *m);

#endif
