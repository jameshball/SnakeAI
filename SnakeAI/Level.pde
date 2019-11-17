/* The Level class holds all details about the current state of the game, including the Snake, Apple and //<>//
   score. It has the functionality to update the grid each frame. */
class Level {
  private int[][] grid;
  Snake snake;
  private PVector apple;
  int score;
  private int movesSinceLastApple = 0;
  private int nextAppleMoves = 300;
  
  Level() {
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
  
  /* Generates a new apple position, which is a random location that is not taken up by the snake.
     TODO: Make this more efficient. In the late-game, random() will be called far too many times. */
  private void resetApple() {
    do  {
      /* Create a new random location within the boundaries of the grid. */
      apple = new PVector((int) random(gridX), (int) random(gridY));
      /* Repeat while the apple is already taken up by the snake. */
    } while ((apple.x == snake.pos.x && apple.y == snake.pos.y) || snake.isTail(apple));
    
    set(apple, APPLE);
  }
  
  /* The update method moves the head of the snake and checks if it has died. If the snake has eaten an
     apple, it will grow, otherwise it will move to the new position. This only executes if the snake is
     alive. */
  void update() {
    snake.update();
  
    /* If the snake has run out of moves for this apple... */
    if (movesSinceLastApple > nextAppleMoves) {
      snake.dead = true;
    }
    
    if (!snake.dead) {
      /* If the snake eats an apple... */
      if (snake.pos.x == apple.x && snake.pos.y == apple.y) {
        /* Increase the score and size of the snake, generate a new apple and change the nextAppleMoves 
           value. */
        snake.extend();
        resetApple();
        score++;
        movesSinceLastApple = 0;
        updateGrid(true, new PVector());
        /* TODO: Turn this function into a lookup table to prevent repeat calculations. */
        nextAppleMoves = (int) (200 * (Math.log(snake.body.size()) / Math.log(3)) + 300);
      }
      else {
        PVector tail = snake.body.get(0);
        updateGrid(false, tail);
        snake.move();
      }
      
      movesSinceLastApple++;
    }
  }
  
  /* The show method draws squares that correspond to the location of the apple, snake and empty squares,
     drawing the snake and apple on different colours if they are currently the best performing snake. */
  void show(boolean isBest) {
    noStroke();
    /* This is a shorthand way of referencing the width and height of squares when they are rendered. */
    int rectWidth = snakeWidth / gridX;
    int rectHeight = snakeHeight / gridY;
    
    for (int i = 0; i < gridX; i++) {
      for (int j = 0; j < gridY; j++) {
        /* Checks the current square in the grid and changes the colour accordingly. Also checks if this
           level is the current 'best', meaning it has the highest score in the population. */
        if (grid[i][j] == APPLE) {
          fill(255, 150, 150);
          if (isBest) {
            fill(0, 255, 0);
          }
        }
        else if (grid[i][j] == SNAKE) {
          fill(128);
          if (isBest) {
            fill(255, 0, 0);
          }
        }
        else {
          noFill();
        }
        
        /* Draws a rectangle at the appropriate location. */
        rect(i * rectWidth, snakeHeight - ((j + 1) * rectHeight), rectWidth, rectHeight);
      }
    }
  }
  
  /* Updates the snake's position in the grid. */
  private void updateGrid(boolean appleEaten, PVector tailPos) {
    if (!appleEaten) {
      set(tailPos, EMPTY);
    }
    
    set(snake.pos, SNAKE);
  }
  
  /* Sets the element stored at 'pos' in the grid array to the value 'objectType'. */
  private void set(PVector pos, int objectType) {
    grid[(int) pos.x][(int) pos.y] = objectType;
  }
  
  /* Returns a list of three numbers. They represent the distance to the snake's body, the apple and the 
     walls of the grid. */
  private List<Float> snakeLook(PVector direction) {
    /* I need to create a deep copy of snake.pos because I will be modifying it in this method. */
    PVector snakePos = new PVector(snake.pos.x, snake.pos.y);
    Float[] vision = new Float[3];
    int distance = 1;
    
    for (int i = 0; i < vision.length; i++) {
      vision[i] = 0.0;
    }
    
    /* Move snakePos in the direction of the dir vector specified and continue if it is still within the
       bounds of the grid. */
    while(withinBounds(snakePos.add(direction))) {
      /* If snakePos comes in contact with the snake's body and vision[0] is unassigned... */ 
      if (grid[(int) snakePos.x][(int) snakePos.y] == SNAKE && vision[0] == 0) {
        vision[0] = 1.0f / distance;
      }
      
      /* If snakePos comes in contact with an apple and vision[1] is unassigned... */ 
      if (grid[(int) snakePos.x][(int) snakePos.y] == APPLE && vision[1] == 0) {
        vision[1] = 1.0;
      }
      
      distance++;
    }
    
    /* Sets the distance to the wall of the grid. */
    vision[2] = 1.0f / distance;
    
    return Arrays.asList(vision);
  }
  
  /* This uses the snakeLook() method to look in eight directions around the snake (i.e. NESW, and all 
  diagonals). This forms as the input to the player's neural network. */ 
  float[] vision() {
    ArrayList<Float> vision = new ArrayList<Float>();
    
    /* Adds the results of looking in eight directions around the snake to the vision array. */
    PVector[] directions = new PVector[] { new PVector(0, 1), new PVector(1, 1), new PVector(1, 0), new PVector(1, -1),
                                           new PVector(0, -1), new PVector(-1, -1), new PVector(-1, 0), new PVector(-1, 1)};
                                           
    for (int i = 0; i < directions.length; i++) {
      vision.addAll(snakeLook(directions[i]));
    }
    
    /* Converts the vision list into an array. */
    float[] arr = new float[vision.size()];
    
    for (int i = 0; i < vision.size(); i++) {
      arr[i] = vision.get(i);
    }
    
    return arr;
  }
  
  /* Returns true if the input vector is within the bounds of the grid. */
  boolean withinBounds(PVector loc) {
    if (loc.x > gridX - 1 || loc.x < 0 || loc.y > gridY - 1 || loc.y < 0) {
      return false;
    }
    
    return true;
  }
}
