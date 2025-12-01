// Vicsek model - standard implementation (Processing, Java mode)
// Press:
//   SPACE - pause/resume
//   r     - reset (new random start)
//   + / - - increase/decrease noise (eta)
//   ] / [ - increase/decrease number of particles (N)
// Created to be easy to experiment with.

GraphWindow graph; // separate window for graphing polarization

int N = 300;            // number of agents
float v0 = 2.0;         // speed (pixels/frame)
float interactionR = 10; // interaction radius
float eta = 0.3;        // noise strength (max angular deviation in radians)
boolean paused = false;

Agent[] agents; // array of agents

// for visualization
int trailLen = 0; // >0 gives trails (spatial memory), 0 = no trails

// Measurement
float globalOrder = 0;

void setup() {
  size(900, 700);
  resetSim();
  smooth(); // antialiasing
}

void resetSim() {
  agents = new Agent[N];
  for (int i = 0; i < N; i++) {
    float x = random(width);
    float y = random(height);
    float theta = random(TWO_PI);
    agents[i] = new Agent(x, y, theta);
  }
}

void draw() {
  if (trailLen <= 0) {
    background(30);
  } else {
    fill(30, 15);
    noStroke();
    rect(0, 0, width, height);
  }

  if (!paused) {
    // Update steps according to Vicsek:
    // 1) for each agent calculate average direction within radius
    // 2) add noise
    // 3) move according to v0 and new direction
    float[] newTheta = new float[N];
    for (int i = 0; i < N; i++) {
      // calculate vector sum of directions within interactionR
      PVector sum = new PVector(0, 0);
      for (int j = 0; j < N; j++) {
        if (i == j) {
          // include self in average (common in Vicsek)
          sum.add(PVector.fromAngle(agents[j].theta));
        } else {
          float dx = wrapDistX(agents[j].pos.x - agents[i].pos.x);
          float dy = wrapDistY(agents[j].pos.y - agents[i].pos.y);
          float dist2 = dx*dx + dy*dy;
          if (dist2 <= interactionR*interactionR) {
            sum.add(PVector.fromAngle(agents[j].theta));
          }
        }
      }
      float avgTheta = atan2(sum.y, sum.x);
      // noise: uniform in [-eta/2, eta/2]
      float noiseAngle = random(-eta/2.0, eta/2.0);
      newTheta[i] = avgTheta + noiseAngle;
    }

    // 4) apply new angles and update positions
    for (int i = 0; i < N; i++) {
      agents[i].theta = newTheta[i];
      agents[i].update();
    }
  }

  // Calculate global order (polarization)
  PVector vsum = new PVector(0,0);
  for (int i = 0; i < N; i++) {
    vsum.add(PVector.fromAngle(agents[i].theta));
  }
  globalOrder = vsum.mag() / (float)N;

  // Draw agents
  for (int i = 0; i < N; i++) agents[i].display();

  // UI text
  fill(255);
  noStroke();
  textAlign(LEFT, TOP);
  text("Vicsek model — N = " + N + "   v0 = " + nf(v0,1,2) + "   R = " + nf(interactionR,1,1), 8, 8);
  text("eta = " + nf(eta,1,3) + "   Polarization = " + nf(globalOrder,1,3), 8, 26);
  text("SPACE: pause  |  r: reset  |  + / - : change noise  |  ] / [: change N", 8, 44);
}

// Helper functions for periodic boundary conditions (wrap-around)
// wrapDistX/ Y return minimal difference in x/y with torus distance
float wrapDistX(float dx) {
  if (dx > width/2.0) dx -= width;
  if (dx < -width/2.0) dx += width;
  return dx;
}
float wrapDistY(float dy) {
  if (dy > height/2.0) dy -= height;
  if (dy < -height/2.0) dy += height;
  return dy;
}


void keyPressed() {
  if (key == ' ' ) {
    paused = !paused;
  } else if (key == 'r' || key == 'R') {
    resetSim();
  } else if (key == '+') {
    eta = max(0, eta - 0.02); // decrease noise (more order)
  } else if (key == '-') {
    eta += 0.02; // increase noise
  } else if (key == ']') {
    N = min(2000, N + 20);
    resetSim();
  } else if (key == '[') {
    N = max(10, N - 20);
    resetSim();
  }
}
