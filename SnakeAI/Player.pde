/* This class manages the level, along with the neural network that controls the snake. */
class Player {
  NeuralNetwork nn;
  Level level;
  
  Player() {
    nn = new NeuralNetwork();
    level = new Level();
  }
  
  Player(NeuralNetwork nn) {
    this.nn = nn;
    level = new Level();
  }
  
  void show(boolean isBest) {
    level.show(isBest);
  }
  
  /* Uses the NN to look at the current state of the game and then decide the next move to make. */
  void update() {
    if (!isDead()) {
      float[] output = nn.feedForward(level.vision());
      
      /* This code looks at the strongest output from the NN to decide what move to make. */
      float max = output[0];
      int maxIndex = 0;
      
      for (int i = 1; i < output.length; i++) {
        if (output[i] > max) {
          max = output[i];
          maxIndex = i;
        }
      }
      
      PVector dir = new PVector();
      
      switch(maxIndex){
        case 0:
          dir = new PVector(0, 1);
          break;
        case 1:
          dir = new PVector(1, 0);
          break;
        case 2:
          dir = new PVector(0, -1);
          break;
        case 3:
          dir = new PVector(-1, 0);
          break;
      }
      
      /* Changes the direction of the snake to the newly decided direction. */
      level.snake.direction = dir;
      
      level.update();
    }
  }
  
  boolean isDead() {
    return level.snake.dead;
  }
}
