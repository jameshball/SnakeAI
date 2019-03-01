package com.company;

import java.io.IOException;

public class Main {

    public static void main(String[] args) throws IOException {
        int gen = 0;
        int popSize = 500;
        Population pop = new Population(popSize, new int[] { 24, 16, 4 });

        while (true) {
            pop.update();

            if (pop.isAllDead()) {
                pop.naturalSelection();
                System.out.println("Gen: " + gen + '\t' + "Max: " + pop.currentMax + '\t' + "Avg: " + pop.currentAvg);
                gen++;
            }
        }
    }
}
