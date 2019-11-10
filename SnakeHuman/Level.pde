/* The Level class holds all details about the current state of the game, including the Snake, Apple and
   score. It has the functionality to update the grid each frame. */
class Level {
  private int[][] grid;
  Snake snake;
  private PVector apple;
  int score;
  
  Level() {
    resetLevel();
  }
  
  private void resetLevel() {
    snake = new Snake();
    resetGrid();
    resetApple();
  }
  
  /* Resets the grid to all EMPTY squares. */
  private void resetGrid() {
    grid = new int[gridX][gridY];
    
    for (int i = 0; i < gridX; i++) {
      for (int j = 0; j < gridY; j++) {
        grid[i][j] = EMPTY;
      }
    }
  }
  
  /* Generates a new apple position, which is a random location that is not taken up by the snake. */
  private void resetApple() {
    do  {
      /* Create a new random location within the boundaries of the grid. */
      apple = new PVector((int) random(gridX), (int) random(gridY));
      /* Repeat while the apple is already taken up by the snake. */
    } while ((apple.x == snake.pos.x && apple.y == snake.pos.y) || snake.isTail(apple));
  }
  
  /* The update method moves the head of the snake and checks if it has died. If the snake has eaten an
     apple, it will grow, otherwise it will move to the new position. This only executes if the snake is
     alive. */
  void update() {
    snake.update();
    
    if (snake.dead) {
      resetLevel();
    }
    
    /* If the snake eats an apple... */
    if (snake.pos.x == apple.x && snake.pos.y == apple.y) {
      /* Increase the score and size of the snake, generate a new apple and change the nextAppleMoves 
         value. */
      snake.extend();
      resetApple();
      score++;
    }
    else {
      snake.move();
    }
      
    updateGrid();
  }
  
  /* The show method draws squares that correspond to the location of the apple, snake and empty squares,
     drawing the snake and apple on different colours if they are currently the best performing snake. */
  void show() {
    noStroke();
    /* This is a shorthand way of referencing the width and height of squares when they are rendered. */
    int rectWidth = snakeWidth / gridX;
    int rectHeight = snakeHeight / gridY;
    
    for (int i = 0; i < gridX; i++) {
      for (int j = 0; j < gridY; j++) {
        /* Checks the current square in the grid and changes the colour accordingly. Also checks if this
           level is the current 'best'. */
        if (grid[i][j] == APPLE) {
          fill(255, 150, 150);
        }
        else if (grid[i][j] == SNAKE) {
          fill(128);
        }
        else {
          noFill();
        }
        
        /* Draws a rectangle at the appropriate location. */
        rect(i * rectWidth, snakeHeight - ((j + 1) * rectHeight), rectWidth, rectHeight);
      }
    }
  }
  
  /* Resets the grid and populates it with the locations of the snake and the apple. */
  private void updateGrid() {
    resetGrid();
    
    set(apple, APPLE);
    
    for (int i = 0; i < snake.body.size(); i++) {
      set(snake.body.get(i), SNAKE);
    }
  }
  
  /* Sets the element stored at 'pos' in the grid array to the value 'objectType'. */
  private void set(PVector pos, int objectType) {
    grid[(int) pos.x][(int) pos.y] = objectType;
  }
  
  /* Returns true if the input vector is within the bounds of the grid. */
  boolean withinBounds(PVector loc) {
    if (loc.x > gridX - 1 || loc.x < 0 || loc.y > gridY - 1 || loc.y < 0) {
      return false;
    }
    
    return true;
  }
}
