import processing.opengl.*;
import oscP5.*;
import netP5.*;
OscP5 meOsc;
float theta;
PFont liGothicMed20, liGothicMed14;
FunkyLM lm;

FunkyLMSet funkyLMSetGCStI; //global class set instance

void setup(){
  size(800, 600, P3D);
  meOsc = new OscP5(this, 12345);
  liGothicMed20 = loadFont("LiGothicMed-20.vlw");
  liGothicMed14 = loadFont("LiGothicMed-14.vlw");
  lm = new FunkyLM( );

  // FUNKY LEVEL METER /////////////////////////////////////////////
  funkyLMSetGCStI = new FunkyLMSet();
  meOsc.plug(funkyLMSetGCStI,"mkInstMainInFLM","/mkMainInFLM");
  meOsc.plug(funkyLMSetGCStI,"mkInstMainOutFLM","/mkMainOutFLM");
  meOsc.plug(funkyLMSetGCStI,"mkInstRouteFunkyLM","/mkFLM");
  meOsc.plug(funkyLMSetGCStI,"rmvInstFunkyLM","/rmvFLM");
  meOsc.plug(funkyLMSetGCStI,"movePannerCStM","/audNetPan");
  meOsc.plug(funkyLMSetGCStI,"chgWidthCStM","/audNetPanWidth");
  meOsc.plug(funkyLMSetGCStI,"aniSpriteCStM","/audNetAmp");
  meOsc.plug(funkyLMSetGCStI,"aniSpriteSatCStM","/audNetAmp");
}

void draw(){
  background(50, 58, 72);
  lights();
 // ortho(-width/2, width/2, -height/2, height/2, -100, 100); 
 // theta = (frameCount/200.0)*TWO_PI;
  
  
  // LINE DRAWN ////////////////////////////////////////////////
  lm.drawFunkyLM();
  funkyLMSetGCStI.drawFunkyLMSet();
}


class FunkyLM{
  //CONSTRTUCTOR VARIABLES (CS) /////////////////////
  int idxCS = 0;
  int xCS = width/2;
  int yCS = height/2;
  float rCS = 50.0;
  int inChCS = 16;
  int numChCS = 4;
  int firstBusChCS = 16;
  //CLASS VARIABLES (C) /////////////////////////////
  float mainShellRotXSpdC = 400.0;
  float mainShellRotYSpdC = 300.0;
  float mainShellRotZSpdC = 375.0;
  color mainShellClrC = color(100, 100, 100, 70);
  color mainSpriteClrC = color(0, 255, 0);
  color sataliteSpriteClrC = color(255, 255, 0);
  color mainSpriteStrokeWtC = 1;
  int vtxsMainSizeC = 333;
  int vtxsSatalitesSizeC = 99;
  Float [] vtxsMainC;
  float mainSpriteAmpMinC = -55.0;
  float mainSpriteAmpMaxC = -4.0;
  float aziC= -HALF_PI;
  float panWidthC = 2.0;
  boolean pannerC = true;
  ArrayList vtxsSatalitesC = new ArrayList();
  //CONSTRTUCTOR(s) ////////////////////////////////////
  FunkyLM(int CidxCS, int CxCS, int CyCS, float CrCS, int CinChCS, int CnumChCS, int CfirstBusChCS){
    idxCS = CidxCS;
    xCS = CxCS;
    yCS = CyCS;
    rCS = CrCS;
    inChCS = CinChCS;
    numChCS = CnumChCS;
    firstBusChCS = CfirstBusChCS;
    //POST-CONSTRUCTOR CLASS VARIABLES (C) ///////////
    vtxsMainC = new Float [vtxsMainSizeC];
    for(int i=0; i<numChCS; i++){
      vtxsSatalitesC.add(new Float [vtxsSatalitesSizeC]);
    }
  }
  //no argument constructor
  FunkyLM(){
    //POST-CONSTRUCTOR CLASS VARIABLES (C) ///////////
    for(int i=0; i<numChCS; i++){
      vtxsSatalitesC.add(new Float [vtxsSatalitesSizeC]);
    }
    vtxsMainC = new Float [vtxsMainSizeC];
  }

