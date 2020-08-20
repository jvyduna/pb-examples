export function beforeRender(delta) {
  t1 = time(.1)
}

export function render(index) {
  v = triangle((2*wave(t1) + index/pixelCount) %1)
  v = v*v*v*v*v
  s = v < .9
  hsv(t1,s,v)
}