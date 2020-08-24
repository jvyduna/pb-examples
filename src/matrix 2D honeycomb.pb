/*
  This pattern is meant to be displayed on an LED matrix or other 2D surface 
  defined in the Mapper tab.
  
  Output demo: https://youtu.be/u9z8_XGe684
  
  This pattern builds on the example "Matrix 2D Pulse". To best understand
  this one, start there.
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
    
    First, we'll derive the brighness (v) from this field.
    
    t4 is a 0 to 1 sawtooth, so (z + t4) now is between -0.5 and 2.5
    wave(z + t4) therfore cycles 0 to 1 three times, ever shifting (by t4)
    with respect to the original egg carton.
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
