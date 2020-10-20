/*
  Honeycomb 2D

  This pattern is meant to be displayed on an LED matrix or other 2D surface
  defined in the Mapper tab, but also has 1D and 3D renderers defined.
  
  Output demo: https://youtu.be/u9z8_XGe684
  
  The mapper allows us to share patterns that work in 2D or 3D space without the
  pattern code being dependent on how the LEDs were wired or placed in space.
  That means these three installations could all render the same pattern after
  defining their specific LED placements in the mapper:
    
    1. A 8x8 matrix in a perfect grid, wired the common zigzag way
    2. Individual pixels on a strand mounted in a triangle hexagon grid
    3. Equal length strips wired as vertical columns on separate channels
         of the output expander board
  
  To get started quickly with matrices, there's an inexpensive 8x8 on the 
  Pixelblaze store. Load the default Matrix example in the mapper and you're
  ready to go. 

  This pattern builds on the example "pulse 2D". To best understand this one,
  start there.
*/

export function beforeRender(delta) {
  tf = 5 // Overall animation duration constant. A smaller duration runs faster.
  
  f  = wave(time(tf * 6.6 / 65.536)) * 5 + 2 // 2 to 7; Frequency (cell density)
  t1 = wave(time(tf * 9.8 / 65.536)) * PI2  // 0 to 2*PI; Oscillates x shift
  t2 = wave(time(tf * 12.5 / 65.536)) * PI2 // 0 to 2*PI; Oscillates y shift
  t3 = wave(time(tf * 9.8 / 65.536)) // Shift h: wavelength of tf * 9.8 s
  t4 = time(tf * 0.66 / 65.536) // Shift v: 0 to 1 every 0.66 sec
}

export function render2D(index, x, y) {
  z = (1 + sin(x * f + t1) + cos(y * f + t2)) * .5 

  /*
    As explained in "Matrix 2D Pulse", z is now an egg-carton shaped surface
    in x and y. The number of hills/valles visible (the frequency) is
    proportional to f; f oscillates. The position of the centers in x and y 
    oscillate with t1 and t2. z's value ranges from -0.5 to 1.5.
    
    First, we'll derive the brightness (v) from this field.
    
    t4 is a 0 to 1 sawtooth, so (z + t4) now is between -0.5 and 2.5 wave(z +
    t4) therefore cycles 0 to 1 three times, ever shifting (by t4) with respect
    to the original egg carton.
  */
  v = wave(z + t4)
  
  // Typical concave-upward brightness scaling for perceptual aesthetics.
  // v enters and exits as 0-1. 0 -> 0, 1 -> 1, but 0.5 -> 0.125 
  v = v * v * v
  
  /*
    Triangle will essentially double the frequency; t3 will add an 
    oscillating offset. With h in 0-1.5, hsv() "wraps" h, and since all
    these functions are continuous, it's just spending extra time on the
    hue wheel in the 0-0.5 range. Tweak this until you like how the final 
    colors progress over time, but anything based on z will make colors
    related to the circles seen from above in the egg carton pattern.
  */
  h = triangle(z) / 2 + t3
  
  hsv(h, 1, v)
}

/*
  When there's no map defined, Pixelblaze will call render() instead of 
  render2D() or render3D(), so it's nice to define a graceful degradation for 1D
  strips. For many geometric patterns, you'll want to define a projection down a
  dimension. 
*/
export function render(index) {
  pct = index / pixelCount  // Transform index..pixelCount to 0..1
  // render2D(index, pct, pct)  // Render the diagonal of a matrix
  // render2D(index, pct, 0)    // Render the top row of a matrix
  render2D(index, 3 * pct, 0)   // Render 3 top rows worth to make it denser
}

// You can also project up a dimension. Think of this as mixing in the z value
// to x and y in order to compose a stack of matrices.
export function render3D(index, x, y, z) {
  x1 = (x - cos(z / 4 * PI2)) / 2
  y1 = (y - sin(z / 4 * PI2)) / 2
  render2D(index, x1, y1)
}
