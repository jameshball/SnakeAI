package com.company;

import org.json.JSONArray;
import org.json.JSONObject;

import static com.company.Main.networkStructure;

/* This class is responsible for managing and creating neural networks for the Player class. */
class NeuralNetwork {
  Matrix[] weightMatrices;

  NeuralNetwork() {
    weightMatrices = new Matrix[networkStructure.length - 1];

    /* Initialises n-1 weight matrices where n is the number of layers in the network. */
    for (int i = 0; i < weightMatrices.length; i++) {
      /* This initialises a weight matrix, considering the extra bias node. */
      weightMatrices[i] = new Matrix(networkStructure[i + 1], networkStructure[i] + 1).randomize();
    }
  }

  /* Loads a NeuralNetwork object from a JSONObject. */
  NeuralNetwork(JSONObject neuralNet) {
    /* Executes NeuralNetwork() constructor. */
    this();

    for (int i = 0; i < weightMatrices.length; i++) {
      /* Fetches the specified weight matrix stored in this JSONObject. */
      JSONObject matrix = neuralNet.getJSONObject("weightMatrix " + Integer.toString(i));

      for (int j = 0; j < weightMatrices[i].rows; j++) {
        /* Fetches the specified row stored in this JSONObject. */
        JSONArray row = matrix.getJSONArray(Integer.toString(j));

        for (int k = 0; k < weightMatrices[i].cols; k++) {
          /* Sets the value of the weight to the weight retrieved from the JSONArray. */
          weightMatrices[i].data[j][k] = row.getFloat(k);
        }
      }
    }
  }

  /* Feeds an input array through the NN to return the output layer. */
  float[] feedForward(float[] arr) throws IllegalArgumentException {
    /* Checks to see the arr parameter is the correct length. */
    if (networkStructure[0] == arr.length) {
      Matrix currentLayer = new Matrix(arr);

      /* Works through the NN and repeatedly calculates the next layer by multiplying the weight matrix
         by the current layer and applying the activation function. */
      for (int i = 0; i < weightMatrices.length; i++) {
        currentLayer = weightMatrices[i].multiply(currentLayer.addBias()).applyReLu();
      }

      return currentLayer.toArray();
    }
    else {
      throw new IllegalArgumentException();
    }
  }

  /* Mutates all weightMatrices and returns the NN object. */
  NeuralNetwork mutateWeights() {
    for (int i = 0; i < weightMatrices.length; i++) {
      weightMatrices[i].mutate();
    }

    return this;
  }

  JSONObject save() {
    JSONObject neuralNet = new JSONObject();

    neuralNet.put("layerCount", networkStructure.length);
    neuralNet.put("matrixCount", weightMatrices.length);

    for (int i = 0; i < networkStructure.length; i++) {
      neuralNet.put("length " + i, networkStructure[i]);
    }

    for (int i = 0; i < weightMatrices.length; i++) {
      JSONObject matrix = new JSONObject();

      for (int j = 0; j < weightMatrices[i].rows; j++) {
        JSONArray row = new JSONArray();

        for (int k = 0; k < weightMatrices[i].cols; k++) {
          row.put(k, weightMatrices[i].data[j][k]);
        }

        matrix.put(Integer.toString(j), row);
      }

      neuralNet.put("weightMatrix " + i, matrix);
    }

    return neuralNet;
  }
}
