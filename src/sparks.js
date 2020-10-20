/*
  Sparks
  
  Sparks is a pattern that illustrates:
  
    - Precomputing the display with a render buffer pixels[] in beforeRender()
    - Calculating basic 2D particle physics
  
  Understand this pattern, and you'll have a good foundation for "sparks center" 
  and "spark fire".
*/

// This is how many sparks we'll be keeping track of. Set this to 1 to visualize
// the behavior of a single spark. For 4m of 60/m there's 20 sparks running.
numSparks = floor(pixelCount / 12)

// These constants set the bounds for a newly spawned spark's initial velocity
ISEM = 1               // ISEM = Initial Spark Energy Minimum
ISER = 0.4 * ISEM      // ISER = Initial Spark Energy Range

// The friction applies a slowing force to the momentum of each spark
friction = 1 / pixelCount

/*
  The main sparks array holds the energy of each spark. The energy will
  determine how much force is accelerating the spark, as well as how much
  the pixel at its current position is heated (and therefore how bright it is).
*/
sparks = array(numSparks)

// Array of the positions of each spark, in pixels. When `sparkX[1] == 40.2,`
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
  pattern clusters on initial load because all sparks start at once while the
  cadence slowly splays out.
*/
for (i = 0; i < numSparks; i++) {
  // Initialize each spark's position to a random point on the strip
  sparkX[i] = random(pixelCount)
  // Further sparks are older and have less energy
  sparks[i] = ISEM * (1 - sparkX[i] / pixelCount) + random(ISER)
}

// Once per frame...
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
      sparks[i] = ISEM + random(ISER)
      // And set its position back to the start
      sparkX[i] = 0
    }
    
    // Slow it down (lose some energy) with friction, which is proportional to 
    // the time that's passed
    sparks[i] -= friction * delta
    
    // If a spark's energy has gone negative, set it to zero. 
    sparkX[i] = max(sparkX[i], 0)
    
    /*
      Advance the position of each spark by the square of its energy (~force),
      proportional to how much time has passed. Using the square is optional,
      and produces a final effect more like the energy of the spark is also 
      imparting a force on it (accelerating it). If you don't use the square,
      the motion appears more like a puck slowing down across ice.
    */
    sparkX[i] += sparks[i] * sparks[i] * delta
    
    // If a spark's position exceeds the end of the strip, reset its position
    // and energy to 0. It'll be reinitialized in the next beforeRender()
    if (sparkX[i] >= pixelCount || sparkX[i] < 0) {
      sparkX[i] = 0
      sparks[i] = 0
    }
    
    /*
      This adds the energy from this spark to the existing heat in the pixel at
      its current position. Notice that sparkX[i] contains decimal values; using
      it as an array index implicitly drops the fractional part, as if we had 
      first called floor() on it.

      Notice that sparks[i] and pixels[x] can both contain values > 1, and 
      hsv() below will clamp brightness and saturation values to be within 0..1.
    */
    pixels[sparkX[i]] += sparks[i]
  }
}

export function render(index) {
  v = pixels[index]
  v *= v // Gamma correction

  /*
    Let's consider hsv(h, s, v) in reverse order:
    v: Brightness value is the "heat" in the pixel
    s: To make hot pixels white, `1.1 - v` takes hot/energetic pixels and 
       desaturates them to white (which is when s has a low saturation). Old
       slow sparks are saturated red.
    h: The hue is set to 0.02, a deep orange-red.
  */
  
  hsv(.02, 1.1 - v, v)
}
