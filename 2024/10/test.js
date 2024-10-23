// First goal:
//    Make it spin

setup_live = () => {
}

glitch_live = (frame) => {
	const fwd_mvs = frame.mv?.forward;

	if ( fwd_mvs ) {
		fwd_mvs.forEach((mv, i, j) => {
			fwd_mvs.width;
			fwd_mvs.height;
			let shiftX = fwd_mvs.height/2 - i;
			mv[0] += shiftX;
		})
	}
}
