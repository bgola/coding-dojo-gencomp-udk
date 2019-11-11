~bgola = "194.95.203.42";
~marcel = "194.95.203.134";
~arik = "194.95.203.86";
~chunli = "194.95.203.17";
~bea = "194.95.203.7";
~giu = "194.95.203.62"

~all = [~bgola, ~marcel, ~bea, ~chunli, ~arik, ~giu];

(
~alladdrs = ~all.collect {arg ip;
	NetAddr(ip, NetAddr.langPort);
});

// Everyone makes a sound at the same time
// 1st Go around in circle, one computer at a time play the same note
// 2nd- Change note after circle is completed, repeat
// 3rd- Each computer plays a different sound
// 4th- create a new pattern that is not a circle
// 5th- find ways of combining computers (play chords!)

(
Tdef(\dojo, {
	[3,4,6,7].do{ arg note;
		~all.do{ arg ip;
			n=NetAddr.new(ip,NetAddr.langPort);
			n.sendMsg("/p",note);
			0.5.wait;
		}
	};
}).play;
)


(
Tdef(\dojo2, { var melody =[6,4,7,5,4,3];
	var pattern1 = ~alladdrs.scramble;
	var pattern2 = pattern1.scramble;
	var computerpatterns = [~alladdrs, pattern1, pattern2];
	5.do {
		~alladdrs.size.do {arg i;
			computerpatterns.do{ arg pattern, j;
				pattern[i].sendMsg("/p", (melody[i]+(j*3)).postln);
			};
			"".postln;
			1.5.wait;
		};
	};
}).play;
)