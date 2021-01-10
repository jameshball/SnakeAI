package sh.ball;

import org.json.JSONObject;

/* This class manages the level, along with the neural network that controls the snake. */
public class Player {
  private final NeuralNetwork nn;
  private float[] output;
  private final Level level;

  public Player() {
    this(new NeuralNetwork());
  }

  public Player(NeuralNetwork nn) {
    this.nn = nn;
    level = new Level();
  }

  public int fitness() {
    return level.score * level.score;
  }

  public int score() {
    return level.score;
  }

  public float[] vision() {
    return level.vision();
  }

  public void setOutput(float[] output) {
    this.output = output;
  }

  public NeuralNetwork neuralNetwork() {
    return nn;
  }

  public JSONObject save() {
    return nn.save();
  }

  /* Uses the NN to look at the current state of the game and then decide the next move to make. */
  public void update() {
    if (isAlive()) {
      /* This code looks at the strongest output from the NN to decide what move to make. */
      float max = output[0];
      int maxIndex = 0;

      for (int i = 1; i < output.length; i++) {
        if (output[i] > max) {
          max = output[i];
          maxIndex = i;
        }
      }

      PVector dir = new PVector(0, 0);

      switch (maxIndex) {
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

  public boolean isAlive() {
    return !level.snake.dead;
  }
}
