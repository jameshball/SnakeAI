class Apple {
  PVector pos;
  
  Apple(int gridX, int gridY) {
    pos = new PVector((int)random(gridX), (int)random(gridY));
  }
}
