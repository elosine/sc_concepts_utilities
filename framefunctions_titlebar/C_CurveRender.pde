// DECLARE/INITIALIZE CLASS SET
CurveRenderSet curveRenderz = new CurveRenderSet();

/**
 /// PUT IN SETUP ///
 osc.plug(curveRenderz, "mk", "/mkcurveRender");
 osc.plug(curveRenderz, "rmv", "/rmvcurveRender");
 
 /// PUT IN DRAW ///
 curveRenderz.drw();
 */


class CurveRender {

  // CONSTRUCTOR VARIALBES /////////
  int ix, winix;
  int wt;
  String crvclr;
  // CLASS VARIABLES ///////////////
  int showcrv=0;
  float x, y, w, h;
  int bufsize;
  float[] sampArray;
  PGraphics offscreenbuffer;
  PImage crvimg;
  boolean drwgate = false;
  // CONSTRUCTORS //////////////////
  //// Constructor 1 ////
  CurveRender(int aix, int awinix, int awt, String acrvclr) {
    ix = aix;
    winix = awinix;
    wt = awt;
    crvclr = acrvclr;

    //Get info from winlet you wish to render curve in
    for (Winlet inst : winletz.cset) {
      if (inst.ix == winix) {
        x = inst.x;
        y = inst.y;
        w = inst.w;
        h = inst.h;

        bufsize = int(inst.w);
        sampArray = new float[bufsize];
        for (int i=0; i<bufsize; i++) sampArray[i] = 0.0;
        offscreenbuffer = createGraphics(int(w), int(h), JAVA2D);
        break;
      }
    }
    //
  } //end constructor 1
  
  //// Constructor 2 ////
  CurveRender(int aix, int awinix, int awt, String acrvclr, int asampArrayNum) {
    ix = aix;
    winix = awinix;
    wt = awt;
    crvclr = acrvclr;
    sampArray = crvArrays[asampArrayNum];

    //Get info from winlet you wish to render curve in
    for (Winlet inst : winletz.cset) {
      if (inst.ix == winix) {
        x = inst.x;
        y = inst.y;
        w = inst.w;
        h = inst.h;
        bufsize = int(inst.w);

        offscreenbuffer = createGraphics(int(w), int(h), JAVA2D);
        break;
      }
    }
    //
  } //end constructor 2

  //  DRAW METHOD //
  void drw() {
    if(drwgate){
      if(showcrv==1){
        image(crvimg, x, y);
      }
    }
  } //End drw

  //  rendercrv METHOD //
  void rendercrv() {

    offscreenbuffer.beginDraw();

    offscreenbuffer.smooth();
    offscreenbuffer.noFill();
    offscreenbuffer.stroke( clr.get(crvclr) );
    offscreenbuffer.strokeWeight(wt);

    for (int i=1; i<bufsize; i++) offscreenbuffer.line( i-1, h-(sampArray[i-1]*h), i, h-(sampArray[i]*h) );

    offscreenbuffer.endDraw();

    crvimg = offscreenbuffer.get(0, 0, offscreenbuffer.width, offscreenbuffer.height);
    
    drwgate = true;
    //
  } //End rendercrv
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class CurveRenderSet {
  ArrayList<CurveRender> cset = new ArrayList<CurveRender>();

  // Make Instance Method //
  void mk(int ix, int winix, int wt, String crvclr) {
    cset.add( new CurveRender(ix,winix,wt,crvclr) );
  } //end mk method

  // Make Instance Method //
  void mkfromarray(int ix, int winix, int wt, String crvclr, int sArray) {
    cset.add( new CurveRender(ix, winix, wt, crvclr, sArray) );
  }

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      CurveRender inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (int i=cset.size ()-1; i>=0; i--) {
      CurveRender inst = cset.get(i);
      inst.drw();
    }
  }//end drw method

  // Remove Instance Method //
  void rendercrv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      CurveRender inst = cset.get(i);
      if (inst.ix == ix) {
        inst.rendercrv();
        break;
      }
    }
  } //End rmv method
  
  // Show Instance Method //
  void showcrv(int ix, int mode) {
    for (int i=cset.size ()-1; i>=0; i--) {
      CurveRender inst = cset.get(i);
      if (inst.ix == ix) {
        inst.showcrv = mode;
        break;
      }
    }
  } //End rmv method
  //////////////////////////////////////////////////
  //////////////////////////////////////////////////
} // END CLASS SET CLASS