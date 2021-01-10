package sh.ball.snake;

import sh.ball.ai.Population;

public class Main {

  private static final int POPULATION_COUNT = 500;
  private static final int[] NETWORK_STRUCTURE = new int[] {24, 16, 4};

  static int GRID_X = 40;
  static int GRID_Y = 40;

  public static void main(String[] args) {
    //Population pop = new Population("/data/program.json");
    Population pop = new Population(POPULATION_COUNT, NETWORK_STRUCTURE, new Level(GRID_X, GRID_Y));

    while (true) {
      pop.update();
    }
  }
}
