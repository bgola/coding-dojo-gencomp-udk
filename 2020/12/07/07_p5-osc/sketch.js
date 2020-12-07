var x, y;
var freq = 0;
var freq2 = 0;
var ampli = 0;
var xPos = 0; 
var strokeW = 4;
var socket;

function setup() {
	createCanvas(1920, 1080);
	setupOsc(12000, 57120);
}

function draw() {
	 var mappedFreq = map(freq, 20, 15000, 0, 1000);
	var freqColor = map(freq,20,15000,0,255);
	var freq2Color = map(freq2,20,15000,0,255);
	//freqColor = 
	colorMode(RGB);
	stroke(freqColor);//, 255, 255);
	strokeWeight(strokeW);
	xPos=frameCount*strokeW % width;
	line(xPos,0,xPos,height/2);
	stroke(freq2Color);//, 255, 255);
	line(xPos,height/2, xPos, height);
		
	//ellipse(width/2, height/2, mappedFreq, mappedFreq);
	if (xPos <= strokeW) {
		sendOsc("/start", 1);
		//strokeW = 1 + (random() * 20);
		}
}

function receiveOsc(address, value) {	
	/*if (address == '/test') {
		x = value[0];
		y = value[1];
	}*/
	if (address == '/soundFreq') {
		freq = value[0];
		freq2 = value[1];
		//ampli = map(value[1], -1, 1, 0, 255);
	};
}

function sendOsc(address, value) {
	if(socket) {
	socket.emit('message', [address].concat(value));
	}
}




function setupOsc(oscPortIn, oscPortOut) {
	socket = io.connect('http://127.0.0.1:8081', { port: 8081, rememberTransport: false });
	socket.on('connect', function() {
		socket.emit('config', {	
			server: { port: oscPortIn,  host: '127.0.0.1'},
			client: { port: oscPortOut, host: '127.0.0.1'}
		});
	});
	socket.on('message', function(msg) {
		if (msg[0] == '#bundle') {
			for (var i=2; i<msg.length; i++) {
				receiveOsc(msg[i][0], msg[i].splice(1));
			}
		} else {
			receiveOsc(msg[0], msg.splice(1));
		}
	});
}
