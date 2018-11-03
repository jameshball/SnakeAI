package com.company;

import java.util.Random;

class HelperClass {
    static int SNAKE = 1;
    static int EMPTY = 0;
    static int APPLE = -1;
    Random rnd = new Random();

    float random() {
        return rnd.nextFloat();
    }

    float random(float f) {
        return rnd.nextFloat() * f;
    }

    float random(float min, float max) {
        return min + rnd.nextFloat() * (max - min);
    }

    float randomGaussian() {
        return (float)rnd.nextGaussian();
    }
}
