// DECLARE/INITIALIZE CLASS SET
TactusSet tactusz = new TactusSet();

/**
 /// PUT IN SETUP ///
 osc.plug(tactusz, "mk", "/mktactus");
 osc.plug(tactusz, "rmv", "/rmvtactus");
 
 /// PUT IN DRAW ///
 tactusz.drw();
 */


class Tactus {

  // CONSTRUCTOR VARIALBES /////////
  int ix, winix;
  int sz;
  String tclr;
  // CLASS VARIABLES ///////////////
  float x, y, winy, winh;
 float ynorm = 0.0;
  // CONSTRUCTORS //////////////////
  //// Constructor 1 ////
  Tactus(int aix, int awinix, int asz, String atclr) {
    ix = aix;
    winix = awinix;
    sz = asz;
    tclr = atclr;

    //Get info from winlet you wish to render curve in
    for (Winlet inst : winletz.cset) {
      if (inst.ix == winix) {
        x = inst.x+(inst.w/2.0);
        y = inst.y+inst.h-(sz/2.0);
        winy = inst.y;
        winh = inst.h;
        break;
      }
    }
    //
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    
    //poll supercollider phasor for x
    osc.send("/getkdata", new Object[]{ix+300 /*using control busses 300-399 */}, sc);
    //map normalized x to window cooridnates
    y = map(ynorm, 1.0, 0.0, winy+(sz/2.0)+12, winy+winh-(sz/2.0)-12);
    
    
    //Draw tactus
    noStroke();
    fill( clr.get(tclr) );
   // ellipse(x,y, sz,sz);
   pushMatrix();
   lights();
   translate(x,y,0);
   sphere(sz);
   popMatrix();
   

  //
  //
  }//END DRAW METHOD 
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class TactusSet {
  ArrayList<Tactus> cset = new ArrayList<Tactus>();

  // Make Instance Method //
  void mk(int ix, int winix, int sz, String tclr) {
    cset.add( new Tactus(ix,winix,sz,tclr) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Tactus inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (int i=cset.size ()-1; i>=0; i--) {
      Tactus inst = cset.get(i);
      inst.drw();
    }
  }//end drw method

  // Get Control value //
  void kdat(int ix, float val) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Tactus inst = cset.get(i);
      if(ix>=300 && ix<400){
      if (inst.ix == (ix-300)){ //using control busses 100-199 need to -100 to get cursor ix
        inst.ynorm = val;
        break;
      }
    }
    }
  } //End kval method


  //////////////////////////////////////////////////
  //////////////////////////////////////////////////
} // END CLASS SET CLASS