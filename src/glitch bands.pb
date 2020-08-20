export function beforeRender(delta) {
  t1 = time(0.1)*PI2;
  t2 = time(.1);
  t3 = time(.5);
  t4 = time(0.2)*PI2;
  t5 = time(.05);
  t6 = time(.02);
}

export function render(index) {
  h = sin(t1)
  m = (.3 + triangle(t2) * .2)
  h = h + (((index - pixelCount / 2) / pixelCount * ( triangle(t3) * 10 + 4 * sin(t4)) % m))
  s1 = triangle((t5 + index / pixelCount * 5) % 1);
  s1 = s1 * s1
  s2 = triangle((t6 - (index - pixelCount) / pixelCount) % 1);
  s2 = s2 * s2 * s2 * s2
  s = 1 - triangle(s1 * s2)
  v = (s1 > s2) + .5
  hsv(h, s, v)
}