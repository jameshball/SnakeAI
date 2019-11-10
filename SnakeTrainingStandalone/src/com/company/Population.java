package com.company;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Arrays;

import static com.company.HelperClass.random;
import static com.company.Main.*;

class Population {
  private Player[] players;
  int gen = 0;

  Population() {
    players = new Player[populationSize];

    for (int i = 0; i < populationSize; i++) {
      players[i] = new Player();
    }
  }

  /* Executes every frame to update the game-state and checks if the generation has ended yet. */
  void update() {
    Arrays.stream(players).parallel().forEach(p -> p.update());

    /* If all snakes have died, create the next generation of players. */
    if (isAllDead()) {
      naturalSelection();
    }
  }

  /* Returns true is all snakes have died, false otherwise. */
  private boolean isAllDead() {
    for (int i = 0; i < players.length; i++) {
      if (!players[i].isDead()) {
        return false;
      }
    }

    return true;
  }

  /* This selects the best players from the last generation, 'breeds' them and then mutates them -
     mimicking natural selection to generate a new generation of players. */
  private void naturalSelection() {
    Player[] nextGen = new Player[populationSize];

    int bestIndex = getBest();

    /* We move the best player from the last generation into the new generation to ensure the next
       generation's best shouldn't perform worse. */
    nextGen[0] = new Player(players[bestIndex].nn);

    for (int i = 1; i < populationSize; i++) {
      /* Create each player in the new generation by performing selection, crossover and mutation. */
      nextGen[i] = new Player(uniformCrossover(selectParent(), selectParent()).mutateWeights());
    }

    float currentAvg = scoreSum() / populationSize;
    float currentMax = players[bestIndex].level.score;

    avgScore.add(currentAvg);
    maxScore.add(currentMax);

    System.out.println("Gen: " + gen + '\t' + "Max: " + currentMax + '\t' + "Avg: " + currentAvg);
    gen++;

    players = nextGen;
    save();
  }

  /* Crosses over the weights of two parent NNs into a child NN which is returned. Mimics breeding. */
  private NeuralNetwork uniformCrossover(NeuralNetwork parent1, NeuralNetwork parent2) {
    /* Normally, I should compare each NN to check their dimensions are the same, but as all NNs in this
       program are created with exactly the same dimensions, this isn't an issue. */
    NeuralNetwork child = new NeuralNetwork();

    for(int i = 0; i < parent1.weightMatrices.length; i++) {
      for (int j = 0; j < parent1.weightMatrices[i].rows; j++) {
        for (int k = 0; k < parent1.weightMatrices[i].cols; k++) {
          /* There is a 50% chance the child inherits this weight from either parent1 or parent2. */
          if (random(1) > 0.5) {
            child.weightMatrices[i].data[j][k] = parent1.weightMatrices[i].data[j][k];
          }
          else {
            child.weightMatrices[i].data[j][k] = parent2.weightMatrices[i].data[j][k];
          }
        }
      }
    }

    return child;
  }

  /* Returns the sum of all snake fitness. This is their score squared. */
  private float fitnessSum() {
    float total = 0;

    for (int i = 0; i < players.length; i++) {
      total += Math.pow(players[i].level.score, 2);
    }

    return total;
  }

  /* Returns the sum of all snake scores. i.e. the total number of apples eaten. */
  private float scoreSum() {
    float total = 0;

    for (int i = 0; i < players.length; i++) {
      total += players[i].level.score;
    }

    return total;
  }

  /* Randomly selects a NN from a player in the population based on how well they performed. It is a
     random selection, but players that perform better are more likely to be chosen. */
  private NeuralNetwork selectParent() {
    float threshold = random(fitnessSum());
    float total = 0;

    for (int i = 0; i < players.length; i++) {
      total += Math.pow(players[i].level.score, 2);

      if (total > threshold) {
        return players[i].nn;
      }
    }

    return null;
  }

  /* Returns the index of the snake that is currently the longest. */
  private int getBest() {
    int max = players[0].level.score;
    int maxIndex = 0;

    for (int i = 1; i < players.length; i++) {
      if (players[i].level.score > max) {
        max = players[i].level.score;
        maxIndex = i;
      }
    }

    return maxIndex;
  }

  void save() {
    JSONObject program = new JSONObject();
    JSONArray neuralNetworks = new JSONArray();
    JSONArray maxScoreData = new JSONArray();
    JSONArray avgScoreData = new JSONArray();

    program.put("layerCount", networkStructure.length);

    /* Appends all of the networkStructure information to the program JSONObject. */
    for (int i = 0; i < networkStructure.length; i++) {
      program.put("length " + i, networkStructure[i]);
    }

    /* Saves the current generation number to the JSONObject. */
    program.put("gen", gen);

    for (int i = 0; i < players.length; i++) {
      /* Appends all the player's neural networks to the neuralNetwork JSONArray. */
      neuralNetworks.put(i, players[i].nn.save());
    }

    for (int i = 0; i < maxScore.size(); i++) {
      /* Saves all graph data to the maxScoreData JSONObject. */
      maxScoreData.put(i, maxScore.get(i));
    }

    for (int i = 0; i < avgScore.size(); i++) {
      avgScoreData.put(i, avgScore.get(i));
    }

    program.put("neuralNetworks", neuralNetworks);
    program.put("maxScoreData", maxScoreData);
    program.put("avgScoreData", avgScoreData);

    /* Saves the JSONObject to the specified path. */
    try (PrintWriter out = new PrintWriter("C:\\dev\\SnakeAI\\SnakeTrainingStandalone\\data\\nn.json")) {
      out.println(program.toString());
    }
    catch (FileNotFoundException e) {}
  }

  void load(String path) {
    // TODO
  }
}
