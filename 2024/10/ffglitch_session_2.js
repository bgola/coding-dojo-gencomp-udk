setup_clean = () => {
	globals['frame'] = 0
}

clean_live = () => {
    return 0;
}

setup_live = () => {
	// Keep track of the frame number
	globals['frame_number'] = 0;
}

glitch_live = (frame) => {
	const fwd_mvs = frame.mv?.forward;
	
	if (fwd_mvs) {
		fwd_mvs.overflow = "truncate"

		globals['frame_number'] += 1;
	}
}