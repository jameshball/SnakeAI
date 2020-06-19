//#ifdef __CUDACC__

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>
#include <cuda_runtime.h>
#include "cublas_v2.h"

#include "matrix.h"

#define HOST_ELEM(m, row, col) ((m)->hostM[(row) + (col) * (m)->rows])
#define DEVICE_ELEM(m, row, col) ((m)->devM[(row) + (col) * (m)->rows])

#define size(m) m->rows * m->cols
#define ELEM_WISE(m, i, op)           \
  for (int i = 0; i < size(m); i++) { \
    op;                               \
  }

struct matrix_t {
  int rows;
  int cols;

  bool dirtyHost;
  float *hostM;
  bool dirtyDevice;
  float *devM;

  cublasHandle_t cublasH;
};

static inline cublasStatus_t host_to_dev(matrix_t *m){
  assert(!m->dirtyHost);

  cublasStatus_t stat = cublasSetMatrix(m->rows, m->cols, sizeof(float), m->hostM, m->rows, m->devM, m->rows);
  if (stat == CUBLAS_STATUS_SUCCESS) {
    m->dirtyDevice = false;
  } else {
    printf("host to device transfer failed");
  }
  return stat;
}

static inline cublasStatus_t dev_to_host(matrix_t *m){
  assert(!m->dirtyDevice);

  cublasStatus_t stat = cublasGetMatrix(m->rows, m->cols, sizeof(float), m->devM, m->rows, m->hostM, m->rows);
  if (stat == CUBLAS_STATUS_SUCCESS) {
    m->dirtyHost = false;
  } else {
    printf("device to host transfer failed");
  }
  return stat;
}

static inline void sync_host(matrix_t *m){
  if (m->dirtyHost){
    dev_to_host(m);
  }
}

static inline void sync_dev(matrix_t *m){
  if (m->dirtyDevice){
    host_to_dev(m);
  }
}

matrix_t *init_matrix(int rows, int cols){
  float *hostM =(float*) calloc(rows * cols, sizeof(float));
  if (!hostM){
    printf("RAM allocation failed\n");
    return NULL;
  }

  float* devM;
  cudaError_t cudaStat = cudaMalloc((void **)&devM, rows * cols * sizeof(float));
  if (cudaStat != cudaSuccess){
    printf("device allocation failed\n");
    return NULL;
  }

  cublasHandle_t handle;
  cublasStatus_t stat = cublasCreate(&handle);
  if (stat != CUBLAS_STATUS_SUCCESS){
    printf("cublas initialisation failed\n");
    return NULL;
  }

  stat = cublasSetMatrix(rows, cols, sizeof(float), hostM, rows, devM, rows);
  if (stat != CUBLAS_STATUS_SUCCESS) {
    printf("host to device transfer failed at %d", __LINE__);
    cudaFree(devM);
    cublasDestroy(handle);
    return NULL;
  }

  matrix_t *m = (matrix_t*) malloc(sizeof(matrix_t));

  m->rows = rows;
  m->cols = cols;
  m->hostM = hostM;
  m->devM = devM;
  m->dirtyHost = false;
  m->dirtyDevice = false;

  m->cublasH = handle;
  
  return m;
}

void matrix_fill(matrix_t *m, float x){
  ELEM_WISE(m,i,m->hostM[i] = x);
}



//#endif
