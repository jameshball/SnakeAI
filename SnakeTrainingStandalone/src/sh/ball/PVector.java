package sh.ball;

public class PVector {
    float x;
    float y;

    PVector(float x, float y) {
        this.x = x;
        this.y = y;
    }

    PVector add(PVector v) {
        x += v.x;
        y += v.y;

        return this;
    }
}
