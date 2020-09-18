package com.company;

import org.json.JSONArray;
import org.json.JSONObject;
import org.ejml.simple.SimpleMatrix;

import java.util.Arrays;

import static com.company.HelperClass.random;
import static com.company.HelperClass.randomGaussian;
import static com.company.Main.networkStructure;
import static java.lang.Math.exp;

/* This class is responsible for managing and creating neural networks for the Player class. */
class NeuralNetwork {
  public static float[][] initialiseNeuralNetwork() {
    float[][] weightMatrices = new float[networkStructure.length - 1][];

    /* Initialises n-1 weight matrices where n is the number of layers in the network. */
    for (int i = 0; i < weightMatrices.length; i++) {
      /* This initialises a weight matrix, considering the extra bias node. */
      weightMatrices[i] = Matrix.randomMatrix(networkStructure[i + 1] * (networkStructure[i] + 1));
    }

    return weightMatrices;
  }

  /* Loads a NeuralNetwork object from a JSONObject. */
  public static float[][] load(JSONObject neuralNet) {
    /* Executes NeuralNetwork() constructor. */
    float[][] weightMatrices = initialiseNeuralNetwork();

    for (int i = 0; i < weightMatrices.length; i++) {
      /* Fetches the specified weight matrix stored in this JSONObject. */
      JSONObject matrix = neuralNet.getJSONObject("weightMatrix " + i);
      int numRows = networkStructure[i + 1];
      int numCols = networkStructure[i] + 1;

      for (int j = 0; j < numRows; j++) {
        /* Fetches the specified row stored in this JSONObject. */
        JSONArray row = matrix.getJSONArray(Integer.toString(j));

        for (int k = 0; k < numCols; k++) {
          /* Sets the value of the weight to the weight retrieved from the JSONArray. */
          weightMatrices[i][j * numCols + k] = row.getFloat(k);
        }
      }
    }

    return weightMatrices;
  }

  /* Feeds an input array through the NN to return the output layer. */
  public static void feedForward(float[][] inputs, Player[] players) {
    float[][] h_B = inputs;
    int n = 1;

    /* Works through the NN and repeatedly calculates the next layer by multiplying the weight matrix
    by the current layer and applying the activation function. */
    for (int i = 0; i < networkStructure.length - 1; i++) {
      int m = networkStructure[i + 1];
      int k = networkStructure[i] + 1;
      float[][] h_A = new float[players.length][];

      for (int j = 0; j < players.length; j++) {
        h_A[j] = players[j].nn[i];
      }

      addBias(h_B);
      if (h_A[0].length != m * k || h_B[0].length != k * n) {
        System.out.println("m: " + m + ". n: " + n + ". k: " + k);
        System.out.println("A has " + h_A[0].length + " elements when it should have " + (m * k));
        System.out.println("B has " + h_B[0].length + " elements when it should have " + (k * n));
      }

      h_B = applyReLu(Matrix.batchMatrixMultiplyCPU(m, n, k, 1, h_A, h_B, 0));
    }

    for (int i = 0; i < players.length; i++) {
      players[i].output = h_B[i];
    }
  }

  /* Converts the matrix data to a 1D array of length rows*cols. */
  float[] toArray(SimpleMatrix m) {
    int rows = m.numRows();
    int cols = m.numCols();

    float[] arr = new float[rows * cols];

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        arr[i * cols + j] = (float) m.get(i, j);
      }
    }

    return arr;
  }

  /* This adds a bias node (node with a constant value of 1.0) to an array of one-column matrices. */
  static float[][] addBias(float[][] ms) {
    for (int i = 0; i < ms.length; i++) {
      int rows = ms[i].length;
      float[] n = new float[rows + 1];
      System.arraycopy(ms[i], 0, n, 0, rows);
      n[rows] = 1;
      ms[i] = n;
    }

    return ms;
  }

  /* Applies the ReLu function to all values in the matrix and returns it. */
  public static float[][] applyReLu(float[][] ms) {
    for (int i = 0; i < ms.length; i++) {
      for (int j = 0; j < ms[i].length; j++) {
        /* This is a simple max(0, data[i][j]) function. */
        if (ms[i][j] < 0) {
          ms[i][j] = 0;
        }
      }
    }

    return ms;
  }

  /* Applies the sigmoid function to all values in the matrix and returns it. */
  public static float[][] applySigmoid(float[][] ms) {
    for (int i = 0; i < ms.length; i++) {
      for (int j = 0; j < ms[i].length; j++) {
        double x = ms[i][j];
        /* This implements the sigmoid function: 1/(1+e^-x). */
        ms[i][j] = (float) (1.0f / (1.0 + exp(-x)));
      }
    }

    return ms;
  }

  /* Mutates all weightMatrices and returns the NN object. */
  public static float[][] mutateWeights(float[][] weightMatrices) {
    for (int i = 0; i < weightMatrices.length; i++) {
      for (int j = 0; j < weightMatrices[i].length; j++) {
        if (random(1) < Main.mutationRate) {
          /* randomGaussian() generates a random number using normalized Gaussian distribution. Dividing
          by 5 reduces how big of an impact it has on the AI's performance as it is unlikely to have a
          positive impact. */
          weightMatrices[i][j] += randomGaussian() / 5;

          /* If the weight falls outside the -1.0 to 1.0 range after mutation, limit it to this range. */
          if (weightMatrices[i][j] > 1) {
            weightMatrices[i][j] = 1;
          } else if (weightMatrices[i][j] < -1) {
            weightMatrices[i][j] = -1;
          }
        }
      }
    }

    return weightMatrices;
  }

  public static JSONObject save(float[][] weightMatrices) {
    JSONObject neuralNet = new JSONObject();

    neuralNet.put("layerCount", networkStructure.length);
    neuralNet.put("matrixCount", weightMatrices.length);

    for (int i = 0; i < networkStructure.length; i++) {
      neuralNet.put("length " + i, networkStructure[i]);
    }

    for (int i = 0; i < weightMatrices.length; i++) {
      JSONObject matrix = new JSONObject();

      int numRows = networkStructure[i + 1];
      int numCols = networkStructure[i] + 1;

      for (int j = 0; j < numRows; j++) {
        JSONArray row = new JSONArray();

        for (int k = 0; k < numCols; k++) {
          row.put(k, weightMatrices[i][j * numCols + k]);
        }

        matrix.put(Integer.toString(j), row);
      }

      neuralNet.put("weightMatrix " + i, matrix);
    }

    return neuralNet;
  }
}
