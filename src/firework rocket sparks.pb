export function beforeRender(delta) {
  t1 = time(.05)
  t2 = time(0.0001) * 0.2
}

export function render(index) {
  v = wave(t1 + index/pixelCount)
  v2 = wave(t1 + (index+10)/pixelCount)
  s = (v2 < 0.9995)
  v = (v > .95 && random(1) > .95) * v
  h = random(1)
  h = (s ? h : (index/20)%.2)
  hsv(h, 1-s, (1-s) + v )
}