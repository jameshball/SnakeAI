package sh.ball.ai;

import java.util.List;

public interface State {
  float evaluateFitness();

  void update(float[] inputs);

  List<Float> getInputs();

  boolean hasEnded();

  State reset();

  State deepCopy();

  float activate(float x);

  static float sigmoid(float x) {
    final float SIGMOID_CONSTANT = 4.9f;
    return (float) (1 / (1 + Math.exp(-SIGMOID_CONSTANT * x)));
  }

  static float relu(float x) {
    return Math.max(0, x);
  }
}
