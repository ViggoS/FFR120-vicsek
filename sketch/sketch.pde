// Vicsek model - standard implementation (Processing, Java mode)
// Tryck:
//   SPACE - pausa/fortsätt
//   r     - nollställ (ny slumpmässig start)
//   + / - - öka/minska brus (eta)
//   ] / [ - öka/minska antal partiklar (N)
// Skapad för att vara enkel att experimentera med.

int N = 300;            // antal agenter
float v0 = 2.0;         // hastighet (pix/frame)
float interactionR = 10; // interaktionsradie
float eta = 0.3;        // brusstyrka (max vinkelavvikelse i radianer)
boolean paused = false;

Agent[] agents;

// för visualisering
int trailLen = 0; // >0 ger spår (rymdminne), 0 = inga spår

// Mätning
float globalOrder = 0;

void setup() {
  size(900, 700);
  resetSim();
  smooth();
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
    // Uppdateringssteg enligt Vicsek:
    // 1) för varje agent beräkna medelriktning inom radius
    // 2) lägga på brus
    // 3) flytta enligt v0 och ny riktning
    float[] newTheta = new float[N];
    for (int i = 0; i < N; i++) {
      // beräkna vektorsumman av riktningar inom interactionR
      PVector sum = new PVector(0, 0);
      for (int j = 0; j < N; j++) {
        if (i == j) {
          // inkludera även sig själv i medel (vanligt i Vicsek)
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
      // brus: uniformt i [-eta/2, eta/2]
      float noiseAngle = random(-eta/2.0, eta/2.0);
      newTheta[i] = avgTheta + noiseAngle;
    }

    // 4) applicera nya vinklar och uppdatera positioner
    for (int i = 0; i < N; i++) {
      agents[i].theta = newTheta[i];
      agents[i].update();
    }
  }

  // Räkna global ordning (polarisation)
  PVector vsum = new PVector(0,0);
  for (int i = 0; i < N; i++) {
    vsum.add(PVector.fromAngle(agents[i].theta));
  }
  globalOrder = vsum.mag() / (float)N;

  // Rita agenter
  for (int i = 0; i < N; i++) agents[i].display();

  // UI-tekst
  fill(255);
  noStroke();
  textAlign(LEFT, TOP);
  text("Vicsek model — N = " + N + "   v0 = " + nf(v0,1,2) + "   R = " + nf(interactionR,1,1), 8, 8);
  text("eta = " + nf(eta,1,3) + "   Polarisation = " + nf(globalOrder,1,3), 8, 26);
  text("SPACE: pausa  |  r: reset  |  + / - : ändra brus  |  ] / [: ändra N", 8, 44);
}

// Hjälpresurser för periodiska randvillkor (wrap-around)
// wrapDistX/ Y returnerar minimal skillnad i x/y med torusavstånd
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

void keyPressed() {
  if (key == ' ' ) {
    paused = !paused;
  } else if (key == 'r' || key == 'R') {
    resetSim();
  } else if (key == '+') {
    eta = max(0, eta - 0.02); // minska brus (mer ordning)
  } else if (key == '-') {
    eta += 0.02; // öka brus
  } else if (key == ']') {
    N = min(2000, N + 20);
    resetSim();
  } else if (key == '[') {
    N = max(10, N - 20);
    resetSim();
  }
}
