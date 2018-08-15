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
    
    neuralNet.setInt("layerCount", lengths.length);
    neuralNet.setInt("matrixCount", weightMatrices.length);
    
    for (int i = 0; i < lengths.length; i++) {
      neuralNet.setInt("length " + Integer.toString(i), lengths[i]);
    }
    
    for (int i = 0; i < weightMatrices.length; i++) {
      JSONObject matrix = new JSONObject();
      
      for (int j = 0; j < weightMatrices[i].rows; j++) {
        JSONArray row = new JSONArray();
        
        for (int k = 0; k < weightMatrices[i].cols; k++) {
          row.setFloat(k, weightMatrices[i].data[j][k]);
        }
        
        matrix.setJSONArray(Integer.toString(j), row);
      }
      
      neuralNet.setJSONObject("weightMatrix " + Integer.toString(i), matrix);
    }
    
    saveJSONObject(neuralNet, filePath);
  }
  
  void load(String filePath) {
    JSONObject neuralNet = loadJSONObject(filePath);
    
    lengths = new int[neuralNet.getInt("layerCount")];
    
    for (int i = 0; i < lengths.length; i++) {
        lengths[i] = neuralNet.getInt("length " + Integer.toString(i));
    }
    
    initializeMatrices(neuralNet.getInt("matrixCount"));
    
    for (int i = 0; i < weightMatrices.length; i++) {
      JSONObject matrix = neuralNet.getJSONObject("weightMatrix " + Integer.toString(i));
    
      for (int j = 0; j < weightMatrices[i].rows; j++) {
        JSONArray row = matrix.getJSONArray(Integer.toString(j));
        
        for (int k = 0; k < weightMatrices[i].cols; k++) {
          weightMatrices[i].data[j][k] = row.getFloat(k);
        }
      }
    }
  }
  
  void initializeMatrices(int arrLength) {
    weightMatrices = new Matrix[arrLength];
    
    for (int i = 0; i < weightMatrices.length; i++) {
      //Considering the bias
      weightMatrices[i] = new Matrix(lengths[i + 1], lengths[i] + 1).randomize();
    }
  }
}
