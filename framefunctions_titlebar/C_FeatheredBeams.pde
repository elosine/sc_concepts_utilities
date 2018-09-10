// DECLARE/INITIALIZE CLASS SET
FeatheredBeamsSet featheredBeamsz = new FeatheredBeamsSet();

/**
 *
 *
 /// PUT IN SETUP ///
 osc.plug(featheredBeamsz, "mk", "/mkfeatheredBeams");
 osc.plug(featheredBeamsz, "rmv", "/rmvfeatheredBeams");
 
 /// PUT IN DRAW ///
 featheredBeamsz.drw();
 *
 *
 */


class FeatheredBeams {

  // CONSTRUCTOR VARIALBES //
  int ix;
  int w, x, y, h;
  int acceldecel;
  // CLASS VARIABLES //
  int show=0;
  int[]xs = new int[0];
  int i = 1;
  int newx = 0;
  int xadd = 0;


  // CONSTRUCTORS //

  /// Constructor 1 ///
  FeatheredBeams(int aix, int ax, int ay, int aw, int ah, int aacceldecel) {
    ix = aix;
    x = ax;
    y = ay;
    w = aw;
    h = ah;
    acceldecel = aacceldecel;
    //calculate x location of stems
    if (acceldecel == 1) { //accel
      while (xadd<w) {
        newx = x + w - xadd;
        xs = append(xs, newx);
        xadd = round(xadd + ( ( 3*( 1+(i* 0.25) ) )*i ));
        i++;
      }
    }//end if acceldecel
    else { //accel
      while (xadd<w) {
        newx = x + xadd;
        xs = append(xs, newx);
        xadd = round(xadd + ( ( 3*( 1+(i* 0.25) ) )*i ));
        i++;
      }
    }//end if acceldecel
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    if (show==1) {
      stroke(0);
      strokeWeight(1);
      for (int i=0; i<xs.length; i++) {
        line(xs[i], y, xs[i], y+h);
      }
      //beams
      strokeWeight(3);
      line(xs[0], y, xs[xs.length-1], y);
      //  if (acceldecel==1) {
      line(xs[0], y+(h*0.67), xs[xs.length-1], y );
      line(xs[0], y+(h*0.503), xs[xs.length-1], y );
      line(xs[0], y+(h*0.336), xs[xs.length-1], y );
      line(xs[0], y+(h*0.169), xs[xs.length-1], y );
      // }
    }
    // +5*i each time until width is reached make array then offscreen buffer
    // copy curve render code
  } //End drw
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class FeatheredBeamsSet {
  ArrayList<FeatheredBeams> cset = new ArrayList<FeatheredBeams>();

  // Make Instance Method //
  void mk(int ix, int x, int y, int w, int h, int acceldecel) {
    cset.add( new FeatheredBeams(ix, x, y, w, h, acceldecel) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      FeatheredBeams inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method
  
  void show(int ix, int md) {
    for (int i=cset.size ()-1; i>=0; i--) {
      FeatheredBeams inst = cset.get(i);
      if (inst.ix == ix) {
        inst.show = md;
        break;
      }
    }
  } //End show method

  // Draw Set Method //
  void drw() {
    for (FeatheredBeams inst : cset) {
      inst.drw();
    }
  }//end drw method
  //
  //
} // END CLASS SET CLASS