
export function beforeRender(delta) {
  t2 = time(0.1) * PI2
  t1 = time(.1)
  t3 = time(.5)
  t4 = time(0.2) * PI2
}

export function render(index) {
  h = sin(t2)
  m = (.3 + triangle(t1) * .2)
  h = h + (((index - pixelCount / 2) / pixelCount * ( triangle(t3) * 10 + 4 * sin(t4)) % m))
  s = 1;
  v = ((abs(h) + abs(m) + t1) % 1);
  v = v * v
  hsv(h, s, v)
}