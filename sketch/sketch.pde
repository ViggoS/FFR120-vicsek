// Vicsek model - standard implementation (Processing, Java mode)
// Tryck:
//   SPACE - pausa/fortsätt
//   r     - nollställ (ny slumpmässig start)
//   + / - - öka/minska brus (eta)
//   ] / [ - öka/minska antal partiklar (N)
// Skapad för att vara enkel att experimentera med.

int simWidth = 900;
int simHeight = 700;

int N = 50;            // number of agents
float v0 = 2.0;         // speed (pix/frame)
float interactionR = 20; // interaction radius
float eta = 0.3;        // noise strength (max angular deviation in radians)
boolean paused = false;

// leader agent variables
int N_leaders = 5;      // number of leader agents
float leader_influence = 50; // how strongly leaders influence others
float leader_v0 = 2.1; // speed of leader agents

GraphWindow gw = new GraphWindow();

Agent[] agents;

// för visualisering
int trailLen = 0; // >0 ger spår (rymdminne), 0 = inga spår

// Mätning
float alignment = 0;

void setup() {
  // simulation window variables
  size(900, 700);
  resetSim();
  smooth();

  // create and start graph window
  //GraphWindow gw = new GraphWindow();
  PApplet.runSketch(new String[] { "GraphWindow" }, gw);

}

int leaders_appointed = 0;

void resetSim() {
  agents = new Agent[N];
  for (int i = 0; i < N; i++) {
    float x = random(simWidth);
    float y = random(simHeight);
    float theta = random(TWO_PI);
    boolean isLeader = false;
    float v;
    if (leaders_appointed < N_leaders) {
      isLeader = true; // make agent leader
      leaders_appointed++;
      v = leader_v0; // leaders move faster
    } else {
      isLeader = false;
      v = v0; // regular agent speed
    }
  
    agents[i] = new Agent(x, y, theta, isLeader, v);
  }
}

void draw() {
  if (trailLen <= 0) {
    background(30);
  } else {
    fill(30, 15);
    noStroke();
    rect(0, 0, simWidth, simHeight);
  }

  if (!paused) {
    // Update agent according to Vicsek model:
    // 1) for each agent, calculate average direction within radius
    // 2) add noise
    // 3) move according to v0 and new direction

    float[] newTheta = new float[N]; // temporary storage for new angles

    for (int i = 0; i < N; i++) {
      // calculate vector sum of directions within interactionR
      PVector sum = new PVector(0, 0);
      for (int j = 0; j < N; j++) {
        if (i == j) {
          // include self in average 
          sum.add(PVector.fromAngle(agents[j].theta)); // .fromAngle creates unit vector with given angle
        } else {
          float dx = wrapDistX(agents[j].pos.x - agents[i].pos.x);
          float dy = wrapDistY(agents[j].pos.y - agents[i].pos.y);
          float dist2 = dx*dx + dy*dy;
          if (dist2 <= interactionR*interactionR) {
            if (agents[j].isLeader) {
              // leaders have stronger influence (add angle from leader multiple times)
              for (int k = 0; k < leader_influence; k++) {
                sum.add(PVector.fromAngle(agents[j].theta));
              }
            } else {
            sum.add(PVector.fromAngle(agents[j].theta));
            }
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

  // Compute alignment (global order parameter)
  PVector vsum = new PVector(0,0);
  for (int i = 0; i < N; i++) {
    vsum.add(PVector.fromAngle(agents[i].theta));
  }
  alignment = vsum.mag() / (float)N; // normalized to [0,1]

  //send to graph window
  gw.addPoint(alignment);

  // Draw agents
  for (int i = 0; i < N; i++) agents[i].display();

  // Draw interaction radius in bottom right corner
  noFill();
  stroke(100);
  ellipse(width - 60, height - 30, interactionR*2, interactionR*2);
  fill(200);
  noStroke();
  textAlign(CENTER, CENTER);
  text("Interaction radius", width - 60, height - 60);


  // UI text
  fill(255);
  noStroke();
  textAlign(LEFT, TOP);
  text("Vicsek model - N = " + N + "   v0 = " + nf(v0,1,2) + "   R = " + nf(interactionR,1,1), 8, 8);
  text("eta = " + nf(eta,1,3) + "   Alignment = " + nf(alignment,1,3), 8, 26);
  text("SPACE: pausa  |  r: reset  |  + / - : andra brus  |  w / s: andra N", 8, 44);
}

// Helper functions for periodic boundary conditions (wrap-around)
// wrapDistX/ Y return minimal difference in x/y with torus distance
float wrapDistX(float dx) {
  if (dx > simWidth/2.0) dx -= simWidth;
  if (dx < -simWidth/2.0) dx += simWidth;
  return dx;
}
float wrapDistY(float dy) {
  if (dy > simHeight/2.0) dy -= simHeight;
  if (dy < -simHeight/2.0) dy += simHeight;
  return dy;
}


void keyPressed() {
  if (key == ' ' ) {
    paused = !paused;
  } else if (key == 'r' || key == 'R') {
    resetSim();
  } else if (key == '+') {
    eta = max(0, eta - 0.02); // minska brus (mer ordning)
  } else if (key == '-') {
    eta += 0.02; // öka brus
  } else if (key == 'w') {
    N = min(2000, N + 20); // increase N (max 2000)
    resetSim();
  } else if (key == 's') {
    N = max(10, N - 20); // decrease N (min 10)
    resetSim();
  }
}
