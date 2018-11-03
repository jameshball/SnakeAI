package com.company;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.FileNotFoundException;
import java.io.PrintWriter;

class NeuralNetwork {
  int[] lengths;
  
  Matrix[] weightMatrices;
  
  NeuralNetwork (int[] inputLengths) {
    lengths = inputLengths;
    
    initializeMatrices(lengths.length - 1);
  }
  
  NeuralNetwork (int[] arrLengths, Matrix[] inputWeightMatrices) {
    lengths = arrLengths;
    weightMatrices = inputWeightMatrices;
  }
  
  NeuralNetwork(String filePath) {
    load(filePath);
  }
  
  Matrix feedForward(float[] arr) {
    Matrix input = new Matrix(arr);
    
    Matrix[] layers = new Matrix[lengths.length];
    
    for (int i = 0; i < layers.length; i++) {
      layers[i] = new Matrix(lengths[i], 1);
    }
    
    if (input.rows == layers[0].rows) {
      layers[0] = input.addBias();
      for (int i = 1; i < layers.length - 1; i++) {
        layers[i] = weightMatrices[i - 1].multiply(layers[i - 1]).applySigmoid().addBias();
      }
      
      layers[layers.length - 1] = weightMatrices[weightMatrices.length - 1].multiply(layers[layers.length - 2]).applySigmoid();
      
      return layers[layers.length - 1];
    }
    
    return null;
  }
  
  NeuralNetwork mutateWeights() {
    NeuralNetwork mutated = new NeuralNetwork(lengths, weightMatrices);
    
    for (int i = 0; i < mutated.weightMatrices.length; i++) {
      mutated.weightMatrices[i].mutate();
    }
    
    return mutated;
  }
  
  boolean dimensionsAreIdentical (NeuralNetwork nn2) {
    for (int i = 0; i < lengths.length; i++) {
      if (lengths[i] != nn2.lengths[i]) {
        return false;
      }
    }
    
    return true;
  }
  
  void save(String filePath) {
    JSONObject neuralNet = new JSONObject();
    
    neuralNet.put("layerCount", lengths.length);
    neuralNet.put("matrixCount", weightMatrices.length);
    
    for (int i = 0; i < lengths.length; i++) {
      neuralNet.put("length " + Integer.toString(i), lengths[i]);
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
      
        neuralNet.put("weightMatrix " + Integer.toString(i), matrix);
    }

      try (PrintWriter out = new PrintWriter(filePath)) {
          out.println(neuralNet.toString());
      }
      catch (FileNotFoundException e) {

      }
  }
  
  void load(String filePath) {
    //needs to be implemented;
  }
  
  void initializeMatrices(int arrLength) {
    weightMatrices = new Matrix[arrLength];
    
    for (int i = 0; i < weightMatrices.length; i++) {
      //Considering the bias
      weightMatrices[i] = new Matrix(lengths[i + 1], lengths[i] + 1).randomize();
    }
  }
}