  //CLASS METHOD (CM): drawFunkyLM /////////////////////////
  void drawFunkyLM(){
    //draw shell
    pushMatrix();
    //scale(1, 1, 0.1);
    translate(xCS, yCS);
    noFill();    
    stroke(mainShellClrC);
    strokeWeight(1);
    rotateX( (frameCount/mainShellRotXSpdC)*TWO_PI );
    rotateY( (frameCount/mainShellRotYSpdC)*TWO_PI );
    rotateZ( (frameCount/mainShellRotZSpdC)*TWO_PI );
    sphere(rCS);
    //write channel number
    textFont(liGothicMed20); 
    fill(255);
    rotateY(0.25*PI); 
    //rotateX(HALF_PI);
    text(inChCS, (cos(-HALF_PI) * (rCS)), (sin(-HALF_PI) * (rCS)));
    //  rotateY(HALF_PI); 
    text(inChCS, (cos(0) * (rCS)), (sin(0) * (rCS))); 
    //  rotateX(HALF_PI);
    text(inChCS, (cos(HALF_PI) * (rCS+14)), (sin(HALF_PI) * (rCS+14)));
    text(inChCS, (cos(PI) * (rCS+14)), (sin(PI) * (rCS+14)));
    text(inChCS, 0, 0, rCS+5);
    text(inChCS, 0, 0, -rCS-5); 
    popMatrix();
    
    pushMatrix();
        translate(xCS, yCS);
    if(pannerC){
      textFont(liGothicMed20); 
      fill(255,0,255);
      text("<"+idxCS+">", (cos(-HALF_PI) * (70))-12, (sin(-HALF_PI) * (70))-10, rCS/2);
    }
    popMatrix();

    //draw sound sprite
    pushMatrix();
    // scale(1, 1, 0.1);
    translate(xCS, yCS, 10);
    rotateY(PI*0.3);
    rotateZ(PI*0.72);
    stroke(mainSpriteClrC);
    strokeWeight(mainSpriteStrokeWtC);
    noFill();
    beginShape();
    for(int i=0; i<vtxsMainC.length/3; i=i+3){
      if(vtxsMainC[i] !=null && vtxsMainC[i+1] !=null && vtxsMainC[i+2] !=null){
        vertex(vtxsMainC[i], vtxsMainC[i+1], vtxsMainC[i+2]);
      }
    }
    endShape(CLOSE);
    popMatrix();

    //draw panner
    if(pannerC){
      pushMatrix();
      //scale(1, 1, 0.1);
      translate(xCS+ (cos(aziC) * (rCS+7)), yCS + (sin(aziC) * (rCS+7)), rCS); 
      noStroke();
      fill(0, 0, 255);
      sphere(7);
      popMatrix();
      // arc for width
      pushMatrix();
      ellipseMode(CENTER);
      translate(xCS, yCS, rCS);
      stroke(255,0,0);
      noFill();
      strokeWeight(5);
      arc(0, 0, rCS+60, rCS+60, aziC-(panWidthC*(PI/numChCS)), aziC+(panWidthC*(PI/numChCS)));
      popMatrix();
    }

    //draw satalites
    for(int j=0; j<numChCS; j++){
      pushMatrix();
      translate(xCS + (cos( (((TWO_PI/numChCS)*j)-(PI/numChCS))-HALF_PI ) * (rCS+4+13+14+5)), yCS + (sin( (((TWO_PI/numChCS)*j)-(PI/numChCS))-HALF_PI ) * (rCS+4+13+14+5)), rCS);
      //   scale(1, 1, 0.1);
      stroke(100, 100, 100, 70);
      strokeWeight(1);
      noFill();
      sphere(13);
      //write channel number
      textFont(liGothicMed14); 
      fill(255);
      // text(firstBusChCS+j, (cos(-HALF_PI) * (13)), (sin(-HALF_PI) * (13)));
      text(firstBusChCS+j, -7, -13, 0);
      //draw sound sprites
      // scale(1, 1, 0.1);
      rotateY(PI*0.3);
      rotateZ(PI*0.72);
      stroke(sataliteSpriteClrC);
      strokeWeight(mainSpriteStrokeWtC);
      noFill();
      beginShape();
      Float[] vtxsSatalitesLoc = (Float[]) vtxsSatalitesC.get(j);
      for(int k=0; k<vtxsSatalitesLoc.length/3; k=k+3){
        if(vtxsSatalitesLoc[k] !=null && vtxsSatalitesLoc[k+1] !=null && vtxsSatalitesLoc[k+2] !=null){
          vertex(vtxsSatalitesLoc[k], vtxsSatalitesLoc[k+1], vtxsSatalitesLoc[k+2]);
        }
      }
      endShape(CLOSE);
      popMatrix();
    }
  }  // end method

