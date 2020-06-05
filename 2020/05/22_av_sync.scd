/*

ORDER: [\bgola, \Chunli, \Carlos2, \ozcan2020, \MengXuan];

// Dojo proposal:
//  create a generative audiovisual-synchronized animation.
//
// A suggestion:
//   In a window of 600x600 pixels show random colored rectangles in horizontal and
//   vertical orientation, and play two random melodies accordingly to the column or
//   line as the rectangles are drawn.
//
// Some basic guidelines:
// - Before you start writing code, describe what you want to do
// - Baby steps, do the minimun necessary to do what you described

1 hour session

15h30 // small break
15h40-16h10 //
16h10-16h30 // feedback round
*/

~win = Window.new("audio visual sync", Rect(0, 0, 600, 600));
~win.front;

~userview = UserView.new(~win, Rect(0, 0, 500, 500));
~userview.background = Color.black;
~userview.animate = true;

~userview.frameRate = 10;
//
(
~userview.drawFunc = {arg uv;
	var x = 500.rand;
	var y = 500.rand;
	~synth.set(\x, x, \y, y);
	Pen.fillColor = Color.rand;
	Pen.addRect(Rect(x, y, rrand (40,70), rrand(20,70));
	Pen.fill;
};
)


s.volume = 0; // full
s.volume = -10; // lower
s.volume = -20; // much lower


//
(
~synth.release;
~synth = {|x=400,y=600|
	SinOsc.ar(LFNoise0.kr([10.0,10.11]).range(x, y))*0.2
}.play;
)

(
~synth.release;
~synth = {|x=400,y=600| SinOsc.ar([x,y])*0.2}.play;
)

//adding reverb
(
~synth.release;
~synth = {|x=400,y=600|
	// this is the reverb:
	FreeVerb.ar(
		SinOsc.ar([x,y])*0.2,
		0.1
	)
}.play;
)

(
// add more complex frequency modulation
~synth.release;~synth = {|x=300,y=100|
	SinOsc.ar(
		SinOsc.ar([x,y], 200, 500)
	) * 0.1
}.play;
)

Pbind(\freq,Prand ([300,500, 300, 220], inf)*100, \dur, 0.2).play;





