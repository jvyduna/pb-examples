/*
  Pulse 2D

  This pattern is meant to be displayed on an LED matrix or other 2D surface
  defined in the Mapper tab. There is also a 1D version defined.
  
  Output demo: https://youtu.be/hZT4z3OQEvg
  
  The mapper allows us to share patterns that work in 2D or 3D space without
  the pattern code being dependent on how the LEDs were wired or placed in 
  space. That means these three installations could all render the same pattern
  after defining their specific LED placements in the mapper:
    
    1. A 8x8 matrix in a perfect grid, wired the common zigzag way
    2. Individual pixels on a strand mounted in a triangle hexagon grid
    3. Equal length strips wired as vertical columns on separate channels
         of the output expander board
  
  To get started quickly with matrices, there's an inexpensive 8x8 on the 
  Pixelblaze store. Load the default Matrix example in the mapper and you're
  ready to go.
*/


export function beforeRender(delta) {
  t1 = time(3.3 / 65.536) * PI2 // Sawtooth 0 to 2*PI every 3.3 seconds
  t2 = time(6.0 / 65.536) * PI2 // Sawtooth 0 to 2*PI every 6 seconds
  z = 1 + wave(time(13 / 65.536)) * 5 // Sine wave, min = 1, max = 6
}

export function render2D(index, x, y) { 
  /*
    This general form produces an egg carton surface: f(x,y) = sin(x) + cos(y)
    Plot: https://www.google.com/search?q=sin%28x%29+%2B+cos%28y%29
    
    We'll make the color hue depend on the height of the egg carton.
    
    Remember this? y = A sin(B(x + C)) + D
      - The period (wavelength) is 2π/B
      - The phase shift is C (and positive is to the left)

    We can animate the "camera's" panning with phase shifts. That's the '+ t1' 
    and '+ t2' below. We animate the diameter (wavelength) of the hills and
    valleys by animating z.
    
    The hue output range is -0.5 to 1.5. hsv() will wrap hues outside 0..1.
  */
  h = (1 + sin(x * z + t1) + cos(y * z + t2)) * 0.5
  
  // Start with value (brightness) equal to our -0.5 to 1.5 hue
  v = h
  
  /*
    It's common to see patterns multiply a 0..1 brightness value by itself  
    several times for aesthetic reasons. v^(some power) makes a small v smaller 
    (when v < 1) and this tends to produce smoother dimming.
    
    Remember that while hsv() will wrap h, it will clamp v within 0..1. Setting 
    v to be odd power of itself preserves the sign, allows h ~= 1 to be bright
    red, low hues to be very dim, and h < 0 to be zero brightness (off).
  */
  v = v * v * v / 2 

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
  render2D(index, 8 * pct, 0)   // Render 8 top rows worth to make it denser
}