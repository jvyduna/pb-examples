/*
  Slow color shift
*/

l4 = pixelCount * 4     // 4 times the strip length

export function beforeRender(delta) {
  t1 = time(.15) * PI2
  t2 = time(.1)
}

export function render(index) {
  h = (t2 + 1 + sin(index / 2 + 5 * sin(t1)) / 5) + index / l4

  v = wave((index / 2 + 5 * sin(t1)) / PI2)
  v = v * v * v * v

  hsv(h, 1, v)
}
