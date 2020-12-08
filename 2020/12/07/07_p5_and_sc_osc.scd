/*
Goal - 07/12/2020

- communicate with p5js using a NetAddr object (OSC messaging)
- draw an object in p5js
 - control that object with a simple synth
  -

- p5js whenever object touches the border, sends a message back to supercollider

- chunli: setup touchdesigner project with an object that moves with osc messages

- extra: draw objects for any new synth
- extra: object only exists while synth is played

*/

n = NetAddr("localhost", 12000);

c = NetAddr("194.212.12.123", 8393);

n.sendMsg("/testMsg", 1231, 12312 ,123123);

(
x = {
	var bounce = SinOsc.ar(0.2).exprange(200,1200);
	//SendTrig.kr(Impulse.kr(30), 2, bounce);
	var sound = SinOsc.ar(bounce);
	SendReply.kr(Impulse.kr(30), "/niceName", [bounce, sound], 3);
	sound;
}.play
)


OSCdef(\receive, {arg msg;
	msg.postln;
	m.sendBundle(0, msg);
	//n.sendBundle(0, msg);

	//[n,c].do { arg addr; addr.sendMsg("/moveObj",  ); }
}, "/niceName");





/*
we have a control wave / LFO that controls some parameter of a sound wave

the amplitude of the control wave sets a gradient color in p5js

we define a specific time window of 5 second
*/



//create a sound
(
Ndef(\sin, 	{
	arg freqzz = 0.1, freqzz2 = 0.2;
	var freq = LFDNoise0.ar([freqzz, freqzz2]).exprange(20,15000);
	//var freq
	var niceTone = SinOsc.ar(freq);

	//send the control signal out
	SendReply.kr(Dust.kr(30), "/soundFreq", freq);
	niceTone;
}).play;
)


// Create net address object

n = NetAddr("localhost", 12000);
c = NetAddr("194.95.203.164", 12000);

//receve OSC signal from server to language
(
OSCdef(\receive, {arg msg;
	// send to two different addresses defined above ("c" and "n") at the same time

	[c, n].do { arg addr;
		addr.sendMsg("/soundFreq", msg[3].explin(20, 15000, 20, 15000), msg[4].explin(20, 15000, 20, 15000));
	};
}, "/soundFreq");
)
(
OSCdef(\start, {arg msg;
	msg.postln;
	Ndef(\sin).set(
		\freqzz, exprand(0.01, 100).postln,
		\freqzz2, exprand(0.01, 100).postln
	);
}, "/start");
)

