package sh.ball.snake;

import java.util.Objects;

public class Vector2 {

  public static final Vector2 NORTH = new Vector2(0, 1);
  public static final Vector2 NORTHEAST = new Vector2(1, 1);
  public static final Vector2 EAST = new Vector2(1, 0);
  public static final Vector2 SOUTHEAST = new Vector2(1, -1);
  public static final Vector2 SOUTH = new Vector2(0, -1);
  public static final Vector2 SOUTHWEST = new Vector2(-1, -1);
  public static final Vector2 WEST = new Vector2(-1, 0);
  public static final Vector2 NORTHWEST = new Vector2(1, 1);

  public float x;
  public float y;

  public Vector2(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public Vector2() {
    this(0, 0);
  }

  public Vector2 add(Vector2 v) {
    x += v.x;
    y += v.y;

    return this;
  }

  public Vector2 copy() {
    return new Vector2(x, y);
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;
    Vector2 vector2 = (Vector2) o;
    return Float.compare(vector2.x, x) == 0 &&
      Float.compare(vector2.y, y) == 0;
  }

  @Override
  public int hashCode() {
    return Objects.hash(x, y);
  }
}
