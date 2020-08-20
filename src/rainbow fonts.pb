hl = pixelCount/2

export function beforeRender(delta) {
  t1 = time(.1)
}

export function render(index) {
  c = 1-abs(index - hl)/hl
  c = wave(c)
  c = wave(c + t1)
  hsv(c,1,.3)
}