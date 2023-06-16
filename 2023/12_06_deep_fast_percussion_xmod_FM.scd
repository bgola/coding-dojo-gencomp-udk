/*

Coding Practice 12.06.2023

+ A sound that has one control input
? synthesis using cross modulated FM
+ deep fast percussion sounds
+ control input is a linear slider
- extra: - map  microphone input amplitude to the control slider

*/

//SynthDef(\DeepFastCrossFM, {

//deep sound
Ndef(\x, {SinOsc.ar(35)}).play;
//deep sound amplitude modulated, amplitude 100 hertz
Ndef(\x, {SinOsc.ar(35, mul: SinOsc.ar(100))}).play;

// mod freq is really high compraed to base freq
Ndef(\x, {SinOsc.ar(35*SinOsc.ar(440))}).play;
// watch and stop ...
Ndef(\x).scope;
Ndef(\x).stop;

// make freq mod really slow, so we hear its tempo
// increase base freq so we hear it go up and down
Ndef(\x, {SinOsc.ar(80*SinOsc.ar(1))}).play;

//
Ndef(\x, {
	//declar speed=amp mod frequency and depth=base frequency)
	var speed = 2;
	var depth = 44;
	var ampmod = SinOsc.ar(speed);
	SinOsc.ar(depth) * ampmod
}).play;

// Adding Percussiveness to the previous code
(
Ndef(\x, {
	//declar speed=amp mod frequency and depth=base frequency)
	var speed = 7;
	var depth = 44;
	var ampmod = LFSaw.ar(speed).range(1,0);
	SinOsc.ar(depth) * ampmod
}).scope;
)



Ndef(\z, {[LFSaw.ar(86/2),Saw.ar(86/2)]}).scope
Ndef(\y, {Saw.ar(86)}).scope

// linear slider
// create vars for every freq parameter
(
Ndef(\x, {
	arg speed = 7,  depth = 88;
	//declar speed=amp mod frequency and depth=base frequency)

	var ampmod = LFSaw.ar(speed).range(1,0);
	// freq modulation
	var freqmod = SinOsc.ar(80).range(-30, 30);
	SinOsc.ar(depth + freqmod) * ampmod
}).play;
)

Ndef(\x).gui;

(
Ndef(\x, {
	//one input to control all the variables
	arg influencer;
	//declar speed=amp mod frequency
	// and base frequency)

	// derive speed from influencer
	var speed = influencer * 20+1;
	//inverse relationship between speed and basefreq
	var basefreq = ((1-influencer) * 20 +1) *7;
	var ampmod = LFSaw.ar(speed).range(1,0);
	// freq modulation
	var freqmod = SinOsc.ar(80).range(-30, 30);
	var sound = SinOsc.ar(basefreq + freqmod) * ampmod;
//protects the speaker by removing the frequencies that are too low
	LeakDC.ar (sound);
}).play;
)

Spec.add(\influencer, [0,1]);


// crossmodulation synthesis!

/*
two oscillators, each osc modulates
frequency of the other osc
*/
Ndef(\xmod).gui;
// range of crossmod amount
Spec.add(\xmod, [0, 10]);
(
Ndef(\xmod, { arg xmod = 2;
	// the two basic freqs
	var freq1 = 100, freq2 = 62;
	// get output of osc2 in for mod input
	var osc2FeedIn = LocalIn.ar(1);

	// osc1:
	var osc1 = SinOsc.ar(
		// keep basic freq1 when xmod is 0,
		freq1 * (1
			// add modulation from osc2,
			// amount scaled by xmod
			+ (xmod * osc2FeedIn))
	);
	// same for osc2:
	var osc2 = SinOsc.ar(
		// keep basic freq2 when xmod is 0,
		freq2 * (1
			// add modulation from osc1,
			// amount scaled by xmod
			+ (xmod * osc1))
	);
	LocalOut.ar(osc2);
	[ osc1, osc2] * 0.3;
}).play;


// merge !
Ndef(\xmod).scope;

Ndef(\xmod).gui;
// range of crossmod amount
Spec.add(\xmod, [0, 10]);
(
Ndef(\xmod, { arg influencer;
	//declar speed=amp mod frequency
	// and base frequency)
	var xmod = (influencer*10).sin.range(0, 15);
	// derive speed from influencer
	var speed = influencer * 20+1;
	//inverse relationship between speed and basefreq
	var basefreq = ((1-influencer) * 20 +1) *7;
	var ampmod = LFSaw.ar(speed*[0.6,1]).range(1,0);
	// freq modulation
	var freqmod = SinOsc.ar(80).range(-30, 30);
	// the two basic freqs
	var freq1 = ((influencer) * 20 +57) *2, freq2 = ((1-influencer) * 20 +1) *7;
	// get output of osc2 in for mod input
	var osc2FeedIn = LocalIn.ar(1);

	// osc1:
	var osc1 = SinOsc.ar(
		// keep basic freq1 when xmod is 0,
		freq1 * (1
			// add modulation from osc2,
			// amount scaled by xmod
			+ (xmod * osc2FeedIn))
	);
	// same for osc2:
	var osc2 = SinOsc.ar(
		// keep basic freq2 when xmod is 0,
		freq2 * (1
			// add modulation from osc1,
			// amount scaled by xmod
			+ (xmod * osc1))
	);
	var sound = [osc1, osc2]*0.3*ampmod;
	LocalOut.ar(osc2);
	LeakDC.ar (sound);
}).play;
)

(
Ndef(\soundIn, {
	Amplitude.ar(SoundIn.ar(0) * 2).pow(0.25).poll;
})
)

100.collect { |i| (i / 100).pow(7) }.plot

Ndef(\xmod).set(\influencer, Ndef(\soundIn))
Ndef(\xmod).scope;






