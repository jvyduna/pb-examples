/*
  Sparks
  
  Sparks is a great pattern that showcases techniques such as:
  
    - Precomputing the display with a render buffer in beforeRender()
    - Calculating basic 2D particle physics
  
  Understand this pattern, and you'll be close to undersandindg "spark center" 
  and "spark fire".
*/

// This is how many sparks we'll be keeping track of. Set this to 1 to visualize
// the bahavior of a single spark. For 4m of 60/m there's 20 sparks running.
numSparks = floor(pixelCount / 12)

// The friction applies a slowing force to the momentum of each spark
friction = 1 / pixelCount

/*
  The main sparks array holds the energy of each spark. The energy will
  determine how much force is accellerating the spark, as well as how much
  the pixel at its current position is heated (and therefore how bright is is).
*/
sparks = array(numSparks)

// Array of the positions of each spark, inpixels. When `sparkX[1] == 40.2,`
// the second spark is heating up the air around pixel 40.
sparkX = array(numSparks)

/*
  The pixels array stores the heat in the air around each pixel, and will set
  the brightness intensity and color of each pixel, heated by the sparks
  traveling through it. The values in each position can be thought of as the
  heat there, where high values will show up as a hot, bright white. If two 
  sparks are in the same pixel of air, that pixel will accumulate heat from
  both of them.
*/
pixels = array(pixelCount)

/*
  Initialize each spark to a random position in the strip. Without this, the 
  pattern clusters on initial load because all sparks start at once whilw the
  cadence slowly splays out.
*/
for (i = 0; i < numSparks; i++) {
  // Initialize each spark's position to a random point on the strip
  sparkX[i] = random(pixelCount)
  // Further sparks are older and have less energy
  sparks[i] = random(0.4) + (1 - sparkX[i] / pixelCount) 
}


export function beforeRender(delta) {
  // delta is the time elapsed (in ms) since the last beforeRender(). Scale 
  // delta for use below. For example, 8ms becomes 0.8
  delta *= .1  
  
  /* 
    First take each pixel's heat value and cool it off by a percentage that's 
    proportional to how much time has passed since the last frame. Even if delta
    is very low, at least cool things by 1% (*= 0.99).
  */
  for (i = 0; i < pixelCount; i++)
    pixels[i] *= min(0.1 / delta, 0.99)
  
  // Examining each spark...
  for (i = 0; i < numSparks; i++) {
    // If a spark has fizzled out...
    if (sparks[i] <= 0) {
      // Initialize each spark's energy to a random value between 1.0 and 1.4
      sparks[i] = 1 + random(.4)
      // And set its position back to the start
      sparkX[i] = 0
    }
    
    // Slow it down (lose some energy) with friction, which is propostional to 
    // the time that's passed
    sparks[i] -= friction * delta
    
    // If a spark's energy has gone negative, set it to zero. 
    sparkX[i] = max(sparkX[i], 0)
    
    // Advance the position of each spark by the square of its energy (~force),
    // proportional to how much time has passed
    sparkX[i] += sparks[i] * sparks[i] * delta
    
    // If a spark's position exceeds the end of the strip, reset its position
    // and energy to 0. It'll be reinitialized in the next beforeRender()
    if (sparkX[i] >= pixelCount) {
      sparkX[i] = 0
      sparks[i] = 0
    }
    
    /*
      This adds the energy from this spark to the existing heat in the pixel at
      its current positon. Notice that sparkX[i] contains decimal values; using
      it as an array index implicitly drops the fractional part, as if we had 
      first called floor() on it.
    */
    pixels[sparkX[i]] += sparks[i]
  }
}

export function render(index) {
  v = pixels[index]
  v *= v // Gamma correction

  /*
    Let's consider hsv(h, s, v) in reverse order:
    v: Brightness value is the gamma-corrected value of the "heat" in the pixel.
    s: To make hot pixels white, `1.1 - v` takes hot/energetic pixels and 
    de saturates them to white (low saturation).
    h: The hue is set to 0.02, a deep orange-red. Shows red for old sparks.
  */
  
  hsv(.02, 1.1 - v, v)
}
