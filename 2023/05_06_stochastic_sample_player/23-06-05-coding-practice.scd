/*

Coding Practice Session 05/06/2023

- Build a small sample bank
- choosing N samples from freesound.org
- sample bank should be stored somewhere in the file system with a folder structure
- have a data structure to load and represent this sample bank
- a sampler that plays samples from the sample bank
- random playback when we press a button
- stochastic sample weighted choice by folder

*/

~codefolder = thisProcess.nowExecutingPath.dirname;

~mainfolder = ~codefolder +/+ "sample_bank/";

// looks up folder structure by matching a pattern
~folders = (~mainfolder +/+ "*").pathMatch;

// Chooses a random folder
~folders.choose;
"Randomness".help

// from help file, how to choose with weight
10.do({ [ 1, 2, 3 ].wchoose([0.1, 0.2, 0.7]).postln });

// 70% chance of choosing the first folder
~folders.wchoose([0.7, 0.3]);


(
// chooses random folder with weighted choice
~folder = ~folders.wchoose([0.7, 0.3]);
// chooses a random file path from the chosen folder
~sample = (~folder +/+ "*").pathMatch.choose.postln;
// loads the chosen sample into a buffer
~buffer = Buffer.read(s, ~sample, action: { arg buffer;
	"sample read, now lets play".postln;
	// plays the chosen buffer after it is completely loaded on the server side
	buffer.play;
});
)


"button".help

// Demonstration of how the global variable value changes when you have processes running in the background changing it
~number = 0;
// runs 10 functions that waits for a time between 0 and 10 seconds, and sets the ~number variable value
fork { 10.do { arg n; 10.rand.wait; ~number = n } }

~number.postln

// our sampler function, does the same as the block in line 35;
// chooses a folder; chooses a file in that folder; creates a new buffer and loads the chosen file; and plays the buffer when ready
~randombuff = {
	~folder = ~folders.wchoose([0.7, 0.3]);
	~sample = (~folder +/+ "*").pathMatch.choose.postln;
	~buffer = Buffer.read(s, ~sample, action: { arg buffer;
		"sample read, now lets play".postln;
		buffer.play;
	});
} ;

// calls our sampler function
~randombuff.value;


// make it monophonic?
// optimize sampler code

// Monophonic version of the sampler function ~randombuff
~randMono = {
	// chooses a folder with weighted values
	var choice = ~folders.wchoose([0.7, 0.3]);
	// choses a file in the chosen folder
	var sample = (choice +/+ "*").pathMatch.choose.postln;
	// creates a buffer and loads the file into it
	var buffer = Buffer.read(s, sample, action: { arg buffer;
		"sample read, now lets play".postln;
		// releases the old synth that played the last file
		~bufsynth.release;
		// plays the new chosen file, and stores the synth created into the ~bufsynth variable so that we can release it later
		~bufsynth = buffer.play;
	});
};

// calls monophic function, will choose a new file and play
~randMono.value;
// stops the current playing buffer
~bufsynth.release;

// demonstration of the Array.collect method
[1,2,3,4,5,6].collect { arg element; element * 10 }

// Loads all the files in our folder structure into a sample bank
// the sample bank is an array, each element of the array is
// an array of buffers representing the folder structure
(
// iterate over all the folders from our main samples folder
~bank = ~folders.collect { arg folder;
	// collect all the sound files in each folder
	var soundfiles = SoundFile.collect(folder +/+ "*");
	// creates buffers and loads the content of each sound file
	var buffers = soundfiles.collect { arg soundfile;
		Buffer.read(s, soundfile.path);
	};
	// returns the newly created buffers
	buffers;
}
)

// check our sample bank structure
~bank;
~bank[0];
~bank[0][1];


// same as ~randMono function but doesn't need to create a buffer for each chosen file, chooses directly from our sound bank structure
~randMonoBuf = {
	// choose a folder from the sample bank
	var chosen_folder = ~bank.wchoose([0.7, 0.3]);
	// choose a buffer from the chosen folder
	var buffer = chosen_folder.choose;
	// releases the old synth
	~bufsynth.release;
	// plays the buffer and stores the synth so we can release it later
	~bufsynth = buffer.play;
};

~randMono.value

(
// creates a new window with the name The Four Noble Truths
var window = Window.new("The Four Noble Truths");

// Adds a button to the window in the position 20,20
Button(window, Rect(20, 20, 340, 100))
.states_([
	// sets text and color for the button
	["there is suffering", Color.black, Color.red],
])
// sets the action of the button, whenever pressed it will run our randMonoBuf sample player function
.action_({
	~randMonoBuf.value;
});

// Adds a button to the window in the position 20,120
Button(window, Rect(20, 120, 340, 100))
.states_([
	// sets text and color for the button
	["there is no suffering", Color.black, Color.green],
])
// sets the action of this button, when pressed it will release the synth if it is playing
.action_({
	~bufsynth.release;
});

// shows window
window.front;
)
