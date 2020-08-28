/*
  Rainbow melt
*/

hl = pixelCount / 2  // Half the strip length

export function beforeRender(delta) {
  t1 = time(.1)     // Time it takes for regions to move and melt 
  t2 = time(.13)    // Time it takes for colors to move
}

export function render(index) {
  c1 = 1 - abs(index - hl) / hl  // 0 at strip endpoints, 1 in the middle
  c2 = wave(c1)
  c3 = wave(c2 + t1)
  v = wave(c3 + t1)
  v = v * v
  hsv(c1 + t2, 1, v)
}