  //CLASS METHOD (CM): aniSpriteMainCM /////////////////////////
  void aniSpriteMainCM(float ampRawM){
    float ampMappedM = map(ampRawM, mainSpriteAmpMinC, mainSpriteAmpMaxC, 0.0, rCS);
    for(int i=0; i<vtxsMainC.length; i++){
      vtxsMainC[i] = constrain(ampMappedM, 0.0, rCS) * random(0.1, 1.4);
    }  
  }  // end method

  //CLASS METHOD (CM): aniSpriteSatalitesCM /////////////////////////
  void aniSpriteSatalitesCM(int satNum, float ampRawM){
    float ampMappedM = map(ampRawM, mainSpriteAmpMinC, mainSpriteAmpMaxC, 0.0, rCS);
    Float[] vtxsSatalitesLoc = (Float[]) vtxsSatalitesC.get(satNum);
    for(int i=0; i<vtxsSatalitesLoc.length; i++){
      vtxsSatalitesLoc[i] = constrain(ampMappedM, 0.0, rCS) * random(0.1, 1.4);
    }
  }  // end method

} //end class 



// CLASS SET CLASS ////////////////////////////////
class FunkyLMSet{
  ArrayList FunkyLMSetCAL = new ArrayList();
  ArrayList FunkyLMInsSetCAL = new ArrayList();
  ArrayList FunkyLMOutsSetCAL = new ArrayList();

  //ADD INSTANCE OF MAIN INS TO ARRAY LIST
  void mkInstMainInFLM(int firstInChCStM, int numChInCStM){
    for (int i = FunkyLMInsSetCAL.size()-1; i >= 0; i--) {
      FunkyLMInsSetCAL.remove(i);
    }
    for(int i=0; i<numChInCStM; i++){
      FunkyLMInsSetCAL.add(new FunkyLM(i, 40 + (70*i), 40, 30, firstInChCStM+i, 0, 16));
    }
    for (int i = FunkyLMInsSetCAL.size()-1; i >= 0; i--) {
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMInsSetCAL.get(i);
      funkyLMLoc.pannerC = false;
    }
  }

  //ADD INSTANCE OF MAIN OUTS TO ARRAY LIST
  void mkInstMainOutFLM(int numChInCStM){
    for (int i = FunkyLMOutsSetCAL.size()-1; i >= 0; i--) {
      FunkyLMOutsSetCAL.remove(i);
    }
    for(int i=0; i<numChInCStM; i++){
      FunkyLMOutsSetCAL.add(new FunkyLM(i, 40 + (70*i), height-40, 30, i, 0, 16));
    }
    for (int i = FunkyLMOutsSetCAL.size()-1; i >= 0; i--) {
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMOutsSetCAL.get(i);
      funkyLMLoc.pannerC = false;
    }
  }

  //ADD INSTANCE ROUTER TO ARRAY LIST
  void mkInstRouteFunkyLM(int CidxCStM, int CinChCStM, int CnumChCStM, int CfirstBusCh){
    FunkyLMSetCAL.add(new FunkyLM(CidxCStM, 85+((50+110)*FunkyLMSetCAL.size()), (120+25+55), 25, CinChCStM, CnumChCStM, CfirstBusCh));
  }

