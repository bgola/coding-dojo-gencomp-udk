




//change the ID (second param) fang 0,1 sani 2,3, TY 4,5, Andres 6,7
//SynthDef send
(
SynthDef("SendMouseXY",{
	SendTrig.kr(Impulse.kr(2), 0, MouseX.kr);
	SendTrig.kr(Impulse.kr(2), 1, MouseY.kr);
}).add;
)

//start the Synth
e = Synth("SendMouseXY");
//stop the Synth
e.free;


///set up a network connection to local if needed
p = NetAddr.new("127.0.0.1", 7771);


~switch = 0;
~xV = false;
~yV = false;


(
//receiver: register to receive this message
o = OSCFunc({ arg msg;


	msg.postln;
	//comment out this if you don't need to send to
	p.sendMsg("/toP5", msg[2],msg[3]); //msg[2] is id 0 = mouseX 1=mouseY; msg[3] is value
	("it's sending " + msg[2]+msg[3] + "to P5").postln;

	//~router.sendMsg('toFang', msg[2],msg[3]); //send this information to other ppl.
	//("it's sending " + msg[2]+msg[3] + "to router").postln;

	if((msg[2]==0).and(msg[3] < 0.5)){
		( "X = "+ msg[3] + "<0.5").postln;
		~xV = false;
	};
	if( (msg[2]==0).and(msg[3] >= 0.5)){
		( "X = "+ msg[3] + ">=0.5").postln;
		~xV = true;
	};
	if( (msg[2]==1).and(msg[3] < 0.5)){
		( "Y = "+msg[3] + "<0.5").postln;
		~yV = false;
	};
	if( (msg[2]==1).and(msg[3] >= 0.5)){
		( "Y = "+msg[3] + ">=0.5").postln;
		~yV = true;
	};
},'/tr', s.addr); //built in  path and port
)


//free the receiver (it won't free the Synth)
o.free;


////don't need to run////
////listening to others on the network and do something (currently not in use)////
(
~router.addResp(\toFang, {arg msg;
	p.sendMsg("/toP5", msg[1],msg[2]);
	("TsingYun it's sending " + msg[1]+msg[2] + "to P5").postln;
	msg.postln;

})
)


///switch to different mode when mouse position is in different erea
(
Tdef(\f,{
	loop{
	arg xV = ~xV, yV = ~yV,switch = ~switch ;

	if( (xV==true).and(yV==true)){

		if(~switch != 1){

		~switch = 1;

		("swith to mode 1!").postln;
		};
		("is mode 1").postln;
	};
	if( (xV==true).and(yV!=true)){

		if(~switch != 2){

		~switch = 2;

		("swith to mode 1!").postln;
		};
		("is mode 2").postln;
	};
	if( (xV!=true).and(yV==true)){

		if(~switch != 3){

		~switch = 3;

		("swith to mode 3!").postln;
		};
		("is mode 3").postln;
	};
	if( (xV!=true).and(yV!=true)){

		if(~switch != 4){

		~switch = 4;

		("swith to mode 4!").postln;
		};
		("is mode 4").postln;
	};

	~switch;
	1.wait;}
})
)

///play the Tdef to see if the mode should be change
Tdef(\f).play;


