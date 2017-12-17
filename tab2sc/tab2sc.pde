import oscP5.*;
import netP5.*;
import codeanticode.tablet.*;

Tablet tab;
OscP5 osc;
NetAddress sc;

void setup() {
  fullScreen();
  tab = new Tablet(this);
  osc = new OscP5(this, 12321);
  sc = new NetAddress("127.0.0.1", 57120);
  background(0);
}

void draw() {
  stroke(153, 255, 0);
  if ( mousePressed ) {
    strokeWeight(30 * tab.getPressure());
    float msx = norm(mouseX, 0.0, width);
    float msy = norm(mouseY, 0.0, height);
    osc.send("/tab", new Object[]{msx, msy, tab.getPressure()}, sc );
    line(pmouseX, pmouseY, mouseX, mouseY);
  }
}

void keyPressed() {
  if (key=='c') {
    background(0);
  }
}