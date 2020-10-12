/*
  Cube fire 3D
  
  3D example: https://youtu.be/iTM-7ILud4M
  
  This pattern is designed for 3D mapped projects, but degrades gracefully in 2D
  and 1D.
  
  The base 3D variant is based on multiplying sine waves of x, y, and z 
  position. This results in a regular 3D array of spheres. The size of the
  spheres pulses, and their position in 3D space oscillates at different
  frequencies.
*/


speed = 1  // How fast the spheres travel through 3D space

export function beforeRender(delta) {
  t1 = time(.1 / speed)    // x offset
  t2 = time(.13 / speed)   // y offset
  t3 = time(.085 / speed)  // z offset

  // Oscillate the scale coefficient of space between 0.25 and 0.75
  scale = (.5 + wave(time(.1))) / 2
}

export function render3D(index, x, y, z) {
  // Color is 20% dependent on each axis and cycling every 6.5 seconds
  h = x / 5 + y / 5 + z / 5 + t1
  
  // Since wave() returns a 0..1 sinusoid, and we multiply it by other 
  // phase-offset wave()s, the final output will be a series of spheres in space
  // with a value of 0..10
  v = 10 * (wave(x * scale + wave(t1)) * 
            wave(y * scale + wave(t2)) * 
            wave(z * scale + wave(t3)))
            
  // The outer surface of the spheres, with the lowest values, will be white. v
  // values between 2 and 10 (the core of the spheres) will be colorful.
  s = v - 1

  /*
    This looks like typical gamma correction here, but really it only serves to
    increase the negative space between nearby spheres; after this the cores
    will all have v > 1 (e.g. center v == 10^3)
  */
  v = v * v * v  
  
  hsv(h, s, v) // Recall that v is automatically capped at 1.0 by hsv()
}

// As we commonly do with 3D fields, a decent 2D rendering is a slice at z == 0
export function render2D(index, x, y) {
  render3D(index, x, y, 0)
}

/*
  A common approach to creating 1D versions of 3D patterns is to render the line
  in 3D where y & z = 0. To translate pixel indices to x's 0..1 world 
  coordinates, divide index by pixelCount to output a 'percent this pixel is into
  the strip', i.e. 0..1. Evaluating this aesthetically in 1D, it seems to look
  best scaled out so we multiply by 8 to plot a longer line from 3D space.
*/
export function render(index) {
  render3D(index, index / pixelCount * 8, 0, 0)
}
