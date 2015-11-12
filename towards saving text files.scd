q.asCompileString
q[\tt] = "hello";
q.asCompileString.writeArchive("/Volumes/Ute/SuperCollider Standalone/test.txt");

p = Dictionary.readArchive( "/Volumes/Ute/SuperCollider Standalone/test.txt" );
"/Volumes/Ute/SuperCollider Standalone/"

p[\tt]

readArchive

