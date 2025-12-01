class Agent {
  PVector pos;
  float theta;

  Agent(float x, float y, float t) {
    pos = new PVector(x, y);
    theta = t;
  }

  void update() {
    // Flytta med konstant hastighet v0 i riktning theta, med wrap-around
    pos.x += v0 * cos(theta);
    pos.y += v0 * sin(theta);

    // Wrap-around
    if (pos.x < 0) pos.x += width;
    if (pos.x >= width) pos.x -= width;
    if (pos.y < 0) pos.y += height;
    if (pos.y >= height) pos.y -= height;
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(theta);
    noStroke();
    fill(200, 120, 40);
    // rita en liten triangel som pekar åt theta
    float s = 6;
    triangle(-s, -s*0.6, -s, s*0.6, s*1.5, 0);
    popMatrix();
  }
}