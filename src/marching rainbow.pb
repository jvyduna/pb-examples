/*
  Marching rainbow

  It starts with a wave of a wave of a wave. A triple rainbow, all the wave.
  To see the original "triple rainbow" (kinda), try changing the v to be 1.

  We then render that through a sieve that slowly marches right. The sieve is 
  almost like a Moiré or interference pattern; marchers slowly change width.
*/

export function beforeRender(delta) {
  t1 = time(.1)
  t2 = time(.05)
}

export function render(index) {
  pct = index / pixelCount // Percent this pixel is into the overall strip

  h = wave(wave(wave(t1 + pct)) - pct)

  w1 = wave(t1 + pct)
  w2 = wave(t2 - pct * 10)

  /*
    Since w1 and w2 will be in range 0..1, this can produce -1..1. That's fine,
    negative values will be clamped to become zero, and thus it produces some
    negative space between rainbow pulses. Want even more? Append `- .2`
  */
  v = w1 - w2
  
  // Replace v with 1 to remove the "sieve" and see the "triple rainbow". Ish.
  hsv(h, 1, v)
}