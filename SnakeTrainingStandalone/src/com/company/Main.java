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

  public static void main(String[] args) {
    Population pop = new Population();
    while (true) {
      pop.update();
    }
  }
}
