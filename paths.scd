for working with text files you can keep and load everything from within your designated Document dir:

Document.dir = "~/sc3docs/"

Document.open("path/within/docsfolder/file.scd")

for determining the path relative to a class file:


path = PathName(MxDrawer.class.filenameSymbol.asString).parentPath +/+ "drivers" +/+ "registerDrawerItems.scd";



for finding the directory of a Quark:


Quark.find("cruciallib").localPath



for finding the path of the file that is currently front and focused:


Document.current.path

Document.current.dir