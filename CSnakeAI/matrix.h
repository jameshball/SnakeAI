#ifndef MATRIX_H
#define MATRIX_H

#include <stdio.h>

typedef struct matrix_t matrix_t;

matrix_t *matrix_from_arr(int rows, int cols, float *arr);

matrix_t *matrix_ifrom_arr(int rows, int cols, float *arr);

matrix_t *init_matrix(int rows, int cols);

matrix_t *init_random(int rows, int cols);

float matrix_get(matrix_t *m, int row, int col);

matrix_t *matrix_set(matrix_t *m, int row, int col, float val);

int rows(matrix_t *m);

int cols(matrix_t *m);

matrix_t *matrix_fill(matrix_t *m, float x);

matrix_t *matrix_mul(matrix_t *m1, matrix_t *m2);

matrix_t *matrix_imul(matrix_t *m1, matrix_t *m2);

matrix_t *matrix_add_bias(matrix_t *m);

matrix_t *matrix_iadd_bias(matrix_t *m);

matrix_t *matrix_imutate(matrix_t *m, float mutation_rate);

matrix_t *horizontal_stack(matrix_t *m1, matrix_t *m2);

matrix_t *ihorizontal_stack(matrix_t *m1, matrix_t *m2);

matrix_t *vertical_stack(matrix_t *m1, matrix_t *m2);

matrix_t *ivertical_stack(matrix_t *m1, matrix_t *m2);

typedef enum { ADD, SUBTRACT, MULTIPLY } OP;

matrix_t *matrix_elem_op(matrix_t *m1, matrix_t *m2, OP op);

matrix_t *matrix_elem_iop(matrix_t *m1, matrix_t *m2, OP op);

matrix_t *matrix_relu(matrix_t *m);

matrix_t *matrix_irelu(matrix_t *m);

matrix_t *matrix_add_const(matrix_t *m, float value);

matrix_t *matrix_iadd_const(matrix_t *m, float value);

matrix_t *matrix_scale(matrix_t *m, float scalar);

matrix_t *matrix_iscale(matrix_t *m, float scalar);

matrix_t *matrix_iclip(matrix_t *m, float floor, float ceiling);

void destroy_matrix(matrix_t *m);

void pretty_print(matrix_t *m);

#endif
