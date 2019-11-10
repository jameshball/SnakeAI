int snakeWidth = 400;
int snakeHeight = 400;
int gridX = 40;
int gridY = 40;

final int SNAKE = 1;
final int EMPTY = 0;
final int APPLE = -1;

Level level = new Level();

void setup() {
  size(400, 400, P2D);
  frameRate(30);
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
      level.snake.direction = new PVector(0, 1);
      break;
    case RIGHT:
      level.snake.direction = new PVector(1, 0);
      break;
    case DOWN:
      level.snake.direction = new PVector(0, -1);
      break;
    case LEFT:
      level.snake.direction = new PVector(-1, 0);
      break;
  }
}
