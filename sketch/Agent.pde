class Agent {
  PVector pos;
  float theta;

  // Constructor      
  Agent(float x, float y, float t) {
    pos = new PVector(x, y);
    theta = t;
  }

  void update() {
    // Move agent forward with speed v0 in direction theta
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
    fill(200, 120, 40); // orange color
    // draw a small triangle pointing in direction theta
    float s = 6;
    triangle(-s, -s*0.6, -s, s*0.6, s*1.5, 0);
    popMatrix();
  }
}