package sh.ball.ai;

import org.json.JSONArray;
import org.json.JSONObject;
import org.ejml.simple.SimpleMatrix;

/* This class is responsible for managing and creating neural networks for the Player class. */
public class NeuralNetwork {

  private static float MUTATION_RATE = 0.02f;
  public SimpleMatrix[] weightMatrices;
  public final int[] networkStructure;

  public NeuralNetwork(int[] networkStructure) {
    this.networkStructure = networkStructure;
    initialiseWeightMatrices();
  }

  /* Loads a NeuralNetwork object from a JSONObject. */
  public NeuralNetwork(JSONObject neuralNet) {
    int layerCount = neuralNet.getInt("layerCount");
    this.networkStructure = new int[layerCount];

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
    weightMatrices = new SimpleMatrix[networkStructure.length - 1];
    /* Initialises n-1 weight matrices where n is the number of layers in the network. */
    for (int i = 0; i < weightMatrices.length; i++) {
      /* This initialises a weight matrix, considering the extra bias node. */
      weightMatrices[i] = SimpleMatrix.random_DDRM(networkStructure[i + 1],
        networkStructure[i] + 1, -1, 1, Population.rnd);
    }
  }

  /* Feeds an input array through the NN to return the output layer. */
  public float[] feedForward(float[] input) throws IllegalArgumentException {
    float[][] floatMatrix = new float[input.length][];

    for (int j = 0; j < floatMatrix.length; j++) {
      floatMatrix[j] = new float[1];
      floatMatrix[j][0] = input[j];
    }

    SimpleMatrix currentLayer = new SimpleMatrix(floatMatrix);

    for (int i = 0; i < networkStructure.length - 1; i++) {
      currentLayer = applyReLu(weightMatrices[i].mult(addBias(currentLayer)));
    }

    return toArray(currentLayer);
  }

  /* Converts the matrix data to a 1D array of length rows*cols. */
  private float[] toArray(SimpleMatrix m) {
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

  /* This adds a bias node (node with a constant value of 1.0) to a one-column matrix. */
  private static SimpleMatrix addBias(SimpleMatrix m) throws IllegalArgumentException {
    SimpleMatrix n;
    int rows = m.numRows();
    int cols = m.numCols();

    /* This should only add a bias node to a one-column matrix so an exception is thrown if the matrix
    is not Nx1. */
    if (cols == 1) {
      n = new SimpleMatrix(rows + 1, cols);

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

  /* Applies the ReLu function to all values in the matrix and returns it. */
  private static SimpleMatrix applyReLu(SimpleMatrix m) {
    for (int i = 0; i < m.numRows(); i++) {
      for (int j = 0; j < m.numCols(); j++) {
        m.set(i, j, State.relu((float) m.get(i, j)));
      }
    }

    return m;
  }

  /* Applies the sigmoid function to all values in the matrix and returns it. */
  private static SimpleMatrix applySigmoid(SimpleMatrix m) {
    for (int i = 0; i < m.numRows(); i++) {
      for (int j = 0; j < m.numCols(); j++) {
        m.set(i, j, State.sigmoid((float) m.get(i, j)));
      }
    }

    return m;
  }

  private SimpleMatrix mutate(SimpleMatrix m) {
    for (int i = 0; i < m.numRows(); i++) {
      for (int j = 0; j < m.numCols(); j++) {
        /* The mutationRate hyper-parameter in the Main class determines how often this occurs. */
        if (Population.rnd.nextFloat() < MUTATION_RATE) {
          /* randomGaussian() generates a random number using normalized Gaussian distribution. Dividing
          by 5 reduces how big of an impact it has on the AI's performance as it is unlikely to have a
          positive impact. */
          double cellValue = m.get(i, j);
          m.set(i, j, cellValue + Population.rnd.nextGaussian() / 5);

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
    for (SimpleMatrix weightMatrix : weightMatrices) {
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
