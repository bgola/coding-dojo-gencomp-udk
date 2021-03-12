/* sync text via network */
~router = OSCRouterClient(\yourname);
~router.join;
/*
~syncText = SyncText(\dojoTest, ~router.userName, ~router);
~syncText.showDoc;
*/

//change the ID (second param)  ID param -----Andres 0,1 fang 2,3, Sani 4,5, TsingYun 6,7
//SynthDef send
(
SynthDef("SendMouseXY",{
	SendTrig.kr(Impulse.kr(2), 0, MouseX.kr.linlin(0,1,0.01,1));
	SendTrig.kr(Impulse.kr(2), 1, MouseY.kr.linlin(0,1, 0.01, 1));
}).add;
)

//start the Synth
e = Synth("SendMouseXY");
//stop the Synth
e.free;

(
//receiver: register to receive this message
o = OSCFunc({ arg msg;


	//msg.postln;
	//comment out this if you don't need to send to
	//p.sendMsg("/toP5", msg[2],msg[3]); //msg[2] is id 0 = mouseX 1=mouseY; msg[3] is value
	//("it's sending " + msg[2]+msg[3] + "to P5").postln;

	~router.sendMsg('toRouter', msg[2],msg[3]); //send this information to other ppl.
	("it's sending " + msg[2]+msg[3] + "to router").postln;


},'/tr', s.addr); //built in  path and port
)

//free the receiver (it won't free the Synth)
o.free;