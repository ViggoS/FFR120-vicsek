class GraphWindow extends PApplet {

  ArrayList<Float> values = new ArrayList<Float>();
  int maxPoints = 400;

  public void settings() {
    size(600, 300);
  }

  public void setup() {
    surface.setTitle("Polarisation");
  }

  public void draw() {
    background(20);

    stroke(200);
    noFill();

    // Draw axes
    stroke(100);
    line(40, height - 40, width - 20, height - 40);  // x-axis
    line(40, 20, 40, height - 40);                   // y-axis

    // Draw graph
    stroke(0, 200, 200);
    beginShape();
    for (int i = 0; i < values.size(); i++) {
      float x = map(i, 0, maxPoints - 1, 40, width - 20);
      float y = map(values.get(i), 0, 1, height - 40, 20);
      vertex(x, y);
    }
    endShape();
  }

  // Called from main sketch to add new polarization value
  void addPoint(float p) {
    values.add(p);
    if (values.size() > maxPoints) {
      values.remove(0);
    }
  }
}
