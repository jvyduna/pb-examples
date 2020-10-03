/*
  Color twinkles
  
  What's interesting about this pattern is the way in which it uses `index`
  without the `pixelCount`. In other words, it depends on the 0-based pixel 
  number, instead of `index / pixelCount`, the "percentage into our overall 
  strip length." Thinking in these terms allows us to start from a design goal
  of making adjascent pixels different, instead of depending on the total
  number of pixels we have.
*/

export function beforeRender(delta) {
  t1 = time(.50) * PI2 
  t2 = time(.15) * PI2 // 3.33 times faster than t1
}

export function render(index) {
  /*
    This is a way to start from a confetti-like idea where each pixel's index,
    plus an oscillating function of time and index, determines it's hue. In
    other words, it's a very short wavelength such that colors change rapidly
    from one pixel to the next.
  */
  h = sin(index / 3 + PI2 * sin(index / 2 + t1))

  // It takes some minor algebra to work out sin() vs wave(). See the docs.
  v = wave(index / 3 / PI2 + sin(index / 2 + t2))
  v = v * v * v * v // Gamma correction
  
  /*
    The following ternary operator translates to, "If v is greater than 0.1, let
    it stand. If it's a low intensity, say, below 0.1, squelch it's brightness 
    value to zero." It's equvalent to:
    
      if (v <= .1) v = 0

    It acts as a gate, establishing a threshold that values need to exceed in
    order to be displayed. For more twinkles, try a higher threshold.
  */
  v = v > .1 ? v : 0
  
  hsv(h, 1, v)
}
