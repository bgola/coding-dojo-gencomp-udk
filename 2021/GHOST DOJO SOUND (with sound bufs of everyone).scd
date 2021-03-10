/////////////////   Dojo Ghost performance  ///////////////////////



// This patch takes a set of recorded sounds and plays them in two ways
// 1) a continous sound that is modified by the position in the scren (x, y mouse axis)
// 2) certain patterns produced with the same sound files. There are 4 patterns. Different patterns should be triggered depending on the position of the mouse on the screen



//// Load sounds ////

(
d = Dictionary.new;
d.add(\andres ->
	// change path name to folder where your sound files are...all the sound files in the folder will be loaded! Each entry corresponds to a particular folder
	PathName("C:/Users/CA/Documents/arreglos y compo/Berlin estudios/UDK/Coding Dojo/Ghost Perfo/soundfiles/Andres").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	}));
d.add(\fang ->
	PathName("C:/Users/CA/Documents/arreglos y compo/Berlin estudios/UDK/Coding Dojo/Ghost Perfo/soundfiles/Fang").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	}));
d.add(\sani ->
	PathName("C:/Users/CA/Documents/arreglos y compo/Berlin estudios/UDK/Coding Dojo/Ghost Perfo/soundfiles/Sani").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	}));
d.add(\tsing ->
	PathName("C:/Users/CA/Documents/arreglos y compo/Berlin estudios/UDK/Coding Dojo/Ghost Perfo/soundfiles/Tsing").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	}));
);
);
/*

"C:/Users/CA/Documents/arreglos y compo/base de sonidos/sound effects/naturaleza/viento/viento voz por pistas".openOS
Test the sound files!

d[\fang][0].play;
d[\wind][1].play;

*/
// To play different sound files each time
//edit with certain settings that you want for your composition

NdefMixer(s)
(
Tdef(\rotation, {
	var time, pause;
	time = 60; //wait time
	pause = 20;
	loop({
		// ANDRES
		~buf = d[\andres];
		Ndef(\grainwind).set(\buf, ~buf.choose, \speedpos, 0.03, \pos, 0);
		Ndef(\windLfo1).set(\min, 0.5, \max, 0.6);
		Mouse.start;
		Ndef(\grainwind).play;
		"andres".postln;

		time.wait;

		//Pause
		"Pause".postln;
		Mouse.stop;
		Pdef(\upright).stop;Pdef(\upleft).stop;
		Pdef(\downright).stop;Pdef(\downleft).stop;
		Ndef(\grainwind).stop;

		pause.wait;

		// FANG
		~buf = d[\fang];
		Ndef(\grainwind).set(\buf, ~buf.choose, \speedpos, 1);
		Ndef(\windLfo1).set(\min, 0.9, \max, 1.1);
		"fang".postln;
		Mouse.start;
		Ndef(\grainwind).play;

		time.wait;

		//Pause
		"Pause".postln;
		Mouse.stop;
		Pdef(\upright).stop;Pdef(\upleft).stop;
		Pdef(\downright).stop;Pdef(\downleft).stop;
		Ndef(\grainwind).stop;

		pause.wait;

		// SANI
		~buf = d[\sani];
		Ndef(\grainwind).set(\buf, ~buf.choose, \speedpos, 1);
		Ndef(\windLfo1).set(\min, 0.9, \max, 1.1);
		"sani".postln;
		Mouse.start;
		Ndef(\grainwind).play;

		time.wait;

		//Pause
		"Pause".postln;
		Mouse.stop;
		Pdef(\upright).stop;Pdef(\upleft).stop;
		Pdef(\downright).stop;Pdef(\downleft).stop;
		Ndef(\grainwind).stop;

		pause.wait;

		// TSING
		~buf = d[\tsing];
		Ndef(\grainwind).set(\buf, ~buf.choose, \speedpos, 1);
		Ndef(\windLfo1).set(\min, 0.9, \max, 1.1);
		"tsing".postln;
		Mouse.start;
		Ndef(\grainwind).play;

		time.wait;

		//Pause
		"Pause".postln;
		Mouse.stop;
		Pdef(\upright).stop;Pdef(\upleft).stop;
		Pdef(\downright).stop;Pdef(\downleft).stop;
		Ndef(\grainwind).stop;

		pause.wait;
})}
).play;
)


