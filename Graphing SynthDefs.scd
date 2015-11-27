if you're unsure of your synthdefs and want a graphical overview (patching schematics), i can recommend to install Rohan's rd_dot quark in combo with http://www.graphviz.org.
then you can do .draw and get the following...


// drawInputName is a boolean flag, it selects if input names are
// drawn in the box representing the UGen.  It is false by default.

DotViewer.drawInputName = true;

// Values for OSX.  The "open" command uses the same table as the
// finder uses to resolve which application to open a file with.  If
// the OSX GraphViz package is installed and the file associations set
// correctly this will open a drawing of the UGen graph.  See:
// www.pixelglow.com/graphviz/ for GraphViz OSX packages.

(
DotViewer.directory = "/Volumes/JY_Archive 2/SynthDefGraphs/";
DotViewer.viewer = "open";
)

// Values for Linux. The "dotty" command is provided with the AT&T
// graphviz release.

(
DotViewer.directory = "/tmp";
DotViewer.viewer = "dotty";
)

// Inspect

[DotViewer.directory, DotViewer.viewer];


{	//1714153092.pdf
var tone,note,chorus;
note = 50;
chorus = LFNoise2.ar(3).range(0.99,1.01).dup(4);
tone = VarSaw.ar(note.midicps * chorus).mean;
Out.ar(0, tone.dup);
}.draw;


{	//1983463754.pdf
var tone,note,chorus;
note = 50;
chorus = LFNoise2.ar(3.dup(4)).range(0.99,1.01);
tone = VarSaw.ar(note.midicps * chorus).mean;
Out.ar(0, tone.dup);
}.draw;


[DotViewer.directory, DotViewer.viewer];