  //REMOVE CLASS INSTANCE FROM ARRAY LIST
  void rmvInstFunkyLM(int idxCStM){
    for (int i = FunkyLMSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMToRmv = (FunkyLM) FunkyLMSetCAL.get(i);
      if (funkyLMToRmv.idxCS == idxCStM) {
        FunkyLMSetCAL.remove(i);
      }
    }
  }

  //MOVE PANNER /////////////////////////
  void movePannerCStM(int idxCStM, float aziScM){
    for (int i = FunkyLMSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMSetCAL.get(i);
      if (funkyLMLoc.idxCS == idxCStM) {
        funkyLMLoc.aziC = map( (aziScM%2.0), 0.0, 2.0, -HALF_PI, (1.5*PI) );
      }
    }
  }  // end method

  //WIDTH /////////////////////////
  void chgWidthCStM(int idxCStM, float widthScM){
    for (int i = FunkyLMSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMSetCAL.get(i);
      if (funkyLMLoc.idxCS == idxCStM) {
        funkyLMLoc.panWidthC = widthScM;
      }
    }
  }  // end method

  //CLASS SET METHOD (CStM): aniSpriteMainCStM /////////////////////////
  void aniSpriteCStM(int inChCStM, int globalChCStM, float ampRawCStM){
    for (int i = FunkyLMInsSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMInsSetCAL.get(i);
      if (funkyLMLoc.inChCS == globalChCStM) {
        funkyLMLoc.aniSpriteMainCM(ampRawCStM);
      }
    }
    for (int i = FunkyLMOutsSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMOutsSetCAL.get(i);
      if (funkyLMLoc.inChCS == globalChCStM) {
        funkyLMLoc.aniSpriteMainCM(ampRawCStM);
      }
    }
    for (int i = FunkyLMSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMSetCAL.get(i);
      if (funkyLMLoc.inChCS == globalChCStM) {
        funkyLMLoc.aniSpriteMainCM(ampRawCStM);
      }
    }
  }  // end method

  //CLASS SET METHOD (CStM): aniSpriteSatCStM /////////////////////////
  void aniSpriteSatCStM(int inChCStM, int globalChCStM, float ampRawCStM){
    for (int i = FunkyLMSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMLoc = (FunkyLM) FunkyLMSetCAL.get(i);
      for(int j=0; j<funkyLMLoc.numChCS; j++){
        if ((funkyLMLoc.firstBusChCS+j) == globalChCStM) {
          funkyLMLoc.aniSpriteSatalitesCM(j, ampRawCStM);
        }
      }
    }
  }  // end method

  //DRAW METHOD
  void drawFunkyLMSet(){
    for (int i = FunkyLMSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMToDraw = (FunkyLM) FunkyLMSetCAL.get(i);
      funkyLMToDraw.drawFunkyLM();
    }
    for (int i = FunkyLMInsSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMInsToDraw = (FunkyLM) FunkyLMInsSetCAL.get(i);
      funkyLMInsToDraw.drawFunkyLM();
    }
    for (int i = FunkyLMOutsSetCAL.size()-1; i >= 0; i--) { 
      FunkyLM funkyLMInsToDraw = (FunkyLM) FunkyLMOutsSetCAL.get(i);
      funkyLMInsToDraw.drawFunkyLM();
    }
  }

} //end of class set class



color colorMaker(int r, int g, int b, int a){
  color newColor = color(r,g,b,a);
  return newColor;
}


void oscEvent(OscMessage theOscMessage) {
  // MESSAGE RECEIVED MESSAGE /////////////////////////////////////////////
  if(theOscMessage.isPlugged()==false) {
    println("OSC MSG RCVD: " + theOscMessage + " NOT PLUGGED");
  }
  /*
  else{
   // println("OSC MSG RCVD: " + theOscMessage + " PLUGGED");
   }
   */
}





















void keyPressed(){
  lm.aniSpriteMainCM(random(1));
}











