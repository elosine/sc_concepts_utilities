~tablesize = 800;
a =  Signal.sineFill(~tablesize, [1,3]);
b = Buffer.alloc(s, ~tablesize);
b.loadCollection(a);
b.plot
//CONVERT BUFFER TO FLOAT ARRAY
b.loadToFloatArray( action:{arg array; c = array.as(Array); "done".postln;} );
c.insert(0, "/sbuf");
~proc = NetAddr("127.0.0.1", 12321); //Processing address
~proc.sendBundle(0.0, ~resampArray);



//Processing Code

/MAKE A DRAGGABLE RANGE

import oscP5.*;
import netP5.*;
OscP5 meosc;

int bufsize = 800;

float[] sampArray;

void setup() {
  size(800, 800);
  sampArray = new float[bufsize];
  for (int i=0; i<bufsize; i++) {
    sampArray[i] = 0.0;
  }

  OscProperties properties= new OscProperties();
  //properties.setRemoteAddress("127.0.0.1", 57120);  //osc send port (to sc)
  properties.setListeningPort(12321);               //osc receive port (from sc)/*
  properties.setDatagramSize(5136);  //5136 is the minimum
  meosc= new OscP5(this, properties);
}

void draw() {
  background(0);
  for (int i=1; i<bufsize; i++) {
    stroke(153, 255, 0);
    point(i, sampArray[i]);
  }
}


void oscEvent(OscMessage msg) {
  if ( msg.checkAddrPattern("/sbuf") ) {
    for (int i=0; i<bufsize; i++) {
      sampArray[i] = msg.get(i).floatValue();
    }
  }
}
