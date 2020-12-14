
 
 // Type some code on a new line (such as "osc().out()"), and press CTRL+shift+enter
//  
a.setBins(8)

a.show()

osc(() => a.fft[0] * 100,0.6)
 .rotate(() => a.fft[3] * Math.PI * 3)
 .out(o0)

s1.initCam()

src(s1).modulate(osc(() => a.fft[6]*400)).out(o3)

src(o2).scale(()=>a.fft[0]*1.8).rotate(() => Math.sin(time)*Math.PI*a.fft[1]*1).out(o0)

src(o0).blend(o3, 0.4).out(o2)


render(o0)


