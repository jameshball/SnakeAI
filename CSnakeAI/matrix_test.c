/*
  Adapted from clexionline 2020 trial test 
*/
#include "matrix.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
int asserts_ran = 0, asserts_failed = 0, tests_ran = 0, tests_failed = 0;

#define assert_eq(a, b)                                                      \
  do {                                                                       \
    asserts_ran++;                                                           \
    if ((a) != (b)) {                                                        \
      printf("%s(line %d): got: %d | expected: %d\n", __func__, __LINE__, a, \
             b);                                                             \
      asserts_failed++;                                                      \
    }                                                                        \
  } while (0)

#define assert_eq_silent(a, b) \
  do {                         \
    asserts_ran++;             \
    if ((a) != (b)) {          \
      asserts_failed++;        \
    }                          \
  } while (0)

#define assert_ptr_notnull(p)                                                  \
  do {                                                                         \
    asserts_ran++;                                                             \
    if (p == NULL) {                                                           \
      printf("%s(line %d): pointer should not be NULL\n", __func__, __LINE__); \
      asserts_failed++;                                                        \
      return;                                                                  \
    }                                                                          \
  } while (0)

#define epsilon 1e-8
#define assert_eq_float(a, b)                                                \
  do {                                                                       \
    asserts_ran++;                                                           \
    if (fabsf((a) - (b)) > epsilon) {                                        \
      printf("%s(line %d): got: %f | expected: %f\n", __func__, __LINE__, a, \
             b);                                                             \
      asserts_failed++;                                                      \
    }                                                                        \
  } while (0)

#define assert_matrix_eq(m1, m2)                                            \
  do {                                                                      \
    assert_eq(rows(m1), rows(m2));\
    assert_eq(cols(m1), cols(m2));\
    asserts_ran++;                                                          \
    int failed = 0;                                                         \
    for (int i = 0; i < rows(m1); i++) {                                    \
      for (int j = 0; j < cols(m1); j++) {                                  \
        if (fabsf(matrix_get(m1, i, j) - matrix_get(m2, i, j)) > epsilon) { \
          failed = 1;                                                       \
        }                                                                   \
      }                                                                     \
    }                                                                       \
    if (failed) {                                                           \
      printf("%s(line %d): got: \n", __func__, __LINE__);                   \
      pretty_print(m1);                                                     \
      printf("expected: \n");                                               \
      pretty_print(m2);                                                     \
      asserts_failed++;                                                     \
    }                                                                       \
  } while (0)

#define run_test(test)                                                 \
  do {                                                                 \
    asserts_ran = asserts_failed = 0;                                  \
    test();                                                            \
    tests_ran++;                                                       \
    if (asserts_failed > 0) {                                          \
      tests_failed++;                                                  \
      printf("****%s: %d asserts failed out of %d asserts\n\n", #test, \
             asserts_failed, asserts_ran);                             \
    }                                                                  \
  } while (0)

static matrix_t *matrix_from_arr(int row, int col, float *arr) {
  matrix_t *m = init_matrix(row, col);
  for (int i = 0; i < rows(m); i++) {
    for (int j = 0; j < cols(m); j++) {
      matrix_set(m, i, j, arr[j + i * col]);
    }
  }
  return m;
}

#define matrix_verify(m, arr)\
  do{\
      matrix_t *exp = matrix_from_arr(rows(m), cols(m), arr); \
      assert_matrix_eq(m, exp);\
      destroy_matrix(exp);\
  } while (0)\


static void destroy_matrices(int num, ...){
  va_list args;
  va_start(args,num);
  for (int i=0;i < num;i++){
    destroy_matrix(va_arg(args, matrix_t*));
  }
}

void test_create_matrix() {
  matrix_t *m = init_matrix(1, 1);
  assert_ptr_notnull(m);
  destroy_matrix(m);
}

void test_fill_matrix() {
  matrix_t *m = init_matrix(1, 1);
  matrix_fill(m, 42.0);
  for (int i = 0; i < rows(m); i++) {
    for (int j = 0; j < cols(m); j++) {
      assert_eq_float(matrix_get(m, i, j), 42.0);
    }
  }
  destroy_matrix(m);
}

