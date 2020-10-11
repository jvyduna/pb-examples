/*
  Xorcery 2D/3D

  An XOR in 2D/3D space based on the 'block reflections' pattern. To think
  through the math, start with the comments on that pattern. The `^` operator is
  bitwise exclusive-or (XOR). Combined with modulus (`%`) and `triangle()`, this
  pattern renders interesting kaleidoscopic blocks in 1D/2D/3D.
  
  Output demo: https://youtu.be/7PQGV59N5hM
*/

export function beforeRender(delta) {
  t1 = time(.1)
  t2 = time(.1) * PI2
  t3 = time(.5)
  t4 = time(.2) * PI2
}

export function render3D(index, x, y, z) {
  m = .3 + triangle(t1) * .2
  h = sin(t2)
  h += (wave((5 * (x - .5) ^ 5 * (y - .5) ^ 5 * (z - .5)) / 50 * 
    (triangle(t3) * 10 + 4 * sin(t4)) % m))
  v = (abs(h) + abs(m) + t1) % 1
  v = triangle(v * v)
  h = triangle(h) / 5 + (x + y + z) / 3 + t1
  v = v * v * v

  hsv(h, 1, v)
}

export function render2D(index, x, y) {
  render3D(index, x, y, 0)
}

// Repeat the top line of the matrix 4X for a more granular 1D
export function render(index) {
  pct = index / pixelCount
  render3D(index, 4 * pct, 0, 0)
}
