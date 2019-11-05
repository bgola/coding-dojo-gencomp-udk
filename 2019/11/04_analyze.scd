// This was more a tutorial than a Coding Dojo session.

// Some UGens that analyze an input:

Amplitude.kr
Pitch.kr
ZeroCrossing.ar
UGen
Concat.ar
Concat2.ar

// Load a file into a buffer
~buffer = Buffer.read(s, "file.wav");

// Another way to load file, using a graphical interface to choose the file:
~buffer2 = Buffer.loadDialog(s);

(
// Tracks the amplitude of a sound signal and changes the amplitude of a sine wave
Ndef(\amplitude, {
	var snd = SinOsc.ar(550);
	var sample = PlayBuf.ar(1, ~buf2)*1.5;
	var amplitude = Amplitude.ar(sample);
	(snd * amplitude)!2;
}).play;
)

(
// Tracks the pitch of a sound signal and changes the pitch of a sine wave
Ndef(\pitch, {
	var sample = PlayBuf.ar(1, ~buf2)*1.5;
	var pitch = Pitch.kr(sample)[0].poll;
	var snd = SinOsc.ar(pitch);
	snd + sample;
}).play;
)

(
// Combine both of the above altering the pitch and amplitude of a sine wave based on the analyzed sound
Ndef(\pitchAmp, {
	var sample = PlayBuf.ar(1, ~buf2)*1.5;

	// If you want to experiment with microphone, you can change the line above to SoundIn.ar:
	//var sample = SoundIn.ar(0);

	// ZeroCrossing analyze the pitch in a simpler/less precise way, but we can use it in Audio Rate
	// so the result is better for the purpose of altering the pitch of another sound.
	var pitch = ZeroCrossing.ar(sample);
	var amplitude = Amplitude.ar(sample);
	var sndamp = SinOsc.ar(500) * amplitude;
	var sndpitch = SinOsc.ar(pitch)*0.25 * amplitude;
	[sndamp, sndpitch];// + sample;
}).play;
)













