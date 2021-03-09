/////////////////   Dojo Ghost performance  ///////////////////////



// This patch takes a set of recorded sounds and plays them in two ways
// 1) a continous sound that is modified by the position in the scren (x, y mouse axis)
// 2) certain patterns produced with the same sound files. There are 4 patterns. Different patterns should be triggered depending on the position of the mouse on the screen (still in development)



//// Load sounds ////

(
d = Dictionary.new;
d.add(\wind ->
	// change path name to folder where your sound files are...all the sound files in the folder will be loaded!
	PathName("C:/Users/CA/Documents/arreglos y compo/base de sonidos/sound effects/naturaleza/viento/viento voz por pistas").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);
);
/*
Test the sound files!

d[\wind][0].play;
d[\wind][1].play;

*/


///////////////// 1. Continuous sound ////////////////////



// Ndef granular synthesizer

(

Ndef(\grainwind,{
	arg sync=1, grainfreq=20, graindur=0.1, durRand=1, buf= (d[\wind][0].bufnum), ratebuf= 1, pos=0, speedpos=1, disorder=0.01, grainEnv=(-1), pan=0, panHz=0.1, panRand=0, atk=1, sus=2, rel=1, c0=1, c1=(-1), vol=1;
	var sig, env, densCtrl, durCtrl, posCtrl, panCtrl;



	densCtrl = Select.ar(sync, [Dust.ar(grainfreq), Impulse.ar(grainfreq)]);

	durCtrl = graindur * LFNoise1.kr(100).exprange(1/durRand, durRand);

	posCtrl = Phasor.ar(Changed.kr(pos), speedpos * BufRateScale.ir(buf), 0, BufSamples.ir(buf)-1, resetPos: pos * BufSamples.ir(buf));
	posCtrl = posCtrl + LFNoise1.kr(100).bipolar(disorder*SampleRate.ir);
	posCtrl = posCtrl / BufSamples.ir(buf);
	posCtrl = posCtrl;

	panCtrl = pan +LFNoise1.kr(panHz).bipolar(panRand);

	sig = GrainBuf.ar(
		2,
		densCtrl,
		durCtrl,
		buf,
		ratebuf,
		posCtrl,
		2,
		panCtrl,
		grainEnv
	);

	sig = sig * vol;

});
Ndef(\grainwind).set(\buf, d[\wind][0].bufnum);
Ndef(\grainwind).addSpec(\grainfreq, [0.001, 100]);
Ndef(\grainwind).addSpec(\pos, [0, 1]);
Ndef(\grainwind).addSpec(\speedpos, [0, 2]);
Ndef(\grainwind).addSpec(\graindur, [0.001, 20]);
Ndef(\grainwind).addSpec(\disorder, [0.001, 20]);
Ndef(\grainwind).addSpec(\vol, [0, 1]);
Ndef(\grainwind).addSpec(\buf, [d[\wind][0].bufnum, d[\wind][5].bufnum]);
Ndef(\grainwind).addSpec(\panHz, [0, 40]);
);



///// LFO (to control the pitch of the sound (or any other parameter you want)

(
Ndef(\windLfo1, {
	arg freq=1, min=0, max=4;
	var sig;
	sig = SinOsc.ar(freq).range(min, max)
});
Ndef(\windLfo1).addSpec(\freq, [0.01, 1000, \exp]);
Ndef(\windLfo1).addSpec(\max, [0, 4], \min, [0, 4]);
);



/// MOUSE CONTROL

(
Ndef(\mouseX, {
	arg min=0.01, max=0.5, warp=1;
	var sig;
	sig = MouseX.kr(min, max, warp);
});
Ndef(\mouseX).addSpec(\min, [0.01, 20000, \exp]);
Ndef(\mouseX).addSpec(\max, [0.01, 20000, \exp]);
Ndef(\mouseX).addSpec(\warp, [0, 1, \lin, 1]);
);

