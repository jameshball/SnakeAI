#ifndef ANN_H
#define ANN_H

#include "matrix.h"

typedef matrix_t **ann_t;

ann_t init_ann();

void destroy_ann(ann_t ann);

matrix_t *feed_forward(ann_t ann, float *input);

ann_t ann_mutate(ann_t ann);

#endif
