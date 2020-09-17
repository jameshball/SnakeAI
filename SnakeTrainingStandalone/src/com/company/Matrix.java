package com.company;

import static jcuda.jcublas.JCublas2.cublasCreate;
import static jcuda.jcublas.JCublas2.cublasDestroy;
import static jcuda.jcublas.JCublas2.cublasSgemmBatched;
import static jcuda.runtime.JCuda.cudaFree;
import static jcuda.runtime.JCuda.cudaMalloc;
import static jcuda.runtime.JCuda.cudaMemcpy;
import static jcuda.runtime.cudaMemcpyKind.cudaMemcpyDeviceToHost;
import static jcuda.runtime.cudaMemcpyKind.cudaMemcpyHostToDevice;

import jcuda.Pointer;
import jcuda.Sizeof;
import jcuda.jcublas.JCublas2;
import jcuda.jcublas.cublasHandle;
import jcuda.jcublas.cublasOperation;
import jcuda.runtime.JCuda;

import java.util.Random;

/**
 * This is a sample class demonstrating the application of JCublas2 for
 * performing a batched BLAS 'sgemm' operation, i.e. for computing the
 * multiple matrices <br>
 * <code>C = alpha * A * B + beta * C</code> <br>
 * for single-precision floating point values alpha and beta, and matrices
 * A, B and C
 */
class Matrix
{
  static void sgemmBatchedJCublas2(int m, int n, int k, float alpha,
                                   float h_A[][], float h_B[][], float beta, float h_C[][])
  {
    int b = h_A.length;
    Pointer[] h_Aarray = new Pointer[b];
    Pointer[] h_Barray = new Pointer[b];
    Pointer[] h_Carray = new Pointer[b];
    for (int i = 0; i < b; i++)
    {
      h_Aarray[i] = new Pointer();
      h_Barray[i] = new Pointer();
      h_Carray[i] = new Pointer();
      cudaMalloc(h_Aarray[i], m * k * Sizeof.FLOAT);
      cudaMalloc(h_Barray[i], k * n * Sizeof.FLOAT);
      cudaMalloc(h_Carray[i], m * n * Sizeof.FLOAT);
      cudaMemcpy(h_Aarray[i], Pointer.to(h_A[i]),
        m * k * Sizeof.FLOAT, cudaMemcpyHostToDevice);
      cudaMemcpy(h_Barray[i], Pointer.to(h_B[i]),
        k * n * Sizeof.FLOAT, cudaMemcpyHostToDevice);
      cudaMemcpy(h_Carray[i], Pointer.to(h_C[i]),
        m * n * Sizeof.FLOAT, cudaMemcpyHostToDevice);
    }
    Pointer d_Aarray = new Pointer();
    Pointer d_Barray = new Pointer();
    Pointer d_Carray = new Pointer();
    cudaMalloc(d_Aarray, b * Sizeof.POINTER);
    cudaMalloc(d_Barray, b * Sizeof.POINTER);
    cudaMalloc(d_Carray, b * Sizeof.POINTER);
    cudaMemcpy(d_Aarray, Pointer.to(h_Aarray),
      b * Sizeof.POINTER, cudaMemcpyHostToDevice);
    cudaMemcpy(d_Barray, Pointer.to(h_Barray),
      b * Sizeof.POINTER, cudaMemcpyHostToDevice);
    cudaMemcpy(d_Carray, Pointer.to(h_Carray),
      b * Sizeof.POINTER, cudaMemcpyHostToDevice);

    cublasHandle handle = new cublasHandle();
    cublasCreate(handle);

    cublasSgemmBatched(
      handle,
      cublasOperation.CUBLAS_OP_N,
      cublasOperation.CUBLAS_OP_N,
      m, n, k,
      Pointer.to(new float[]{ alpha }),
      d_Aarray, n, d_Barray, n,
      Pointer.to(new float[]{ beta }),
      d_Carray, n, b);

    for (int i = 0; i < b; i++)
    {
      cudaMemcpy(Pointer.to(h_C[i]), h_Carray[i],
        m * n * Sizeof.FLOAT, cudaMemcpyDeviceToHost);
      cudaFree(h_Aarray[i]);
      cudaFree(h_Barray[i]);
      cudaFree(h_Carray[i]);
    }
    cudaFree(d_Aarray);
    cudaFree(d_Barray);
    cudaFree(d_Carray);
    cublasDestroy(handle);
  }

  /**
   * Creates an array of the specified size, containing float values from
   * the range [0.0f, 1.0f)
   *
   * @param n The size of the array
   * @return The array of random values
   */
  public static float[] createRandomFloatData(int n)
  {
    Random random = new Random(0);
    float a[] = new float[n];
    for (int i = 0; i < n; i++)
    {
      a[i] = random.nextFloat();
    }
    return a;
  }

  /**
   * Compares the given result against a reference, and returns whether the
   * error norm is below a small epsilon threshold
   *
   * @param result The result
   * @param reference The reference
   * @return Whether the arrays are equal based on the error norm
   * @throws NullPointerException If any argument is <code>null</code>
   * @throws IllegalArgumentException If the arrays have different lengths
   */
  public static boolean equalByNorm(float result[], float reference[])
  {
    if (result == null)
    {
      throw new NullPointerException("The result is null");
    }
    if (reference == null)
    {
      throw new NullPointerException("The reference is null");
    }
    if (result.length != reference.length)
    {
      throw new IllegalArgumentException(
        "The result and reference array have different lengths: " +
          result.length + " and " + reference.length);
    }
    final float epsilon = 1e-6f;
    float errorNorm = 0;
    float refNorm = 0;
    for (int i = 0; i < result.length; ++i)
    {
      float diff = reference[i] - result[i];
      errorNorm += diff * diff;
      refNorm += reference[i] * result[i];
    }
    errorNorm = (float) Math.sqrt(errorNorm);
    refNorm = (float) Math.sqrt(refNorm);
    if (Math.abs(refNorm) < epsilon)
    {
      return false;
    }
    return (errorNorm / refNorm < epsilon);
  }
}
