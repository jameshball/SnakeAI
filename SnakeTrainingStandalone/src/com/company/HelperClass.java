package com.company;

import java.util.Random;

class HelperClass {
  static int SNAKE = 1;
  static int EMPTY = 0;
  static int APPLE = -1;
  private static Random rnd = new Random();

  static float random() {
    return rnd.nextFloat();
  }

  static float random(float f) {
    return rnd.nextFloat() * f;
  }

  static float random(float min, float max) {
    return min + rnd.nextFloat() * (max - min);
  }

  static float randomGaussian() {
    return (float) rnd.nextGaussian();
  }
}
