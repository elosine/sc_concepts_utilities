// DECLARE/INITIALIZE CLASS SET
CurvefollowerSet curvefollowerz = new CurvefollowerSet();

/**
 /// PUT IN SETUP ///
 osc.plug(curvefollowerz, "mk", "/mkcurvefollower");
 osc.plug(curvefollowerz, "rmv", "/rmvcurvefollower");
 
 /// PUT IN DRAW ///
 curvefollowerz.drw();
 */


class Curvefollower {

  // CONSTRUCTOR VARIALBES //
  int ix, csrix, crvix;
  // CLASS VARIABLES //
  int show = 0;
  String cfclr;
  float b, t, h;
  float x=0;
  float y=0;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Curvefollower(int aix, int acsrix, int acrvix) {
    ix = aix;
    csrix = acsrix;
    crvix = acrvix;

    //get color & height from curve clr
    for (CurveRender inst : curveRenderz.cset) {
      if (inst.ix == crvix) {
        cfclr = inst.crvclr;
        t = inst.y;
        h = inst.h;
        b = t+h;
      }
    }
    //
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    show();
    if (show == 1) {
      //Get x from Cursor
      for (int i=cursorz.cset.size ()-1; i>=0; i--) {
        Cursor inst = cursorz.cset.get(i);
        if (csrix == inst.ix) {
          x = inst.x;
        }
      }

      //Get y
      //osc.send("/getkdata", new Object[]{ix+200/*crvfollowers use controlbusses 200-299*/}, sc);
      y = height - (crvArrays[crvix][int(x)]*h);

      ellipseMode(CENTER);
      noFill();
      strokeWeight(3);
      stroke( clr.get(cfclr) );
      ellipse(x, y, 27, 27);
    }
  } //End drw

  void show() {
    for (int i=curveRenderz.cset.size ()-1; i>=0; i--) {
      CurveRender inst = curveRenderz.cset.get(i);
      if (inst.ix == crvix) {
        int crshow = inst.showcrv;
        for (int j=cursorz.cset.size ()-1; j>=0; j--) {
          Cursor inst2 = cursorz.cset.get(j);
          if (inst2.ix == csrix) {
            int csrshow = inst2.show;
            if (csrshow==1 && crshow ==1) show = 1;
            else show = 0;
          } //end if(inst2.ix == csrix)
        }//end for (int j=cursorz.cset.size ()-1; j>=0; j--)
      }// end if(inst.ix == crvix)
    }//end for (int i=curveRenderz.cset.size ()-1; i>=0; i--)
  } //end show method
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class CurvefollowerSet {
  ArrayList<Curvefollower> cset = new ArrayList<Curvefollower>();

  // Make Instance Method //
  void mk(int ix, int csrix, int crvix) {
    cset.add( new Curvefollower(ix, csrix, crvix) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Curvefollower inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method

  // Draw Set Method //
  void drw() {
    for (int i=cset.size ()-1; i>=0; i--) {
      Curvefollower inst = cset.get(i);
      inst.drw();
    }
  }//end drw method

  // Get y from Control Bus //
  void kdat(int ix, float val) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Curvefollower inst = cset.get(i);
      if (ix>=200 && ix<300) {
        if ( inst.ix == (ix-200) ) {
          // inst.y = map(val, -1.0, 1.0, inst.b, inst.t);
          inst.y = map(val, 0.0, 1.0, inst.b, inst.t);
        }
      } // end if (ix>=200) {
    }
  }// end kdat method
  //
  //
} // END CLASS SET CLASS