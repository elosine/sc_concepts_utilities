//Dionysis Athinaios 2010

KtoVal{var bus;
         var rout, value;

     *new { arg bus;
		  ^super.newCopyArgs(bus).init;
     }

     init {rout = Routine({inf.do{bus.get{arg v; value = v}; 0.006.wait}}).play
     }

     get{^value
     }

     stop{rout.stop
     }


}