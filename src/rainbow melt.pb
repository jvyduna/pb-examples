/*
  Rainbow melt

  This is derived from the "rainbow fonts" pattern, but adds dark regions 
  between colors to create a more distinct melting effect.

  It also doesn't use the shifting offset, so notice the sources don't move.
*/

scale = pixelCount / 2

export function beforeRender(delta) {
  t1 = time(.1)  // Time it takes for regions to move and melt 
}

export function render(index) {
  c1 = 1 - abs(index - scale) / scale  // 0 at strip endpoints, 1 in the middle
  c2 = wave(c1)
  c3 = wave(c2 + t1)

  v = wave(c3 + t1)  // Separate the colors with dark regions
  v = v * v

  hsv(c1 + t1, 1, v)
}
