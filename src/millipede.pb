export function beforeRender(delta) {
  t1 = time(.05)
  t2 = time(.1)
}

export function render(index) {
  h = ((index + time(.1)*pixelCount)/pixelCount*5%.5 + index/pixelCount + wave(t1))
  v = wave(h + t2)
  v=v*v
  hsv(h,1,v)
}