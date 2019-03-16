class Matrix {
  int rows;
  int cols;
  float mutationRate = 0.02;
  
  float[][] data;
  
  Matrix (int r, int c) {
    data = new float[r][c];
    rows = r;
    cols = c;
    
    for (int i = 0; i < r; i++) {
      for (int j = 0; j < c; j++) {
        data[i][j] = 0;
      }
    }
  }
  
  Matrix (float[] arr) {
    rows = arr.length;
    cols = 1;
    data = new float[rows][cols];
    
    for (int i = 0; i < arr.length; i++) {
      data[i][0] = arr[i];
    }
  }
  
  Matrix addBias() {
    if (cols != 1) {
      print("ADDED BIAS NODE TO NON-1D MATRIX!");
    }
    
    Matrix m = new Matrix(rows + 1, 1);
    
    for (int i = 0; i < rows; i++) {
      m.data[i][0] = data[i][0];
    }
    
    m.data[m.rows - 1][0] = 1;
    
    return m;
  }
  
  Matrix randomize() {
    Matrix m = new Matrix(rows, cols);
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        m.data[i][j] = random(-1, 1);
      }
    }
    
    return m;
  }
  
  Matrix mutate() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (mutationRate > random(1)) {
          data[i][j] += randomGaussian() / 5;
          
          if (data[i][j]>1) {
            data[i][j] = 1;
          }
          if (data[i][j] <-1) {
            data[i][j] = -1;
          }
        }
      }
    }
    
    return this;
  }
  
  Matrix multiply(Matrix m) {
    Matrix r = new Matrix(rows, m.cols);
    
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
    }
    else {
      print("ERROR");
    }
    
    return r;
  }
  
  /* Applies the sigmoid function to all values in the matrix and returns it. */
  Matrix applySigmoid() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        float x = data[i][j];
        /* This implements the sigmoid function: 1/(1+e^-x). */
        data[i][j] = 1.0/(1.0 + exp(-x));
      }
    }
    
    return this;
  }
  
  float[] toArray() {
    float[] arr = new float[rows*cols];
    
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        arr[i*cols + j] = data[i][j];
      }
    }
    
    return arr;
  }
}
