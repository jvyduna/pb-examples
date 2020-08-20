export function beforeRender(delta) {
  t1 = time(.5)*2
  t2 = time(.25)
  t3 = time(.15)
}

export function render(index) {
  h = index/(pixelCount/2)
  s = wave(-index/3 + t2)
  s = 1-s*s*s*s
  v = wave(index/2 + t3) * wave(index/5 - t3) + wave(index/7 + t3)
  v = v*v*v*v
  hsv(h, s, v)
}