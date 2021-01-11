package sh.ball.snake;

import java.util.*;
import java.util.concurrent.ThreadLocalRandom;

/* Snake holds all the information about the Snake, including its current position, location of all parts
of its tail and whether it is still alive. */
public class Snake {

  /* By default, the snake moves right */
  private static final Vector2 DEFAULT_DIRECTION = Vector2.WEST;

  private final Level level;
  private final Deque<Vector2> body;
  private final Set<Vector2> bodySet;
  private final Vector2 head;

  private Vector2 direction;
  private boolean dead;

  public Snake(Level level) {
    this.level = level;
    /* This resets the snake's head to a random position at least 1 square away from the edges. */
    this.head = new Vector2(ThreadLocalRandom.current().nextInt(level.width() - 1) + 1, ThreadLocalRandom.current().nextInt(level.height() - 1) + 1);
    this.dead = false;
    this.body = new ArrayDeque<>();
    this.bodySet = new HashSet<>();
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

    if (isBody(head) || !level.withinBounds(head)) {
      dead = true;
    }
  }

  /* This method moves the snake by removing the last element in their tail and adding the location of the
  snake's head. */
  public void move() {
    Vector2 removed = body.removeFirst();
    bodySet.remove(removed);
    extend();
  }

  /* This method extends the snake's body by adding the new position of the snake's head, without removing
  the end of its tail. */
  public void extend() {
    Vector2 newHead = head.copy();
    body.add(newHead);
    bodySet.add(newHead);
  }

  /* Compares each part of the snake's tail with the new head position. If they are equal, the snake has
  hit its tail. */
  private boolean isBody(Vector2 vector) {
    return bodySet.contains(vector);
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
    return body.peekFirst();
  }

  public Vector2 head() {
    return head;
  }
}
