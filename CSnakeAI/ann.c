#include <stdlib.h>
#include "ann.h"
#include "common.h"
#include "matrix.h"

#define MUTATION_RATE 0.02
#define NUM_LAYERS 3

const int layer_dims[NUM_LAYERS] = {24, 16, 4};

ann_t init_ann() {
  ann_t ann = malloc((NUM_LAYERS - 1) * sizeof(matrix_t *));
  null_check(ann);

  for (int i = 0; i < NUM_LAYERS - 1; i++) {
    // layer_dims[i] + 1 for bias node weights
    ann[i] = init_random(layer_dims[i + 1], layer_dims[i] + 1);
  }

  return ann;
}

void destroy_ann(ann_t ann) {
  if (ann) {
    for (int i = 0; i < NUM_LAYERS - 1; i++) {
      destroy_matrix(ann[i]);
    }
    free(ann);
  }
}

// assumes input is the correct length
matrix_t *feed_forward(ann_t ann, float *input) {
  matrix_t *current_layer = matrix_ifrom_arr(layer_dims[0], 1, input);

  for (int i = 0; i < NUM_LAYERS - 1; i++) {
    matrix_t *orig = current_layer;
    current_layer = matrix_irelu(matrix_mul(ann[i], matrix_iadd_bias(current_layer)));
    destroy_matrix(orig);
  }

  return current_layer;
}

ann_t ann_mutate(ann_t ann) {
  for (int i = 0; i < NUM_LAYERS - 1; i++) {
    matrix_imutate(ann[i], MUTATION_RATE);
  }

  return ann;
}
