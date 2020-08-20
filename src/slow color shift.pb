l4 = pixelCount*4

export function beforeRender(delta) {
  t1 = time(.15)*PI2
  t2 = time(.1)
}

export function render(index) {
  a = (1 + sin((index / 2 + 5 * sin(t1)))) / 2
  b = (t2 + 1 + sin((index / 2 + 5 * sin(t1))) / 5 ) + index / l4
  v = (a * a * a * a)
  hsv(b, 1, v)
}