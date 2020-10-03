/*
  Sparks center
  
  This pattern builds on the "sparks" pattern.
  
  If you understood the comments on that one, this is a straightforward
  adaptation to spawn sparks at the center of the strip. The comments here focus
  on that adaptaton.
*/

numSparks = floor(pixelCount / 6)

// Middle index of the strip
midIndex = pixelCount / 2

// These constants set the bounds for a newly spawned spark's initial velocity
ISEM = 0.45           // ISEM = Initial Spark Energy Minimum
ISER = 0.66 * ISEM    // ISER = Initial Spark Energy Range

// Each spark has half the strip distance to cover, so halve the friction
friction = 1 / pixelCount / 2
sparks = array(numSparks)  // Energy of each spark
sparkX = array(numSparks)  // Positions of each sprak
pixels = array(pixelCount) // Heat / intensity in each pixel

for (i = 0; i < numSparks; i++) {
  // Initialize each spark's position to a random point on the strip
  sparkX[i] = random(pixelCount)
  // Sparks further from the center are older and have less energy
  sparks[i] = ISEM * (1 - abs(sparkX[i] - midIndex) / midIndex) + random(ISER)
  // Set the sparks left of center to head left (I..E. have negative energy) 
  if (sparkX[i] < pixelCount / 2) sparks[i] *= -1
}


export function beforeRender(delta) {
  delta *= .1  

  for (i = 0; i < pixelCount; i++)
    pixels[i] *= min(0.1 / delta, 0.99)
  
  // Examining each spark...
  for (i = 0; i < numSparks; i++) {
    // If a spark has fizzled out...
    if (abs(sparks[i]) < 0.001) {
      // Set this spark's energy to a value between ISEM and (ISEM + ISER)
      sparks[i] = ISEM + random(ISER)
      // Randomly set half the sparks to go left (IE negative energy)
      if (random(1) > 0.5) sparks[i] *= -1
      // Set the spark's position back to the center
      sparkX[i] = midIndex
    }

    // Slow it down (lose some energy) with friction; preserve the sign
    sparks[i] -= friction * delta * (sparks[i] > 0 ? 1 : -1)
    
    /*
      Advance the position of each spark proportional to how much time has 
      passed. sparks[i] is signed, so negative energy reduces its position.
      Notice we opted to not use the square of sparks[i] this time. You can,
      but don't forget to add the sign back:

      sparkX[i] += pow(sparks[i], 2) * delta * (sparks[i] > 0 ? 1 : -1)

      As-is, it functions more like a velocity, where Δx = v ⋅ Δt
    */
    sparkX[i] += sparks[i] * delta
    
    /*
      If a spark's position exceeds either end of the strip, reset its energy
      to 0. It'll be reinitialized in the next beforeRender(). The position in 
      sparkX also needs to be set to zero in order to avoid an "array index out 
      of bounds" error in the next part.
    */
    if (sparkX[i] >= pixelCount || sparkX[i] < 0) {
      sparkX[i] = 0
      sparks[i] = 0
    }
    
    // Since negative energy is allowed, we need to drop the sign when 
    // accumulating the heat
    pixels[sparkX[i]] += abs(sparks[i])
  }
}

// For every pixel...w
export function render(index) {
  v = pixels[index]  // Brightness is the heat in this pixel
  v *= v // Gamma correction. Small v (0 < v < 1) becomes smaller.
  
  /*
    h: The hue is set to 0.63, so sparks cool (saturate) to blue
    s: Make hot/fast pixels white (v close to or above 1 means s is near 0)
    v: The heat (brightness) in the pixel
  */
  hsv(.63, 1 - v, v)
}
