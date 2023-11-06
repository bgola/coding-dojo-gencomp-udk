/*

30.10.2023

Use buffers as control data for a sequencer.

- write a markov chain sequencer √
- a ndef that writes the control to a buffer (BufWr)
- a ndef that reads the buffer and outputs triggers and values (BufRd) √
- make a GUI using the Plotter object to draw values into the buffer
- strict number of steps (define in startup) √


Example of Markov matrix with 4 steps:
[
[0,1,0,0],
[0,0,1,0],
[0,0,0,1],
[1,0,0,0],
]
*/

// numWireBufs
s.options.numWireBufs = 1024;

// boot the server
s.boot;

~numberOfSteps = 16;
// Create a new empty Buffer with ~numberOfSteps samples
~valuesBuffer = Buffer.alloc(s, ~numberOfSteps);

// load the amen break (should be downloaded form github and added to the same folder)
b = Buffer.read(s, thisProcess.nowExecutingPath.dirname +/+ "amen_4_bars.wav");


(
// this is a new draft for a 2-dimensional buffer......

// 4x4 probability matrix
a = [
	[0,1,0,0],
	[0,0,1,0],
	[0,0,0,1],
	[1,0,0,0]
];

// ~numberOfSteps x ~numberOfSteps probability matrix
~probMatrix = ~numberOfSteps.collect {|i| ~numberOfSteps.collect {|j| if ((i+1) == j) { 1 } { 0 } } } ;
)


(
// Ndef for the frequency of the main trigger
Ndef(\freq, {arg freq=1; freq});
// Ndef that represents the main trigger / clock of our system
Ndef(\trig,{Impulse.ar(Ndef(\freq).kr(1))});

// Choose the next step according to the probability distribution in the probbility matrix
Ndef(\readABuffer2, {
	// The trigger comes from the Ndef we defined above
	var trig = Ndef(\trig).ar(1);
	// The next step is initialized as 0, so it starts from the step 0
	// but we receive the next step as a LocalIn so that we can send the next step
	// after we read the probability matrix
	var step = LocalIn.ar(1, 0);
	// Select the current step as the line in the probability matrix
	var probabilities = Select.ar(step, K2A.ar(\probMatrix.kr(~probMatrix)));
	// Choose the next step using the probabilities as weight for the choice
	var nextStep = TWChoose.ar(trig, K2A.ar((0..(~numberOfSteps-1))), probabilities, 1);
	// Send the nextStep to the LocalIn so we can read the next step :)
	LocalOut.ar(nextStep);
	nextStep;
});
);

//get the output of this Ndef and use it to read the valuesBuffer
(
Ndef(\readABuffer, {arg glide=0.001, octave=4;
	// declare some variables we are going to use
	var trig, step, sequencerValue, sig, dur, trigDur, note, sigtrig, sigtrigdur, dly, fb;
	var freq = Ndef(\freq).kr(1);

	fb = LocalIn.ar(2, 0);
	// the trigger
	trig = Ndef(\trig).ar(1);
	// The current step (coming from our other ndef
	step = Ndef(\readABuffer2).ar(1);

	// Read the step value from the valuesBuffer
	sequencerValue =  BufRd.ar(1, ~valuesBuffer, step);
	// Latch is the same as Sample & Hold:
	// it will lock its value when it receives a trig. it is important, in case we are changing values
	// in the ~valuesBuffer
	sequencerValue = Latch.ar(sequencerValue, trig);

	// The values from the ~valuesBuffer are between 0 and 12
	// we convert them to frequency here, using the octave that is an argument to the ndef
	// notes are gr
	note = (sequencerValue + (octave*12)).midicps.lag(glide);

	// Calculate the trig durantion based on the current frequency of steps
	trigDur = 1/freq;

	sigtrigdur = trigDur/2;
	sigtrig = trig + DelayN.ar(trig, 2, sigtrigdur);
	sigtrig = CoinGate.ar(\bassLineProb.kr(0.3), sigtrig);

	sig = Env.perc(0.01, sigtrigdur/2, 1, 3).ar(0, sigtrig) * MoogVCF.ar(Saw.ar((Select.kr(sequencerValue, Scale.minor.degrees.mirror )  * [1,1.04] + (octave*12)).midicps.lag(glide) * Env.perc(0.01, sigtrigdur/5, 1, 2).ar(0, sigtrig).range(1,8), 0.6, mul: 1), 200 * Env.perc(0.01,sigtrigdur/4, 1, -2).ar(0,sigtrig, 1.0, 16.0, 1.0) , 0.7);

	sig = (sig * 5).tanh * 0.6;
	dly = CombC.ar(sig*0.5 + LPF.ar((HPF.ar(fb, 300)*\fb.kr(0.91,spec:[0,1])), 4000), 2, sigtrigdur/([32,48]), 0);
	LocalOut.ar(dly);

	sig = sig + dly;
	dur = BufDur.kr(b) / 16;
	sig = sig + ((PlayBuf.ar(2, b, BufRateScale.kr(b) * (dur / trigDur), trig, (sequencerValue.linlin(0,11,0,~numberOfSteps-1).floor / ~numberOfSteps) * BufFrames.kr(b)) * Env.perc(0.01, trigDur, 1, 4).ar(0, trig) * 4).tanh * 0.4);

	sig;
});
)

// check the current values Buffer value, it is probably empty:
~valuesBuffer.plot;

// set the values from 0 to 11:
~valuesBuffer.set(*(~numberOfSteps.collect {|i| [i, i.linlin(0,~numberOfSteps-1,0,11)]}).flatten)

// check new values
~valuesBuffer.plot;


// Listen to it
Ndef(\readABuffer).play

// play with different values for the synthesis
Ndef(\readABuffer).set(\glide, 0.1, \octave, 1, \bassLineProb, 0.5, \fb, 0.2)
Ndef(\freq).set(\freq, 3.4);

// change the sequence values to some random numbers/notes
~valuesBuffer.set(*(~numberOfSteps.collect {|i| [i, 12.0.rand]}).flatten)

// change the probability matrix and sets it again (run this block a few times):
(
~probMatrix[~numberOfSteps.rand][~numberOfSteps.rand] = 1.0.rand;
Ndef(\readABuffer2).set(\probMatrix, ~probMatrix);
);

// Editable plot to change values of the buffer
(
~valuesPlot = ~valuesBuffer.plot;
~valuesPlot.editMode = true;
~valuesPlot.specs = [0,12].asSpec;

~valuesPlot.editFunc = {|plot|
	~valuesBuffer.set(*plot.value[0].collect {|val,idx| [idx, val] }.flatten)
};
)

// Same thing but for the probability matrix:
(
~probMatrixPlot = ~probMatrix.plot;
~probMatrixPlot.editMode = true;
~probMatrixPlot.specs = [0, 1].asSpec;
~probMatrixPlot.editFunc = {arg plot; Ndef(\readABuffer2).set(\probMatrix, plot.value);};
~probMatrixPlot.plotMode = \bars;~probMatrixPlot.refresh;
)

// stop the sound
Ndef(\readABuffer).stop
