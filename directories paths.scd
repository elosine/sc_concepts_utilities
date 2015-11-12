//TO GET PATH OF CURRENT IDE DOCUMENT:
thisProcess.nowExecutingPath.dirname



//OTHER RESEARCH

SuperCollider handles relative paths just fine - just like a lot of software, it resolves them relative to the current working directory. Usually this is relative to the executable, not the script file, hence the confusion.

What's the current working directory in your case? You can find out by running

File.getcwd

(This is what .asAbsolutePath uses.) The cwd depends on your OS - on some platforms it's not a particularly handy default. You can't rely on it being anything in particular.

In your case, if you want the path to be resolved relative to the location of your script or class, then you need to do that yourself. For example:

     // Use the path of whatever file is currently executing:
     var samplePath = thisProcess.nowExecutingPath.dirname +/+ "Samples/HiHats1.hihat2.wav";

     // Use the path of the class file for the class you're coding
     var samplePath = this.class.filenameSymbol.asString.dirname +/+ "Samples/HiHats1.hihat2.wav";


MultiFileReader

.fileNameWithoutExtension



for working with text files you can keep and load everything from within your designated Document dir:

Document.dir = "~/sc3docs/"

Document.open("path/within/docsfolder/file.scd")

Document.open("/Users/jyang/Dropbox/SpotLights/SpotlightsController_001.scd")


"/Users/jyang/Dropbox/SpotLights/SpotlightsController_001.scd"



for determining the path relative to a class file:

path = PathName( MxDrawer.class.filenameSymbol.asString ).parentPath  +/+  "drivers"  +/+  "registerDrawerItems.scd" ;


for finding the directory of a Quark:

Quark.find("cruciallib").localPath



for finding the path of the file that is currently front and focused:

Document.current.path


Expand ~ to your home directory, and resolve aliases on OSX. See PathName for more complex needs. See File: *realpath if you want to resolve symlinks.
"~/".standardizePath; //This will print your home directory


Perform -pathMatch on this String, then load and execute all paths in the resultant Array.
//first prepare a file with some code...
(
var f = File("/tmp/loadPaths_example.scd", "w");
if(f.isOpen, {
    f.putString("\"This text is the result of a postln command which was loaded and executed by loadPaths\".postln");
}, {
    "test file could not be created - please edit the file's path above".warn;
});
f.close;
)

//then load the file...
"/tmp/loadPaths_example.scd".loadPaths; //This file posts some text


thisProcess.nowExecutingPath