(
Ndef(\mouseY, {
	arg min=0.01, max=100, warp=1;
	var sig;
	sig = MouseY.kr(min, max, warp);
});
Ndef(\mouseY).addSpec(\min, [0.01, 20000, \exp]);
Ndef(\mouseY).addSpec(\max, [0.01, 20000, \exp]);
Ndef(\mouseY).addSpec(\warp, [0, 1, \lin, 1]);
);

// To balance the volume of the granulation
(
Ndef(\mouseYvol, {
	arg min=1.0, max=0.2, warp=1;
	var sig;
	sig = MouseY.kr(min, max, warp);
});
Ndef(\mouseY).addSpec(\min, [0.01, 20000, \exp]);
Ndef(\mouseY).addSpec(\max, [0.01, 20000, \exp]);
Ndef(\mouseY).addSpec(\warp, [0, 1, \lin, 1]);
);


/////// Settings

//mapping the grain duration to mouse Y
Ndef(\grainwind).map(\graindur, Ndef(\mouseY));
Ndef(\mouseY).set(\min, 0.001, \max, 0.5);
//to balance the volume
Ndef(\grainwind).map(\vol, Ndef(\mouseYvol));
Ndef(\mouseYvol).set(\min, 1.0, \max, 0.2);


// Mapping the LFO to the rate
Ndef(\grainwind).map(\ratebuf, Ndef(\windLfo1));
// range of the LFO
Ndef(\windLfo1).set(\min, 0.5, \max, 0.6);
// then mapping the mouse to the frequency of that LFO
Ndef(\windLfo1).map(\freq, Ndef(\mouseX));
// choose the range of the mouse
Ndef(\mouseX).set(\min, 2,\max,0.01);

// other settings
Ndef(\grainwind).set(
	\grainfreq, 82,
	\pos, 0,
	\speedpos, 0.03
);

// GUI to play and mix the NDEF!
NdefMixer(s);


///////////////// 2. Triggered compositions ////////////////////

// This section is still under construction --> to be done: mechanism that triggers composition depending on mouse position.


// SynthDef

