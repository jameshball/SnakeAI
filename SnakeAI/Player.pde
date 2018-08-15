class Player {
  NeuralNetwork nn;
  Level level;
  PVector startPos;
  PVector startAngle;
  int moveTimer;
  float[] input = new float[0];
  
  Player(int[] lengthArr) {
    nn = new NeuralNetwork(lengthArr);
    level = new Level();
    moveTimer = frameCount;
  }
  
  Player(NeuralNetwork nnInput) {
    nn = nnInput;
    level = new Level();
    moveTimer = frameCount;
  }
  
  void show() {
    level.show();
  }
  
  void update() {
    if (!level.frog.dead && frameCount - moveTimer >= 50) {
      int fLane = level.frog.lane;
      Car carAbove = level.getCar(fLane - 1);
      Car carAbove2 = level.getCar(fLane - 2);
      Car carBelow = level.getCar(fLane + 1);
      Car carOnLane = level.getCar(fLane);
      
      
      
      //input = new float[] { level.frog.loc - (carAbove.loc - 1), level.frog.loc - (carAbove.loc + carAbove.sizeX) };
      //there is a saved NN for this => input = new float[] { level.frog.loc - (carAbove.loc - 1), level.frog.loc - (carAbove.loc + carAbove.sizeX), level.frog.loc - (carOnLane.loc - 1), level.frog.loc - (carOnLane.loc + carOnLane.sizeX) };
      input = new float[] { level.frog.loc - (carBelow.loc - 1), level.frog.loc - (carBelow.loc + carBelow.sizeX), carBelow.getDirNum(), level.frog.loc - (carAbove2.loc - 1), level.frog.loc - (carAbove2.loc + carAbove2.sizeX), carAbove2.getDirNum(), level.frog.loc - (carAbove.loc - 1), level.frog.loc - (carAbove.loc + carAbove.sizeX), carAbove.getDirNum(), level.frog.loc - (carOnLane.loc - 1), level.frog.loc - (carOnLane.loc + carOnLane.sizeX), carOnLane.getDirNum() };
      
      float[] output = nn.feedForward(input).toArray();
      
      float max = output[0];
      int maxIndex = 0;
      
      for (int i = 1; i < output.length; i++) {
        if (output[i] > max) {
          max = output[i];
          maxIndex = i;
        }
      }
      
      if (max > 0.5) {
        level.frog.frogMove(maxIndex);
      }
      
      moveTimer = frameCount;
    }
    
    level.update();
  }
}
