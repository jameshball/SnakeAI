int snakeWidth = 400;
int snakeHeight = 400;
Level level = new Level(20, 20);

void setup() {
  size(400, 400, P2D);
  frameRate(60);
  smooth();
}

void draw() {
  background(255);
  level.update();
  level.show();
}

void keyPressed() {
  switch(keyCode) {
    case UP:
      level.snake.direction = 0;
      break;
    case RIGHT:
      level.snake.direction = 1;
      break;
    case DOWN:
      level.snake.direction = 2;
      break;
    case LEFT:
      level.snake.direction = 3;
      break;
  }
}
