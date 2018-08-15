class NNGraph {
  NeuralNetwork nn;
  int sx;
  int sy;
  int padding;
  int neuronSize;
  
  NNGraph(NeuralNetwork neuralNet, int sizex, int sizey, int inputPadding, int inputNeuronSize) {
    nn = neuralNet;
    sx = sizex;
    sy = sizey;
    padding = inputPadding;
    neuronSize = inputNeuronSize;
  }
  
  void show(int px, int py) {
    PVector[][] layerLocations = new PVector[nn.lengths.length][];
    
    for (int i = 0; i < layerLocations.length; i++) {
      layerLocations[i] = new PVector[nn.lengths[i]];
    }
    
    int layerXSteps = (int)((sx - (2 * padding)) / nn.lengths.length);
    
    int layerYSteps, layerYPadding;
    
    for (int i = 0; i < layerLocations.length; i++) {
      layerYSteps = (int)((sy - (2 * padding)) / nn.lengths[i]);
      layerYPadding = (sy - (2 * padding) - ((nn.lengths[i] - 1) * layerYSteps)) / 2;
      
      for (int j = 0; j < layerLocations[i].length; j++) {
        layerLocations[i][j] = new PVector(px + padding + i * layerXSteps, py + padding + layerYPadding + j * layerYSteps);
      }
    }
    
    for (int i = 0; i < nn.weightMatrices.length; i++) {
      for (int j = 0; j < nn.weightMatrices[i].rows; j++) {
        for (int k = 0; k < nn.weightMatrices[i].cols - 1; k++) {
          if (nn.weightMatrices[i].data[i][j] > 0) {
            stroke(0, 255 * nn.weightMatrices[i].data[j][k], 0);
          }
          else {
            stroke(255 * Math.abs(nn.weightMatrices[i].data[j][k]), 0, 0);
          }
          
          line(layerLocations[i][k].x, layerLocations[i][k].y, layerLocations[i + 1][j].x, layerLocations[i + 1][j].y);
        }
      }
    }
    
    fill(255);
    stroke(0);
    
    for (int i = 0; i < nn.lengths.length; i++) {
      for (int j = 0; j < nn.lengths[i]; j++) {
        ellipse(layerLocations[i][j].x, layerLocations[i][j].y, neuronSize, neuronSize);
      }
    }
  }
}
