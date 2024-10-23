// First goal:
//    Make it spin

setup_live = () => {
}

glitch_live = (frame) => {
	const fwd_mvs = frame.mv?.forward;

	if ( fwd_mvs ) {
		// go over all motion vectors (2D)
		fwd_mvs.forEach((mv, row, col) => {
			fwd_mvs.width;
			let spinspeed = 0.2;
			// calculate how much to shift each column:
			// begin with half height for left, 
			// and go down to -half height on right.
			let shiftX = fwd_mvs.height/2 - row;
			mv[0] += shiftX * spinspeed;
			let shiftY = fwd_mvs.width/2 - col;
			mv[1] -= shiftY *  spinspeed;
			
		})
	}
}