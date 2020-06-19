#ifndef __CUDACC__

#include "matrix.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>

struct matrix_t {
  int rows;
  int cols;
  float *data;
};

inline int rows(matrix_t *m) { return m->rows; }

inline int cols(matrix_t *m) { return m->cols; }

static matrix_t *__alloc_matrix(int rows, int cols) {
  float *data = malloc(rows * cols * sizeof(float));
  matrix_t *m = malloc(sizeof(matrix_t));
  m->rows = rows;
  m->cols = cols;
  m->data = data;
  return m;
}

void destroy_matrix(matrix_t *m) {
  assert(m != NULL);
  free(m->data);
  free(m);
}

matrix_t *init_matrix(int rows, int cols) {
  float *data = calloc(rows * cols, sizeof(float));
  matrix_t *m = malloc(sizeof(matrix_t));
  m->rows = rows;
  m->cols = cols;
  m->data = data;
  return m;
}

#define size(m) m->rows * m->cols
#define ELEM_WISE(m, i, op)           \
  for (int i = 0; i < size(m); i++) { \
    op;                               \
  }

void matrix_fill(matrix_t *m, float x) { ELEM_WISE(m, i, m->data[i] = x); }

matrix_t *init_random(int rows, int cols) {
  matrix_t *m = __alloc_matrix(rows, cols);
  ELEM_WISE(m, i, m->data[i] = (float)rand() / (float)RAND_MAX;);
  return m;
}

#define OUTER_BLOCK_SIZE 256
#define INNER_BLOCK_SIZE 2048
#define MIN(x, y) (((x) < (y)) ? (x) : (y))
#define ELEM(m, row, col) ((m)->data[(col) + (row) * (m)->cols])

inline float matrix_get(matrix_t *m, int row, int col) {
  return ELEM(m, row, col);
}
inline void matrix_set(matrix_t *m, int row, int col, float val) {
  ELEM(m, row, col) = val;
}

matrix_t *matrix_mul(matrix_t *m1, matrix_t *m2) {
  assert(m1->cols == m2->rows);

  matrix_t *ret = init_matrix(m1->rows, m2->cols);
  for (int kk = 0; kk < m1->cols; kk += OUTER_BLOCK_SIZE) {
    const int maxk = MIN(kk + OUTER_BLOCK_SIZE, m1->cols);

    for (int jj = 0; jj < m2->cols; jj += INNER_BLOCK_SIZE) {
      const int maxj = MIN(jj + INNER_BLOCK_SIZE, m2->cols);

      for (int i = 0; i < m1->rows; i++) {  // going down a

        for (int k = kk; k < maxk;
             k++) {  // going across on a and down b, one outer block
          float m1_val = ELEM(m1, i, k);
          if (m1_val == 0) continue;
          for (int j = jj; j < maxj;
               j++) {  // going across on b, one inner block
            ELEM(ret, i, j) += m1_val * ELEM(m2, k, j);
          }
        }
      }
    }
  }
  return ret;
}

void matrix_imul(matrix_t *m1, matrix_t *m2){
  // There isn't a good way to do in-place (or low allocation)
  // matrix multiplication
  matrix_t *ret = matrix_mul(m1, m2);
  free(m1->data);
  m1->rows = ret->rows;
  m1->cols = ret->cols;
  m1->data = ret->data;
  free(ret); // don't free data
}

#define ROW(m, i) ELEM(m, i, 0)

matrix_t *horizontal_stack(matrix_t *m1, matrix_t *m2) {
  assert(m1->rows == m2->rows);

  matrix_t *ret = __alloc_matrix(m1->rows, m1->cols + m2->cols);
  for (int i = 0; i < ret->rows; i++) {
    memcpy(&ELEM(ret, i, 0), &ROW(m1, i), m1->cols * sizeof(float));
    memcpy(&ELEM(ret, i, m1->cols), &ROW(m2, i), m2->cols * sizeof(float));
  }
  return ret;
}

