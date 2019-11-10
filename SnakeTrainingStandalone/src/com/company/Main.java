package com.company;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class Main {
    static int[] networkStructure = new int[] { 24, 16, 4 };
    static int populationSize = 500;
    static int gridX = 20;
    static int gridY = 20;
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
