package sh.ball;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Date;
import java.util.stream.IntStream;

import static sh.ball.HelperClass.random;
import static sh.ball.Main.*;

class Population {

  private static final SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy--HH-mm-ss");
  private static final int SAVING_FREQUENCY = 5;

  private Player[] players;
  private int gen = 0;

  Population() {
    players = new Player[populationSize];

    for (int i = 0; i < populationSize; i++) {
      players[i] = new Player();
    }
  }

  Population(String path) throws FileNotFoundException {
    load(path);
  }

  /* Executes every frame to update the game-state and checks if the generation has ended yet. */
  void update() {
    NeuralNetwork.feedForward(getInputs(), players);
    Arrays.stream(players).parallel().forEach(Player::update);

    /* If all snakes have died, create the next generation of players. */
    if (isAllDead()) {
      naturalSelection();
    }
  }

  float[][] getInputs() {
    float[][] inputs = new float[players.length][];

    for (int i = 0; i < players.length; i++) {
      if (players[i].isAlive()) {
        inputs[i] = players[i].vision();
      }
    }

    return inputs;
  }

  /* Returns true is all snakes have died, false otherwise. */
  private boolean isAllDead() {
    return Arrays.stream(players).noneMatch(Player::isAlive);
  }

  /* This selects the best players from the last generation, 'breeds' them and then mutates them -
  mimicking natural selection to generate a new generation of players. */
  private void naturalSelection() {
    Player[] nextGen = new Player[populationSize];

    int bestIndex = getBest();

    /* We move the best player from the last generation into the new generation to ensure the next
    generation's best shouldn't perform worse. */
    nextGen[0] = new Player(players[bestIndex].neuralNetwork());

    for (int i = 1; i < populationSize; i++) {
      /* Create each player in the new generation by performing selection, crossover and mutation. */
      nextGen[i] = new Player(uniformCrossover(selectParent(), selectParent()).mutateWeights());
    }

    float currentAvg = scoreSum() / populationSize;
    float currentMax = players[bestIndex].score();

    avgScore.add(currentAvg);
    maxScore.add(currentMax);

    System.out.printf(
        "Gen: %1$s\tMax: %2$s\tAvg: %3$s\tTime: %4$s%n",
        gen, currentMax, currentAvg, LocalDateTime.now().toLocalTime());
    gen++;

    players = nextGen;
    if (gen % SAVING_FREQUENCY == 0) {
      save();
    }
  }

  /* Crosses over the weights of two parent NNs into a child NN which is returned. Mimics breeding. */
  private NeuralNetwork uniformCrossover(NeuralNetwork parent1, NeuralNetwork parent2) {
    /* Normally, I should compare each NN to check their dimensions are the same, but as all NNs in this
    program are created with exactly the same dimensions, this isn't an issue. */
    NeuralNetwork child = new NeuralNetwork();

    for (int i = 0; i < parent1.weightMatrices.length; i++) {
      for (int j = 0; j < parent1.weightMatrices[i].numRows(); j++) {
        for (int k = 0; k < parent1.weightMatrices[i].numCols(); k++) {
          /* There is a 50% chance the child inherits this weight from either parent1 or parent2. */
          if (random(1) > 0.5) {
            child.weightMatrices[i].set(j, k, parent1.weightMatrices[i].get(j, k));
          } else {
            child.weightMatrices[i].set(j, k, parent2.weightMatrices[i].get(j, k));
          }
        }
      }
    }

    return child;
  }

  /* Returns the sum of all snake fitness. This is their score squared. */
  private float fitnessSum() {
    return Arrays.stream(players)
        .map(Player::fitness)
        .reduce(Integer::sum)
        .orElse(0);
  }

  /* Returns the sum of all snake scores. i.e. the total number of apples eaten. */
  private float scoreSum() {
    return Arrays.stream(players)
      .map(Player::score)
      .reduce(Integer::sum)
      .orElse(0);
  }

  /* Randomly selects a NN from a player in the population based on how well they performed. It is a
  random selection, but players that perform better are more likely to be chosen. */
  private NeuralNetwork selectParent() {
    float threshold = random(fitnessSum());
    float total = 0;

    for (Player player : players) {
      total += player.fitness();

      if (total > threshold) {
        return player.neuralNetwork();
      }
    }

    return null;
  }

  /* Returns the index of the snake that is currently the longest. */
  private int getBest() {
    return IntStream
      .range(0, players.length)
      .reduce((i, j) -> players[i].score() > players[j].score() ? i : j)
      .orElse(0);
  }

  private void save() {
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
      neuralNetworks.put(i, players[i].save());
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

    Date date = new Date();
    /* Saves the JSONObject to the specified path. */
    try (PrintWriter out =
        new PrintWriter("data/generation-" + gen + "--" + formatter.format(date) + ".json")) {
      out.println(program.toString());
    } catch (FileNotFoundException ignored) {

    }
  }

  void load(String path) throws FileNotFoundException {
    File file = new File(workingDir + path);

    JSONTokener tokener = new JSONTokener(new FileInputStream(file));
    JSONObject program = new JSONObject(tokener);

    JSONArray neuralNetworks = program.getJSONArray("neuralNetworks");
    JSONArray maxScoreData = program.getJSONArray("maxScoreData");
    JSONArray avgScoreData = program.getJSONArray("avgScoreData");

    networkStructure = new int[program.getInt("layerCount")];

    /* Loads all details about the networkStructure from the JSONObject. */
    for (int i = 0; i < networkStructure.length; i++) {
      networkStructure[i] = program.getInt("length " + i);
    }

    gen = program.getInt("gen");

    /* Change populationSize to the number of neural networks in the neuralNetworks JSONArray. */
    populationSize = neuralNetworks.length();

    players = new Player[populationSize];

    for (int i = 0; i < populationSize; i++) {
      /* Initialises new Player objects using the neural network JSONObjects in neuralNetworks. */
      players[i] = new Player(new NeuralNetwork(neuralNetworks.getJSONObject(i)));
    }

    /* Loads all graph data. */
    for (int i = 0; i < maxScoreData.length(); i++) {
      maxScore.add(maxScoreData.getFloat(i));
    }

    for (int i = 0; i < avgScoreData.length(); i++) {
      avgScore.add(avgScoreData.getFloat(i));
    }
  }
}
