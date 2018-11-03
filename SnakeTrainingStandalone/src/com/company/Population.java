package com.company;
class Population {
  Player[] players;
  float currentMax = 0;
    float currentAvg = 0;
    HelperClass h = new HelperClass();
  
  Population (int pSize, int[] lengthArr) {
    players = new Player[pSize];
    
    for (int i = 0; i < pSize; i++) {
      players[i] = new Player(lengthArr);
    }
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

    for (int i = 0; i < players.length; i++) {
      nextGen[i] = new Player(uniformCrossover(selectParent(), selectParent()).mutateWeights());
    }
    
    float maxScore = players[0].level.score;
    
    for (int i = 1; i < players.length; i++) {
      if (players[i].level.score > maxScore) {
        maxScore = players[i].level.score;
      }
    }

    currentMax = maxScore;
    currentAvg = scoreSum() / players.length;
    
    players = nextGen;
  }
  
  NeuralNetwork uniformCrossover(NeuralNetwork parent1, NeuralNetwork parent2) {
    if (parent1.dimensionsAreIdentical(parent2)) {
      NeuralNetwork child = new NeuralNetwork(parent1.lengths);
      
      for (int i = 0; i < child.weightMatrices.length; i++) {
        for (int j = 0; j < child.weightMatrices[i].rows; j++) {
          for (int k = 0; k < child.weightMatrices[i].cols; k++) {
            if (h.random() > 0.5) {
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
      return players[(int)h.random(players.length)].nn;
    }
    
    float randomNum = h.random(fitnessSum());
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

  void saveBestPlayer() {
    players[getBest()].nn.save("C:\\dev\\SnakeAI\\SnakeTrainingStandalone\\data\\nn.json");
  }
}
