class Population {
  private Player[] players;
  /* Setting this initially to 300 as this is an arbitrary number greater than 200. */
  int framesSinceLastSort = 300;
  
  Population() {
    players = new Player[populationSize];
    
    for (int i = 0; i < populationSize; i++) {
      players[i] = new Player();
    }
  }
  
  /* Displays the best snakes to the screen. The number of snakes shown is determined by the
     playersRendered variable in the Main class. */
  void show() {
    /* Check if any players need to be rendered. */
    if (playersRendered > 0) {
      /* If it's been more than 200 frames since the last sort... */
      if (framesSinceLastSort > 200) {
        /* Sorts all players in the players array based on their score. The highest scoring players are
           at the front of the array. */
        Arrays.sort(players, new PlayerComparator());
        Collections.reverse(Arrays.asList(players));
        
        framesSinceLastSort = 0;
      }
      
      /* Shows these players as normal snakes. i.e. not best-performing. */
      for (int i = 1; i < playersRendered; i++) {
        players[i].show(false);
      }
      
      /* The best player is the first in the list as it has been sorted. This player is shown last
         so that they display above all other snakes. */
      players[0].show(true);
    }
    
    framesSinceLastSort++;
  }
  
  /* This is a custom Comparator class that is implemented to define how two player objects should be
     compared. If the player is dead, it has a score of -1, otherwise its score is the number of apples
     obtained. This score of two players is compared to allow sorting of the players array. */
  private class PlayerComparator implements Comparator<Player> {
    @Override
    public int compare(Player p1, Player p2) {
      int score1 = p1.level.score;
      int score2 = p2.level.score;
      
      if (p1.level.snake.dead) {
        score1 = -1;
      }
      
      if (p2.level.snake.dead) {
        score2 = -1;
      }
      
      /* Returns -1, 0 and 1 for less than, equal to or greater than, respectively. */
      return Integer.compare(score1, score2);
    }
  }
  
  /* Executes every frame to update the game-state and checks if the generation has ended yet. */
  void update() {
    for (int i = 0; i < players.length; i++) {
      players[i].update();
    }
    
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
    
    avgScore.add(scoreSum() / (float) populationSize);
    maxScore.add(players[bestIndex].level.score);
    
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
      total += pow(players[i].level.score, 2);
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
      total += pow(players[i].level.score, 2);
      
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
  
  /* Returns the number of snakes in the population of players that are dead. */
  int getNumberDead() {
    int noDead = 0;
    
    for (int i = 0; i < players.length; i++) {
      if (players[i].level.snake.dead) {
        noDead++;
      }
    }
    
    return noDead;
  }
  
  void save() {
    /* Sorts all players in the players array based on their score. The highest scoring players are
       at the front of the array. */
    Arrays.sort(players, new PlayerComparator());
    Collections.reverse(Arrays.asList(players));
    
    JSONObject program = new JSONObject();
    JSONArray neuralNetworks = new JSONArray();
    JSONArray maxScoreData = new JSONArray();
    JSONArray avgScoreData = new JSONArray();
    
    program.setInt("layerCount", networkStructure.length);
    
    /* Appends all of the networkStructure information to the program JSONObject. */
    for (int i = 0; i < networkStructure.length; i++) {
      program.setInt("length " + i, networkStructure[i]);
    }
    
    /* Saves the current generation number to the JSONObject. */
    program.setInt("gen", gen);
    
    for (int i = 0; i < players.length; i++) {
      /* Appends all the player's neural networks to the neuralNetwork JSONArray. */
      neuralNetworks.setJSONObject(i, players[i].nn.save());
    }
    
    for (int i = 0; i < maxScore.size(); i++) {
      /* Saves all graph data to the maxScoreData JSONObject. */
      maxScoreData.setFloat(i, maxScore.get(i));
    }
    
    for (int i = 0; i < avgScore.size(); i++) {
      avgScoreData.setFloat(i, avgScore.get(i));
    }
    
    program.setJSONArray("neuralNetworks", neuralNetworks);
    program.setJSONArray("maxScoreData", maxScoreData);
    program.setJSONArray("avgScoreData", avgScoreData);
    
    /* Saves the JSONObject to the specified path. */
    saveJSONObject(program, "/data/program.json");
  }
  
  void load(String path) {
    /* Loads the JSONObject from the specified path. */
    JSONObject program = loadJSONObject(path);
    JSONArray neuralNetworks = program.getJSONArray("neuralNetworks");
    JSONArray maxScoreData = program.getJSONArray("maxScoreData");
    JSONArray avgScoreData = program.getJSONArray("avgScoreData");
    
    networkStructure = new int[program.getInt("layerCount")];
    
    /* Loads all details about the networkStructure from the JSONObject. */
    for (int i = 0; i < networkStructure.length; i++) {
      networkStructure[i] = program.getInt("length " + Integer.toString(i));
    }
    
    gen = program.getInt("gen");
    
    /* Change populationSize to the number of neural networks in the neuralNetworks JSONArray. */
    populationSize = neuralNetworks.size();
    
    players = new Player[populationSize];
    
    for (int i = 0; i < populationSize; i++) {
      /* Initialises new Player objects using the neural network JSONObjects in neuralNetworks. */
      players[i] = new Player(new NeuralNetwork(neuralNetworks.getJSONObject(i)));
    }
    
    /* Loads all graph data. */
    for (int i = 0; i < maxScoreData.size(); i++) {
      maxScore.add(maxScoreData.getFloat(i));
    }
    
    for (int i = 0; i < avgScoreData.size(); i++) {
      avgScore.add(avgScoreData.getFloat(i));
    }
  }
}
