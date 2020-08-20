export function beforeRender(delta) {
  t1 = time(.1)
  t2 = time(.05)
}

export function render(index) {
  w1 = wave(t1 + index/pixelCount)
  w2 = wave(t2-index/pixelCount*10+.2)
  v = w1 - w2
  h = wave(wave(wave(t1 + index/pixelCount)) - index/pixelCount)
  hsv(h,1,v)
}