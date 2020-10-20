/*
  Millipede

  There's something mesmerizing about the waves that travel along a millipede's
  feet. This pattern's combination of wave()s and a remainder seems to capture
  a similar motion.

  Regarding the order of operations, remainder has the same precedence as
  multiplication and division, so `a * b / c % d * e` happens left-to-right.
*/

speed = 20
legs = 10

export function beforeRender(delta) {
  t1 = time(1 / speed)
  t2 = time(2 / speed)
}

export function render(index) {
  h = index / pixelCount + wave(t1)
  h += (index / pixelCount + t2) * legs / 2 % .5
  v = wave(h + t2)
  v = v * v // Gamma correction
  hsv(h, 1, v)
}