void test_matrix_mul() {
  float a1[9] = {
    1, 0, 0, 
    0, 1, 0, 
    0, 0, 1
  };
  matrix_t *m1 = matrix_from_arr(3, 3, a1);

  float a2[9] = {
    2, 3, 2, 
    1, 1, 2, 
    1, 1, 1
  };
  matrix_t *m2 = matrix_from_arr(3, 3, a2);

  matrix_t *m3 = matrix_mul(m1, m2);
  assert_matrix_eq(m3, m2);

  matrix_imul(m1,m2);
  assert_matrix_eq(m1, m2);

  destroy_matrices(3, m1,m2,m3);

  float a4[3] ={
    1, 2, 3
  };
  matrix_t *m4 = matrix_from_arr(1,3,a4);
  
  float a5[3] = {
    4,
    5,
    6,
  };
  matrix_t *m5 = matrix_from_arr(3, 1, a5);

  float a45_exp[1] = {32};
  matrix_t *m45_act = matrix_mul(m4, m5);

  matrix_verify(m45_act, a45_exp); 

  matrix_imul(m4,m5);
  matrix_verify(m4, a45_exp); 

  destroy_matrices(3, m4,m5,m45_act);
}

void test_horizontal_stack() {
  float a1[9] = {
    1, 0, 0, 
    0, 1, 0, 
    0, 0, 1
  };
  matrix_t *m1 = matrix_from_arr(3, 3, a1);

  float a2[6] = {
    2, 3,
    4, 5, 
    6, 7
  };
  matrix_t *m2 = matrix_from_arr(3, 2, a2);

  float a1_2[15]={
    1, 0, 0, 2, 3, 
    0, 1, 0, 4, 5,
    0, 0, 1, 6, 7
  };

  matrix_t *m3 = horizontal_stack(m1, m2);
  matrix_verify(m3, a1_2);

  ihorizontal_stack(m1, m2);
  matrix_verify(m1, a1_2);

  destroy_matrices(3, m1,m2,m3);
}

void test_vertical_stack() {
  float a1[9] = {
    1, 0, 0, 
    0, 1, 0, 
    0, 0, 1
  };
  matrix_t *m1 = matrix_from_arr(3, 3, a1);

  float a2[9] = {
    2, 3, 0,
    1, 1, 0,
    1, 3, 0,
  };
  matrix_t *m2 = matrix_from_arr(3, 3, a2);

  float a1_2[18]={
    1, 0, 0, 
    0, 1, 0, 
    0, 0, 1,
    2, 3, 0,
    1, 1, 0,
    1, 3, 0
  };

  matrix_t *m3 = vertical_stack(m1, m2);
  matrix_verify(m3, a1_2);

  ivertical_stack(m1, m2);
  matrix_verify(m1, a1_2);

  destroy_matrices(3,m1,m2,m3);
}

void test_add_const(){
  float a1[9] = {
    1, 2, 3, 
    4, 5, 6, 
    7, 8, 9
  };
  matrix_t *m1 = matrix_from_arr(3, 3, a1);

  float a1_add_1[9] = {
    2, 3, 4,
    5, 6, 7,
    8, 9, 10
  };
  matrix_t *m1_add_1_act = matrix_add_const(m1, 1);
  matrix_verify(m1_add_1_act,a1_add_1);

  matrix_iadd_const(m1, 1);
  matrix_verify(m1,a1_add_1);

  destroy_matrices(2,m1,m1_add_1_act);
}


void run() {
  tests_ran = 0;
  tests_failed = 0;
  run_test(test_create_matrix);
  run_test(test_fill_matrix);
  run_test(test_matrix_mul);
  run_test(test_horizontal_stack);
  run_test(test_vertical_stack);
  run_test(test_add_const);
  if (tests_failed == 0) {
    printf(
        "********************\n"
        "WELL DONE!\n"
        "********************\n");
  } else {
    printf(
        "****************************************************\n"
        "%d incorrect functions out of %d tested\n"
        "****************************************************\n\n",
        tests_failed, tests_ran);
  }
}

int main(int argc, char **argv) {
  run();
  return EXIT_SUCCESS;
}
