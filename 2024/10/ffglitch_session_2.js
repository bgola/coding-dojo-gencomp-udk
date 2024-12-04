setup_clean = () => {
    globals['frame'] = 0
}

clean_live = () => {
    globals['frame'] += 1
    if (globals['frame'] < 3) { return 1 };
    return 0;
}

setup_live = () => {
    globals['frame_number'] = 0;
    globals['past_frames'] = [];
}

glitch_live = (frame) => {
    const fwd_mvs = frame.mv?.forward;

    if (!fwd_mvs) return;

    let ramp =  0.2;
    fwd_mvs.forEach((mv, row, col) => {
        if(!mv) { return };
        let x = row / fwd_mvs.height;
        let y = row / fwd_mvs.width;
        //mv[0] = Math.random()*20-10
        //mv[1] = Math.random()*20-10
        mv[0] += (noise(col * ramp * 0.9 , row * ramp * 1.3, globals['frame_number']*0.002) - 0.5) * 7
        mv[1] += (noise(row * ramp * 3.4, col * ramp * 0.5,globals['frame_number']*0.006) - 0.5) * 9
        
    })
    globals['frame_number'] += 1;
}