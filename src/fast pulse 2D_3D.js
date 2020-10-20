/*
  Fast pulse 2D/3D
  
  3D example: https://youtu.be/EGUTLHb98wM
  
  This pattern is designed for 3D mapped projects, but degrades gracefully
  degrade in 2D and 1D.
  
  The 3D variant of this pattern sweeps a series of parallel planes (layers) 
  though space and rotates them.
  
  The 1D variant is a single Cylon-like eye that changes colors slowly, and
  bounces across the boundary of the strip's endpoints with a circular
  continuance.
*/


export function beforeRender(delta) {
  /*
    This 0..1 time() output cycles every (0.1 * 65.535) seconds. We'll use this 
    both as the single output hue, as well as a basis for the function that 
    creates the rotating / bouncing pulse(s).
  */
  t1 = time(.1)
  
  a = sin(time(.10) * PI2)  // -1..1 sinusoid every 6.5 seconds
  b = sin(time(.05) * PI2)  // -1..1 sinusoid every 3.3 seconds
  c = sin(time(.07) * PI2)  // -1..1 sinusoid every 6.6 seconds
}

export function render3D(index, x, y, z) {
  /*
    The formula for a 3D plane is:

      a(x − x1) + b(y − y1) + c(z − z1) = 0 

    where the plane is normal to the vector (a, b, c). By setting out output
    brightness to the right hand side, the initial defined plane is the dark
    region, where `v == 0`. This pattern oscillates a, b, and c to rotate the
    plane in space. By using the `triangle` function, which is repeatedly
    returning 0..1 for input values continuing in either direction away from 0,
    we get several resulting 0..1..0.. layers all normal to the vector. 

    The `3 * wave(t1)` term introduces a periodic phase shift. The final result
    is a series of parallel layers, rotating and slicing through 3D space.
  */
  v = triangle(3 * wave(t1) + a * x + b * y + c * z)

  // Aggressively thin the plane by making medium-low v very small, for wider 
  // dark regions
  v = pow(v, 5)

  // Make the highest brightness values (when v is greater than 0.8) white
  // instead of a saturated color
  s = v < .8
  
  hsv(t1, s, v)
}

// The 2D version is a slice (a projection) of the 3D version, taken at the
// z == 0 plane
export function render2D(index, x, y) {
  render3D(index, x, y, 0)
}

export function render(index) {
  // The core of the oscillation is a triangle wave, bouncing across two total
  // strip lengths. The 1D version removes the rotation element.
  v = triangle(2 * wave(t1) + index / pixelCount)
  
  // Aggressive gamma correction looks good, reduces the pulse width, and makes
  // the dimmer parts of the pulse very smooth on APA102s / SK9822s.
  v = pow(v, 5)
  
  s = v < .9  // For the top 0.1 (10%) of brightness values, make it white
  
  hsv(t1, s, v)
}
