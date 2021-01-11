package sh.ball.ai;

import java.util.concurrent.ThreadLocalRandom;

public class Matrix {
  public final float[][] data;
  private final int rows;
  private final int cols;

  public Matrix(int rows, int cols) {
    this.data = new float[rows][cols];
    this.rows = rows;
    this.cols = cols;
  }

  public Matrix(float[][] data) {
    this.data = data;
    this.rows = data.length;
    this.cols = data[0].length;
  }

  public int numRows() {
    return rows;
  }

  public int numCols() {
    return cols;
  }

  public void set(int i, int j, float value) {
    data[i][j] = value;
  }

  public float get(int i, int j) {
    return data[i][j];
  }

  public Matrix randomize() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        data[i][j] = ThreadLocalRandom.current().nextFloat() * 2 - 1;
      }
    }

    return this;
  }

  public Matrix multiply(Matrix b) {
    final int OUTER_BLOCK_SIZE = 256;
    final int INNER_BLOCK_SIZE = 2048;
    final int aNRow = rows;
    final int aNCol = cols;
    final int bNCol = b.cols;

    final float[][] ret = new float[aNRow][bNCol];

    for (int kk = 0; kk < aNCol; kk += OUTER_BLOCK_SIZE) {
      final int maxk = Math.min(kk + OUTER_BLOCK_SIZE, aNCol);

      for (int jj = 0; jj < bNCol; jj += INNER_BLOCK_SIZE) {
        final int maxj = Math.min(jj + INNER_BLOCK_SIZE, bNCol);

        for (int i = 0; i < aNRow; i++) { // going down a
          final float[] retRow = ret[i];

            for (int k = kk; k < maxk; k++) { // going across on a and down b, one outer block
              final double aVal = data[i][k];
              if (aVal == 0) continue;
              for (int j = jj; j < maxj; j++) { // going across on b, one inner block
                retRow[j]+=aVal * b.data[k][j];
              }
            }
        }
      }
    }
    return new Matrix(ret);
  }
}
