// DECLARE/INITIALIZE CLASS SET
CrescendoSet crescendoz = new CrescendoSet();

/**
 *
 *
 /// PUT IN SETUP ///
 osc.plug(crescendoz, "mk", "/mkcrescendo");
 osc.plug(crescendoz, "rmv", "/rmvcrescendo");
 
 /// PUT IN DRAW ///
 crescendoz.drw();
 *
 *
 */


class Crescendo {

  // CONSTRUCTOR VARIALBES //
  int ix;
  int x, y, w, h;
  String cl;
  // CLASS VARIABLES //
  int show = 0;
  int c;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Crescendo(int aix, int ax, int ay, int aw, int ah, String acl) {
    ix = aix;
    x = ax;
    y = ay;
    w = aw;
    h = ah;
    cl = acl;
    c = y + int(h/2);
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    if (show==1) {
      strokeWeight(3);
      stroke(clr.get(cl));
      line(x, c, x+w, y);
      line(x, c, x+w, y+h);
    }
  } //End drw
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class CrescendoSet {
  ArrayList<Crescendo> cset = new ArrayList<Crescendo>();

  // Make Instance Method //
  void mk(int ix, int x, int y, int w, int h, String cl) {
    cset.add( new Crescendo(ix, x, y, w, h, cl) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Crescendo inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method
  
  void show(int ix, int md) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Crescendo inst = cset.get(i);
      if (inst.ix == ix) {
        inst.show = md;
        break;
      }
    }
  } //End show method

  // Draw Set Method //
  void drw() {
    for (Crescendo inst : cset) {
      inst.drw();
    }
  }//end drw method
  //
  //
} // END CLASS SET CLASS