///////////////// 1. Continuous sound ////////////////////


(
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
Ndef(\grainwind).set(\buf, ~buf.choose);
Ndef(\grainwind).addSpec(\grainfreq, [0.001, 100]);
Ndef(\grainwind).addSpec(\pos, [0, 1]);
Ndef(\grainwind).addSpec(\speedpos, [0, 2]);
Ndef(\grainwind).addSpec(\graindur, [0.001, 20]);
Ndef(\grainwind).addSpec(\disorder, [0.001, 20]);
Ndef(\grainwind).addSpec(\vol, [0, 1]);
Ndef(\grainwind).addSpec(\panHz, [0, 40]);
);


///// LFO (to control the pitch of the sound (or any other parameter you want)
(
(
Ndef(\windLfo1, {
	arg freq=1, min=0.01, max=4;
	var sig;
	sig = SinOsc.ar(freq).range(min, max)
});
Ndef(\windLfo1).addSpec(\freq, [0.01, 1000, \exp]);
Ndef(\windLfo1).addSpec(\max, [0, 4], \min, [0, 4]);
);



/// MOUSE CONTROL

(
Ndef(\mouseX, {
	arg min=0.01, max=0.5, warp=0;
	var sig;
	sig = MouseX.kr(min, max, warp, 0);
});
Ndef(\mouseX).addSpec(\min, [0.01, 20000, \exp]);
Ndef(\mouseX).addSpec(\max, [0.01, 20000, \exp]);
Ndef(\mouseX).addSpec(\warp, [0, 1, \lin, 1]);
);

(
Ndef(\mouseY, {
	arg min=0.01, max=100, warp=1;
	var sig;
	sig = MouseY.kr(min, max, warp, 0);
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
	sig = MouseY.kr(min, max, warp, 0);
});
Ndef(\mouseY).addSpec(\min, [0.01, 20000, \exp]);
Ndef(\mouseY).addSpec(\max, [0.01, 20000, \exp]);
Ndef(\mouseY).addSpec(\warp, [0, 1, \lin, 1]);
);
);

/////// Settings
(
//mapping the grain duration to mouse Y
Ndef(\grainwind).map(\graindur, Ndef(\mouseY));
Ndef(\mouseY).set(\min, 0.001, \max, 0.5);
//to balance the volume
Ndef(\grainwind).map(\vol, Ndef(\mouseYvol));
Ndef(\mouseYvol).set(\min, 0.8, \max, 0.15);


// Mapping the LFO to the rate
Ndef(\grainwind).map(\ratebuf, Ndef(\windLfo1));
// range of the LFO
Ndef(\windLfo1).set(\min, 0.5, \max, 0.6);
// then mapping the mouse to the frequency of that LFO
Ndef(\windLfo1).map(\freq, Ndef(\mouseX));
// choose the range of the mouse
Ndef(\mouseX).set(\min, 2,\max,0.1);

// other settings
Ndef(\grainwind).set(
	\grainfreq, 82,
);
);


/*
// GUI to play and mix the NDEF!
NdefMixer(s);
*/


///////////////// 2. Triggered compositions ////////////////////




// SynthDef

