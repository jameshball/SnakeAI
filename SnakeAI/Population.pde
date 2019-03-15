class Population {
  Player[] players;
  int bestIndex = -1;
  int framesSinceLastSort;
  Graph maxFitnessGraph;
  Graph avgFitnessGraph;
  NNGraph nnGraph;
  
  Population (int pSize, int[] lengthArr) {
    players = new Player[pSize];
    
    for (int i = 0; i < pSize; i++) {
      players[i] = new Player(lengthArr);
    }
    
    framesSinceLastSort = frameCount;
    nnGraph = new NNGraph(players[0].nn, 700, 950, 10, 10);
  }
  
  Population() {
    players = new Player[1];
    players[0] = new Player(new int[] { 1, 1});
    
    framesSinceLastSort = frameCount;
    nnGraph = new NNGraph(players[0].nn, 700, 950, 10, 10);
  }
  
  void show() {
    showBestPlayers();
  }
  
  void update() {
    for (int i = 0; i < players.length; i++) {
      players[i].update();
    }
  }
  
  boolean isAllDead() {
    for (int i = 0; i < players.length; i++) {
      if (!players[i].level.snake.dead) {
        return false;
      }
    }
    
    return true;
  }
  
  void naturalSelection() {
    Player[] nextGen = new Player[players.length];
    
    bestIndex = getBest();
    nextGen[players.length - 1] = new Player(players[bestIndex].nn);
    
    gen++;
    
    for (int i = 0; i < players.length - 1; i++) {
      nextGen[i] = new Player(uniformCrossover(selectParent(), selectParent()).mutateWeights());
    }
    
    float maxScore = players[0].level.score;
    
    for (int i = 1; i < players.length; i++) {
      if (players[i].level.score > maxScore) {
        maxScore = players[i].level.score;
      }
    }
    
    maxFitnessGraph.addData(new Datapoint(maxScore, false));
    avgFitnessGraph.addData(new Datapoint(scoreSum() / players.length, false));
    
    players = nextGen;
    
    saveProgram();
  }
  
  NeuralNetwork uniformCrossover(NeuralNetwork parent1, NeuralNetwork parent2) {
    if (parent1.dimensionsAreIdentical(parent2)) {
      NeuralNetwork child = new NeuralNetwork(parent1.lengths);
      
      for (int i = 0; i < child.weightMatrices.length; i++) {
        for (int j = 0; j < child.weightMatrices[i].rows; j++) {
          for (int k = 0; k < child.weightMatrices[i].cols; k++) {
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
    
    return null;
  }
  
  float fitnessSum() {
    float sum = 0;
    
    for (int i = 0; i < players.length; i++) {
      sum += players[i].level.fitness;
    }
    
    return sum;
  }
  
  float scoreSum() {
    float sum = 0;
    
    for (int i = 0; i < players.length; i++) {
      sum += players[i].level.score;
    }
    
    return sum;
  }
  
  NeuralNetwork selectParent() {
    if (fitnessSum() == 0) {
      return players[(int)random(players.length)].nn;
    }
    
    float randomNum = random(fitnessSum());
    float runningSum = 0;
    
    for (int i = 0; i < players.length; i++) {
      runningSum += players[i].level.fitness;
      
      if (runningSum > randomNum) {
        return players[i].nn;
      }
    }
    
    return null;
  }
  
  int getBest() {
    float max = players[0].level.fitness;
    int maxIndex = 0;
    
    for (int i = 1; i < players.length; i++) {
      if (players[i].level.fitness > max) {
        max = players[i].level.fitness;
        maxIndex = i;
      }
    }
    
    return maxIndex;
  }
  
  int getNumberDead() {
    int sum = 0;
    
    for (int i = 0; i < players.length; i++) {
      if (players[i].level.snake.dead) {
        sum++;
      }
    }
    
    return sum;
  }
  
  void showBestPlayers() {
    if (playersRendered > 0) {
      for (int i = 0; i < players.length; i++) {
        players[i].level.calculateFitness();
      }
      
      if (frameCount - framesSinceLastSort > 200) {
        sortPlayers();
        
        framesSinceLastSort = frameCount;
      }
      
      for (int i = 1; i < playersRendered; i++) {
        players[i].show();
        players[i].level.isBest = false;
      }
      
      players[0].level.isBest = true;
      players[0].show();
      
      nnGraph.nn = players[0].nn;
    }
    
  }
  
  void sortPlayers() {
    Arrays.sort(players, new Comparator<Player>() {
      @Override
      public int compare(Player p1, Player p2) {
        float fitness1 = p1.level.fitness;
        float fitness2 = p2.level.fitness;
        
        if (p1.level.snake.dead) {
          fitness1 = -1;
        }
        
        if (p2.level.snake.dead) {
          fitness2 = -1;
        }
        
        return Float.compare(fitness1, fitness2);
      }
    });
    
    Collections.reverse(Arrays.asList(players));
  }
  
  void saveProgram() {
    sortPlayers();
    
    JSONObject program = new JSONObject();
    JSONArray neuralNetworks = new JSONArray();
    JSONArray maxFitnessData = new JSONArray();
    JSONArray avgFitnessData = new JSONArray();
    
    program.setInt("gen", gen);
    program.setInt("start", start);
    
    for (int i = 0; i < players.length; i++) {
      neuralNetworks.setJSONObject(i, players[i].nn.save());
    }
    
    for (int i = 0; i < maxFitnessGraph.data[0].size(); i++) {
      JSONObject datapoint = new JSONObject();
      
      datapoint.setFloat("data", maxFitnessGraph.data[0].get(i).data);
      datapoint.setBoolean("isInteger", maxFitnessGraph.data[0].get(i).isInteger);
      datapoint.setBoolean("isEmpty", maxFitnessGraph.data[0].get(i).isEmpty);
      
      maxFitnessData.setJSONObject(i, datapoint);
    }
    
    for (int i = 0; i < avgFitnessGraph.data[0].size(); i++) {
      JSONObject datapoint = new JSONObject();
      
      datapoint.setFloat("data", avgFitnessGraph.data[0].get(i).data);
      datapoint.setBoolean("isInteger", avgFitnessGraph.data[0].get(i).isInteger);
      datapoint.setBoolean("isEmpty", avgFitnessGraph.data[0].get(i).isEmpty);
      
      avgFitnessData.setJSONObject(i, datapoint);
    }
    
    program.setJSONArray("neuralNetworks", neuralNetworks);
    program.setJSONArray("maxFitnessData", maxFitnessData);
    program.setJSONArray("avgFitnessData", avgFitnessData);
    
    saveJSONObject(program, "/data/program.json");
  }
  
  void loadProgram(String path) {
    JSONObject program = loadJSONObject(path);
    JSONArray neuralNetworks = program.getJSONArray("neuralNetworks");
    JSONArray maxFitnessData = program.getJSONArray("maxFitnessData");
    JSONArray avgFitnessData = program.getJSONArray("avgFitnessData");
    
    gen = program.getInt("gen");
    start = program.getInt("start");
    
    if (neuralNetworks.size() == popSize) {
      players = new Player[popSize];
      
      for (int i = 0; i < popSize; i++) {
        players[i] = new Player(new NeuralNetwork(neuralNetworks.getJSONObject(i)));
      }
    }
    
    maxFitnessGraph.data[0] = new ArrayList<Datapoint>();
    
    for (int i = 0; i < maxFitnessData.size(); i++) {
      maxFitnessGraph.data[0].add(new Datapoint(maxFitnessData.getJSONObject(i)));
    }
    
    avgFitnessGraph.data[0] = new ArrayList<Datapoint>();
    
    for (int i = 0; i < avgFitnessData.size(); i++) {
      avgFitnessGraph.data[0].add(new Datapoint(avgFitnessData.getJSONObject(i)));
    }
  }
}
