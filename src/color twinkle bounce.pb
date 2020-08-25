/* 
  Color twinkle bounce
  
  The wave math in this pattern can challenge you to ask whether you wish to
  think in terms of the unit-friendly wave(), or traditional sin() and cos().
*/

export function beforeRender(delta) {
  t1 = time(.05) * PI2
}

export function render(index) {
  // Start with hues bouncing back and forth. To do this, the phase shift 
  // oscillates. Hue values from here are in 0..2. As a reminder, hsv() will 
  // "wrap" the values outside of 0..1 for us.
  h = 1 + sin((index / 2 + 5 * sin(t1)))
  
  // We'll also shift the hues over time, slower than the bouncing. 
  // Try commenting this out to see the hues move in lockstep.
  h += time(.1)
  
  // Using the same period as the hue bounce, we'll set brightness `v`alues
  // to zero to create space betweeen pulses.
  v = (1 + sin((index / 2 + 5 * sin(t1)))) / 2
  
  v = v * v * v * v // Gamma correcion
  hsv(h, 1, v)
}