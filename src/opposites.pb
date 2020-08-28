/*
  Opposites
*/

export function beforeRender(delta) {
  t1 = time(.1)
  t2 = time(.2)
}

export function render(index) {
  pct = index / pixelCount  // Percentage into the strip length
  w1 = wave(t1 + pct)
  w2 = wave(t2 - pct)
  w3 = wave(pct + w1 + w2)
  h = w3 % .3
  h = (h > .15 ? h : h + .5) + t1

  v = (w1 + .1) * (w2 + .1) * (w3 + .1)
  v = v * v

  hsv(h, 1, v)
}
