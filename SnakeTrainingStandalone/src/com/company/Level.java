package com.company;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

class Level {
    HelperClass h = new HelperClass();
  int[][] grid;
  int gridX;
  int gridY;
  Snake snake;
  PVector apple;
  int score = 0;
  int fitness;
  boolean isBest = false;
  int movesOfLastApple;
  int moves = 0;
  
  Level (int x, int y) {
    gridX = x;
    gridY = y;
    
    resetGrid();
    
    snake = new Snake(gridX, gridY);
    resetApple();
    
    while (snake.pos.x == apple.x && snake.pos.y == apple.y) {
      resetApple();
    }
  }

  void resetApple() {
      apple = new PVector((int)h.random(gridX), (int)h.random(gridY));
  }

  void update() {
      if (!snake.dead) {
          snake.update();
          if (snake.pos.x == apple.x && snake.pos.y == apple.y) {
              snake.extend();
              resetApple();
              score++;
              movesOfLastApple = moves;
          }
          else {
              snake.move();
          }

          checkDead();
          if (!snake.dead) {
              updateGrid();
          }

          moves++;
      }
  }
  
  void checkDead() {
    int allowedMoves = (int)(500 * (Math.log(snake.body.size()) / Math.log(2)) + 500);
    
    if (!snake.withinBounds() || snake.hitTail() || moves - movesOfLastApple > allowedMoves) {
      snake.dead = true;
      calculateFitness();
    }
  }
  
  void set(PVector pos, int objectType) {
    grid[(int)pos.x][(int)pos.y] = objectType;
  }
  
  void updateGrid() {
    resetGrid();
    
    set(apple, HelperClass.APPLE);
    
    for (int i = 0; i < snake.body.size(); i++) {
      set(snake.body.get(i), HelperClass.SNAKE);
    }
  }
  
  void resetGrid() {
    grid = new int[gridX][gridY];
    
    for (int i = 0; i < grid.length; i++) {
      grid[i] = new int[gridY];
    }
  }
  
  void calculateFitness() {
    fitness = score * score;
  }
  
  boolean withinBounds(PVector loc) {
    if (loc.x > gridX - 1 || loc.x < 0 || loc.y > gridY - 1 || loc.y < 0) {
      return false;
    }
    
    return true;
  }
  
  List<Float> snakeLook(PVector dir) {
    PVector snakePos = new PVector(snake.pos.x, snake.pos.y);
    Float[] vision = new Float[3];
    boolean tailSeen = false;
    boolean appleSeen = false;
    int dist = 1;
    
    for (int i = 0; i < vision.length; i++) {
      vision[i] = 0f;
    }
    
    while(withinBounds(snakePos.add(dir))) {
      if (grid[(int)snakePos.x][(int)snakePos.y] == HelperClass.SNAKE && !tailSeen) {
        vision[0] = 1.0f / (float)dist;
        tailSeen = true;
      }
      
      if (grid[(int)snakePos.x][(int)snakePos.y] == HelperClass.APPLE && !appleSeen) {
        vision[1] = 1.0f;
        appleSeen = true;
      }
      
      dist++;
    }
    
    vision[2] = 1.0f / (float)dist;
    
    return Arrays.asList(vision); //<>//
  }
  
  float[] vision() {
    ArrayList<Float> vision = new ArrayList<Float>();
    
    vision.addAll(snakeLook(new PVector(0, 1)));
    vision.addAll(snakeLook(new PVector(1, 1)));
    vision.addAll(snakeLook(new PVector(1, 0)));
    vision.addAll(snakeLook(new PVector(1, -1)));
    vision.addAll(snakeLook(new PVector(0, -1)));
    vision.addAll(snakeLook(new PVector(-1, -1)));
    vision.addAll(snakeLook(new PVector(-1, 0)));
    vision.addAll(snakeLook(new PVector(-1, 1)));
    
    return floatListToArray(vision);
  }
  
  float[] floatListToArray(ArrayList<Float> list) {
    float[] arr = new float[list.size()];
    
    for (int i = 0; i < list.size(); i++) {
      arr[i] = list.get(i);
    }
    
    return arr;
  }
}
