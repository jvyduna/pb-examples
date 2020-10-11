/*
  Opposites
  
  This pattern gets its name from multiplying wave functions that have phase
  shifts in opposite directions. This is one way to create mirrored patterns.

  A useful technique shown in this pattern is how to take a rainbow
  pattern(where hue inclues most values from 0..1) and transform it so that
  there's a more opinionated subset of colors. In this way, it's a basic
  pallette generator.
*/

export function beforeRender(delta) {
  t1 = time(6 / 65.536)  // Wave one every 6 seconds
  t2 = time(12 / 65.536) // Wave two every 12 seconds
}

export function render(index) {
  pct = index / pixelCount  // Percentage into the strip length
  w1 = wave(t1 + pct)
  w2 = wave(t2 - pct)       // Notice the opposite phase shift
  w3 = wave(pct + w1 + w2)
  
  // Create a basic pallette of two hue ranges: 0.15..0.3 & 0.5..0.55.
  // If t1 is taken out, the pattern will only be yellows and blues.
  h = w3 % .3
  h = (h > .15 ? h : h + .5) + t1

  v = (w1 + .1) * (w2 + .1) * (w3 + .1)
  v = v * v  // Gamma correction

  hsv(h, 1, v)
}
