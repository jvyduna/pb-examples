/*
  Sparks center
  
  This pattern builds on the "sparks" pattern.
  
  If you understand that one, this is a straightforward adaptation to spawn
  sparks at the center of the strip.
*/

numSparks = floor(pixelCount / 12)

// Each spark has half the strip distance to cover, so halve the friction
friction = 1 / pixelCount / 2
sparks = array(numSparks)  // Energy of each spark
sparkX = array(numSparks)  // Positions of each sprak
pixels = array(pixelCount) // Heat / intensity in each pixel

for (i = 0; i < numSparks; i++) {
  // Initialize each spark's position to a random point on the strip
  sparkX[i] = random(pixelCount)
  // Further sparks are older and have less energy
  sparks[i] = random(0.4) + (1 - sparkX[i] / pixelCount)
  // Set the sparks left of center to head left (I..E. have negative energy) 
  if (sparkX[i] < pixelCount / 2) sparks[i] *= -1
}

// Once per frame
export function beforeRender(delta) {
  delta *= .1  
  // Reduce each spark's energy proportionaly to the time passed between frames
  for (i = 0; i < pixelCount; i++)
    pixels[i] *= min(0.1 / delta, 0.99)
  
  // Examining each spark...
  for (i = 0; i < numSparks; i++) {
    // If a spark has fizzleè out...
    if (abs(sparks[i]) < 0.001) {
      // Initialize this spark's energy to a random value between 0.4 and 0.8
      sparks[i] = 0.3 + random(.4)
      // Randomly set half the sparks to go left (IE negative energy)
      if (random(1) > 0.5) sparks[i] *= -1
      // Set the spark's position back to the center
      sparkX[i] = pixelCount / 2
    }

    // Slow it down (lose some energy) with friction
    sparks[i] -= friction * delta * (sparks[i] > 0 ? 1 : -1)
    
    // Advance the position of each spark proportional to how much time has passed
    // Notice we preserve the sign of sparks[], so left moves left
    sparkX[i] += sparks[i] * delta
    
    // If a spark's position exceeds EITHER end of the strip, reset its position
    // and energy to 0. It'll be reinitialized in the next beforeRender()
    if (sparkX[i] >= pixelCount || sparkX[i] < 0) {
      sparkX[i] = 0
      sparks[i] = 0
    }
    
    /*
      This adds the energy from this spark to the existing heat in the pixel at
      its current positon. Notice that sparkX[i] contains decimal values; using
      it as an array index implicitly drops the fractional part, as if we had 
      first called floor() on it.
    */
    pixels[sparkX[i]] += abs(sparks[i])
  }
}

// For every pixel...w
export function render(index) {
  v = pixels[index]  // Brightness is the heat in this pixel
  v *= v // Gamma correction. Small v (v < 0)  gets smaller.
  
  /*
    h: The hue is set to 0.63, so sparks cool (saturate) to blue
    s: Make hot pixels white (v close to or above 1 means s approaches 0)
    v: The heat (brightness) in the pixel
  */
  hsv(.63, 1 - v, v)
}
