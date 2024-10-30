// Initial idea:
//   slit scanning type of effect
//     freeze the motion vectors in a specific line or group 
//     of lines
//
//  Connect to SC with some buffer scrubbing and
//  send the buffer position to FFLive to control
//  which line to scan


setup_clean = () => {
	globals['frame'] = 0
}

clean_live = () => {
    globals['frame']+=1
    if(globals['frame'] % 350 == 0) { return 1 };
    return 0;
}

setup_live = () => {
	// Keep track of the frame number
	globals['frame_number'] = 0;
    globals['past_frames'] = [];
}

glitch_live = (frame) => {
	const fwd_mvs = frame.mv?.forward;

    if (!fwd_mvs) return;

 const number_of_frames = 20
	
// freeze only one row of vectors
// if the row is in the middle of the frame, freeze it

let frame_vel = globals['frame_number']
frame_vel = Math.floor(frame_vel/10)

let glitch_line = frame_vel % fwd_mvs.height
let avg = [0,0];
let number_of_mvs=0;

 const size = globals['past_frames'].length 
 const avgFrames = [0,0];
     globals['past_frames'].forEach((avgFrame) => {
         avgFrames[0] += avgFrame[0];
         avgFrames[1] += avgFrame[1];
     });
     avgFrames[0] = avgFrames[0] / size;
     avgFrames[1] = avgFrames[1] / size;

fwd_mvs.forEach((mv, row, col) => {
/*    if (row == glitch_line) {
        if (globals['frame_number'] % 42 == 0) {
            // big jump
            mv[0] = Math.random() * 100 - 50
            mv[1] = Math.random() * 100 - 50
        }  else { 

            mv[0] = 0;
            mv[1] = 0;
        }
    }*/
   
   avg[0] += mv[0]
   avg[1] += mv[1]
   number_of_mvs += 1;
   mv[0] += avgFrames[0]*0.1
   mv[1] += avgFrames[1]*0.1
    //mv[0] *= 0.2
})
    avg[0] /= number_of_mvs;
    avg[1] /= number_of_mvs; 
    globals['past_frames'].push(avg)
    globals['past_frames'] = globals['past_frames'].slice(-number_of_frames)



    fwd_mvs.overflow = "truncate"
    globals['frame_number'] += 1;
    
}