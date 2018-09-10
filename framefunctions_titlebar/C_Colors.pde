Colors clr = new Colors();

class Colors {
  StringDict clrs = new StringDict(); 

  Colors() {
    ////add colors
    clrs.set("TranquilBlue", "25 33 47");
    clrs.set("orange", "255 128 0");
    clrs.set("red", "255 0 0");
    clrs.set("green", "0 255 0");
    clrs.set("blue", "0 0 255");
    clrs.set("black", "0 0 0");
    clrs.set("white", "255 255 255");
    clrs.set("violetred", "208 32 144"); //7
    clrs.set("springgreen", "0 255 127");
    clrs.set("turquoiseblue", "0 199 140");//9
    clrs.set("seagreen", "67 205 128"); 
    clrs.set("mint", "189 252 201");
    clrs.set("yellow", "255 255 0");
    clrs.set("goldenrod", "218 165 32");//13
    clrs.set("darkorange", "238 118 0");
    clrs.set("chocolate", "139 69 19");
    clrs.set("slateblue", "113 113 198");//16
    clrs.set("indigo", "75 0 130");
    clrs.set("purple", "128 0 128");
    clrs.set("magenta", "255 0 255");
    clrs.set("plum", "221 160 221");
    clrs.set("maroon", "139 10 80"); //21
    clrs.set("pink", "255 105 180"); //22
    clrs.set("royalblue", "72 118 255");
    clrs.set("dodgerblue", "30 144 255");
    clrs.set("grey", "119 136 153"); //25
    clrs.set("nicegreen", "138 216 20");
    clrs.set("pine", "64 129 64");
    clrs.set("papaya", "255 164 142");
    clrs.set("beet", "157 84 156");
    clrs.set("slate", "117 119 123"); //30
    clrs.set("peacock", "0 130 137");
    clrs.set("fig", "128 84 98");
    clrs.set("sunshine", "255 234 100");
    clrs.set("limegreen", "153 255 0"); //34
  } //End Constructor

  color get(String clrname) {
    color cl; 
    String[] rgb = split(clrs.get(clrname), ' ');
    cl = color(int(rgb[0]), int(rgb[1]), int(rgb[2]));
    return cl;
  } //End get method

  color getByIx(int ix) {
    color cl; 
    String[] rgb = clrs.valueArray();
    String[] rgbsplit = split(rgb[ix], ' ');
    cl = color(int(rgbsplit[0]), int(rgbsplit[1]), int(rgbsplit[2]));
    return cl;
  } //End get method

  color getAlpha(String clrname, int alpha ) {
    color cl; 
    String[] rgb = split(clrs.get(clrname), ' ');
    cl = color(int(rgb[0]), int(rgb[1]), int(rgb[2]), alpha);
    return cl;
  } //End getAlpha method
} //End Class