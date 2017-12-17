


//--processing code 
import oscP5.*; 
import netP5.*; 
OscP5 oscP5; 
void setup() { 
  OscProperties properties= new OscProperties(); 
  properties.setRemoteAddress("127.0.0.1", 57110); 
  properties.setListeningPort(9000); 
  properties.setSRSP(OscProperties.ON); 
  oscP5= new OscP5(this, properties); 
  OscMessage msgNotify= new OscMessage("/notify"); 
  msgNotify.add(1); 
  oscP5.send(msgNotify); 
} 
void draw() {} 
void oscEvent(OscMessage oscIn) { 
  if(oscIn.checkAddrPattern("/test")) { 
    if(oscIn.checkTypetag("iif")) { 
      println("reveived: "+oscIn.get(2).floatValue()); 
    } 
  } 
} 