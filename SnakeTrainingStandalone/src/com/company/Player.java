package com.company;
class Player {
  NeuralNetwork nn;
  Level level;
  PVector startPos;
  PVector startAngle;
  float[] input = new float[0];
  
  Player(int[] lengthArr) {
    nn = new NeuralNetwork(lengthArr);
    level = new Level(20, 20);
  }
  
  Player(NeuralNetwork nnInput) {
    nn = nnInput;
    level = new Level(20, 20);
  }

  void update() {
    if (!level.snake.dead) {
      input = level.vision();
      
      float[] output = nn.feedForward(input).toArray();
      
      float max = output[0];
      int maxIndex = 0;
      
      for (int i = 1; i < output.length; i++) {
        if (output[i] > max) {
          max = output[i];
          maxIndex = i;
        }
      }
      
      level.snake.direction = maxIndex;
    }
    
    level.update();
  }
}
