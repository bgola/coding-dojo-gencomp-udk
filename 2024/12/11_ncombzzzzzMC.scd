(
~ncombs = 16;

~ncombs.do {|idx| Ndef(\combzzzzzMC).addSpec("modfreq%".format(idx).asSymbol, [0.01, 100, \exp]) };
Ndef(\combzzzzzMC).addSpec(\min, [0.2, 20, \exp]);
Ndef(\combzzzzzMC).addSpec(\max, [0.2, 20, \exp]);

Ndef(\combzzzzzMC, {
	arg min=1, max=1, in=0;
	var sndmix = in;
    var snd = ~ncombs.collect {arg idx;
		sndmix = CombC.ar(sndmix, 8,
			LFDNoise3.kr("modfreq%".format(idx).asSymbol.kr(1)).range(min, max),
			1);
		sndmix
	};
	snd;
}).scope
)

Ndef(\soundin, {SoundIn.ar(0)})
Ndef(\mixin, {Ndef(\soundin).ar + Ndef(\somendef).ar})
Ndef(\combzzzzzMC).set(\in, Ndef(\simWire));
Ndef(\combzzzzzMC).set(\in, Ndef(\soundin));
Ndef(\combzzzzzMC).set(\in, Ndef(\mixin));
Ndef(\combzzzzzMC).gui;
Ndef(\monitorMC, {Splay.ar(Ndef(\combzzzzzMC).ar)}).play;
~ncombs.do {|idx| Ndef(\combzzzzzMC).set("modfreq%".format(idx).asSymbol, 0) };