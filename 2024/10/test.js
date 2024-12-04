setup_clean = () => {
	globals['frame'] = 0
}

clean_live = () => {
	let fr = globals['frame']
	globals['frame'] += 1
	if(fr % 120 == 300) { return 1 }
	return 0;
}

setup_live = () => {
	// Keep track of the frame number
	globals['frame_number'] = 0;
	if (!globals['args']) { globals['args'] = [0,0,0,0, 0,0,0,0]; }
	if (!globals['sock']) {
		globals['sock'] = zmqctx.socket(zmq.SUB)
		globals['sock'].setsockopt(zmq.SUBSCRIBE, "")
		globals['sock'].connect("tcp://localhost:5556");
	}
}

function dist(xA, yA, xB, yB) { 
	var xDiff = xA - xB; 
	var yDiff = yA - yB;

	return Math.sqrt(xDiff * xDiff + yDiff * yDiff);
}

glitch_live = (frame) => {
	const fwd_mvs = frame.mv?.forward;
	let ms = globals['sock'].recv_str(zmq.DONTWAIT)
	if (ms) { 
		//console.log(ms)
		let vals = ms.split(",")
		for (let i = 0; i < vals.length; i=i+1) {
			//let idx = parseInt(vals[i])
			//console.log(vals[i])
			let val = parseFloat(vals[i])
			//console.log(vals[i])
			if (i < 8) {
				globals['args'][i] = Math.min(1, Math.max(-1, val + globals['args'][i]));
			}
		}
		
	}
	if (fwd_mvs) {
		fwd_mvs.overflow = "truncate"

		globals['frame_number'] += 1;
		//console.log("got frame")
		const frame_number = globals['frame_number'];
		const sine = 1//Math.sin(frame_number*0);
		// go over all motion vectors (2D)
		const height = fwd_mvs.height;
		const width = fwd_mvs.width;
		const spinspeed = 0.3*sine;
		let rrow=Math.floor(Math.random()*fwd_mvs.height);
		let rcol=Math.floor(Math.random()*fwd_mvs.width);
		let dirx = Math.random()*120 - 60
		let diry = Math.random()*120 - 60
		if (Math.random() < 1) {
		
		fwd_mvs.forEach((mv, row, col) => {
			if (!mv) { return }
			const magnitude = mv.magnitude()
			const heightMiddle = height/2;
			let nrow = row/fwd_mvs.height
			let ncol = col/fwd_mvs.width
			let di = 1-dist(nrow, ncol, 0.5, 0.5)/dist(0,0,0.5,0.5);
			let d = Math.pow(di, 1)
			let n = noise(row*0.1, col*0.1, frame_number*0.2);
			mv[0] *= n*d*20// globals['args'][Math.floor(row/Math.abs(globals['args'][1])*30)%8]*globals['args'][2]*4.2 //* Math.sin(frame_number*0.2)
			mv[1] *= n*d*20// (n*60-30) * d// globals['args'][Math.floor(col/Math.abs(globals['args'][2])*30)%8]*globals['args'][3]*4.2
			//mv[0] += globals['args'][Math.floor(row/Math.abs(globals['args'][1])*50*noise(col*0.1,row*0.1,frame_number*0.001))%8]*globals['args'][2]*2.2 //* Math.sin(frame_number*0.2)
			//mv[1] -= globals['args'][Math.floor(col/Math.abs(globals['args'][2])*50*noise(col*0.1,row*0.1,frame_number*0.001))%8]*globals['args'][3]*2.2
			
		})
	}
	}
}