class Population {
  Player[] players;
  int framesSinceLastGen = 0;
  int bestIndex = -1;
  int framesSinceLastSort = 0;
  Graph maxFitnessGraph;
  Graph avgFitnessGraph;
  NNGraph nnGraph;
  
  Population (int pSize, int[] lengthArr) {
    players = new Player[pSize];
    
    for (int i = 0; i < pSize; i++) {
      players[i] = new Player(lengthArr);
    }
    
    framesSinceLastGen = frameCount;
    framesSinceLastSort = frameCount;
    nnGraph = new NNGraph(players[0].nn, 700, 800, 10, 10);
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
    framesSinceLastGen = frameCount;
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
  
  void saveBestPlayer() {
    players[getBest()].nn.save("/data/nn.json");
  }
  
  void replaceAllNN(String filePath) {
    for (int i = 0; i < players.length; i++) {
      players[i].nn.load(filePath);
    }
  }
}