void ihorizontal_stack(matrix_t *m1, matrix_t *m2) {
  assert(m1->rows == m2->rows);
  m1->data = realloc(m1->data, (size(m1) + size(m2)) * sizeof(float));

  int new_cols = m1->cols + m2->cols;
  int orig_cols = m1->cols;
  m1->cols = new_cols;
  for (int i = m1->rows - 1; i >= 0; i--) {
    memmove(&ELEM(m1, i, 0), &m1->data[i * orig_cols],
            orig_cols * sizeof(float));
  }

  for (int i = 0; i < m1->rows; i++) {
    memcpy(&ELEM(m1, i, orig_cols), &ROW(m2, i), m2->cols * sizeof(float));
  }
}

matrix_t *vertical_stack(matrix_t *m1, matrix_t *m2) {
  assert(m1->cols == m2->cols);

  matrix_t *ret = __alloc_matrix(m1->rows + m2->rows, m1->cols);

  memcpy(&ret->data[0], m1->data, size(m1) * sizeof(float));
  memcpy(&ret->data[size(m1)], m2->data, size(m2) * sizeof(float));
  return ret;
}

void ivertical_stack(matrix_t *m1, matrix_t *m2) {
  assert(m1->cols == m2->cols);

  int new_rows = m1->rows + m2->rows;
  m1->data = realloc(m1->data, (size(m1) + size(m2)) * sizeof(float));
  memcpy(&m1->data[size(m1)], m2->data, size(m2) * sizeof(float));
  m1->rows = new_rows;
}

matrix_t *matrix_elem_op(matrix_t *m1, matrix_t *m2, OP op) {
  assert(m1->rows == m2->rows);
  assert(m1->cols == m2->cols);

  matrix_t *ret = __alloc_matrix(m1->rows, m1->cols);

  switch (op) {
    case ADD:
      ELEM_WISE(ret, i, ret->data[i] = m1->data[i] + m2->data[i]);
      break;
    case SUBTRACT:
      ELEM_WISE(ret, i, ret->data[i] = m1->data[i] - m2->data[i]);
      break;
    case MULTIPLY:
      ELEM_WISE(ret, i, ret->data[i] = m1->data[i] * m2->data[i]);
      break;
  }
  return ret;
}

void matrix_elem_iop(matrix_t *m1, matrix_t *m2, OP op) {
  assert(m1->rows == m2->rows);
  assert(m1->cols == m2->cols);

  switch (op) {
    case ADD:
      ELEM_WISE(m1, i, m1->data[i] += m2->data[i]);
      break;
    case SUBTRACT:
      ELEM_WISE(m1, i, m1->data[i] -= m2->data[i]);
      break;
    case MULTIPLY:
      ELEM_WISE(m1, i, m1->data[i] *= m2->data[i]);
      break;
  }
}

matrix_t *matrix_add_const(matrix_t *m, float value) {
  matrix_t *ret = __alloc_matrix(m->rows, m->cols);
  ELEM_WISE(m, i, ret->data[i] = m->data[i] + value);
  return ret;
}

void matrix_iadd_const(matrix_t *m, float value) {
  ELEM_WISE(m, i, m->data[i] += value);
}

matrix_t *matrix_scale(matrix_t *m, float scalar) {
  matrix_t *ret = __alloc_matrix(m->rows, m->cols);
  ELEM_WISE(m, i, ret->data[i] = m->data[i] * scalar);
  return ret;
}

void matrix_iscale(matrix_t *m, float scalar) {
  ELEM_WISE(m, i, m->data[i] *= scalar);
}

void matrix_iclip(matrix_t *m, float floor, float ceiling) {
  ELEM_WISE(
      m, i,
      if (m->data[i] < floor) {
        m->data[i] = floor;
      } else if (m->data[i] > ceiling) { m->data[i] = ceiling; });
}

void pretty_print(matrix_t *m) {
  for (int i = 0; i < rows(m); i++) {
    for (int j = 0; j < cols(m); j++) {
      printf("%.2f ", matrix_get(m, i, j));
    }
    printf("\n");
  }
  printf("\n");
}
#endif