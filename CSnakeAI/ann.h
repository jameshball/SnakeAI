#ifndef ANN_H
#define ANN_H

#include "matrix.h"

ann_t *init_ann();

float *feed_forward(ann_t **ann, float *input);

ann_t *ann_mutate(ann_t *ann);

#endif
