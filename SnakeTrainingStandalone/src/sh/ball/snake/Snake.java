package sh.ball.snake;

import sh.ball.ai.Population;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

/* Snake holds all the information about the Snake, including its current position, location of all parts
of its tail and whether it is still alive. */
public class Snake {

  /* By default, the snake moves right */
  private static final Vector2 DEFAULT_DIRECTION = Vector2.WEST;

  private final Level level;
  private final List<Vector2> body;
  private final Vector2 head;

  private Vector2 direction;
  private boolean dead;

  public Snake(Level level) {
    this.level = level;
    /* This resets the snake's head to a random position at least 1 square away from the edges. */
    this.head = new Vector2(Population.rnd.nextInt(level.width() - 1) + 1, Population.rnd.nextInt(level.height() - 1) + 1);
    this.dead = false;
    this.body = new ArrayList<>();
    this.body.add(new Vector2(head.x, head.y));
    this.direction = DEFAULT_DIRECTION;
  }

  public int length() {
    return body.size();
  }

  /* This method is executed every frame. 'direction' is updated externally and corresponds to the next
  direction the snake will move in. 'direction' is added to the location of the snake's head.
  It also checks if the snake has hit its tail or gone out of the bounds of the grid. */
  public void update() {
    head.add(direction);

    if (isTail(head) || !level.withinBounds(head)) {
      dead = true;
    }
  }

  /* This method moves the snake by removing the last element in their tail and adding the location of the
  snake's head. */
  public void move() {
    body.remove(0);
    body.add(head.copy());
  }

  /* This method extends the snake's body by adding the new position of the snake's head, without removing
  the end of its tail. */

  public void extend() {
    body.add(head.copy());
  }
  /* Compares each part of the snake's tail with the new head position. If they are equal, the snake has
  hit its tail. */

  private boolean isTail(Vector2 vector) {
    for (int i = 0; i < body.size() - 1; i++) {
      Vector2 part = body.get(i);
      if (vector.equals(part)) {
        return true;
      }
    }

    return false;
  }
  /* Updates the snake's direction so it now points in the new direction. */

  public void point(Vector2 dir) {
    direction = dir;
  }
  public void kill() {
    dead = true;
  }

  public boolean isDead() {
    return dead;
  }

  public Vector2 tail() {
    return body.get(0);
  }

  public Vector2 head() {
    return head;
  }
}
