package sh.ball.ai;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

/* This class is responsible for managing and creating neural networks for the Player class. */
public class NeuralNetwork {

  private static final float MUTATION_RATE = 0.02f;
  public Matrix[] weightMatrices;
  public final int[] networkStructure;

  private final State state;

  public NeuralNetwork(int[] networkStructure, State state) {
    this.networkStructure = networkStructure;
    this.state = state;
    initialiseWeightMatrices();
  }

  /* Loads a NeuralNetwork object from a JSONObject. */
  public NeuralNetwork(JSONObject neuralNet, State state) {
    int layerCount = neuralNet.getInt("layerCount");
    this.networkStructure = new int[layerCount];
    this.state = state;

    for (int i = 0; i < layerCount; i++) {
      networkStructure[i] = neuralNet.getInt("length " + i);
    }

    initialiseWeightMatrices();

    for (int i = 0; i < weightMatrices.length; i++) {
      /* Fetches the specified weight matrix stored in this JSONObject. */
      JSONObject matrix = neuralNet.getJSONObject("weightMatrix " + i);

      for (int j = 0; j < weightMatrices[i].numRows(); j++) {
        /* Fetches the specified row stored in this JSONObject. */
        JSONArray row = matrix.getJSONArray(Integer.toString(j));

        for (int k = 0; k < weightMatrices[i].numCols(); k++) {
          /* Sets the value of the weight to the weight retrieved from the JSONArray. */
          weightMatrices[i].set(j, k, row.getFloat(k));
        }
      }
    }
  }

  private void initialiseWeightMatrices() {
    weightMatrices = new Matrix[networkStructure.length - 1];
    /* Initialises n-1 weight matrices where n is the number of layers in the network. */
    for (int i = 0; i < weightMatrices.length; i++) {
      /* This initialises a weight matrix, considering the extra bias node. */
      weightMatrices[i] = new Matrix(networkStructure[i + 1], networkStructure[i] + 1).randomize();
    }
  }

  /* Feeds an input array through the NN to return the output layer. */
  public float[] feedForward(List<Float> input) throws IllegalArgumentException {
    float[][] floatMatrix = new float[input.size()][];

    for (int j = 0; j < floatMatrix.length; j++) {
      floatMatrix[j] = new float[1];
      floatMatrix[j][0] = input.get(j);
    }

    Matrix currentLayer = new Matrix(floatMatrix);

    for (int i = 0; i < networkStructure.length - 1; i++) {
      currentLayer = activate(weightMatrices[i].multiply(addBias(currentLayer)));
    }

    return toArray(currentLayer);
  }

  /* Converts the matrix data to a 1D array of length rows*cols. */
  private float[] toArray(Matrix m) {
    int rows = m.numRows();
    int cols = m.numCols();

    float[] arr = new float[rows * cols];

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        arr[i * cols + j] = m.get(i, j);
      }
    }

    return arr;
  }

  /* This adds a bias node (node with a constant value of 1.0) to a one-column matrix. */
  private static Matrix addBias(Matrix m) throws IllegalArgumentException {
    Matrix n;
    int rows = m.numRows();
    int cols = m.numCols();

    /* This should only add a bias node to a one-column matrix so an exception is thrown if the matrix
    is not Nx1. */
    if (cols == 1) {
      n = new Matrix(rows + 1, cols);

      for (int i = 0; i < rows; i++) {
        n.set(i, 0, m.get(i, 0));
      }

      n.set(rows, 0, 1);
    }
    else {
      throw new IllegalArgumentException();
    }

    return n;
  }

  /* Activates all values in the matrix and returns it. */
  private Matrix activate(Matrix m) {
    for (int i = 0; i < m.numRows(); i++) {
      for (int j = 0; j < m.numCols(); j++) {
        m.set(i, j, state.activate(m.get(i, j)));
      }
    }

    return m;
  }

  private Matrix mutate(Matrix m) {
    for (int i = 0; i < m.numRows(); i++) {
      for (int j = 0; j < m.numCols(); j++) {
        /* The mutationRate hyper-parameter in the Main class determines how often this occurs. */
        if (ThreadLocalRandom.current().nextFloat() < MUTATION_RATE) {
          /* randomGaussian() generates a random number using normalized Gaussian distribution. Dividing
          by 5 reduces how big of an impact it has on the AI's performance as it is unlikely to have a
          positive impact. */
          m.set(i, j, (float) (m.get(i, j) + ThreadLocalRandom.current().nextGaussian() / 5));
          double cellValue = m.get(i, j);

          /* If the weight falls outside the -1.0 to 1.0 range after mutation, limit it to this range. */
          if (cellValue > 1) {
            m.set(i, j, 1);
          } else if (cellValue < -1) {
            m.set(i, j, -1);
          }
        }
      }
    }

    return m;
  }

  /* Mutates all weightMatrices and returns the NN object. */
  public NeuralNetwork mutateWeights() {
    for (Matrix weightMatrix : weightMatrices) {
      mutate(weightMatrix);
    }

    return this;
  }

  public JSONObject save() {
    JSONObject neuralNet = new JSONObject();

    neuralNet.put("layerCount", networkStructure.length);
    neuralNet.put("matrixCount", weightMatrices.length);

    for (int i = 0; i < networkStructure.length; i++) {
      neuralNet.put("length " + i, networkStructure[i]);
    }

    for (int i = 0; i < weightMatrices.length; i++) {
      JSONObject matrix = new JSONObject();

      for (int j = 0; j < weightMatrices[i].numRows(); j++) {
        JSONArray row = new JSONArray();

        for (int k = 0; k < weightMatrices[i].numCols(); k++) {
          row.put(k, weightMatrices[i].get(j, k));
        }

        matrix.put(Integer.toString(j), row);
      }

      neuralNet.put("weightMatrix " + i, matrix);
    }

    return neuralNet;
  }
}