(
SynthDef(\bufwind, {
	arg buf, rate = 1, vol = 1, spd = 1, pan= 0, gate=1, atk=0.1, rel=0.1, curve=(-4), out=0, startpos=0, loop=0;
	var sig, env;
	env = EnvGen.ar(Env.perc(atk,rel, curve: curve), gate: gate, doneAction:2);
	sig = PlayBuf.ar(1, buf, rate* BufRateScale.ir(buf), 1, startpos * BufFrames.ir(buf), loop, doneAction: 2);
	sig = sig * env * vol;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add
)





///// composition bottom screen /////

// BPM of quantization
~globalQuant = (60/120 *4);
// This is the bottom left composition
(
Pdef(
	\downleft,
	Pbind(
		\type, \note,
		\instrument, \bufwind,
		\stretch, ~globalQuant ,
		\dur, Pseq([
			Pwhite(0.2, 0.4, 3),
			Pwhite(0.8, 1.2, 4),
			Pwhite(4, 5, 1),
			Pwhite(0.2, 0.4, 3),
			Pwhite(3, 4, 1)
		], inf),
		\buf, Pxrand([d[\wind][0].bufnum, d[\wind][1].bufnum,d[\wind][2].bufnum,d[\wind][3].bufnum,d[\wind][4].bufnum,d[\wind][5].bufnum], inf),
		\rate, Pwhite(0.1, 0.5, inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, 2,
		\rel, 4,
		\amp, Pseq([
			Pseq([0.2], 7),
			Pseq([0.3], 5)
		], inf),
		\pan, Pseq([
			Pwhite(-0.2, 0.2, 6),
			Pwhite(-0.2, 0.2, 1),
			Pwhite(-0.5, 0.5, 1),
		], inf),
		\out, 0,
	)
).quant_(~globalQuant);
);

/*
play or stop!
Pdef(\downleft).play;
Pdef(\downleft).stop;
*/


// This is the bottom right composition

(
Pdef(
	\downright,
	Pbind(
		\type, \note,
		\instrument, \bufwind,
		\stretch, ~globalQuant ,
		\dur, Pseq([
			Pwhite(0.2, 0.4, 1),
			Pwhite(0.1, 0.3, 2),
			Pwhite(4, 5, 1),
			Pwhite(0.2, 0.4, 2),
			Pwhite(4, 5, 1),
			Pwhite(0.2, 0.4, 4),
			Pwhite(3, 4, 1)
		], inf),
		\buf, Pxrand([d[\wind][0].bufnum, d[\wind][1].bufnum,d[\wind][2].bufnum,d[\wind][3].bufnum,d[\wind][4].bufnum,d[\wind][5].bufnum], inf),
		\rate, Pwhite(1.0, 3.0, inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, 2,
		\rel, Pseq([
			Pwhite(0.5, 1.0, 4),
			Pwhite(8, 10, 8)
		]),
		\amp, 0.1,
		\pan, Pseq([
			Pwhite(-0.2, 0.2, 6),
			Pwhite(-0.2, 0.2, 1),
			Pwhite(-0.5, 0.5, 1),
		], inf),
		\out, 0,
	)
).quant_(~globalQuant);
);
/*
play or stop!
Pdef(\downright).play;
Pdef(\downright).stop;
*/


///// Patterns upper screen /////

// This is the upper left composition

(
Pdef(
	\upleft,
	Pbind(
		\type, \note,
		\instrument, \bufwind,
		\stretch, ~globalQuant ,
		\dur, Pseq([
			Pwhite(0.01, 0.02, 32),
			Pbrown(0.1, 0.2, 0.01, 8),
			Rest(2),
			Pbrown(0.1, 0.2, 0.01, 7),
		], inf),
		\buf, Pxrand([d[\wind][0].bufnum, d[\wind][1].bufnum,d[\wind][2].bufnum,d[\wind][3].bufnum,d[\wind][4].bufnum,d[\wind][5].bufnum], inf),
		\rate, Pseq([
			Pbrown(0.1, 0.5, 0.01, 32),
			Pwhite(0.1, 0.5, 16)
		], inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, 0.1,
		\rel, 0.1,
		\amp, Pseq([
			Pseq([0.2], 32),
			Pseq([0.3], 16)
		], inf),
		\pan, Pseq([
			Pwhite(-0.2, 0.2, 32),
			Pbrown(-1, 1, 0.1, 16)
		], inf),
		\out, 0,
	)
).quant_(~globalQuant);
);
/*
play or stop!
Pdef(\upleft).play;
Pdef(\upleft).stop;
*/

// This is the upper right composition

(
Pdef(
	\upright,
	Pbind(
		\type, \note,
		\instrument, \bufwind,
		\stretch, ~globalQuant ,
		\dur, Pseq([
			Pwhite(0.01, 0.02, 16),
			Pbrown(0.1, 0.2, 0.01, 4),
			Rest(1),
			Pbrown(0.1, 0.2, 0.01, 3),
			Pwhite(0.01, 0.02, 16),
			Pbrown(0.1, 0.2, 0.01, 4),
			Rest(1),
			Pbrown(0.1, 0.2, 0.01, 3),
		], inf),
		\buf, Pxrand([d[\wind][0].bufnum, d[\wind][1].bufnum,d[\wind][2].bufnum,d[\wind][3].bufnum,d[\wind][4].bufnum,d[\wind][5].bufnum], inf),
		\rate, Pseq([
			Pbrown(1.0, 3.0, 0.01, 16),
			Pwhite(1.0, 3.0, 8),
			Pbrown(1.0, 3.0, 0.01, 16),
			Pwhite(1.0, 3.0, 8),
		], inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, Pseq([
			Pseries(0.1, 0.01, 20),
			Pseries(0.3, -0.01, 20),
		], inf),
		\rel, 0.1,
		\amp, Pseq([
			Pseq([0.01], 32),
			Pseq([0.05], 16)
		], inf),
		\pan, Pseq([
			Pwhite(-0.2, 0.2, 32),
			Pbrown(-1, 1, 0.1, 16)
		], inf),
		\out, 0,
	)
).quant_(~globalQuant);
);

/*
play or stop!
Pdef(\upright).play;
Pdef(\upright).stop;
*/
