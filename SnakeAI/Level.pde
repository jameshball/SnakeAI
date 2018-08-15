class Level {
  int[][] grid;
  int gridX;
  int gridY;
  Snake snake;
  Apple apple;
  int moveTimer;
  
  Level (int x, int y) {
    gridX = x;
    gridY = y;
    
    resetGrid();
    
    snake = new Snake(gridX - 1, gridY - 1);
    apple = new Apple(gridX, gridY);
    
    while (snake.pos.x == apple.pos.x && snake.pos.y == apple.pos.y) {
      apple = new Apple(gridX, gridY);
    }
    
    moveTimer = frameCount;
  }
  
  void show() {
    for (int i = 0; i < gridX; i++) {
      for (int j = 0; j < gridY; j++) {
        if (grid[i][j] == ObjectTypes.APPLE) {
          fill(255, 0, 0);
        }
        else if (grid[i][j] == ObjectTypes.SNAKE) {
          fill(128);
        }
        else {
          fill(256, 0);
        }
        
        int rectWidth = snakeWidth / gridX;
        int rectHeight = snakeHeight / gridY;
        rect(i * rectWidth, snakeHeight - ((j + 1) * rectHeight), rectWidth, rectHeight);
      }
    }
  }
  
  void update() {
    if (snake.dead) {
      snake = new Snake(gridX - 1, gridY - 1);
      apple = new Apple(gridX, gridY);
    }
    if (!snake.dead && frameCount - moveTimer > 2) {
      snake.update();
      if (snake.pos.x == apple.pos.x && snake.pos.y == apple.pos.y) {
        snake.extend();
        apple = new Apple(gridX, gridY);
      }
      else {
        snake.move();
      }
      
      checkDead();
      if (!snake.dead) {
        updateGrid();
      }
      
      moveTimer = frameCount;
    }
  }
  
  void checkDead() {
    if (snake.pos.x > gridX - 1 || snake.pos.x < 0 || snake.pos.y > gridY - 1 || snake.pos.y < 0 || snake.hitTail()) {
      snake.dead = true;
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
}
