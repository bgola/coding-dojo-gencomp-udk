/*

14/12/2020

GOAL

- SuperCollider sound affecting Hydra

- SuperCollider
  - modulations / FM
  - melody + rythm + harmony
  - Pbind / Pseq (SynthDef) or Demand.kr / Dseq (Ndef)
  -

- Hydra
  -



*/




// First Synths and modulation

(
Ndef(\synth, {
	arg vol= 0.3;
	var sig;
	var freq = Ndef(\synthmelo).kr;
	var mod = Ndef(\synthmod).ar;
	sig = EnvGen.ar(Env.perc, Ndef(\gate).kr)  * SinOsc.ar(freq*mod, mul: vol)!2
}).stop
)

// harmony
(
Ndef(\harmony, {
	var sig;
	var freq = Ndef(\synthmelo).kr * Ndef(\harmsel).kr;
	var gate = PulseDivider.kr(Ndef(\gate).kr, 4);
	sig = SinOsc.ar(Latch.kr(freq, gate)) !2
}).play
)




// harmony sleector
(
Ndef(\harmsel, { arg mode=1;
	Select.kr(mode, [
		2, 0.5
	]);
});
)

(
Ndef(\synthmod, {
	arg vol= 1.0;
	var sig;
	var ratio = Demand.kr(Ndef(\gate).kr, 0,
		Dseq([0.25, 0.3, 0.75,0.125], inf));
	var freq = Ndef(\synthmelo).kr*ratio;
	SinOsc.ar(freq).range(0, SinOsc.kr(0.01).range(0.1,10));
})
)

(
//create a melody
Ndef(\synthmelo, {
	var freqs = [70,190,302,503,151]*2, vol = 1.0;
	var a, trig;
	a = Dseq(freqs,inf);
	trig = Ndef(\gate).kr;
	Demand.kr(trig,0,a);
});
)

(
Ndef(\gate, { arg speed = 1, mode=0;
	Select.kr(mode, [
		Impulse.kr(speed),
		Dust.kr(speed)
	]);
});
)

Ndef(\gate).set(\mode, 0, \speed, 2)

Ndef(\synthmod).gui

(
Ndef(\reverb, {
	var sig = \in.ar(0!2);
	10.do {
		sig = AllpassN.ar(sig, 0.1, SinOsc.kr({0.009.rand}!2).range(0.1,0.005), 1);
	};
	sig;
});

Ndef(\tremolo, { arg speed=6;
	var sig = \in.ar(0!2);
	sig * LFTri.kr(speed).range(0,1);
});

Ndef(\panner, { arg speed=6;
	Pan2.ar(Mix.ar(\in.ar(0!2)), SinOsc.kr(speed));
});

Ndef(\master, {
	\in.ar(0!2);
});
)

Ndef(\reverb) <<> nil //Ndef(\synth)


Ndef(\master) <<> nil ;
Ndef(\panner) <<> nil;
Ndef(\tremolo) <<> nil;
Ndef(\reverb) <<> nil;

Ndef(\master) <<> Ndef(\reverb) <<> Ndef(\panner) <<> Ndef(\synth)

NdefMixer(s)

Ndef(\synth).play

NdefMixer(s)
