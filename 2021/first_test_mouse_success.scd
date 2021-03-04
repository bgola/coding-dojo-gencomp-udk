/* sync text via network */
//yun
s.boot

//method 3: put it in a SynthDef
(
SynthDef("SendMouseXY",{
    SendTrig.kr(Impulse.kr(1), 2, MouseX.kr);
	SendTrig.kr(Impulse.kr(1), 3, MouseY.kr);
}).add;
)

///set up a network connection to local p5
p = NetAddr.new("127.0.0.1", 7771);
p.sendMsg("/toP5", 5.0);


(
// method3 receiver: register to receive this message
o = OSCFunc({ arg msg;
	//msg.postln;
	p.sendMsg("/toP5", msg[2],msg[3]);  //msg[2] is id 0 = mouseX 1=mouseY; msg[3] is value
	("it's sending " + msg[2]+msg[3] + "to P5").postln;
	//~router.sendMsg('toFang', msg[2],msg[3]); //send this information to other ppl.
},'/tr', s.addr); //built in  path and port
)

//start the Synth
e = Synth("SendMouseXY");
e.free;


//free the receiver (it won't free the Synth)
o.free;







//recieving OSC message from myself and send it to P5
(
OSCdef(\toP5, {|msg|
	p.sendMsg("/toP5", msg[0],msg[1]);
	("it's sending " + msg[0]+msg[1] + "to P5").postln;
},"/here")
)


////listening to others on the network and do something (currently not in use)////
(
~router.addResp(\toFang, {arg msg;
	p.sendMsg("/toP5", msg[1],msg[2]);
	("TsingYun it's sending " + msg[1]+msg[2] + "to P5").postln;
	msg.postln;

})
)