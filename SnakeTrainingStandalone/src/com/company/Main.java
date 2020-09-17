package com.company;

import java.util.ArrayList;
import java.util.List;

public class Main {
  static String workingDir = System.getProperty("user.dir");
  static int[] networkStructure = new int[] {24, 16, 4};
  static int populationSize = 500;
  static int gridX = 40;
  static int gridY = 40;
  static float mutationRate = 0.02f;
  static List<Float> maxScore = new ArrayList<>();
  static List<Float> avgScore = new ArrayList<>();
  /* Stores the number of moves a snake is allowed to take to get an apple, given its current length.
  i.e. allowedMoves[5] returns the number of moves allowed to get the next apple when the snake is
  length 5. */
  static int[] allowedMoves = new int[gridX * gridY + 1];
  /* Adds the results of looking in eight directions around the snake to the vision array. */
  static PVector[] directions =
      new PVector[] {
        new PVector(0, 1),
        new PVector(1, 1),
        new PVector(1, 0),
        new PVector(1, -1),
        new PVector(0, -1),
        new PVector(-1, -1),
        new PVector(-1, 0),
        new PVector(-1, 1)
      };

  public static void main(String[] args) {
    for (int i = 0; i < allowedMoves.length; i++) {
      allowedMoves[i] = (int) (200 * (Math.log(i) / Math.log(3)) + 300);
    }

    //Population pop = new Population("/data/program.json");
    Population pop = new Population();

    while (true) {
      pop.update();
    }
  }
}
