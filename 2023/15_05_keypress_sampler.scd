/*

Generating random sounds.

features:
 - use oscillators
 - use noises
 - use recorded sounds / live sampling
    - starts recording when the level goes above a certain threshold - DetectSilence.ar / Amplitude.kr
 - key controls switch between recorded sounds / synthesized sounds
*/

(
Ndef(\randomSound, {
	arg t_gate = 0;
	var perc = Env.perc(0.01, 0.5, 1, -4).ar(0, t_gate);
	[SinOsc, LFSaw, LFTri, LFPulse].choose.ar(exprand(50,2000) * LFNoise2.ar(exprand(0.2,10)).range(0.8,1.2))*perc;
}).play;
)



Env.perc(0.01, 0.5, 1, -4).plot
SoundIn.ar(0)
b = Buffer.alloc(s, s.sampleRate * 3)

(
Ndef(\recordBuf, {
	var snd SoundIn.ar(0);
	var thresh = Amplitude.ar(snd) >0.5;
	RecordBuf.ar(snd, b, loop:0, trigger:thresh);
});
)

b.play;

(
w = Window.new;
v = View(w);
View.globalKeyDownAction = {
	|view, char, modifiers, unicode, keycode, key|
	if (char == $r) { Ndef(\randomSound).end; b.play};
	if (char == $s) { Ndef(\randomSound).rebuild.play; };
	if (char == $e) { Ndef(\randomSound).set(\t_gate, 1);};
};
w.front;
)


b.plot

{LFNoise2.ar(10)}.plot(2)


{ arg myarg; myarg.postln}.value(2)