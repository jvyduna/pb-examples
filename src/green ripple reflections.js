/*
  Green ripple reflections

  Using a single hue of 0.3 (green), we can still output light and dark greens,
  greys, white and black.
*/

// We can set up our own global "constants" (actually variables) by defining
// them outside of any function.
PI10 = PI2 * 5
PI6  = PI2 * 3

export function beforeRender(delta) {
  t1 = time(.03) * PI2 // A period of (0.03 * 65.535), or ~2 seconds
  t2 = time(.05) * PI2
  t3 = time(.04) * PI2
}

export function render(index) {
  // This will be used for saturation, creating the greys seen in the output
  a = sin(index / pixelCount * PI10 + t1)
  a = a * a

  // Notice this is a different wave with longer wavelength travelling the other
  // direction; This is part of how you might see a "reflection" in the output.
  b = sin(index / pixelCount * PI6 - t2)
  c = triangle((index / pixelCount * 3 + sin(t3)) / 2)

  // Average of the three waves above. Range -2/3..1
  v = (a + b + c) / 3

  /*
    Squaring v in this case is doing a little more than the typical gamma
    correction. It adds wave reflections from the negative numbers. Clamping v
    to be within 0..1 first loses these nice little murmurs.
  */
  
  // v = clamp(v, 0, 1)     // Try uncommenting this
  v = v * v

  // As we said up top, a hue of 0.3 is green
  hsv(.3, a, v)
}
