/*
  Fast pulse
  
  Let's set out with a simple design goal: a single Cylon-like eye that changes
  colors slowly, and bounces across the boundary of the strip's endpoints with
  a circular continuance.
*/

export function beforeRender(delta) {
  /*
    This 0..1 time output cycles every (0.1 * 65.535) seconds. We'll use this 
    both as the single output hue, as well as a basis for the function that 
    creates a single large bouncing pulse.
  */
  t1 = time(.1)
}

export function render(index) {
  // The core of the oscillation is a triangle wave, bouncing across two total
  // strip lenghts
  v = triangle(index / pixelCount + 2 * wave(t1))

  // Aggressive gamma correction. Looks good, reduced the pulse width, and makes
  // the dimmer parts of the pulse very smooth on APA102s / SK9822s.
  v = pow(v, 5)

  s = v < .9 // For the top 0.1 (10%) of brightness values, just make it white

  hsv(t1, s, v)
}
