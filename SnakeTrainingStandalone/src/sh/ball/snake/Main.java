package sh.ball.snake;

import sh.ball.ai.Population;

import java.io.FileNotFoundException;

public class Main {

  private static final int POPULATION_COUNT = 500;
  private static final int[] NETWORK_STRUCTURE = new int[] {24, 16, 4};

  static int GRID_X = 20;
  static int GRID_Y = 20;

  public static void main(String[] args) throws FileNotFoundException {
    Population pop;
    if (args.length == 1) {
      pop = new Population(args[0], new Level(GRID_X, GRID_Y));
    } else {
      pop = new Population(POPULATION_COUNT, NETWORK_STRUCTURE, new Level(GRID_X, GRID_Y));
    }

    while (true) {
      pop.update();
    }
  }
}
