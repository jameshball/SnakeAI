class Snake {
  PVector pos;
  ArrayList<PVector> body = new ArrayList<PVector>();
  int direction;
  boolean dead = false;
  int gridX;
  int gridY;
  
  Snake(int iGridX, int iGridY) {
    gridX = iGridX;
    gridY = iGridY;
    pos = new PVector((int)random(1, gridX - 1), (int)random(1, gridY - 1));
    body.add(new PVector(pos.x, pos.y));
    direction = -1;
  }
  
  void update() {
    switch(direction){
      case 0:
        moveHead(0, 1);
        break;
      case 1:
        moveHead(1, 0);
        break;
      case 2:
        moveHead(0, -1);
        break;
      case 3:
        moveHead(-1, 0);
        break;
    }
  }
  
  void moveHead(int x, int y) {
    pos.x += x;
    pos.y += y;
  }
  
  void extend() {
    body.add(new PVector(pos.x, pos.y));
  }
  
  void move() {
    body.remove(0);
    body.add(new PVector(pos.x, pos.y));
  }
  
  boolean hitTail() {
    for (int i = 0; i < body.size() - 1; i++) {
      if (pos.x == body.get(i).x && pos.y == body.get(i).y) {
        return true;
      }
    }
    
    return false;
  }
  
  boolean withinBounds() {
    if (pos.x > gridX - 1 || pos.x < 0 || pos.y > gridY - 1 || pos.y < 0) {
      return false;
    }
    
    return true;
  }
}
