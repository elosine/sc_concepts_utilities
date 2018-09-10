// DECLARE/INITIALIZE CLASS SET
CursorSet cursorz = new CursorSet();

/**
 /// PUT IN SETUP ///
 osc.plug(cursorz, "mk", "/mkcursor");
 osc.plug(cursorz, "rmv", "/rmvcursor");
 
 /// PUT IN DRAW ///
 cursorz.drw();
 */


class Cursor {

  // CONSTRUCTOR VARIALBES //
  int ix, winix;
  int clkix;
  int w;
  String csrclr;
  // CLASS VARIABLES //
  int show = 0;
  float x, y1, y2;
  float winw, winx;
  float xnorm=0.0;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Cursor(int aix, int awinix, int aclkix, int aw, String acsrclr) {
    ix = aix;
    winix = awinix;
    clkix = aclkix;
    w = aw;
    csrclr = acsrclr;

    for (Winlet inst : winletz.cset) {
      if (inst.ix == winix) {
        x = inst.x;
        y1 = inst.t;
        y2 = inst.b;
        winw = inst.w;
      }
    }
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {

    //get window coordinates for ys
    for (Winlet inst : winletz.cset) {
      if (inst.ix == winix) {
        winx = inst.x;
        y1 = inst.t;
        y2 = inst.b;
      }
    }

    //poll supercollider phasor for x
    //osc.send("/getkdata", new Object[]{clkix+100 /*using control busses 100-199 */}, sc);
    //map normalized x to window cooridnates
    x = map(xnorm, 0.0, 1.0, winx, winx+winw);


    //Draw cursor
    if(show==1){
    strokeWeight(w);
    stroke( clr.get(csrclr) );
    line(x, y1, x, y2);
    }
  } //End drw
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class CursorSet {
  ArrayList<Cursor> cset = new ArrayList<Cursor>();

  // Make Instance Method //
  void mk(int ix, int winix, int clkix, int w, String csrclr) {
    cset.add( new Cursor(ix, winix, clkix, w, csrclr) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Cursor inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (int i=cset.size ()-1; i>=0; i--) {
      Cursor inst = cset.get(i);
      inst.drw();
    }
  }//end drw method
  
  void show(int ix, int md) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Cursor inst = cset.get(i);
      if (inst.ix == ix) {
        inst.show = md;
        break;
      }
    }
  } //End show method


  // Get Control value //
  void kdat(int ix, float val) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Cursor inst = cset.get(i);
      if (ix>=100 && ix <200) {
        if (inst.ix == (ix-100)) { //using control busses 100-199 need to -100 to get cursor ix
          inst.xnorm = val;
          break;
        }
      }
    }
  } //End kval method
  //
  //
} // END CLASS SET CLASS