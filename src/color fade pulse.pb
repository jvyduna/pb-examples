
export function beforeRender(delta) {
  t1 = time(.01)
  t2 = time(.1)*PI2
  t3 = time(.02)
}

export function render(index) {
  h = (index/pixelCount*2 - t1) 
  s = (1+sin(t2 + index/pixelCount*PI))/2 
  v = triangle((t3 + index/pixelCount*4) %1) 
  v = (v*v*v*v)*.5 
  hsv(h,s,v)
}