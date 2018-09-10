// DECLARE/INITIALIZE CLASS SET
WinletSet winletz = new WinletSet();

/**
 /// PUT IN SETUP ///
 osc.plug(winletz, "mk", "/mkwinlet");
 osc.plug(winletz, "rmv", "/rmvwinlet");
 
 /// PUT IN DRAW ///
 winletz.drw();
 */


class Winlet {

  // CONSTRUCTOR VARIALBES //
  int ix;
  float x, y, w, h;
  String winclr;
  // CLASS VARIABLES //
  float l, r, t, b, m, c;
  //win border
  int bdr = 0;
  int bdrwt = 1;
  String bdrclr = "orange";
  //win highlight
  int hl = 0;
  String hlclr = "yellow";
  int hlalpha = 50;

  // CONSTRUCTORS //

  /// Constructor 1 ///
  Winlet(int aix, float ax, float ay, float aw, float ah, String awinclr) {
    ix = aix;
    x = ax;
    y = ay;
    w = aw;
    h = ah;
    winclr = awinclr;

    l = x;
    r = x+w;
    t = y;
    b = y+h;
    m = x+(w/2.0);
    c = y+(h/2.0);
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {

    // Draw Window
    if (bdr==0)noStroke();
    else {
      stroke(clr.getAlpha(bdrclr, 90));
      strokeWeight(bdrwt);
    }
    fill( clr.get(winclr) );
    rect(x, y, w, h);
    //highlight
    if (hl==1) {
      fill(clr.getAlpha(hlclr, hlalpha));
      rect(x, y, w, h);
    }
  } //End drw
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class WinletSet {
  ArrayList<Winlet> cset = new ArrayList<Winlet>();

  // Make Instance Method //
  void mk(int ix, float x, float y, float w, float h, String winclr) {
    cset.add( new Winlet(ix, x, y, w, h, winclr) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Winlet inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  //void drw() {
  //  for (int i=cset.size ()-1; i>=0; i--) {
  //    Winlet inst = cset.get(i);
  //    inst.drw();
  //  }
  //}//end drw method
  void drw() {
    for (int i=0; i<cset.size(); i++) {
      Winlet inst = cset.get(i);
      inst.drw();
    }
  }//end drw method

  // Get Win Width Method //
  void winw(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Winlet inst = cset.get(i);
      if (inst.ix == ix) {
        osc.send("/winw", new Object[]{ix, inst.w}, sc);
        break;
      }
    }
  } //End winw method

  // winbdr Method //
  void winbdr(int ix, int mode, int wt, String clr) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Winlet inst = cset.get(i);
      if (inst.ix == ix) {
        inst.bdr = mode;
        inst.bdrwt = wt;
        inst.bdrclr = clr;
        break;
      }
    }
  } //End winbdr method

  // window highlight Method //
  void winhl(int ix, int mode, String clr, int alpha) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Winlet inst = cset.get(i);
      if (inst.ix == ix) {
        inst.hl = mode;
        inst.hlclr = clr;
        inst.hlalpha = alpha;
        break;
      }
    }
  } //End winbdr method

  // Move Window Method //
  void mvwin(int ix, float x, float y) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Winlet inst = cset.get(i);
      if (ix == inst.ix) {
        inst.x = x;
        inst.y = y;
        inst.l = inst.x;
        inst.r = inst.x+inst.w;
        inst.t = inst.y;
        inst.b = inst.y+inst.h;
        inst.m = inst.x+(inst.w/2.0);
        inst.c = inst.y+(inst.h/2.0);
      }
    }
  }//end move window method
  //
  //
} // END CLASS SET CLASS