package com.company;

import static com.company.HelperClass.random;
import static com.company.HelperClass.randomGaussian;
import static java.lang.Math.exp;

/* The Matrix class is used by the NeuralNetwork class to store the weight matrices.
It provides functions for manipulating and multiplying matrices. */
class Matrix {
  int rows;
  int cols;
  float[][] data;

  Matrix(int r, int c) {
    rows = r;
    cols = c;

    data = new float[rows][cols];

    /* Initialise all values in the matrix to 0. */
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        data[i][j] = 0;
      }
    }
  }

  /* This creates a one-column matrix with the values of the float[] parameter. */
  Matrix(float[] arr) {
    rows = arr.length;
    cols = 1;

    data = new float[rows][cols];

    for (int i = 0; i < rows; i++) {
      data[i][0] = arr[i];
    }
  }

  /* This adds a bias node (node with a constant value of 1.0) to a one-column matrix. */
  Matrix addBias() throws IllegalArgumentException {
    Matrix m;

    /* This should only add a bias node to a one-column matrix so an exception is thrown if the matrix
    is not Nx1. */
    if (cols == 1) {
      m = new Matrix(rows + 1, cols);

      for (int i = 0; i < rows; i++) {
        m.data[i][0] = data[i][0];
      }

      m.data[rows][0] = 1;
    } else {
      throw new IllegalArgumentException();
    }

    return m;
  }

  /* Randomizes the current matrix with weights in the range -1.0 to 1.0 and returns it. */
  Matrix randomize() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        data[i][j] = random(-1, 1);
      }
    }

    return this;
  }

  /* Mutates every value in the current matrix using the mutationRate hyper-parameter and returns it. */
  void mutate() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        /* The mutationRate hyper-parameter in the Main class determines how often this occurs. */
        if (random(1) < Main.mutationRate) {
          /* randomGaussian() generates a random number using normalized Gaussian distribution. Dividing
          by 5 reduces how big of an impact it has on the AI's performance as it is unlikely to have a
          positive impact. */
          data[i][j] += randomGaussian() / 5;

          /* If the weight falls outside the -1.0 to 1.0 range after mutation, limit it to this range. */
          if (data[i][j] > 1) {
            data[i][j] = 1;
          } else if (data[i][j] < -1) {
            data[i][j] = -1;
          }
        }
      }
    }
  }

  /* Multiplies two matrices and returns the result as a new Matrix object. */
  Matrix multiply(Matrix m) throws IllegalArgumentException {
    Matrix r = new Matrix(rows, m.cols);

    /* This performs matrix multiplication, as detailed in the Analysis section. The column number of this
    matrix must be the same as the row number of the matrix we are multiplying by. */
    if (cols == m.rows) {
      for (int i = 0; i < rows; i++) {
        for (int j = 0; j < m.cols; j++) {
          float sum = 0;
          for (int k = 0; k < cols; k++) {
            sum += data[i][k] * m.data[k][j];
          }

          r.data[i][j] = sum;
        }
      }
    } else {
      throw new IllegalArgumentException();
    }

    return r;
  }

  /* Applies the sigmoid function to all values in the matrix and returns it. */
  Matrix applySigmoid() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        float x = data[i][j];
        /* This implements the sigmoid function: 1/(1+e^-x). */
        data[i][j] = 1.0f / (float) (1.0 + exp(-x));
      }
    }

    return this;
  }

  /* Applies the ReLu function to all values in the matrix and returns it. */
  Matrix applyReLu() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        /* This is a simple max(0, data[i][j]) function. */
        if (data[i][j] < 0) {
          data[i][j] = 0;
        }
      }
    }

    return this;
  }

  /* Converts the matrix data to a 1D array of length rows*cols. */
  float[] toArray() {
    float[] arr = new float[rows * cols];

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        arr[i * cols + j] = data[i][j];
      }
    }

    return arr;
  }
}
