// First goal:
//    Make it spin

setup_live = () => {
	// Keep track of the frame number
	globals['frame_number'] = 0;
}

glitch_live = (frame) => {
	const fwd_mvs = frame.mv?.forward;

	if (fwd_mvs) {
		globals['frame_number'] += 1;
		const frame_number = globals['frame_number'];
		const sine = Math.sin(frame_number*0.01);
		// go over all motion vectors (2D)
		const height = fwd_mvs.height;
		const width = fwd_mvs.width;
		const spinspeed = 4*sine;
		fwd_mvs.forEach((mv, row, col) => {
			const magnitude = mv.magnitude()
			const heightMiddle = height/2;
			// calculate how much to shift each column:
			// begin with half height for left, 
			// and go down to -half height on right.

			if (row >= heightMiddle) {
				let shiftX = fwd_mvs.height / 2 - row;
				mv[0] += shiftX * spinspeed;
				let shiftY = fwd_mvs.width / 2 - col;
				mv[1] -= shiftY * spinspeed;
			} else {
				let shiftX = fwd_mvs.height / 2 - row;
				mv[0] -= shiftX * spinspeed;
				let shiftY = fwd_mvs.width / 2 - col;
				mv[1] += shiftY * spinspeed;
			}
		})
	}
}