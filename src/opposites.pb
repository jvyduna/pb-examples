export function beforeRender(delta) {
  t1 = time(.1)
  t2 = time(.2)
}

export function render(index) {
  il = index/pixelCount
  w1 = wave(t1 + il)
  w2 = wave(t2 - il)
  w3 = wave((il + w1 + w2 )%1)
  h = w3 %.3
  h = (h > .15 ? h : h +.5) + t1
  s = 1
  v = ((w1+.1) * (w2+.1) * (w3+.1))
  v = v*v
  hsv(h,s,v)
}