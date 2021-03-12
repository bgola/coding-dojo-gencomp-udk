
~router = OSCRouterClient(\fang);
~router.join;



//change the ID (second param)  ID param -----Andres 0,1 fang 2,3, Sani 4,5, TsingYun 6,7
//SynthDef send
(
SynthDef("SendMouseXY2",{
	SendTrig.kr(Impulse.kr(2), 0, MouseX.kr.linlin(-1.6,1,0.01,1));
	SendTrig.kr(Impulse.kr(2), 1, MouseY.kr.linlin(-0.16,1.22, 0.01, 1));
}).add;
)

//start the Synth
e = Synth("SendMouseXY2");
//stop the Synth
e.free;


///set up a network connection to local if needed
//p = NetAddr.new("127.0.0.1", 7771);

(
~switch = 0;
~xV = false;
~yV = false;
~p1x =0;
~p1y =0;
~p2x =0;
~p2y =0;
~p3x =0;
~p3y =0;
~p4x =0;
~p4y =0;
)

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



////don't need to run////
////listening to others on the network and do something (currently not in use)////

(
~router.addResp(\toRouter, {arg msg;
	//distinguish different user's mouse X and Y ----msg1 is id, msg2 is value
	//// ID param -----Andres 0,1 fang 2,3, Sani 4,5, TsingYun 6,7

	///////Andres mouse/////////
	if((msg[1]==0).and(msg[2] < 0.5)){
		//( "X = "+ msg[3] + "<0.5").postln;
		~xV = false;
		~p1x = msg[2];
		if(~buf == d[\andres]){
			Ndef(\mouseX).set(\in,msg[2]);};

	};
	if( (msg[1]==0).and(msg[2] >= 0.5)){
		//( "X = "+ msg[3] + ">=0.5").postln;
		~xV = true;
		~p1x = msg[2];
		if(~buf == d[\andres]){
			Ndef(\mouseX).set(\in,msg[2]);};
	};
	if( (msg[1]==1).and(msg[2] < 0.5)){
		//( "Y = "+msg[3] + "<0.5").postln;
		~yV = false;
		~p1y = msg[2];
		if(~buf == d[\andres]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	if( (msg[1]==1).and(msg[2] >= 0.5)){
		//( "Y = "+msg[3] + ">=0.5").postln;
		~yV = true;
		~p1y = msg[2];
		if(~buf == d[\andres]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	///////Fang mouse/////////
	if((msg[1]==2).and(msg[2] < 0.5)){
		//( "X = "+ msg[3] + "<0.5").postln;
		~xV = false;
		~p2x = msg[2];
		if(~buf == d[\fang]){
			Ndef(\mouseX).set(\in,msg[2]);};
	};
	if( (msg[1]==2).and(msg[2] >= 0.5)){
		//( "X = "+ msg[3] + ">=0.5").postln;
		~xV = true;
		~p2x = msg[2];
		if(~buf == d[\fang]){
			Ndef(\mouseX).set(\in,msg[2]);};
	};
		if( (msg[1]==3).and(msg[2] < 0.5)){
		//( "Y = "+msg[3] + "<0.5").postln;
		~yV = false;
		~p2y = msg[2];
		if(~buf == d[\fang]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	if( (msg[1]==3).and(msg[2] >= 0.5)){
		//( "Y = "+msg[3] + ">=0.5").postln;
		~yV = true;
		~p2y = msg[2];
		if(~buf == d[\fang]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	///////Sani mouse/////////
	if((msg[1]==4).and(msg[2] < 0.5)){
		//( "X = "+ msg[3] + "<0.5").postln;
		~xV = false;
		~p3x = msg[2];
		if(~buf == d[\sani]){
			Ndef(\mouseX).set(\in,msg[2]);};
	};
	if( (msg[1]==4).and(msg[2] >= 0.5)){
		//( "X = "+ msg[3] + ">=0.5").postln;
		~xV = true;
		~p3x = msg[2];
		if(~buf == d[\sani]){
			Ndef(\mouseX).set(\in,msg[2]);};
	};
		if( (msg[1]==5).and(msg[2] < 0.5)){
		//( "Y = "+msg[3] + "<0.5").postln;
		~yV = false;
		~p3y = msg[2];
		if(~buf == d[\sani]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	if( (msg[1]==5).and(msg[2] >= 0.5)){
		//( "Y = "+msg[3] + ">=0.5").postln;
		~yV = true;
		~p3y = msg[2];
		if(~buf == d[\sani]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	///////TY mouse/////////
	if((msg[1]==6).and(msg[2] < 0.5)){
		//( "X = "+ msg[3] + "<0.5").postln;
		~xV = false;
		~p4x = msg[2];
		if(~buf == d[\tsing]){
			Ndef(\mouseX).set(\in,msg[2]);};
	};
	if( (msg[1]==6).and(msg[2] >= 0.5)){
		//( "X = "+ msg[3] + ">=0.5").postln;
		~xV = true;
		~p4x = msg[2];
		if(~buf == d[\tsing]){
			Ndef(\mouseX).set(\in,msg[2]);};
	};
		if( (msg[1]==7).and(msg[2] < 0.5)){
		//( "Y = "+msg[3] + "<0.5").postln;
		~yV = false;
		~p4y = msg[2];
		if(~buf == d[\tsing]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	if( (msg[1]==7).and(msg[2] >= 0.5)){
		//( "Y = "+msg[3] + ">=0.5").postln;
		~yV = true;
		~p4y = msg[2];
		if(~buf == d[\tsing]){
			Ndef(\mouseY).set(\in,msg[2]);};
	};
	("x1 = " +(~p1x.value*10).round +  "; y1 ="+ (~p1y.value*10).round).postln;

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
		("up right").postln;
			Pdef(\upright).play;
			Pdef(\upleft).stop;
			Pdef(\downright).stop;
			Pdef(\downleft).stop;

		};

	};
	if( (xV==true).and(yV!=true)){

		if(~switch != 2){

		~switch = 2;

		("down right!").postln;
			Pdef(\upright).stop;
			Pdef(\upleft).stop;
			Pdef(\downright).play;
			Pdef(\downleft).stop;

		};

	};
	if( (xV!=true).and(yV==true)){

		if(~switch != 3){

		~switch = 3;
			("up left").postln;
			Pdef(\upright).stop;
			Pdef(\upleft).play;
			Pdef(\downright).stop;
			Pdef(\downleft).stop;

		};

	};
	if( (xV!=true).and(yV!=true)){

		if(~switch != 4){

		~switch = 4;
			("down left").postln;
			Pdef(\upright).stop;
			Pdef(\upleft).stop;
			Pdef(\downright).stop;
			Pdef(\downleft).play;

		};

	};

	~switch;
	1.wait;}
})
)

///play the Tdef to see if the mode should be change
Tdef(\f).stop


