/*
  sound - rays

  This pattern is designed to use the sensor expansion board, but falls back to
  simulated sound data if the sensor board isn't detected.

  The beginning of the strip will originate pixels with color based on the most
  prevalent frequency in the sound, and brighness based on the magnitude. Those
  rays of color will then travel down the strip.

  Please check out the "sound - blink fade" pattern for more verbose comments
  explaining the PI controller used below for automatic gain control. 
*/


// Speed that the rays travel down the strip
speed = 0.05

// These vars are set by the external sensor board, if one is connected. We
// don't actually use light readings in this pattern, so if the `light` value
// remains -1, no sensor board is connected.
export var light = -1 
export var maxFrequencyMagnitude
export var maxFrequency

hues = array(pixelCount)
vals = array(pixelCount)

// A position pointer, in pixels, that turns hues[] and vals[] into a circular
// buffer
pos = 0
// Stores the last brightness value to feed back into the PI gain controller 
lastVal = 0

export var pic = makePIController(.05, .35, 200, 0, 400)

// Make a new PI Controller
function makePIController(kp, ki, start, min, max) {
  var pic = array(5)
  pic[0] = kp
  pic[1] = ki
  pic[2] = start // This is the accumulated error
  pic[3] = min
  pic[4] = max
  return pic
}

function calcPIController(pic, err) {
  pic[2] = clamp(pic[2] + err, pic[3], pic[4])
  return max(pic[0] * err + pic[1] * pic[2], .3)
}

export function beforeRender(delta) {
  // Here the PI controller is aiming for a sensitivity based on chasing recent
  // maxFrequencyMagnitudes to be 0.5
  sensitivity = calcPIController(pic, .5 - lastVal)
  
  // To make the rays travel along the strip, sweep a position offset pointer
  // down the arrays of values and hues
  pos = (pos + delta * speed) % pixelCount
  
  if (light == -1) simulateSound()  // No sensor board attached
  
  // The brightness value will be determined by the magnitude of the most
  // intense frequency. This is also our feedback to the PI controller.
  lastVal = vals[pos] = pow(maxFrequencyMagnitude * sensitivity, 2)
  
  /*
    The base color will be modified by time and strip position in render(), but
    its hue begins based on the most intense frequency detected. If you played a
    swept tone bewtween 20 Hz and 5 KHz, it'd trace a rainbow. 
  */
  hues[pos] = maxFrequency / 5000

  // Used to subtly advance the hue over time
  t1 = time(6.5 / 65.536)
}

export function render(index) {
  // Reverse indices so that pixels flow to the right
  index = pixelCount - index
  // Shift the index circularly based on the position offset
  i = (index + pos) % pixelCount
  
  h = hues[i]
  /*
    This rotates color by adding a component based on time and position.  
    Comment this out to more clearly see the detected maximum frecuencies.
    Adding `index / pixelCount / 4` adds a quarter of the hue wheel across the
    strip's entire length. Notice that since index is reversed, *adding* t1 back
    in has the effect of *slowing* the hue progression.
  */
  h += index / pixelCount / 4 + t1

  v = vals[i]
  v = v * v  // Gamma correction

  hsv(h, 1, v)
}

/* 
  Simulate the sensor board variables used in this pattern, if no senor board is
  detected. The values and waveforms were chosen to approximate the look when
  sound is sensed. 
*/
function simulateSound() { 
  t1 = time(10 / 65.536) 
  maxFrequency = 2000 * (1 + wave(t1)) * (0.7 + random(0.3)) 
  maxFrequencyMagnitude = log(1.05 + wave(17 * t1) * wave( 19 * t1) * wave(23 * t1)) 
  maxFrequencyMagnitude *= 0.7 + random(0.3)
}