(
SynthDef(\bufwind, {
	arg buf, rate = 1, amp = 1, spd = 1, pan= 0, gate=1, atk=0.1, rel=0.1, curve=(-4), out=0, startpos=0, loop=0;
	var sig, env;
	env = EnvGen.ar(Env.perc(atk,rel, curve: curve), gate: gate, doneAction:2);
	sig = PlayBuf.ar(1, buf, rate* BufRateScale.ir(buf), 1, startpos * BufFrames.ir(buf), loop, doneAction: 2);
	sig = sig * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add
);





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
		\buf, Pseq([Pfunc({~buf.choose.bufnum}), ], inf),
		\rate, Pwhite(0.1, 0.5, inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, 2,
		\rel, 4,
		\amp, Pwhite(0.6, 0.7, inf),
		\pan, Pxrand([
			Pwhite(-0.8, -0.3, 1),
			Pwhite(0.3, 0.8, 1)
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
		\buf, Pseq([Pfunc({~buf.choose.bufnum}), ], inf),
		\rate, Pwhite(1.0, 3.0, inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, 2,
		\rel, Pseq([
			Pwhite(0.5, 1.0, 4),
			Pwhite(8, 10, 8)
		], inf),
		\amp, Pwhite(0.35, 0.45),
		\pan, Pxrand([
			Pwhite(-0.8, -0.3, 1),
			Pwhite(0.3, 0.8, 1)
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
		\buf, Pseq([Pfunc({~buf.choose.bufnum}), ], inf),
		\rate, Pseq([
			Pbrown(0.1, 0.5, 0.01, 32),
			Pwhite(0.1, 0.5, 16)
		], inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, 0.1,
		\rel, 0.1,
		\amp,  Pwhite(0.6, 0.7, inf),
		\pan, Pxrand([
			Pwhite(-0.8, -0.3, 1),
			Pwhite(0.3, 0.8, 1)
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
		\buf, Pseq([Pfunc({~buf.choose.bufnum}), ], inf),
		\rate, Pseq([
			Pbrown(1.0, 3.0, 0.01, 16),
			Pwhite(1.0, 3.0, 8),
			Pbrown(1.0, 3.0, 0.01, 16),
			Pwhite(1.0, 3.0, 8),
		], inf),
		\startpos,Pwhite(0, 0.9, inf),
		\loop, 1,
		\atk, Pbrown(0.1, 0.2, 0.01, inf),
		\rel, 0.1,
		\amp, Pwhite(0.35, 0.45),
		\pan, Pxrand([
			Pwhite(-0.8, -0.3, 1),
			Pwhite(0.3, 0.8, 1)
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


// To trigger compositions!!



(
// ACHTUNG --> there is a bug in the code of the Mouse class...the xval and yval are the same...you have to change it in the source code (and then recompile class library)
 Mouse(\showPosition, { |mouse, xval, yval, xraw, yraw|
	var xV, yV, switch;
	// first to see if if we are on one side or another side of x and y
	if(xval < 0.5){
		xV = false;};
	if(xval >= 0.5){
		xV = true;};
	if(yval < 0.5){
		yV = true;};
	if(yval >= 0.5){
		yV = false;};


	// For upper right corner
	if( (xV==true).and(yV==true)){

		if(~switch != 1){

		~switch = 1;

		("up right").postln;
			Pdef(\upright).play;
			Pdef(\upleft).stop;
			Pdef(\downright).stop;
			Pdef(\downleft).stop;
		};
	};
	// down right
	if( (xV==true).and(yV!=true)){

		if(~switch != 2){

		~switch = 2;

		("down right!").postln;
			Pdef(\upright).stop;
			Pdef(\upleft).stop;
			Pdef(\downright).play;
			Pdef(\downleft).stop;
		};
	};
	//up left
		if( (xV!=true).and(yV==true)){

		if(~switch != 3){

		~switch = 3;

		("up left").postln;
			Pdef(\upright).stop;
			Pdef(\upleft).play;
			Pdef(\downright).stop;
			Pdef(\downleft).stop;
		};
	// down left

	};
		if( (xV!=true).and(yV!=true)){

		if(~switch != 4){

		~switch = 4;

		("down left").postln;
			Pdef(\upright).stop;
			Pdef(\upleft).stop;
			Pdef(\downright).stop;
			Pdef(\downleft).play;
		};
	};


});
);
Mouse.stop;
/* to free the mouse!

Mouse(\showPosition).free;

to start and stop the mouse
Mouse.start;
Mouse.stop;

*/

);


