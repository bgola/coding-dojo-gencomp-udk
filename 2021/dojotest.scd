/* sync text via network */
// sani in
fang in
bgola in
yun in
chunli in


// and now? (ANDRESSS YESSSSSSS!!!!!!!brign i!()
//this is fang again
//Critical bug on Window!!!Ok no more
// solution: keep restaring unilit works ... or: fake till you make it


s.boot;
NetAddr.langPort; ///check SC default in-port
// something that makes sound when receiving OSC messages
// pop up a window for some seconds
//
// passes/send the OSC message to another program
//    python-osc NetAddr("ip-of-rpi", port-of-python) .sendMsg

// this.openUDPPort(33333)


w = Window("new window", Rect(300, 120, 300, 500)).front;
w.close;

// write a OSCdef that open a window
// closes the window after some seconds
// can choose size of window
// can choose background color of window
(
OSCdef (\window, {| msg | // arg msg;
	var width = msg[1], height = msg[2], posx = msg[3], posy = msg[4];
	var colorLo = msg[5], colorHi = msg[6];
	(note: rrand(30,60)).play;
	AppClock.sched(0, {
		var w = Window("dojo window", Rect(posx, posy, width, height));
		w.background = Color.rand(colorLo, colorHi);
		w.front;
	})

}, "/createWindow"); //path of OSC msg
)

(
OSCdef (\windowClose, {
	Pbind(\note, Pseq([40,32,45,35,32,28], 1), \dur, 0.25).play;
	AppClock.sched(0,{
		Window.closeAll;
	})
},"/closeWindow");
)
//whenever you want to create something wih visuals--- you need to do it in AppClock, sche

~router.sendMsg("/createWindow", 500.rand, 700.rand,1000.rand,500.rand, 0.2, 0.9)
~router.sendMsg("/closeWindow")

// write a OSCdef that makes a sound