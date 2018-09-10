// DECLARE/INITIALIZE CLASS SET
ImgSet imgz = new ImgSet();

/**
 *
 *
 /// PUT IN SETUP ///
 osc.plug(sVGz, "mk", "/mksVG");
 osc.plug(sVGz, "rmv", "/rmvsVG");
 
 /// PUT IN DRAW ///
 sVGz.drw();
 *
 *
 */


class Img {

  // CONSTRUCTOR VARIALBES //
  int ix;
  String svgname;
  float scale;
  int x,y;
  // CLASS VARIABLES //
  int show=0;
  PImage svg;
  float w, h;
  // CONSTRUCTORS //

  /// Constructor 1 ///
  Img(int aix, String asvgname, float ascale, int ax, int ay) {
    ix = aix;
    svgname = asvgname;
    scale = ascale;
    x = ax;
    y = ay;

    svg = loadImage(svgname);
    w = svg.width*scale;
    h = svg.height*scale;
    
  } //end constructor 1

  //  DRAW METHOD //
  void drw() {
    if(show==1)image(svg, x, y, w, h);
  } //End drw
  //
  //
}  //End class

////////////////////////////////////////////////////////////
/////////////   CLASS SET     //////////////////////////////
////////////////////////////////////////////////////////////

class ImgSet {
  ArrayList<Img> cset = new ArrayList<Img>();

  // Make Instance Method //
  void mk(int ix, String svgname, float scale, int x, int y) {
    cset.add( new Img(ix,svgname,scale,x,y) );
  } //end mk method

  // Remove Instance Method //
  void rmv(int ix) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Img inst = cset.get(i);
      if (inst.ix == ix) {
        cset.remove(i);
        break;
      }
    }
  } //End rmv method
  
  void show(int ix, int md) {
    for (int i=cset.size ()-1; i>=0; i--) {
      Img inst = cset.get(i);
      if (inst.ix == ix) {
        inst.show = md;
        break;
      }
    }
  } //End show method

  // Draw Set Method //
  void drw() {
    for (Img inst : cset) {
      inst.drw();
    }
  }//end drw method
  //
  //
} // END CLASS SET CLASS