class Agent {
  PVector pos;
  float theta;
  boolean isLeader;
  float v0;
  color agentColor = color(200, 120, 40); // orange color for regular agents
  color leaderColor = color(255, 50, 50); // red color for leaders


// Constructor      
  Agent(float x, float y, float t, boolean isLeader, float v0) {
    pos = new PVector(x, y);
    theta = t;
    this.v0 = v0;
    this.isLeader = isLeader;
    if (isLeader) {
      agentColor = leaderColor;
    }
  }

  void update() {
    // Move agent forward with speed v0 in direction theta
    pos.x += v0 * cos(theta);
    pos.y += v0 * sin(theta);

    // Wrap-around
    if (pos.x < 0) pos.x += simWidth;
    if (pos.x >= simWidth) pos.x -= simWidth;
    if (pos.y < 0) pos.y += simHeight;
    if (pos.y >= simHeight) pos.y -= simHeight;
  }

  void display() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(theta);
    noStroke();
    fill(agentColor);
    // draw a small triangle pointing in direction theta
    float s = 6;
    triangle(-s, -s*0.6, -s, s*0.6, s*1.5, 0);
    popMatrix();
  }
}