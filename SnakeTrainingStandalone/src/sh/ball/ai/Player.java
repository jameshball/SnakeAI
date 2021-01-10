package sh.ball.ai;

import org.json.JSONObject;

import java.util.List;

/* This class manages the level, along with the neural network that controls the snake. */
public class Player {
  private final NeuralNetwork nn;
  private float[] output;
  private final State level;

  public Player(int[] networkStructure, State state) {
    this(new NeuralNetwork(networkStructure, state), state);
  }

  public Player(NeuralNetwork nn, State state) {
    this.nn = nn;
    level = state.deepCopy().reset();
  }

  public float fitness() {
    return level.evaluateFitness();
  }

  public float score() {
    return (float) Math.sqrt(level.evaluateFitness());
  }

  public List<Float> vision() {
    return level.getInputs();
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
      level.update(output);
    }
  }

  public boolean isAlive() {
    return !level.hasEnded();
  }
}
