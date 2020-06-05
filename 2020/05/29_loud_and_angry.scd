/*

14h20 - 5 min talk about last session
14h25 - problem / challenge proposal
14h30 - we start
15h00 - quick pause to check everyone is following
15h30 - finish and quick feedback round

- MengXuan
- bruno
- giu
- Carlos
- ozcan
- k10
- adc

Challenge:
  Draw something interesting, loud and angry. Also with sound.

Feedback:

Feedback for this session


Pros:
    Loud
    and angry +1 h

    it makes sense to work in pairs with an expert like Alberto and Bruno. It helps a lot! +1

    Incredible plataform to work together in the same project +1


Cons:

    technical problems (freezing sc sections, lost some typing)
    we forgot to document the code / add comments again

    we need to do a Preview of some functions before? like check the help file and try the code

suggestion:

    could be possible to lern in a separate session more about variables and arguments?


*/


// Window.closeAll;
// c.setupUserView;
// Butz.show;

(
Window.findAll("LOUD").do(_.close);
// Window.onClose=
Ndef(\loud).set(\freq, 1000.rand);
Ndef(\loud).play;

10.do {
	var rect = Rect(1000.rand, 1000.rand, 1000.rand, 1000.rand);
	w = Window("LOUD&ANGRY!!!", rect).front;
	u = UserView(w, Rect(0, 0, rect.width, rect.height));
	u.background = Color.rand;
    u.animate = true;

	u.drawFunc = {
		Pen.stringCenteredIn("Yo", u.bounds)
		//w = Window("LOUD&ANGRY!!!").front;

	};
};
Ndef(\loud, { |freq = 20|
	var blip = Blip.ar(freq, LFNoise0.kr([125, 323, 2, 25],3, 5), 0.5, 0.1);
	AdCVerb.ar(blip)
}).play;
)


//// control the Ndef:
Ndef(\loud).set(\freq, 1000.rand);
Ndef(\loud).stop;
Ndef(\loud).play;



// we stole verb from here

Ndef(\adcverb_help, {
    var src, verb;
    blip = Decay2.ar(Impulse.ar(0.5, 0.99), 0.001, 0.03, PinkNoise.ar(1));
    verb = AdCVerb.ar(src * 0.1);
    src + verb;
});


//// m ake one wundow and cghange itrs size
w = Window("LOUD&ANGRY!!!").front;
w.bounds;

w.bounds = Rect(1000.rand, 1000.rand, 1000.rand, 1000.rand);
w.front;
