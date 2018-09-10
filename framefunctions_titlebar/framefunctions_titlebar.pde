import netP5.*;
import oscP5.*;


OscP5 osc;
NetAddress sc;
NetAddress meosc;

int eventix = 0;
float[][]crvArrays = new float[20][512];

void settings() {
    fullScreen();
}

void setup() {
      surface.setSize(512,300);
      surface.setLocation(400, 300);

  String[] s0 = loadStrings("crv001.csv");
  for(int i=0;i<s0.length;i++) crvArrays[0][i] = float( s0[i] );
  String[] s1 = loadStrings("crv002.csv");
  for(int i=0;i<s1.length;i++) crvArrays[1][i] = float( s1[i] );
  String[] s2 = loadStrings("crv003.csv");
  for(int i=0;i<s2.length;i++) crvArrays[2][i] = float( s2[i] );
  String[] s3 = loadStrings("crv004.csv");
  for(int i=0;i<s3.length;i++) crvArrays[3][i] = float( s3[i] );
  String[] s4 = loadStrings("crv005.csv");
  for(int i=0;i<s4.length;i++) crvArrays[4][i] = float( s4[i] );
  
  size(512, 300, P3D);

  OscProperties oscproperties = new OscProperties();
  oscproperties.setListeningPort(12321);
  oscproperties.setDatagramSize(5136);
  osc = new OscP5(this, oscproperties);
  sc = new NetAddress("127.0.0.1", 57120);
  meosc = new NetAddress("127.0.0.1", 12321);


  // OSC PLUGS //////////////////////////

  ////WINLETS //////////////////////////////
  osc.plug(winletz, "mk", "/mkwinlet");
  osc.plug(winletz, "rmv", "/rmvwinlet");
  osc.plug(winletz, "mvwin", "/mvwin");
  osc.plug(winletz, "winw", "/winw");
  osc.plug(winletz, "winbdr", "/winbdr");
  osc.plug(winletz, "winhl", "/winhl");
  //////////////////////////////////////////

  //// CURSORS /////////////////////////////
  osc.plug(cursorz, "mk", "/mkcursor");
  osc.plug(cursorz, "rmv", "/rmvcursor");
  osc.plug(cursorz, "kdat", "/kdat");
  osc.plug(cursorz, "show", "/showcsr");
  //////////////////////////////////////////

  //// CURVERENDERS /////////////////////////////
  osc.plug(curveRenderz, "mk", "/mkcrv");
  osc.plug(curveRenderz, "mkfromarray", "/mkcrvfromarray");
  osc.plug(curveRenderz, "rmv", "/rmvcrv");
  osc.plug(curveRenderz, "rendercrv", "/rendercrv");
  osc.plug(curveRenderz, "showcrv", "/showcrv");
  //////////////////////////////////////////

  //// CURVEFOLLOWER /////////////////////////////
  osc.plug(curvefollowerz, "mk", "/mkcrvfollow");
  osc.plug(curvefollowerz, "rmv", "/rmvcrvfollow");
  osc.plug(curvefollowerz, "kdat", "/kdat");
  //////////////////////////////////////////

  //// TACTUS /////////////////////////////
  osc.plug(tactusz, "mk", "/mktactus");
  osc.plug(tactusz, "rmv", "/rmvtactus");
  osc.plug(tactusz, "kdat", "/kdat");
  //////////////////////////////////////////

  //// FEATHERED BEAMS /////////////////////////////
  osc.plug(featheredBeamsz, "mk", "/mkfeatheredBeams");
  osc.plug(featheredBeamsz, "rmv", "/rmvfeatheredBeams");
  osc.plug(featheredBeamsz, "show", "/showfeatheredBeams");
  //////////////////////////////////////////

  //// SVGs /////////////////////////////
  osc.plug(sVGz, "mk", "/mksVG");
  osc.plug(sVGz, "rmv", "/rmvsVG");
  osc.plug(sVGz, "show", "/showsVG");
  //////////////////////////////////////////

  //// imgs /////////////////////////////
  osc.plug(imgz, "mk", "/mkimg");
  osc.plug(imgz, "rmv", "/rmvimg");
  osc.plug(imgz, "show", "/showimg");
  //////////////////////////////////////////

  //// Crescendos /////////////////////////////
 osc.plug(crescendoz, "mk", "/mkcrescendo");
 osc.plug(crescendoz, "rmv", "/rmvcrescendo");
  osc.plug(crescendoz, "show", "/showcrescendo");
  //////////////////////////////////////////
  
  


  //osc.send("/mkfeatheredBeams", new Object[]{0, 55, 35, 140, 80, 0}, meosc);
  //osc.send("/mksVG", new Object[]{0, "trill.svg", 1.0, 300, 50}, meosc);
  //osc.send("/mkcrescendo", new Object[]{0,485,35,150, 80, "mint"}, meosc);
  
  osc.send("/mkwinlet", new Object[]{10, 5.0, 5.0, 100.0, 40.0, "white"}, meosc);
  osc.send("/mkwinlet", new Object[]{11, 110.0, 5.0, 100.0, 40.0, "white"}, meosc);
  osc.send("/mkwinlet", new Object[]{12, 215.0, 5.0, 100.0, 40.0, "white"}, meosc);
  osc.send("/mkwinlet", new Object[]{13, 320.0, 5.0, 100.0, 40.0, "white"}, meosc);
  
  osc.send("/mksVG", new Object[]{0, "trill.svg", 1.0, 10, 10}, meosc);
  osc.send("/mkcrescendo", new Object[]{0, 115, 10, 90, 30, "black"}, meosc);
  osc.send("/mkfeatheredBeams", new Object[]{0, 220, 10, 90, 30, 1}, meosc);
  osc.send("/mkimg", new Object[]{0, "noise.jpg", 1.0, 325, 10}, meosc);



  
  
  osc.send("/mkwinlet", new Object[]{0, 0.0, 50.0, 512.0, 250.0, "black"}, meosc);

  osc.send("/mkcrvfromarray", new Object[]{0, 0, 3, "orange", 0 }, meosc);
  osc.send("/mkcrvfromarray", new Object[]{1, 0, 3, "yellow", 1 }, meosc);
  osc.send("/mkcrvfromarray", new Object[]{2, 0, 3, "dodgerblue", 2 }, meosc);
  osc.send("/mkcrvfromarray", new Object[]{3, 0, 3, "limegreen", 3 }, meosc);
  osc.send("/mkcrvfromarray", new Object[]{4, 0, 3, "violetred", 4 }, meosc);

  
  osc.send("/mkcursor", new Object[]{0, 0, 0, 3,"springgreen" }, meosc);
  osc.send("/mkcursor", new Object[]{1, 0, 1, 3, "turquoiseblue" }, meosc);
  osc.send("/mkcursor", new Object[]{2, 0, 2, 3, "pink" }, meosc);
  osc.send("/mkcursor", new Object[]{3, 0, 3, 3, "sunshine" }, meosc);
  
  osc.send("/mkcrvfollow", new Object[]{0, 0, 0 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{1, 0, 1 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{2, 0, 2 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{3, 0, 3 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{4, 0, 4 }, meosc);
  
  osc.send("/mkcrvfollow", new Object[]{10, 1, 0 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{11, 1, 1 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{12, 1, 2 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{13, 1, 3 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{14, 1, 4 }, meosc);
  
  osc.send("/mkcrvfollow", new Object[]{20, 2, 0 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{21, 2, 1 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{22, 2, 2 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{23, 2, 3 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{24, 2, 4 }, meosc);
  
  osc.send("/mkcrvfollow", new Object[]{30, 3, 0 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{31, 3, 1 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{32, 3, 2 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{33, 3, 3 }, meosc);
  osc.send("/mkcrvfollow", new Object[]{34, 3, 4 }, meosc);
  


  osc.send("/rendercrv", new Object[]{0}, meosc);
  osc.send("/rendercrv", new Object[]{1}, meosc);
  osc.send("/rendercrv", new Object[]{2}, meosc);
  osc.send("/rendercrv", new Object[]{3}, meosc);
  osc.send("/rendercrv", new Object[]{4}, meosc);


  ///////////////////////////////////////
  ///////////////////////////////////////
  ///////////////////////////////////////
} // end setup

void draw() {

  background(25, 33, 47);

  // Winlets ///////
  winletz.drw();
  //////////////////

  // Tactus ///////
  tactusz.drw();
  //////////////////

  // Feathered Beams ///////
  featheredBeamsz.drw();
  /////////////////

  // Curves ///////
  curveRenderz.drw();
  /////////////////

  // SVGs ///////
  sVGz.drw();
  /////////////////

  // imgs ///////
  imgz.drw();
  /////////////////

  // Crescendos ///////
  crescendoz.drw();
  /////////////////

  // Cursors ///////
  cursorz.drw();
  /////////////////

  // Curvefollowers ///////
  curvefollowerz.drw();
  /////////////////






  /////////////////////////////////////////////
  /////////////////////////////////////////////
}// end draw

void keyPressed(){
    osc.send("/rendercrv", new Object[]{0}, meosc);

}

void oscEvent(OscMessage msg) {

  //Receive Arrays for calculating curvs
  if ( msg.checkAddrPattern("/crvcoord") ) {
    int crvix = msg.get(0).intValue(); //curve number

    for (int i=curveRenderz.cset.size ()-1; i>=0; i--) {
      CurveRender inst = curveRenderz.cset.get(i); 

      if (inst.ix == crvix) {

        for (int j=1; j<inst.bufsize+1; j++) { //j=1 because msg[0]=curvenumber
          //float val = map(msg.get(j).floatValue(), -1.0, 1.0, 0.0, 1.0);
          float val = msg.get(j).floatValue();
          

          inst.sampArray[j-1] = val;
        } //end for (int i=0; i<inst.bufsize; i++)

        break;
      } //end  if (inst.ix == crvix)
      
      
      
      
      
      
      
    } //end for (int i=curvRenderz.cset.size ()-1; i>=0; i--)
    //
  } //end   if ( msg.checkAddrPattern("/crvcoord") ) {
    
    
    
  //
  //////////////////////////////////
  //////////////////////////////////
} //end oscEvent