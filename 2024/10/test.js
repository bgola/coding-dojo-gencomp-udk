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
		let switchvariable
		fwd_mvs.forEach((mv, row, col) => {
			if (Math.random () > 0) {
				switchvariable = mv[1]
				mv[1]= mv[0]
				mv[0]= switchvariable
			}
		
		})
	}
}