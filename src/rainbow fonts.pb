export function beforeRender(delta) {
  t1 =  time(.1)
  scale = pixelCount / 4
  offset = sin(time(.2) * PI2) * pixelCount / 10
  offsetL = offset / pixelCount
}

export function render(index) {
  c = 1 - abs((index + offset) - scale) / scale
  c = wave(c)
  c = wave(c + t1 + offsetL)
  hsv(c, 1, 1)
}