/* This class is responsible for managing and creating neural networks for the Player class. */
class NeuralNetwork {
  private Matrix[] weightMatrices;
  
  NeuralNetwork() {
    weightMatrices = new Matrix[networkStructure.length - 1];
    
    /* Initialises n-1 weight matrices where n is the number of layers in the network. */
    for (int i = 0; i < weightMatrices.length; i++) {
      /* This initialises a weight matrix, considering the extra bias node. */
      weightMatrices[i] = new Matrix(networkStructure[i + 1], networkStructure[i] + 1).randomize();
    }
  }
  
  NeuralNetwork(Matrix[] weightMatrices) {
    this.weightMatrices = weightMatrices;
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
    if (arr.length == networkStructure[0]) {
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
  
  /* Returns a JSONObject used to store the NN object in a file. */
  JSONObject save() {
    JSONObject neuralNet = new JSONObject();
    
    for (int i = 0; i < weightMatrices.length; i++) {
      JSONObject matrix = new JSONObject();
      
      for (int j = 0; j < weightMatrices[i].rows; j++) {
        JSONArray row = new JSONArray();
        
        /* Processes a row in the weight matrix. */
        for (int k = 0; k < weightMatrices[i].cols; k++) {
          row.setFloat(k, weightMatrices[i].data[j][k]);
        }
        
        /* Appends the row to the matrix JSONArray. */
        matrix.setJSONArray(Integer.toString(j), row);
      }
      
      /* Appends the matrix to the neuralNet JSONObject. */
      neuralNet.setJSONObject("weightMatrix " + Integer.toString(i), matrix);
    }
    
    return neuralNet;
  }
  
  /* Displays the NeuralNetwork object including all neurons, layers and weights. */
  void show(int posX, int posY, int graphWidth, int graphHeight, int neuronSize) {
    /* Shorthand way of referring to the number of layers in the NN. */
    int layerAmount = networkStructure.length;
    
    /* neuronPos stores all of the positions of the neurons to be drawn. This makes it easy for drawing
       lines between neurons. */
    PVector[][] neuronPos = new PVector[layerAmount][];
    
    /* The size of the neuronPos 2D array depends on the structure of the NN. */
    for (int i = 0; i < layerAmount - 1; i++) {
      /* Includes the extra neuron for the bias neuron. */
      neuronPos[i] = new PVector[networkStructure[i] + 1];
    }
    
    /* The output layer doesn't have a bias neuron so it is dealt with differently. */
    neuronPos[layerAmount - 1] = new PVector[networkStructure[layerAmount - 1]];
    
    /* Defines the pixel gap between layers in the network. */
    int layerXSteps = graphWidth / (layerAmount - 1);
    
    for (int i = 0; i < neuronPos.length; i++) {
      /* This is required as the neuron count depends on if there are bias neurons or not. */
      int neuronsInLayer = networkStructure[i];
      
      /* If this is not the output layer, there is an extra bias node. */
      if (i != neuronPos.length - 1) {
        neuronsInLayer++;
      }
      
      /* Defines the vertical pixel gap between neurons in a layer. */
      int layerYSteps = graphHeight / neuronsInLayer;
      /* This padding allows neurons to be centred within their layer. */
      int layerYPadding = (graphHeight - ((neuronsInLayer - 1) * layerYSteps)) / 2;
      
      for (int j = 0; j < neuronPos[i].length; j++) {
        /* Calculates and adds the neuron position of this specific neuron. */
        neuronPos[i][j] = new PVector(posX + i * layerXSteps, posY + layerYPadding + j * layerYSteps);
      }
    }
    
    strokeWeight(1.5);
    
    for (int i = 0; i < weightMatrices.length; i++) {
      for (int j = 0; j < weightMatrices[i].rows; j++) {
        for (int k = 0; k < weightMatrices[i].cols; k++) {
          float weight = weightMatrices[i].data[j][k];
          /* If there is a positive weight, draw it as a green line, if it is negative, draw it as red.
             The line is more red/green the more negative/positive it is respectively. */
          if (weight > 0) {
            stroke(0, 255 * weight, 0);
          }
          else {
            stroke(255 * Math.abs(weight), 0, 0);
          }
          
          /* Draws a line from the kth neuron in layer i to the jth neuron in layer i + 1. */
          line(neuronPos[i][k].x, neuronPos[i][k].y, neuronPos[i + 1][j].x, neuronPos[i + 1][j].y);
        }
      }
    }
    
    fill(255);
    stroke(0);
    
    /* Draws neurons (circles) at all neuronPos locations. */
    for (int i = 0; i < neuronPos.length; i++) {
      for (int j = 0; j < neuronPos[i].length; j++) {
        circle(neuronPos[i][j].x, neuronPos[i][j].y, neuronSize);
      }
    }
  }
}
