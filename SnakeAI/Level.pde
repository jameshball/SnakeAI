class Level {
  int[][] grid;
  int gridX;
  int gridY;
  Snake snake;
  Apple apple;
  int score = 0;
  int fitness;
  boolean isBest = false;
  int movesOfLastApple;
  int framesPerMove = 0;
  int moveTimer;
  int moves = 0;
  
  Level (int x, int y) {
    gridX = x;
    gridY = y;
    
    resetGrid();
    
    snake = new Snake(gridX, gridY);
    apple = new Apple(gridX, gridY);
    
    while (snake.pos.x == apple.pos.x && snake.pos.y == apple.pos.y) {
      apple = new Apple(gridX, gridY);
    }
    
    moveTimer = frameCount;
  }
  
  void show() {
    for (int i = 0; i < gridX; i++) {
      for (int j = 0; j < gridY; j++) {
        if (isBest) {
          if (grid[i][j] == ObjectTypes.APPLE) {
            fill(0, 255, 0);
          }
          else if (grid[i][j] == ObjectTypes.SNAKE) {
            fill(255, 0, 0);
          }
          else {
            fill(256, 0);
          }
        }
        else {
          if (grid[i][j] == ObjectTypes.APPLE) {
            fill(255, 150, 150);
          }
          else if (grid[i][j] == ObjectTypes.SNAKE) {
            fill(128);
          }
          else {
            fill(256, 0);
          }
        }
        
        strokeWeight(0);
        int rectWidth = snakeWidth / gridX;
        int rectHeight = snakeHeight / gridY;
        rect(i * rectWidth, snakeHeight - ((j + 1) * rectHeight), rectWidth, rectHeight);
      }
    }
  }
  
  void frameRateUpdate() {
    if (!snake.dead) {
      if (lowerFramerate) {
        if ((float)(frameCount - moveTimer) >= (float)(frameRate * 0.03)) {
          update();
          moves++;
          moveTimer = frameCount;
        }
      }
      else {
        update();
        moves++;
      }
    }
  }
  
  void update() {
    snake.update();
    if (snake.pos.x == apple.pos.x && snake.pos.y == apple.pos.y) {
      snake.extend();
      apple = new Apple(gridX, gridY);
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
    
    set(apple.pos, ObjectTypes.APPLE);
    
    for (int i = 0; i < snake.body.size(); i++) {
      set(snake.body.get(i), ObjectTypes.SNAKE);
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
      vision[i] = 0.0;
    }
    
    while(withinBounds(snakePos.add(dir))) {
      if (grid[(int)snakePos.x][(int)snakePos.y] == ObjectTypes.SNAKE && !tailSeen) {
        vision[0] = 1.0 / (float)dist;
        tailSeen = true;
      }
      
      if (grid[(int)snakePos.x][(int)snakePos.y] == ObjectTypes.APPLE && !appleSeen) {
        vision[1] = 1.0;
        appleSeen = true;
      }
      
      dist++;
    }
    
    vision[2] = 1.0 / (float)dist;
    
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
