/*
  Rainbow fonts
  
  This pattern displays a rainbow and its mirror, but stretches regions and
  melts them into each other. Font means "fountain", and you'll notice there
  are fonts (sources) and drains (sinks) for the colors.

  This pattern's functions have been built up for you to follow along in 
  Desmos, an online graphing calculator. Check it out here: 

  https://www.desmos.com/calculator/fxykibqkjc
*/

// The denominator of this is the number of times it repeats across the strip.
// If `scale == pixelCount`, there will be one source and one sink.
scale = pixelCount / 2

export function beforeRender(delta) {
  t1 = time(.1) // Time it takes to melt = 0.1 * 65.536s
  
  // Speed and scale of how the sources and sinks of color oscillate in space.
  // Set this to zero to easily visualize the fonts.
  offset = sin(time(.2) * PI2) * pixelCount / 10
}

export function render(index) {
  // A peak near lower index
  c1 = 1 - abs((index + offset) - scale) / scale

  // Yields a rainbow that reflects (ROYGBIVIBGYOR) and stretches out the reds
  c2 = wave(c1)

  // wave(wave()) yields an alternating M/W/M/W shape within 0..1
  // Since t1 can effectively double the final period, 
  c3 = wave(c2 + t1)

  hsv(c3, 1, 1)
}
